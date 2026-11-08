using System.Security.Cryptography;
using System.Text;
using System.Text.RegularExpressions;
using Microsoft.SqlServer.TransactSql.ScriptDom;

namespace FitPlan.Migrator;

// Accepts only an idempotent script in the exact shape EF Core generates for this project's migrations.
// Anything else is rejected, including statements EF could produce that this project hasn't needed yet.
public sealed partial class ScriptValidator(KnownMigrations known)
{
    private const string HistoryTable = "__EFMigrationsHistory";

    private const string HistoryBatch = """
        IF OBJECT_ID(N'[__EFMigrationsHistory]') IS NULL
        BEGIN
            CREATE TABLE [__EFMigrationsHistory] (
                [MigrationId] nvarchar(150) NOT NULL,
                [ProductVersion] nvarchar(32) NOT NULL,
                CONSTRAINT [PK___EFMigrationsHistory] PRIMARY KEY ([MigrationId])
            );
        END;
        """;

    // Statements a migration may run. Each one needs a test before it is added.
    private static readonly HashSet<string> AllowedSchemaStatements =
    [
        nameof(CreateTableStatement),
        nameof(AlterTableAddTableElementStatement),
        nameof(AlterTableAlterColumnStatement),
        nameof(AlterTableDropTableElementStatement),
        nameof(CreateIndexStatement),
        nameof(DropIndexStatement),
        nameof(DropTableStatement)
    ];

    // Rejected anywhere, including inside EXEC(N'...'). These could change who the script runs as,
    // change permissions, leave the database, or commit a failed migration (RAISERROR).
    private static readonly HashSet<string> ForbiddenNodes =
    [
        "RevertStatement",
        "ExecuteAsStatement",
        "ExecuteAsClause",
        "SetUserStatement",
        "SecurityStatement",
        "SecurityStatementBody2005",
        "RoleStatement",
        "UserStatement",
        "DropUserStatement",
        "LoginStatement",
        "DropLoginStatement",
        "AlterAuthorizationStatement",
        "UseStatement",
        "AlterDatabaseStatement",
        "RaiseErrorStatement",
        "RaiseErrorLegacyStatement",
        "ThrowStatement",
        "PrintStatement"
    ];

    public ValidatedScript Validate(byte[] file)
    {
        var sha256 = Convert.ToHexString(SHA256.HashData(file));
        string text;
        try
        {
            text = new UTF8Encoding(false, true).GetString(file).TrimStart('﻿');
        }
        catch (DecoderFallbackException)
        {
            throw new ScriptRejectedException("The file isn't valid UTF-8.");
        }

        var script = Parse(text, "the script");
        RejectForbidden(script, "the script");

        if (script.Batches.Count < 2)
        {
            throw new ScriptRejectedException("The script has no migration batch.");
        }

        if (Normalize(script.Batches[0]) != Normalize(Parse(HistoryBatch, "the expected history batch").Batches[0]))
        {
            throw new ScriptRejectedException("Batch 1 isn't the EF Core history table batch.");
        }

        var batches = new List<ScriptBatch> { new(1, null, Slice(text, script.Batches[0])) };
        var migrationIds = new List<string>();

        for (var index = 1; index < script.Batches.Count; index++)
        {
            var id = ValidateMigrationBatch(script.Batches[index], index + 1);
            if (migrationIds.Contains(id))
            {
                throw new ScriptRejectedException($"Migration {id} appears in more than one batch.");
            }

            migrationIds.Add(id);
            batches.Add(new ScriptBatch(index + 1, id, Slice(text, script.Batches[index])));
        }

        RequireKnownOrder(migrationIds);

        return new ValidatedScript(sha256, batches, migrationIds);
    }

    private string ValidateMigrationBatch(TSqlBatch batch, int number)
    {
        var statements = batch.Statements;
        if (statements.Count < 3
            || statements[0] is not BeginTransactionStatement
            || Normalize(statements[0]) != "BEGIN TRANSACTION ;"
            || statements[^1] is not CommitTransactionStatement
            || Normalize(statements[^1]) != "COMMIT ;")
        {
            throw new ScriptRejectedException($"Batch {number} doesn't start with BEGIN TRANSACTION and end with COMMIT.");
        }

        string? id = null;
        for (var index = 1; index < statements.Count - 1; index++)
        {
            if (statements[index] is not IfStatement { ElseStatement: null } guard)
            {
                throw new ScriptRejectedException(
                    $"Batch {number} has {statements[index].GetType().Name} outside an EF Core migration check, at line {statements[index].StartLine}.");
            }

            var match = MigrationCheck().Match(Normalize(guard.Predicate));
            if (!match.Success)
            {
                throw new ScriptRejectedException($"Batch {number} has an IF that isn't an EF Core migration check, at line {guard.StartLine}.");
            }

            var guardId = match.Groups["id"].Value;
            if (id is not null && guardId != id)
            {
                throw new ScriptRejectedException($"Batch {number} mixes migrations {id} and {guardId}.");
            }

            id = guardId;

            if (guard.ThenStatement is not BeginEndBlockStatement { StatementList.Statements.Count: 1 } block)
            {
                throw new ScriptRejectedException($"Batch {number} has a migration step that isn't exactly one statement, at line {guard.StartLine}.");
            }

            var body = block.StatementList.Statements[0];
            var isLast = index == statements.Count - 2;
            if (isLast)
            {
                RequireHistoryInsert(body, id, number);
            }
            else
            {
                RequireSchemaStatement(body, number, allowExec: true);
            }
        }

        return id!;
    }

