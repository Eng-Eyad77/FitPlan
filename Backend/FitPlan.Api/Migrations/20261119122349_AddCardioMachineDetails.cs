using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace FitPlan.Api.Migrations
{
    /// <inheritdoc />
    public partial class AddCardioMachineDetails : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "CadenceRpm",
                table: "CardioEntries",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "DistanceMeters",
                table: "CardioEntries",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "Floors",
                table: "CardioEntries",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "Laps",
                table: "CardioEntries",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "Level",
                table: "CardioEntries",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "PoolLengthMeters",
                table: "CardioEntries",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "StrokeRate",
                table: "CardioEntries",
                type: "int",
                nullable: true);

            migrationBuilder.AddCheckConstraint(
                name: "CK_CardioEntries_CadenceRpm",
                table: "CardioEntries",
                sql: "[CadenceRpm] >= 20 AND [CadenceRpm] <= 200");

            migrationBuilder.AddCheckConstraint(
                name: "CK_CardioEntries_DistanceMeters",
                table: "CardioEntries",
                sql: "[DistanceMeters] >= 1 AND [DistanceMeters] <= 50000");

            migrationBuilder.AddCheckConstraint(
                name: "CK_CardioEntries_Floors",
                table: "CardioEntries",
                sql: "[Floors] >= 1 AND [Floors] <= 1000");

            migrationBuilder.AddCheckConstraint(
                name: "CK_CardioEntries_Laps",
                table: "CardioEntries",
                sql: "[Laps] >= 1 AND [Laps] <= 2000");

            migrationBuilder.AddCheckConstraint(
                name: "CK_CardioEntries_Level",
                table: "CardioEntries",
                sql: "[Level] >= 1 AND [Level] <= 30");

            migrationBuilder.AddCheckConstraint(
                name: "CK_CardioEntries_PoolLengthMeters",
                table: "CardioEntries",
                sql: "[PoolLengthMeters] >= 10 AND [PoolLengthMeters] <= 100");

            migrationBuilder.AddCheckConstraint(
                name: "CK_CardioEntries_StrokeRate",
                table: "CardioEntries",
                sql: "[StrokeRate] >= 10 AND [StrokeRate] <= 60");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropCheckConstraint(
                name: "CK_CardioEntries_CadenceRpm",
                table: "CardioEntries");

            migrationBuilder.DropCheckConstraint(
                name: "CK_CardioEntries_DistanceMeters",
                table: "CardioEntries");

            migrationBuilder.DropCheckConstraint(
                name: "CK_CardioEntries_Floors",
                table: "CardioEntries");

            migrationBuilder.DropCheckConstraint(
                name: "CK_CardioEntries_Laps",
                table: "CardioEntries");

            migrationBuilder.DropCheckConstraint(
                name: "CK_CardioEntries_Level",
                table: "CardioEntries");

            migrationBuilder.DropCheckConstraint(
                name: "CK_CardioEntries_PoolLengthMeters",
                table: "CardioEntries");

            migrationBuilder.DropCheckConstraint(
                name: "CK_CardioEntries_StrokeRate",
                table: "CardioEntries");

            migrationBuilder.DropColumn(
                name: "CadenceRpm",
                table: "CardioEntries");

            migrationBuilder.DropColumn(
                name: "DistanceMeters",
                table: "CardioEntries");

            migrationBuilder.DropColumn(
                name: "Floors",
                table: "CardioEntries");

            migrationBuilder.DropColumn(
                name: "Laps",
                table: "CardioEntries");

            migrationBuilder.DropColumn(
                name: "Level",
                table: "CardioEntries");

            migrationBuilder.DropColumn(
                name: "PoolLengthMeters",
                table: "CardioEntries");

            migrationBuilder.DropColumn(
                name: "StrokeRate",
                table: "CardioEntries");
        }
    }
}
