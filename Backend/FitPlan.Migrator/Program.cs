using FitPlan.Migrator;

// Usage:
//   FitPlan.Migrator validate <script.sql>
//   FitPlan.Migrator apply <script.sql> --sha256 <approved hash> --target dev
//   FitPlan.Migrator apply <script.sql> --sha256 <approved hash> --target prod --confirm FitPlanDb
//   FitPlan.Migrator fetch-exercises <new file.json>
//   FitPlan.Migrator import-exercises <file.json> --sha256 <approved hash> --target dev
//   (import-exercises takes --target prod --confirm FitPlanDb the same way as apply)
//   FitPlan.Migrator check-gifs <file.json>
//   FitPlan.Migrator update-exercise-details <file.json> --sha256 <approved hash> --target dev
//   FitPlan.Migrator import-translations <pack.json> --sha256 <approved hash> --target dev
//   (both take --target prod --confirm FitPlanDb the same way as apply)
//   (exit code 4 for check-gifs means some links couldn't be reached, so the check is incomplete)
// Exit codes: 0 done, 1 usage, 2 refused before connecting, 3 another run holds the lock, 4 failed.

const int Usage = 1, Refused = 2, LockBusy = 3, Failed = 4;

if (args.Length >= 2 && args[0] == "fetch-exercises")
{
    // Downloads the list into a new local file and checks it. Nothing touches a database.
    if (File.Exists(args[1]))
    {
        Console.Error.WriteLine($"{args[1]} already exists. Give a new file name.");
        return Usage;
    }

    using var http = new HttpClient { BaseAddress = new Uri(ExerciseFile.Source), Timeout = TimeSpan.FromSeconds(60) };
    try
    {
        var bytes = await ExerciseFile.FetchAsync(http, line => Console.WriteLine($"Fetched {line}"));
        await File.WriteAllBytesAsync(args[1], bytes);
        var fetched = ExerciseFile.Validate(bytes);
        Console.WriteLine($"Saved {fetched.Rows.Count} exercises to {args[1]}. Nothing was imported.");
        Console.WriteLine($"SHA-256: {fetched.Sha256}");
        foreach (var part in fetched.Rows.GroupBy(r => r.BodyPart).OrderBy(g => g.Key))
        {
            Console.WriteLine($"  {part.Key}: {part.Count()}");
        }

        return 0;
    }
    catch (Exception ex) when (ex is HttpRequestException or TaskCanceledException or ExerciseFileRejectedException or System.Text.Json.JsonException)
    {
        Console.Error.WriteLine($"Fetching failed, nothing was saved: {ex.Message} {ex.InnerException?.Message}".Trim());
        return Failed;
    }
}

if (args.Length >= 2 && args[0] == "check-gifs")
{
    // Checks every GIF link in an exercise file and lists the ones that don't work. Read-only.
    ValidatedExercises list;
    try
    {
        list = ExerciseFile.Validate(await File.ReadAllBytesAsync(args[1]));
    }
    catch (Exception ex) when (ex is IOException or ExerciseFileRejectedException)
    {
        Console.Error.WriteLine($"Can't read the exercise file: {ex.Message}");
        return Usage;
    }

    using var http = new HttpClient { Timeout = TimeSpan.FromSeconds(30) };
    var results = await GifChecker.CheckAsync(http, list.Rows, count => Console.WriteLine($"Checked {count} of {list.Rows.Count}"));

    foreach (var status in Enum.GetValues<GifStatus>())
    {
        Console.WriteLine($"{status}: {results.Count(r => r.Status == status)}");
    }

    foreach (var result in results.Where(r => r.Status != GifStatus.Works).OrderBy(r => r.Status).ThenBy(r => r.Exercise.Id, StringComparer.Ordinal))
    {
        Console.WriteLine($"  {result.Status}\t{result.Exercise.Id}\t{result.Exercise.BodyPart}\t{result.Exercise.Name}\t{result.Detail}");
    }

    // exit 0 only when every link was answered, so "broken" never hides "not checked"
    return results.Any(r => r.Status == GifStatus.Unreachable) ? Failed : 0;
}

if (args.Length < 2 || args[0] is not ("validate" or "apply" or "import-exercises" or "update-exercise-details" or "import-translations"))
{
    Console.Error.WriteLine("Usage: validate <script.sql> | apply <script.sql> --sha256 <hash> --target dev | --target prod --confirm FitPlanDb");
    Console.Error.WriteLine("       fetch-exercises <new file.json> | import-exercises <file.json> --sha256 <hash> --target dev");
    Console.Error.WriteLine("       check-gifs <file.json>");
    Console.Error.WriteLine("       update-exercise-details <file.json> | import-translations <pack.json>, each with --sha256 <hash> --target dev");
    return Usage;
}

