
using FitPlan.Api.Common.Results;
using FitPlan.Api.Data;
using FitPlan.Api.DTOs.WorkoutSessions;
using FitPlan.Api.Models;
using FitPlan.Api.Services.BodyWeight;
using FitPlan.Api.Services.WorkoutSessions;
using Microsoft.EntityFrameworkCore;

namespace FitPlan.Api.Services.CardioEntries;

public class CardioEntryService(FitPlanDbContext context, IBodyWeightService bodyWeightService) : ICardioEntryService
{
    public async Task<Result<CardioEntryResponseDto>> AddCardioAsync(Guid userId, Guid sessionId, CardioEntryRequestDto dto)
    {
        if (await context.CheckActiveSessionAsync(userId, sessionId) is { } error)
        {
            return Result<CardioEntryResponseDto>.Failure(error);
        }

        // Other is only kept for old entries
        if (dto.Machine == CardioMachine.Other)
        {
            return Result<CardioEntryResponseDto>.Failure(Errors.CardioMachineRetired);
        }

        if (Check(dto) is { } invalid)
        {
            return Result<CardioEntryResponseDto>.Failure(invalid);
        }

        var cardio = new CardioEntry
        {
            Id = Guid.NewGuid(),
            WorkoutSessionId = sessionId,
            RecordedAt = DateTime.UtcNow
        };

        await ApplyAsync(cardio, dto, userId);

        context.CardioEntries.Add(cardio);
        await context.SaveChangesAsync();

        return Result<CardioEntryResponseDto>.Success(WorkoutSessionMappings.ToCardioDto(cardio));
    }


    public async Task<Result<CardioEntryResponseDto>> UpdateCardioAsync(Guid userId, Guid sessionId, Guid id, CardioEntryRequestDto dto)
    {
        if (await context.CheckActiveSessionAsync(userId, sessionId) is { } error)
        {
            return Result<CardioEntryResponseDto>.Failure(error);
        }

        var cardio = await context.CardioEntries
            .FirstOrDefaultAsync(c => c.Id == id && c.WorkoutSessionId == sessionId);

        if (cardio is null)
        {
            return Result<CardioEntryResponseDto>.Failure(Errors.CardioEntryNotFound);
        }

        // an old Other entry can still be corrected, but nothing can become Other
        if (dto.Machine == CardioMachine.Other && cardio.Machine != CardioMachine.Other)
        {
            return Result<CardioEntryResponseDto>.Failure(Errors.CardioMachineRetired);
        }

        if (Check(dto) is { } invalid)
        {
            return Result<CardioEntryResponseDto>.Failure(invalid);
        }

        await ApplyAsync(cardio, dto, userId);
        await context.SaveChangesAsync();

        return Result<CardioEntryResponseDto>.Success(WorkoutSessionMappings.ToCardioDto(cardio));
    }


    public async Task<Result<bool>> DeleteCardioAsync(Guid userId, Guid sessionId, Guid id)
    {
        if (await context.CheckActiveSessionAsync(userId, sessionId) is { } error)
        {
            return Result<bool>.Failure(error);
        }

        var cardio = await context.CardioEntries
            .FirstOrDefaultAsync(c => c.Id == id && c.WorkoutSessionId == sessionId);

        if (cardio is null)
        {
            return Result<bool>.Failure(Errors.CardioEntryNotFound);
        }

        context.CardioEntries.Remove(cardio);
        await context.SaveChangesAsync();

        return Result<bool>.Success(true);
    }


    // the details must belong to the machine, and a swim worked out from laps must stay in range
    private static Error? Check(CardioEntryRequestDto dto)
    {
        if (CardioFields.Check(dto) is { } error)
        {
            return error;
        }

        return CardioFields.SwimDistanceMeters(dto) > 50000 ? Errors.CardioDistanceTooLong : null;
    }

    // copies the request values and (re)calculates the calories with the user's current weight
    private async Task ApplyAsync(CardioEntry cardio, CardioEntryRequestDto dto, Guid userId)
    {
        cardio.Machine = dto.Machine!.Value; // [Required] guarantees it is not null
        cardio.DurationSeconds = dto.DurationSeconds;
        cardio.SpeedKmh = dto.SpeedKmh;
        cardio.InclinePercent = dto.InclinePercent;
        cardio.DistanceKm = dto.DistanceKm;
        cardio.Level = dto.Level;
        cardio.Floors = dto.Floors;
        cardio.CadenceRpm = dto.CadenceRpm;
        cardio.StrokeRate = dto.StrokeRate;
        cardio.DistanceMeters = CardioFields.SwimDistanceMeters(dto);
        cardio.PoolLengthMeters = dto.PoolLengthMeters;
        cardio.Laps = dto.Laps;

        cardio.EstimatedCalories = CalorieEstimator.Estimate(cardio, await bodyWeightService.GetCurrentWeightAsync(userId));
    }
}
