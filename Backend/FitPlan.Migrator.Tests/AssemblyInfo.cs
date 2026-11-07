using Xunit;

// Tests create and drop databases on one local server, so they run one at a time, like the API tests.
[assembly: CollectionBehavior(DisableTestParallelization = true)]
