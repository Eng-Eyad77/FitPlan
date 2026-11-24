using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace FitPlan.Api.Migrations
{
    /// <inheritdoc />
    public partial class AddEmailAccounts : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // D18: accounts without an email are deleted, not migrated, with everything they own.
            // Workouts don't cascade from the user, so they go first (as in account deletion).
            // Profile picture files are removed in the release step. Down can't bring the accounts back.
            migrationBuilder.Sql("DELETE FROM [WorkoutSessions];");
            migrationBuilder.Sql("DELETE FROM [Users];");

            migrationBuilder.AddColumn<string>(
                name: "Email",
                table: "Users",
                type: "nvarchar(254)",
                maxLength: 254,
                nullable: false);

            migrationBuilder.CreateTable(
                name: "EmailCodes",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    Email = table.Column<string>(type: "nvarchar(254)", maxLength: 254, nullable: false),
                    Purpose = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: false),
                    UserId = table.Column<Guid>(type: "uniqueidentifier", nullable: true),
                    CodeHash = table.Column<string>(type: "nvarchar(64)", maxLength: 64, nullable: false),
                    Attempts = table.Column<int>(type: "int", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    ExpiresAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UsedAt = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_EmailCodes", x => x.Id);
                });

            migrationBuilder.CreateIndex(
                name: "IX_Users_Email",
                table: "Users",
                column: "Email",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_EmailCodes_Email_CreatedAt",
                table: "EmailCodes",
                columns: new[] { "Email", "CreatedAt" });

            migrationBuilder.CreateIndex(
                name: "IX_EmailCodes_UserId_CreatedAt",
                table: "EmailCodes",
                columns: new[] { "UserId", "CreatedAt" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "EmailCodes");

            migrationBuilder.DropIndex(
                name: "IX_Users_Email",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "Email",
                table: "Users");
        }
    }
}
