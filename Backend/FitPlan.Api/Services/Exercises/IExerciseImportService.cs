using System;
using System.Xml.Serialization;

namespace FitPlan.Api.Services.Exercises;

public interface IExerciseImportService
{
    Task ImportExercisesAsync();
}
