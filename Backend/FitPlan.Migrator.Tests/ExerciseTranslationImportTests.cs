using System.Text;
using FitPlan.Migrator.Tests.Infrastructure;
using Microsoft.EntityFrameworkCore;
using Xunit;

namespace FitPlan.Migrator.Tests;

// Phase 11C: filling the equipment and muscles of existing exercises, and importing Arabic text.
public sealed class ExerciseTranslationImportTests
{
    private static string Row(string id, string name = "Push-up", string details = "") =>
        $$"""{"id":"{{id}}","name":"{{name}}","gifUrl":"https://static.example.test/a.gif","bodyPart":"chest","instructions":["Step:1 Start","Step:2 Push"]{{details}}}""";

    private static string Details(string equipment = "body weight", string target = "pectorals") =>
        $$""","equipments":["{{equipment}}"],"targetMuscles":["{{target}}"],"secondaryMuscles":["triceps","deltoids"]""";

    private static byte[] List(params string[] rows) => Encoding.UTF8.GetBytes("[" + string.Join(",", rows) + "]");

    private static byte[] Pack(string exercises, string terms = """{"equipment":{"body weight":"وزن الجسم"},"muscle":{"pectorals":"الصدر"}}""") =>
        Encoding.UTF8.GetBytes($$"""{"version":1,"language":"ar","terms":{{terms}},"exercises":{{exercises}}}""");

    private static string ExerciseSha(byte[] file) => ExerciseFile.Validate(file).Sha256;

    private static string PackSha(byte[] file) => TranslationFile.Validate(file).Sha256;

    private static async Task<MigratorDatabase> DatabaseWithExercisesAsync(params string[] ids)
    {
        var database = await MigratorDatabase.CreateAsync();
        await database.Context.Database.MigrateAsync();
        var file = List(ids.Select(id => Row(id)).ToArray());
        await ExerciseImporter.ImportAsync(file, ExerciseSha(file), database.ConnectionString);
        return database;
    }

    [Fact]
    public async Task A_new_import_keeps_the_details()
    {
        await using var database = await MigratorDatabase.CreateAsync();
        await database.Context.Database.MigrateAsync();
        var file = List(Row("abc1", details: Details()));

        await ExerciseImporter.ImportAsync(file, ExerciseSha(file), database.ConnectionString);

        var row = await database.Context.Exercises.AsNoTracking().SingleAsync();
        Assert.Equal(["body weight"], row.Equipments);
        Assert.Equal(["pectorals"], row.TargetMuscles);
        Assert.Equal(["triceps", "deltoids"], row.SecondaryMuscles);
    }

    [Fact]
    public async Task An_import_without_details_gives_empty_lists()
    {
        await using var database = await DatabaseWithExercisesAsync("abc1");

        var row = await database.Context.Exercises.AsNoTracking().SingleAsync();
        Assert.Empty(row.Equipments);
        Assert.Empty(row.TargetMuscles);
    }

    [Fact]
    public async Task Updating_details_changes_only_the_details_and_a_second_run_changes_nothing()
    {
        await using var database = await DatabaseWithExercisesAsync("abc1", "abc2");
        var file = List(Row("ABC1", "Renamed", Details()), Row("abc2", details: Details("barbell")), Row("not-there", details: Details()));

        var first = await ExerciseImporter.UpdateDetailsAsync(file, ExerciseSha(file), database.ConnectionString);
        var second = await ExerciseImporter.UpdateDetailsAsync(file, ExerciseSha(file), database.ConnectionString);

        Assert.Equal(RunOutcome.Succeeded, first.Outcome);
        Assert.Equal((2, 2, 2), (first.Updated, first.RowsBefore, first.RowsAfter));
        Assert.Equal(RunOutcome.Succeeded, second.Outcome);
        Assert.Equal(0, second.Updated);
        var abc1 = await database.Context.Exercises.AsNoTracking().SingleAsync(e => e.Id == "abc1");
        Assert.Equal("Push-up", abc1.Name);
        Assert.Equal(["Step:1 Start", "Step:2 Push"], abc1.Instructions);
        Assert.Equal(["body weight"], abc1.Equipments);
        Assert.Equal(["barbell"], (await database.Context.Exercises.AsNoTracking().SingleAsync(e => e.Id == "abc2")).Equipments);
        Assert.Equal(2, await database.Context.Exercises.CountAsync());
    }

    [Fact]
    public async Task Updating_details_refuses_a_file_from_before_the_details()
    {
        await using var database = await DatabaseWithExercisesAsync("abc1");
        var file = List(Row("abc1"));

        var report = await ExerciseImporter.UpdateDetailsAsync(file, ExerciseSha(file), database.ConnectionString);

        Assert.Equal(RunOutcome.Refused, report.Outcome);
    }

