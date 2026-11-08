using FitPlan.Migrator;

// Usage:
//   FitPlan.Migrator validate <script.sql>
//   FitPlan.Migrator apply <script.sql> --sha256 <approved hash> --target dev
// Exit codes: 0 done, 1 usage, 2 refused before connecting, 3 another run holds the lock, 4 failed.

const int Usage = 1, Refused = 2, LockBusy = 3, Failed = 4;

if (args.Length < 2 || args[0] is not ("validate" or "apply"))
{
    Console.Error.WriteLine("Usage: validate <script.sql> | apply <script.sql> --sha256 <hash> --target dev");
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
if (sha256 is null || target != "dev")
{
    Console.Error.WriteLine("apply needs --sha256 <approved hash> and --target dev. No other target exists.");
    return Usage;
}

RunReport report;
try
{
    report = await ScriptRunner.ApplyAsync(file, sha256, MigrationTarget.Dev, known);
}
catch (Exception ex)
{
    Console.Error.WriteLine($"The run stopped unexpectedly: {ex.GetType().Name}: {ex.Message}");
    Console.Error.WriteLine("The result is uncertain. Don't run again before comparing the schema and __EFMigrationsHistory with a reference database.");
    return Failed;
}

Console.WriteLine($"Target: {MigrationTarget.DevServer}/{MigrationTarget.DevDatabase}");
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
