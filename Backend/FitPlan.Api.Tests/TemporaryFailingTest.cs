using Xunit;

namespace FitPlan.Api.Tests;

// TEMPORARY: proves that a failing test blocks the merge. This branch is never merged.
public sealed class TemporaryFailingTest
{
    [Fact]
    public void This_test_fails_on_purpose()
    {
        Assert.Fail("Temporary failing test for the Phase 3B merge-blocking check.");
    }
}
