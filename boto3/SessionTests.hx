package boto3;

import boto3.Boto3;

import python.Dict;
import python.Lib;
import python.lib.datetime.Datetime;

/**
   test boto3 session
 **/
class SessionTests {
    /** session object */
    private var session :Session;

    /** dynamo client made from session */
    private var sessionDynamo :DynamoDBClient;

    /**
       init session and client objects
     **/
    public function new() {
        session = Boto3.session({regionName: "us-east-1",
                                 profileName: "default"});
        sessionDynamo = session.client("dynamodb");
    }

    /**
       run tests
    **/
    public function run() {
        // general
        sessionTests();

        // list tables using client made from session
        listTables();
    }

    private function sessionTests() {
        trace("");
        trace("SessionTests:");
        trace("  profiles: " + session.availableProfiles);
        trace("  partitions: " + session.getAvailablePartitions());
        trace("  regions: " + session.getAvailableRegions("dynamodb", "aws", false));
        trace("  services: " + session.getAvailableServices());
        trace("  profileName: " + session.profileName);
        trace("  regionName: " + session.regionName);
    }

    private function listTables() {
        var request = {Limit: 3};
        var result = sessionDynamo.listTables(request);
        trace("  found tables: " + result.get("TableNames"));
    }
}
