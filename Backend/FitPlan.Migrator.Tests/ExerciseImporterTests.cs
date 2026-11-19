using System.Text;
using FitPlan.Migrator.Tests.Infrastructure;
using Microsoft.EntityFrameworkCore;
using Xunit;

namespace FitPlan.Migrator.Tests;

// Phase 6: loading the exercise list into Dev without copying Production data.
public sealed class ExerciseImporterTests
{
    private static string Row(string id, string name = "Push-up", string bodyPart = "chest", string gif = "https://static.example.test/a.gif") =>
        $$"""{"id":"{{id}}","name":"{{name}}","gifUrl":"{{gif}}","bodyPart":"{{bodyPart}}","instructions":["Step:1 Start","Step:2 Push"]}""";

    private static byte[] File(params string[] rows) => Encoding.UTF8.GetBytes("[" + string.Join(",", rows) + "]");

    private static string Sha(byte[] file) => ExerciseFile.Validate(file).Sha256;

    private static async Task<MigratorDatabase> DatabaseWithTablesAsync()
    {
        var database = await MigratorDatabase.CreateAsync();
        await database.Context.Database.MigrateAsync();
        return database;
    }

    [Fact]
    public async Task Imports_every_row_as_the_API_reads_it()
    {
        await using var database = await DatabaseWithTablesAsync();
        var file = File(Row("abc1", "Push-up – wide"), Row("abc2", "Treadmill run", "cardio"));

        var report = await ExerciseImporter.ImportAsync(file, Sha(file), database.ConnectionString);

        Assert.Equal(RunOutcome.Succeeded, report.Outcome);
        Assert.Equal((0, 2, 2), (report.RowsBefore, report.Inserted, report.RowsAfter));
        var push = await database.Context.Exercises.AsNoTracking().SingleAsync(e => e.Id == "abc1");
        Assert.Equal("Push-up – wide", push.Name);
        Assert.Equal(["Step:1 Start", "Step:2 Push"], push.Instructions);
        Assert.Equal("cardio", (await database.Context.Exercises.AsNoTracking().SingleAsync(e => e.Id == "abc2")).BodyPart);
    }

    [Fact]
    public async Task Running_again_adds_nothing_and_never_changes_an_existing_row()
    {
        await using var database = await DatabaseWithTablesAsync();
        var first = File(Row("abc1"));
        await ExerciseImporter.ImportAsync(first, Sha(first), database.ConnectionString);
        var second = File(Row("ABC1", "Renamed"), Row("abc2"));

        var report = await ExerciseImporter.ImportAsync(second, Sha(second), database.ConnectionString);

        Assert.Equal(RunOutcome.Succeeded, report.Outcome);
        Assert.Equal((1, 1, 2), (report.RowsBefore, report.Inserted, report.RowsAfter));
        Assert.Equal("Push-up", (await database.Context.Exercises.AsNoTracking().SingleAsync(e => e.Id == "abc1")).Name);
    }

    [Fact]
    public async Task Refuses_a_file_that_does_not_match_the_approved_hash()
    {
        await using var database = await DatabaseWithTablesAsync();
        var file = File(Row("abc1"));

        var report = await ExerciseImporter.ImportAsync(file, new string('0', 64), database.ConnectionString);

        Assert.Equal(RunOutcome.Refused, report.Outcome);
        Assert.Empty(await database.QueryAsync("SELECT Id FROM Exercises"));
    }

    [Fact]
    public async Task Refuses_any_database_that_is_not_Dev_Production_or_a_local_test_one()
    {
        var file = File(Row("abc1"));

        var report = await ExerciseImporter.ImportAsync(file, Sha(file), "Server=localhost;Database=FitPlanDb;Trusted_Connection=True;TrustServerCertificate=True");

        Assert.Equal(RunOutcome.Refused, report.Outcome);
    }

    [Fact]
    public async Task Runs_as_the_migrator_user_and_reverts()
    {
        await using var database = await DatabaseWithTablesAsync();
        await database.ExecuteAsync($"ALTER ROLE db_datawriter DROP MEMBER [{ScriptRunner.MigratorUser}];");
        var file = File(Row("abc1"));

        var report = await ExerciseImporter.ImportAsync(file, Sha(file), database.ConnectionString);

        // without db_datawriter the insert is refused, which proves it didn't run as the admin
        Assert.Equal(RunOutcome.Failed, report.Outcome);
        Assert.Empty(await database.QueryAsync("SELECT Id FROM Exercises"));
    }

    [Theory]
    [InlineData("""[{"id":"a","name":"x","gifUrl":"https://e.test/a.gif","bodyPart":"tail","instructions":["s"]}]""")]
    [InlineData("""[{"id":"a","name":"x","gifUrl":"http://e.test/a.gif","bodyPart":"chest","instructions":["s"]}]""")]
    [InlineData("""[{"id":"a","name":"x","gifUrl":"https://e.test/a.gif","bodyPart":"chest","instructions":[]}]""")]
    [InlineData("""[{"id":"a","name":"","gifUrl":"https://e.test/a.gif","bodyPart":"chest","instructions":["s"]}]""")]
    [InlineData("""[{"id":"a","name":"x","gifUrl":"https://e.test/a.gif","bodyPart":"chest","instructions":["s"]},{"id":"A","name":"y","gifUrl":"https://e.test/b.gif","bodyPart":"chest","instructions":["s"]}]""")]
    [InlineData("[]")]
    [InlineData("{}")]
    public void Rejects_a_file_with_bad_rows(string json)
    {
        Assert.Throws<ExerciseFileRejectedException>(() => ExerciseFile.Validate(Encoding.UTF8.GetBytes(json)));
    }
}
