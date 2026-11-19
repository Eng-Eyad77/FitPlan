using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace FitPlan.Api.Migrations
{
    /// <inheritdoc />
    public partial class AddRestSeconds : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "RestSeconds",
                table: "WorkoutPlanExercises",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "RestSeconds",
                table: "SessionExercises",
                type: "int",
                nullable: true);

            migrationBuilder.AddCheckConstraint(
                name: "CK_WorkoutPlanExercises_RestSeconds",
                table: "WorkoutPlanExercises",
                sql: "[RestSeconds] IS NULL OR ([RestSeconds] >= 15 AND [RestSeconds] <= 600)");

            migrationBuilder.AddCheckConstraint(
                name: "CK_SessionExercises_RestSeconds",
                table: "SessionExercises",
                sql: "[RestSeconds] IS NULL OR ([RestSeconds] >= 15 AND [RestSeconds] <= 600)");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropCheckConstraint(
                name: "CK_WorkoutPlanExercises_RestSeconds",
                table: "WorkoutPlanExercises");

            migrationBuilder.DropCheckConstraint(
                name: "CK_SessionExercises_RestSeconds",
                table: "SessionExercises");

            migrationBuilder.DropColumn(
                name: "RestSeconds",
                table: "WorkoutPlanExercises");

            migrationBuilder.DropColumn(
                name: "RestSeconds",
                table: "SessionExercises");
        }
    }
}
