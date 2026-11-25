using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace FitPlan.Api.Migrations
{
    /// <inheritdoc />
    public partial class AddExerciseNotes : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "Note",
                table: "WorkoutPlanExercises",
                type: "nvarchar(500)",
                maxLength: 500,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Note",
                table: "SessionExercises",
                type: "nvarchar(500)",
                maxLength: 500,
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Note",
                table: "WorkoutPlanExercises");

            migrationBuilder.DropColumn(
                name: "Note",
                table: "SessionExercises");
        }
    }
}
