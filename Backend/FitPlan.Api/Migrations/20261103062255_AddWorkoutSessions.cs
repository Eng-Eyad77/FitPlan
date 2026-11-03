using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace FitPlan.Api.Migrations
{
    /// <inheritdoc />
    public partial class AddWorkoutSessions : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "BodyWeightEntries",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    UserId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    WeightKg = table.Column<decimal>(type: "decimal(5,2)", precision: 5, scale: 2, nullable: false),
                    RecordedAt = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_BodyWeightEntries", x => x.Id);
                    table.CheckConstraint("CK_BodyWeightEntries_WeightKg", "[WeightKg] >= 20 AND [WeightKg] <= 400");
                    table.ForeignKey(
                        name: "FK_BodyWeightEntries_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "WorkoutSessions",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    UserId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    WorkoutPlanId = table.Column<Guid>(type: "uniqueidentifier", nullable: true),
                    Name = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    StartedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    CompletedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    Notes = table.Column<string>(type: "nvarchar(1000)", maxLength: 1000, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_WorkoutSessions", x => x.Id);
                    table.ForeignKey(
                        name: "FK_WorkoutSessions_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_WorkoutSessions_WorkoutPlans_WorkoutPlanId",
                        column: x => x.WorkoutPlanId,
                        principalTable: "WorkoutPlans",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                });

            migrationBuilder.CreateTable(
                name: "CardioEntries",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    WorkoutSessionId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    Machine = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: false),
                    DurationSeconds = table.Column<int>(type: "int", nullable: false),
                    SpeedKmh = table.Column<decimal>(type: "decimal(5,2)", precision: 5, scale: 2, nullable: true),
                    InclinePercent = table.Column<decimal>(type: "decimal(5,2)", precision: 5, scale: 2, nullable: true),
                    DistanceKm = table.Column<decimal>(type: "decimal(6,2)", precision: 6, scale: 2, nullable: true),
                    EstimatedCalories = table.Column<int>(type: "int", nullable: true),
                    RecordedAt = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_CardioEntries", x => x.Id);
                    table.CheckConstraint("CK_CardioEntries_DistanceKm", "[DistanceKm] > 0 AND [DistanceKm] <= 100");
                    table.CheckConstraint("CK_CardioEntries_DurationSeconds", "[DurationSeconds] >= 1 AND [DurationSeconds] <= 18000");
                    table.CheckConstraint("CK_CardioEntries_EstimatedCalories", "[EstimatedCalories] >= 0");
                    table.CheckConstraint("CK_CardioEntries_InclinePercent", "[InclinePercent] >= 0 AND [InclinePercent] <= 40");
                    table.CheckConstraint("CK_CardioEntries_SpeedKmh", "[SpeedKmh] > 0 AND [SpeedKmh] <= 30");
                    table.ForeignKey(
                        name: "FK_CardioEntries_WorkoutSessions_WorkoutSessionId",
                        column: x => x.WorkoutSessionId,
                        principalTable: "WorkoutSessions",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "SessionExercises",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    WorkoutSessionId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    ExerciseId = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    Order = table.Column<int>(type: "int", nullable: false),
                    TargetSets = table.Column<int>(type: "int", nullable: true),
                    TargetReps = table.Column<int>(type: "int", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SessionExercises", x => x.Id);
                    table.CheckConstraint("CK_SessionExercises_Order", "[Order] > 0");
                    table.ForeignKey(
                        name: "FK_SessionExercises_Exercises_ExerciseId",
                        column: x => x.ExerciseId,
                        principalTable: "Exercises",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_SessionExercises_WorkoutSessions_WorkoutSessionId",
                        column: x => x.WorkoutSessionId,
                        principalTable: "WorkoutSessions",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "SessionSets",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    SessionExerciseId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    SetNumber = table.Column<int>(type: "int", nullable: false),
                    Reps = table.Column<int>(type: "int", nullable: false),
                    WeightKg = table.Column<decimal>(type: "decimal(6,2)", precision: 6, scale: 2, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SessionSets", x => x.Id);
                    table.CheckConstraint("CK_SessionSets_Reps", "[Reps] >= 1 AND [Reps] <= 100");
                    table.CheckConstraint("CK_SessionSets_SetNumber", "[SetNumber] > 0");
                    table.CheckConstraint("CK_SessionSets_WeightKg", "[WeightKg] >= 0 AND [WeightKg] <= 500");
                    table.ForeignKey(
                        name: "FK_SessionSets_SessionExercises_SessionExerciseId",
                        column: x => x.SessionExerciseId,
                        principalTable: "SessionExercises",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_BodyWeightEntries_UserId_RecordedAt",
                table: "BodyWeightEntries",
                columns: new[] { "UserId", "RecordedAt" });

            migrationBuilder.CreateIndex(
                name: "IX_CardioEntries_WorkoutSessionId",
                table: "CardioEntries",
                column: "WorkoutSessionId");

            migrationBuilder.CreateIndex(
                name: "IX_SessionExercises_ExerciseId",
                table: "SessionExercises",
                column: "ExerciseId");

            migrationBuilder.CreateIndex(
                name: "IX_SessionExercises_WorkoutSessionId_ExerciseId",
                table: "SessionExercises",
                columns: new[] { "WorkoutSessionId", "ExerciseId" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_SessionSets_SessionExerciseId",
                table: "SessionSets",
                column: "SessionExerciseId");

            migrationBuilder.CreateIndex(
                name: "IX_WorkoutSessions_OneActivePerUser",
                table: "WorkoutSessions",
                column: "UserId",
                unique: true,
                filter: "[CompletedAt] IS NULL");

            migrationBuilder.CreateIndex(
                name: "IX_WorkoutSessions_UserId_CompletedAt",
                table: "WorkoutSessions",
                columns: new[] { "UserId", "CompletedAt" });

            migrationBuilder.CreateIndex(
                name: "IX_WorkoutSessions_WorkoutPlanId",
                table: "WorkoutSessions",
                column: "WorkoutPlanId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "BodyWeightEntries");

            migrationBuilder.DropTable(
                name: "CardioEntries");

            migrationBuilder.DropTable(
                name: "SessionSets");

            migrationBuilder.DropTable(
                name: "SessionExercises");

            migrationBuilder.DropTable(
                name: "WorkoutSessions");
        }
    }
}
