using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace FitPlan.Api.Migrations
{
    /// <inheritdoc />
    public partial class AddExerciseAdminFields : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateTime>(
                name: "GifCheckedAt",
                table: "Exercises",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "GifStatus",
                table: "Exercises",
                type: "nvarchar(20)",
                maxLength: 20,
                nullable: true);

            migrationBuilder.AddColumn<bool>(
                name: "Hidden",
                table: "Exercises",
                type: "bit",
                nullable: false,
                defaultValue: false);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "GifCheckedAt",
                table: "Exercises");

            migrationBuilder.DropColumn(
                name: "GifStatus",
                table: "Exercises");

            migrationBuilder.DropColumn(
                name: "Hidden",
                table: "Exercises");
        }
    }
}
