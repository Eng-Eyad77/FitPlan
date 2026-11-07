namespace FitPlan.Migrator;

// One batch of the script, in the order it runs. MigrationId is null for the batch that creates the history table.
public sealed record ScriptBatch(int Number, string? MigrationId, string Sql);

// A script that passed ScriptValidator. Only the validator (and tests) can create one.
public sealed class ValidatedScript
{
    internal ValidatedScript(string sha256, IReadOnlyList<ScriptBatch> batches, IReadOnlyList<string> migrationIds)
    {
        Sha256 = sha256;
        Batches = batches;
        MigrationIds = migrationIds;
    }

    public string Sha256 { get; }

    public IReadOnlyList<ScriptBatch> Batches { get; }

    public IReadOnlyList<string> MigrationIds { get; }
}

public sealed class ScriptRejectedException(string message) : Exception(message);