    private void RequireHistoryInsert(TSqlStatement statement, string id, int number)
    {
        var expected = $"INSERT INTO [{HistoryTable}] ( [MigrationId] , [ProductVersion] ) VALUES ( N'{id}' , N'{known.ProductVersion}' )";
        if (statement is not InsertStatement || TrimSemicolon(Normalize(statement)) != expected)
        {
            throw new ScriptRejectedException(
                $"Batch {number} doesn't end by recording {id} with EF Core {known.ProductVersion}.");
        }
    }

    private static void RequireSchemaStatement(TSqlStatement statement, int number, bool allowExec)
    {
        var line = statement.StartLine;

        if (allowExec && statement is ExecuteStatement execute)
        {
            var sql = ReadLiteralExec(execute, number, line);
            var inner = Parse(sql, $"the EXEC at line {line}");
            RejectForbidden(inner, $"the EXEC at line {line}");

            if (inner.Batches.Count != 1 || inner.Batches[0].Statements.Count != 1)
            {
                throw new ScriptRejectedException($"The EXEC at line {line} must contain exactly one statement.");
            }

            RequireSchemaStatement(inner.Batches[0].Statements[0], number, allowExec: false);
            return;
        }

        var type = statement.GetType().Name;
        if (!AllowedSchemaStatements.Contains(type))
        {
            throw new ScriptRejectedException($"{type} isn't allowed in a migration, at line {line} of batch {number}.");
        }

        if (TouchesHistoryTable(statement))
        {
            throw new ScriptRejectedException($"Only the final step of a migration may change {HistoryTable}, at line {line}.");
        }
    }

    // Only EXEC(N'...') with one constant string, so the SQL it runs can be checked like the rest.
    private static string ReadLiteralExec(ExecuteStatement execute, int number, int line)
    {
        if (execute.ExecuteSpecification is not
            {
                ExecuteContext: null,
                LinkedServer: null,
                Variable: null,
                ExecutableEntity: ExecutableStringList { Strings.Count: 1, Parameters.Count: 0 } list
            }
            || list.Strings[0] is not StringLiteral literal)
        {
            throw new ScriptRejectedException($"Only EXEC(N'...') with one constant string is allowed, at line {line} of batch {number}.");
        }

        return literal.Value;
    }

    private static bool TouchesHistoryTable(TSqlFragment fragment)
    {
        for (var index = fragment.FirstTokenIndex; index <= fragment.LastTokenIndex; index++)
        {
            var token = fragment.ScriptTokenStream[index];
            if (token.TokenType is TSqlTokenType.Identifier or TSqlTokenType.QuotedIdentifier
                && token.Text.Trim('[', ']', '"').Equals(HistoryTable, StringComparison.OrdinalIgnoreCase))
            {
                return true;
            }
        }

        return false;
    }

    private void RequireKnownOrder(List<string> migrationIds)
    {
        var start = known.Ids.ToList().IndexOf(migrationIds[0]);
        for (var index = 0; index < migrationIds.Count; index++)
        {
            if (start < 0 || start + index >= known.Ids.Count || known.Ids[start + index] != migrationIds[index])
            {
                throw new ScriptRejectedException(
                    $"Migration {migrationIds[index]} isn't the next migration in the API. The script must list the API's migrations in order.");
            }
        }
    }

    private static TSqlScript Parse(string sql, string what)
    {
        var parser = new TSql170Parser(initialQuotedIdentifiers: true);
        using var reader = new StringReader(sql);
        var fragment = parser.Parse(reader, out var errors);

        if (errors.Count > 0)
        {
            var first = errors[0];
            throw new ScriptRejectedException($"SQL in {what} doesn't parse, line {first.Line}: {first.Message}");
        }

        return (TSqlScript)fragment;
    }

    private static void RejectForbidden(TSqlFragment fragment, string where)
    {
        var finder = new ForbiddenFinder();
        fragment.Accept(finder);
        if (finder.Found is { } node)
        {
            throw new ScriptRejectedException($"{node.GetType().Name} is forbidden, at line {node.StartLine} of {where}.");
        }
    }

    // Tokens without whitespace or comments, so formatting can't hide a difference.
    private static string Normalize(TSqlFragment fragment)
    {
        var tokens = new List<string>();
        for (var index = fragment.FirstTokenIndex; index <= fragment.LastTokenIndex; index++)
        {
            var token = fragment.ScriptTokenStream[index];
            if (token.TokenType is not (TSqlTokenType.WhiteSpace or TSqlTokenType.SingleLineComment
                or TSqlTokenType.MultilineComment or TSqlTokenType.EndOfFile))
            {
                tokens.Add(token.Text);
            }
        }

        return string.Join(' ', tokens);
    }

    private static string TrimSemicolon(string normalized) =>
        normalized.EndsWith(" ;", StringComparison.Ordinal) ? normalized[..^2] : normalized;

    private static string Slice(string text, TSqlFragment fragment) =>
        text.Substring(fragment.StartOffset, fragment.FragmentLength);

    [GeneratedRegex(@"^NOT EXISTS \( SELECT \* FROM \[__EFMigrationsHistory\] WHERE \[MigrationId\] = N'(?<id>[0-9]{14}_[A-Za-z0-9_]+)' \)$")]
    private static partial Regex MigrationCheck();

    private sealed class ForbiddenFinder : TSqlFragmentVisitor
    {
        public TSqlFragment? Found { get; private set; }

        public override void Visit(TSqlFragment fragment)
        {
            if (Found is not null)
            {
                return;
            }

            for (var type = fragment.GetType(); type is not null; type = type.BaseType)
            {
                if (ForbiddenNodes.Contains(type.Name))
                {
                    Found = fragment;
                    return;
                }
            }
        }
    }
}
