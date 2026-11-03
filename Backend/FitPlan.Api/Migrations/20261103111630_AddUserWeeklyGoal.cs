using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace FitPlan.Api.Migrations
{
    /// <inheritdoc />
    public partial class AddUserWeeklyGoal : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "WeeklyGoal",
                table: "Users",
                type: "int",
                nullable: true);

            migrationBuilder.AddCheckConstraint(
                name: "CK_Users_WeeklyGoal",
                table: "Users",
                sql: "[WeeklyGoal] IS NULL OR ([WeeklyGoal] >= 1 AND [WeeklyGoal] <= 7)");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropCheckConstraint(
                name: "CK_Users_WeeklyGoal",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "WeeklyGoal",
                table: "Users");
        }
    }
}
