package boto3;

/**
 * runs tests
 */
class TestRunner {

    public function new() {
    }

    public function run() {
        var sessionTests = new SessionTests();
        sessionTests.run();

        var stsTests = new StsTests();
        stsTests.run();

        // var dynamoTests = new DynamoTests();
        // dynamoTests.run();

        var lambdaTests = new LambdaTests(stsTests.accountId);
        lambdaTests.run();
    }

    /**
       test runner
     **/
    static public function main() {
        var runner = new TestRunner();
        runner.run();
    }
}