var path = args[1];
if (!File.Exists(path))
{
    Console.Error.WriteLine($"File not found: {path}");
    return Usage;
}

var file = await File.ReadAllBytesAsync(path);
var known = KnownMigrations.FromApi();

if (args[0] == "validate")
{
    try
    {
        var script = new ScriptValidator(known).Validate(file);
        Console.WriteLine("The script passed validation. Nothing was run.");
        Console.WriteLine($"SHA-256: {script.Sha256}");
        Console.WriteLine($"Batches: {script.Batches.Count}");
        Console.WriteLine($"Migrations, in order: {string.Join(", ", script.MigrationIds)}");
        return 0;
    }
    catch (ScriptRejectedException ex)
    {
        Console.Error.WriteLine($"Rejected: {ex.Message}");
        return Refused;
    }
}

var sha256 = Option("--sha256");
var target = Option("--target");
if (sha256 is null || target is not ("dev" or "prod"))
{
    Console.Error.WriteLine("apply needs --sha256 <approved hash> and --target dev or --target prod. No other target exists.");
    return Usage;
}

// Production also needs its database name typed out, so it is never chosen by a slip.
if (target == "prod" && Option("--confirm") != MigrationTarget.ProdDatabase)
{
    Console.Error.WriteLine($"--target prod also needs --confirm {MigrationTarget.ProdDatabase}. Nothing was run.");
    return Usage;
}

var (server, database, connectionString) = target == "prod"
    ? (MigrationTarget.ProdServer, MigrationTarget.ProdDatabase, MigrationTarget.Prod)
    : (MigrationTarget.DevServer, MigrationTarget.DevDatabase, MigrationTarget.Dev);

if (args[0] is "import-exercises" or "update-exercise-details" or "import-translations")
{
    ImportReport import;
    try
    {
        import = args[0] switch
        {
            "update-exercise-details" => await ExerciseImporter.UpdateDetailsAsync(file, sha256, connectionString),
            "import-translations" => await ExerciseImporter.ImportTranslationsAsync(file, sha256, connectionString),
            _ => await ExerciseImporter.ImportAsync(file, sha256, connectionString)
        };
    }
    catch (Exception ex)
    {
        Console.Error.WriteLine($"The import stopped unexpectedly: {ex.GetType().Name}: {ex.Message}");
        Console.Error.WriteLine("The result is uncertain. Count the rows it writes before running again.");
        return Failed;
    }

    Console.WriteLine($"Target: {server}/{database}");
    Console.WriteLine($"Outcome: {import.Outcome}");
    Console.WriteLine(import.Message);
    if (import.RowsBefore is not null)
    {
        Console.WriteLine($"Rows before: {import.RowsBefore}, added: {import.Inserted}, updated: {import.Updated ?? 0}, rows after: {import.RowsAfter}");
    }

    return import.Outcome switch
    {
        RunOutcome.Succeeded => 0,
        RunOutcome.Refused => Refused,
        RunOutcome.LockBusy => LockBusy,
        _ => Failed
    };
}

RunReport report;
try
{
    report = await ScriptRunner.ApplyAsync(file, sha256, connectionString, known);
}
catch (Exception ex)
{
    Console.Error.WriteLine($"The run stopped unexpectedly: {ex.GetType().Name}: {ex.Message}");
    Console.Error.WriteLine("The result is uncertain. Don't run again before comparing the schema and __EFMigrationsHistory with a reference database.");
    return Failed;
}

Console.WriteLine($"Target: {server}/{database}");
Console.WriteLine($"Outcome: {report.Outcome}");
Console.WriteLine(report.Message);
Console.WriteLine($"History before: {Describe(report.AppliedBefore)}");
Console.WriteLine($"History after: {Describe(report.AppliedAfter)}");
if (report.FailedBatch is not null)
{
    Console.WriteLine($"Failed batch: {report.FailedBatch} ({report.FailedMigrationId ?? "history table"}), SQL error {report.SqlErrorNumber?.ToString() ?? "none"}");
}

return report.Outcome switch
{
    RunOutcome.Succeeded => 0,
    RunOutcome.Refused => Refused,
    RunOutcome.LockBusy => LockBusy,
    _ => Failed
};

string? Option(string name)
{
    var index = Array.IndexOf(args, name);
    return index >= 0 && index + 1 < args.Length ? args[index + 1] : null;
}

static string Describe(IReadOnlyList<string> ids) => ids.Count == 0 ? "(none)" : string.Join(", ", ids);
