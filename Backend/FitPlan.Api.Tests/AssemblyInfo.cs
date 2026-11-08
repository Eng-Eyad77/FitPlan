using Xunit;

// Each WebApplicationFactory host is built through a process-wide listener, so hosts must not start in parallel.
[assembly: CollectionBehavior(DisableTestParallelization = true)]
