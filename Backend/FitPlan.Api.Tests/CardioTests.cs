using System.Net;
using System.Net.Http.Json;
using System.Text.Json;
using System.Text.Json.Serialization;
using FitPlan.Api.DTOs.WorkoutSessions;
using FitPlan.Api.Models;
using FitPlan.Api.Services.CardioEntries;
using FitPlan.Api.Tests.Infrastructure;
using Xunit;

namespace FitPlan.Api.Tests;

// Phase 8 (4.3, 4.4): each machine records what its display shows, Other is retired, Swimming is new.
[Collection(ApiCollection.Name)]
public class CardioTests(ApiFixture api)
{
    private static readonly JsonSerializerOptions Json = new(JsonSerializerDefaults.Web)
    {
        Converters = { new JsonStringEnumConverter() }
    };

    public static TheoryData<string, object> AcceptedDetails => new()
    {
        { "Treadmill", new { speedKmh = 8.5, inclinePercent = 2, distanceKm = 3.4 } },
        { "StairClimber", new { level = 8, floors = 45 } },
        { "StationaryBike", new { level = 12, distanceKm = 9.5, cadenceRpm = 85 } },
        { "Elliptical", new { level = 10, distanceKm = 3.1, inclinePercent = 5 } },
        { "Rower", new { distanceMeters = 2000, level = 5, strokeRate = 24 } },
        { "Swimming", new { distanceMeters = 1500, poolLengthMeters = 25, laps = 60 } }
    };

    [Theory]
    [MemberData(nameof(AcceptedDetails))]
    public async Task Each_machine_takes_its_own_details(string machine, object details)
    {
        var (user, sessionId) = await StartAsync();

        var response = await AddAsync(user, sessionId, machine, details);

        Assert.Equal(HttpStatusCode.Created, response.StatusCode);
        var saved = (await response.Content.ReadFromJsonAsync<CardioEntryResponseDto>(Json))!;
        Assert.Equal(machine, saved.Machine.ToString());
    }

    public static TheoryData<string, object, string> RefusedDetails => new()
    {
        { "StairClimber", new { speedKmh = 5 }, "speedKmh" },
        { "StairClimber", new { distanceKm = 1 }, "distanceKm" },
        { "Treadmill", new { level = 3 }, "level" },
        { "StationaryBike", new { speedKmh = 25 }, "speedKmh" },
        { "Rower", new { distanceKm = 2 }, "distanceKm" },
        { "Swimming", new { speedKmh = 2 }, "speedKmh" },
        { "Swimming", new { distanceKm = 1.5 }, "distanceKm" },
        { "Elliptical", new { strokeRate = 20 }, "strokeRate" }
    };

    [Theory]
    [MemberData(nameof(RefusedDetails))]
    public async Task A_detail_the_machine_does_not_have_is_refused(string machine, object details, string field)
    {
        var (user, sessionId) = await StartAsync();

        var response = await AddAsync(user, sessionId, machine, details);

        var text = await response.Content.ReadAsStringAsync();
        await response.AssertProblemAsync(HttpStatusCode.BadRequest, "CardioFieldNotAllowed");
        Assert.Contains(field, text);
    }

    [Fact]
    public async Task The_rower_damper_stops_at_10_and_ranges_are_checked()
    {
        var (user, sessionId) = await StartAsync();

        await (await AddAsync(user, sessionId, "Rower", new { level = 11 }))
            .AssertProblemAsync(HttpStatusCode.BadRequest, "CardioFieldNotAllowed");
        Assert.Equal(HttpStatusCode.BadRequest, (await AddAsync(user, sessionId, "StairClimber", new { level = 31 })).StatusCode);
        Assert.Equal(HttpStatusCode.BadRequest, (await AddAsync(user, sessionId, "Swimming", new { poolLengthMeters = 5 })).StatusCode);
    }

    [Fact]
    public async Task Other_is_refused_for_new_entries_but_old_ones_still_show_and_can_be_corrected()
    {
        var (user, sessionId) = await StartAsync();

        await (await AddAsync(user, sessionId, "Other", new { }))
            .AssertProblemAsync(HttpStatusCode.BadRequest, "CardioMachineRetired");

        // an entry saved before Other was retired
        var oldId = Guid.NewGuid();
        await api.WithDbContextAsync(async context =>
        {
            context.CardioEntries.Add(new CardioEntry
            {
                Id = oldId,
                WorkoutSessionId = sessionId,
                Machine = CardioMachine.Other,
                DurationSeconds = 600,
                DistanceKm = 2,
                RecordedAt = DateTime.UtcNow
            });
            await context.SaveChangesAsync();
        });

        var session = await user.Client.GetFromJsonAsync<WorkoutSessionResponseDto>("/api/sessions/active", Json);
        var old = session!.Cardio.Single();
        Assert.Equal(CardioMachine.Other, old.Machine);
        Assert.Equal(2m, old.DistanceKm);

        var corrected = await user.Client.PutAsJsonAsync($"/api/sessions/{sessionId}/cardio/{oldId}",
            new { machine = "Other", durationSeconds = 900, distanceKm = 2.5 });
        Assert.Equal(HttpStatusCode.OK, corrected.StatusCode);

        var swum = await AddAsync(user, sessionId, "Swimming", new { });
        var swimId = (await swum.Content.ReadFromJsonAsync<CardioEntryResponseDto>(Json))!.Id;
        var becameOther = await user.Client.PutAsJsonAsync($"/api/sessions/{sessionId}/cardio/{swimId}",
            new { machine = "Other", durationSeconds = 900 });
        await becameOther.AssertProblemAsync(HttpStatusCode.BadRequest, "CardioMachineRetired");
    }

