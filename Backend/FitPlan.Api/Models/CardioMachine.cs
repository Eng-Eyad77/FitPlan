namespace FitPlan.Api.Models;

public enum CardioMachine
{
    Treadmill = 1,
    StationaryBike = 2,
    Elliptical = 3,
    StairClimber = 4,
    Rower = 5,

    // Retired from new entries (it had no way to say what it was). Old entries keep it.
    Other = 6,

    Swimming = 7
}
