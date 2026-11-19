using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace FitPlan.Api.Migrations
{
    /// <inheritdoc />
    public partial class AddRecoveryCode : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateTime>(
                name: "RecoveryCodeCreatedAt",
                table: "Users",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "RecoveryCodeHash",
                table: "Users",
                type: "nvarchar(200)",
                maxLength: 200,
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "RecoveryCodeCreatedAt",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "RecoveryCodeHash",
                table: "Users");
        }
    }
}