    [Fact]
    public async Task Laps_times_pool_length_gives_the_swim_distance_when_it_is_missing()
    {
        var (user, sessionId) = await StartAsync();

        var fromLaps = await AddAsync(user, sessionId, "Swimming", new { poolLengthMeters = 25, laps = 40 });
        Assert.Equal(1000, (await fromLaps.Content.ReadFromJsonAsync<CardioEntryResponseDto>(Json))!.DistanceMeters);

        // a distance the user typed wins
        var typed = await AddAsync(user, sessionId, "Swimming", new { distanceMeters = 950, poolLengthMeters = 25, laps = 40 });
        Assert.Equal(950, (await typed.Content.ReadFromJsonAsync<CardioEntryResponseDto>(Json))!.DistanceMeters);

        var tooLong = await AddAsync(user, sessionId, "Swimming", new { poolLengthMeters = 50, laps = 1001 });
        await tooLong.AssertProblemAsync(HttpStatusCode.BadRequest, "CardioDistanceTooLong");
    }

    [Fact]
    public async Task Calories_are_estimated_with_the_body_weight()
    {
        var (user, sessionId) = await StartAsync();
        (await user.Client.PostAsJsonAsync("/api/body-weight", new { weightKg = 80 })).EnsureSuccessStatusCode();

        var swim = await AddAsync(user, sessionId, "Swimming", new { distanceMeters = 1500 });
        var calories = (await swim.Content.ReadFromJsonAsync<CardioEntryResponseDto>(Json))!.EstimatedCalories;

        // 1500 m in 30 min = 50 m/min, fast freestyle: 9.8 MET × 3.5 × 80 / 200 × 30
        Assert.Equal(412, calories);
    }

    [Fact]
    public void The_treadmill_estimate_is_unchanged()
    {
        // ACSM by hand, 80 kg: walking 5 km/h at 3% for 30 min = (8.33 + 4.5 + 3.5) ml/kg/min × 0.4 × 30 = 196;
        // running 10 km/h for 20 min = (33.3 + 3.5) × 0.4 × 20 = 295
        Assert.Equal(196, CalorieEstimator.Estimate(CardioMachine.Treadmill, 1800, 5m, 3m, null, null, 80m));
        Assert.Equal(295, CalorieEstimator.Estimate(CardioMachine.Treadmill, 1200, 10m, null, null, null, 80m));
        // distance without speed gives the speed
        Assert.Equal(295, CalorieEstimator.Estimate(CardioMachine.Treadmill, 1200, null, null, 10m / 3, null, 80m));
        Assert.Null(CalorieEstimator.Estimate(CardioMachine.Treadmill, 1200, 10m, null, null, null, null));
    }

    [Theory]
    [InlineData(CardioMachine.Swimming, null, 6.0)]
    [InlineData(CardioMachine.Swimming, 20.0, 5.8)]
    [InlineData(CardioMachine.Swimming, 40.0, 8.3)]
    [InlineData(CardioMachine.Swimming, 60.0, 9.8)]
    [InlineData(CardioMachine.Rower, null, 7.0)]
    [InlineData(CardioMachine.Rower, 100.0, 4.8)]
    [InlineData(CardioMachine.Rower, 150.0, 7.0)]
    [InlineData(CardioMachine.Rower, 200.0, 8.5)]
    [InlineData(CardioMachine.StairClimber, 90.0, 9.0)]
    [InlineData(CardioMachine.Other, null, 5.0)]
    public void The_pace_picks_the_intensity_for_rowing_and_swimming(CardioMachine machine, double? pace, double met)
    {
        Assert.Equal(met, CalorieEstimator.GetMet(machine, pace));
    }

    private async Task<(TestUser User, Guid SessionId)> StartAsync()
    {
        var user = await api.RegisterUserAsync();
        var response = await user.Client.PostAsJsonAsync("/api/sessions", new { });
        response.EnsureSuccessStatusCode();
        return (user, (await response.Content.ReadFromJsonAsync<WorkoutSessionResponseDto>(Json))!.Id);
    }

    private static Task<HttpResponseMessage> AddAsync(TestUser user, Guid sessionId, string machine, object details)
    {
        var body = JsonSerializer.SerializeToNode(details, Json)!.AsObject();
        body["machine"] = machine;
        body["durationSeconds"] = 1800;
        return user.Client.PostAsJsonAsync($"/api/sessions/{sessionId}/cardio", body);
    }
}