    [Fact]
    public async Task Imports_the_text_unreviewed_skips_unknown_exercises_and_a_second_run_changes_nothing()
    {
        await using var database = await DatabaseWithExercisesAsync("abc1", "abc2");
        var pack = Pack("""{"abc1":{"name":"ضغط","instructions":["ابدأ","ادفع"]},"zzz9":{"name":"غير موجود","instructions":["س"]}}""");

        var first = await ExerciseImporter.ImportTranslationsAsync(pack, PackSha(pack), database.ConnectionString);
        var second = await ExerciseImporter.ImportTranslationsAsync(pack, PackSha(pack), database.ConnectionString);

        Assert.Equal(RunOutcome.Succeeded, first.Outcome);
        Assert.Equal((1, 0), (first.Inserted, first.Updated));
        Assert.Contains("still without ar text: 1", first.Message);
        Assert.Equal((0, 0), (second.Inserted, second.Updated));
        var text = await database.Context.ExerciseTranslations.AsNoTracking().SingleAsync();
        Assert.Equal(("abc1", "ar", "ضغط", false), (text.ExerciseId, text.Language, text.Name, text.Reviewed));
        Assert.Equal(["ابدأ", "ادفع"], text.Instructions);
        Assert.Equal(["الصدر", "وزن الجسم"], await database.QueryAsync("SELECT [Text] FROM TermTranslations ORDER BY [Text]"));
        // stored as readable text, not \u escapes
        Assert.Equal(["[\"ابدأ\",\"ادفع\"]"], await database.QueryAsync("SELECT Instructions FROM ExerciseTranslations"));
    }

    [Fact]
    public async Task A_changed_text_replaces_the_old_one_and_is_unreviewed_again()
    {
        await using var database = await DatabaseWithExercisesAsync("abc1", "abc2");
        var first = Pack("""{"abc1":{"name":"ضغط","instructions":["ابدأ"]},"abc2":{"name":"سكوات","instructions":["انزل"]}}""");
        await ExerciseImporter.ImportTranslationsAsync(first, PackSha(first), database.ConnectionString);
        await database.ExecuteAsync("UPDATE ExerciseTranslations SET Reviewed = 1;");
        var second = Pack(
            """{"abc1":{"name":"ضغط واسع","instructions":["ابدأ"]},"abc2":{"name":"سكوات","instructions":["انزل"]}}""",
            """{"muscle":{"pectorals":"عضلة الصدر"}}""");

        var report = await ExerciseImporter.ImportTranslationsAsync(second, PackSha(second), database.ConnectionString);

        Assert.Equal((0, 1), (report.Inserted, report.Updated));
        var texts = await database.Context.ExerciseTranslations.AsNoTracking().OrderBy(t => t.ExerciseId).ToListAsync();
        Assert.Equal(("ضغط واسع", false), (texts[0].Name, texts[0].Reviewed));
        Assert.Equal(("سكوات", true), (texts[1].Name, texts[1].Reviewed));
        Assert.Equal(["عضلة الصدر", "وزن الجسم"], await database.QueryAsync("SELECT [Text] FROM TermTranslations ORDER BY [Text]"));
    }

    [Fact]
    public async Task Refuses_a_pack_that_does_not_match_the_approved_hash()
    {
        await using var database = await DatabaseWithExercisesAsync("abc1");
        var pack = Pack("""{"abc1":{"name":"ضغط","instructions":["ابدأ"]}}""");

        var report = await ExerciseImporter.ImportTranslationsAsync(pack, new string('0', 64), database.ConnectionString);

        Assert.Equal(RunOutcome.Refused, report.Outcome);
        Assert.Empty(await database.QueryAsync("SELECT ExerciseId FROM ExerciseTranslations"));
    }

    [Fact]
    public async Task Translations_run_as_the_migrator_user()
    {
        await using var database = await DatabaseWithExercisesAsync("abc1");
        await database.ExecuteAsync($"ALTER ROLE db_datawriter DROP MEMBER [{ScriptRunner.MigratorUser}];");
        var pack = Pack("""{"abc1":{"name":"ضغط","instructions":["ابدأ"]}}""");

        var report = await ExerciseImporter.ImportTranslationsAsync(pack, PackSha(pack), database.ConnectionString);

        // without db_datawriter the write is refused, which proves it didn't run as the admin
        Assert.Equal(RunOutcome.Failed, report.Outcome);
        Assert.Empty(await database.QueryAsync("SELECT ExerciseId FROM ExerciseTranslations"));
    }

    [Theory]
    [InlineData("""{"version":2,"language":"ar","exercises":{"a":{"name":"س","instructions":["س"]}}}""")]
    [InlineData("""{"version":1,"language":"fr","exercises":{"a":{"name":"س","instructions":["س"]}}}""")]
    [InlineData("""{"version":1,"language":"ar","exercises":{}}""")]
    [InlineData("""{"version":1,"language":"ar","exercises":{"a":{"name":"","instructions":["س"]}}}""")]
    [InlineData("""{"version":1,"language":"ar","exercises":{"a":{"name":"س","instructions":[]}}}""")]
    [InlineData("""{"version":1,"language":"ar","exercises":{"a":{"name":"س","instructions":["س"]},"A":{"name":"ص","instructions":["ص"]}}}""")]
    [InlineData("""{"version":1,"language":"ar","terms":{"colour":{"red":"أحمر"}},"exercises":{"a":{"name":"س","instructions":["س"]}}}""")]
    [InlineData("""{"version":1,"language":"ar","terms":{"muscle":{"biceps":""}},"exercises":{"a":{"name":"س","instructions":["س"]}}}""")]
    [InlineData("[]")]
    public void Rejects_a_bad_pack(string json)
    {
        Assert.Throws<ExerciseFileRejectedException>(() => TranslationFile.Validate(Encoding.UTF8.GetBytes(json)));
    }

    [Fact]
    public void Rejects_blank_detail_terms()
    {
        var file = List(Row("abc1", details: Details(equipment: " ")));

        Assert.Throws<ExerciseFileRejectedException>(() => ExerciseFile.Validate(file));
    }
}
