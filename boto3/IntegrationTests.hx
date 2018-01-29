package boto3;

import boto3.Boto3;

import python.Dict;
import python.Lib;
import python.lib.datetime.Datetime;

/**
   WARNING these tests access aws!

   we create a client using the default profile, then create a table (Books), manipulate it, then
   delete it. the table has a low provisioning and is short lived so this should be well below the
   free quota, but this does interact with actual dynamo tables.

   if the test table already exists the tests will not run.
 **/
class IntegrationTests {
    static var TABLE_NAME = "Books";

    /** session object */
    private var session :Session;

    /** dynamo client made from session */
    private var sessionDynamo :DynamoDBClient;

    /** dynamo client made using default session */
    private var dynamo :DynamoDBClient;

    /** this gets set when we create a backup */
    private var backupArn :String;

    /**
       init session and client objects
     **/
    public function new() {
        session = Boto3.session({regionName: "us-east-1",
                                 profileName: "default"});
        sessionDynamo = session.client("dynamodb");
        dynamo = Boto3.client("dynamodb");
    }

    /**

     **/
    static public function main() {
        var runner = new IntegrationTests();
        runner.run();
    }

    /**
       Books
       properties: title (s), author (n), year (s), categories (ss)
       table: title (hash), author (range)
       index: author (hash), year (range)
     **/
    public function run() {
        // general
        sessionTests();
        describeLimits();
        generatePresignedUrl();

        // make sure the test table doesn't already exist
        quitIfTestTableExists();

        // create a test table
        createTable();
        waitForTableCreate();

        // view table
        listTables();
        describeTable();

        // fill table
        putItem();
        batchWriteItem();

        // read table
        scan();

        // update
        updateItem();

        // verify changes
        getItem();
        batchGetItem();

        // update table
        updateTable();
        describeTable();

        // tags
        tagResource();
        listTagsOfResource();
        untagResource();
        listTagsOfResource();

        // make backup
        createBackup();
        listBackups();
        describeBackup();
        describeContinuousBackups();

        // modify table and query
        query();
        deleteItem();
        query();

        // restore from backup
        deleteTable();
        waitForTableDelete();
        restoreTableFromBackup();
        waitForTableCreate();
        query();
        deleteBackup();
        listBackups();

        // set TTL
        describeTimeToLive();
        updateTTL();
        describeTimeToLive();

        // TODO global table
        createGlobalTable();
        listGlobalTables();
        updateGlobalTable();
        describeGlobalTable();

        // delete test table
        deleteTable();
        waitForTableDelete();
    }


    private function sessionTests() {
        trace("session tests:");
        trace("  profiles: " + session.availableProfiles);
        trace("  partitions: " + session.getAvailablePartitions());
        trace("  regions: " + session.getAvailableRegions("dynamodb", "aws", false));
        trace("  services: " + session.getAvailableServices());
        trace("  profileName: " + session.profileName);
        trace("  regionName: " + session.regionName);
    }

    private function describeLimits() {
        var result = sessionDynamo.describeLimits();
        trace("checking limits");
        trace("  account read limit: " + result.get("AccountMaxReadCapacityUnits"));
        trace("  account write limit: " + result.get("AccountMaxWriteCapacityUnits"));
    }

    private function generatePresignedUrl() {
        var request = {"ClientMethod": "describe_table",
                       "Params": Lib.anonToDict({"TableName": TABLE_NAME}),
                       "ExpiresIn": 60,
                       "HttpMethod": "GET"};
        var result = sessionDynamo.generatePresignedUrl(request);
        trace("example presigned url: " + result);
    }

    private function quitIfTestTableExists() {
        var request = {"TableName": TABLE_NAME};
        try {
            var result = dynamo.describeTable(request);
            throw "test table \"" + TABLE_NAME + "\" exists. exiting.";
        } catch (e: ClientError) {
            trace("no test table, good: " + Type.getClassName(Type.getClass(e)));
        }
    }

    private function createTable() {
        var request = {"AttributeDefinitions": [Lib.anonToDict({AttributeName: "title", AttributeType: "S"}),
                                                Lib.anonToDict({AttributeName: "author", AttributeType: "S"}),
                                                Lib.anonToDict({AttributeName: "year", AttributeType: "N"})],
                       "TableName": TABLE_NAME,
                       "KeySchema": [Lib.anonToDict({AttributeName: "title", KeyType: "HASH"}),
                                     Lib.anonToDict({AttributeName: "author", KeyType: "RANGE"})],
                       "ProvisionedThroughput": Lib.anonToDict({ReadCapacityUnits: 2, WriteCapacityUnits: 2}),
                       "GlobalSecondaryIndexes": [Lib.anonToDict({IndexName: "author-year-index",
                                                                  KeySchema: [Lib.anonToDict({AttributeName: "author", KeyType: "HASH"}),
                                                                              Lib.anonToDict({AttributeName: "year", KeyType: "RANGE"})],
                                                                  Projection: Lib.anonToDict({ProjectionType: "ALL"}),
                                                                  ProvisionedThroughput: Lib.anonToDict({ReadCapacityUnits: 2, WriteCapacityUnits: 2})})]};
        var result = dynamo.createTable(request);
        trace('creating table ($TABLE_NAME): ' + result.get("TableDescription").get("TableStatus"));
    }

    private function waitForTableCreate() {
        trace("  waiting for table creation...");
        var waiter = dynamo.getWaiter("table_exists");
        var request = {TableName: TABLE_NAME,
                       WaiterConfig: Lib.anonToDict({Delay: 40, MaxAttempts: 50})};
        waiter.wait(request);
        trace("  done waiting. table exists");
    }

    private function listTables() {
        var request = {Limit: 3};
        var result = dynamo.listTables(request);
        trace("found tables: " + result.get("TableNames"));
    }

    private function describeTable() {
        var request = {"TableName": TABLE_NAME};
        var result = dynamo.describeTable(request);
        trace('table description ($TABLE_NAME):');
        trace("  status: " + result.get("Table").get("TableStatus"));
        trace("  arn: " + result.get("Table").get("TableArn"));
        trace("  num items: " + result.get("Table").get("ItemCount"));
    }

    private function putItem() {
        var dateStr = Std.string(Math.floor(Datetime.utcnow().timestamp()));
        var request = {"TableName": TABLE_NAME,
                       "Item": Lib.anonToDict({title: Lib.anonToDict({S: "The Martian"}),
                                               author: Lib.anonToDict({S: "Andy Weir"}),
                                               year: Lib.anonToDict({N: "2013"}),
                                               categories: Lib.anonToDict({SS: ["Science Fiction"]}),
                                               date: Lib.anonToDict({N: dateStr})})};
        var result = dynamo.putItem(request);
        trace("put, status code: " + result.get("ResponseMetadata").get("HTTPStatusCode"));
    }

    private function batchWriteItem() {
        var dateStr = Std.string(Math.floor(Datetime.utcnow().timestamp()));
        var request = {"RequestItems": Lib.anonToDict({
                "Books":[
                         Lib.anonToDict({PutRequest: Lib.anonToDict({Item: Lib.anonToDict({title: Lib.anonToDict({S: "The Magician's Nephew"}),
                                                                                           author: Lib.anonToDict({S: "C. S. Lewis"}),
                                                                                           year: Lib.anonToDict({N: "1955"}),
                                                                                           categories: Lib.anonToDict({SS: ["Christian Literature", "Children's Fantasy"]}),
                                                                                           ttl: Lib.anonToDict({N: dateStr})})})}),
                         Lib.anonToDict({PutRequest: Lib.anonToDict({Item: Lib.anonToDict({title: Lib.anonToDict({S: "The Lion, the Witch and the Wardrobe"}),
                                                                                           author: Lib.anonToDict({S: "C. S. Lewis"}),
                                                                                           year: Lib.anonToDict({N: "1950"}),
                                                                                           categories: Lib.anonToDict({SS: ["Christian Literature", "Children's Fantasy"]}),
                                                                                           ttl: Lib.anonToDict({N: dateStr})})})}),
                         Lib.anonToDict({PutRequest: Lib.anonToDict({Item: Lib.anonToDict({title: Lib.anonToDict({S: "Out of the Silent Planet"}),
                                                                                           author: Lib.anonToDict({S: "C. S. Lewis"}),
                                                                                           year: Lib.anonToDict({N: "1938"}),
                                                                                           categories: Lib.anonToDict({SS: ["Science Fiction"]}),
                                                                                           ttl: Lib.anonToDict({N: dateStr})})})}),
                         Lib.anonToDict({PutRequest: Lib.anonToDict({Item: Lib.anonToDict({title: Lib.anonToDict({S: "Seveneves"}),
                                                                                           author: Lib.anonToDict({S: "Neal Stephenson"}),
                                                                                           year: Lib.anonToDict({N: "2015"}),
                                                                                           categories: Lib.anonToDict({SS: ["Science Fiction"]}),
                                                                                           ttl: Lib.anonToDict({N: dateStr})})})}),
                         Lib.anonToDict({PutRequest: Lib.anonToDict({Item: Lib.anonToDict({title: Lib.anonToDict({S: "Man's Search for Meaning"}),
                                                                                           author: Lib.anonToDict({S: "Viktor Frankl"}),
                                                                                           year: Lib.anonToDict({N: "1946"}),
                                                                                           categories: Lib.anonToDict({SS: ["Nonfiction"]}),
                                                                                           ttl: Lib.anonToDict({N: dateStr})})})}),
                         Lib.anonToDict({PutRequest: Lib.anonToDict({Item: Lib.anonToDict({title: Lib.anonToDict({S: "A Christmas Carol"}),
                                                                                           author: Lib.anonToDict({S: "Charles Dickens"}),
                                                                                           year: Lib.anonToDict({N: "1843"}),
                                                                                           categories: Lib.anonToDict({SS: ["Novella"]}),
                                                                                           ttl: Lib.anonToDict({N: dateStr})})})}),
                         Lib.anonToDict({PutRequest: Lib.anonToDict({Item: Lib.anonToDict({title: Lib.anonToDict({S: "On Intelligence"}),
                                                                                           author: Lib.anonToDict({S: "Jeff Hawkins"}),
                                                                                           year: Lib.anonToDict({N: "2004"}),
                                                                                           categories: Lib.anonToDict({SS: ["Nonfiction"]}),
                                                                                           ttl: Lib.anonToDict({N: dateStr})})})}),
                         Lib.anonToDict({PutRequest: Lib.anonToDict({Item: Lib.anonToDict({title: Lib.anonToDict({S: "A Man Called Ove"}),
                                                                                           author: Lib.anonToDict({S: "Fredrik Backman"}),
                                                                                           year: Lib.anonToDict({N: "2012"}),
                                                                                           categories: Lib.anonToDict({SS: ["Novel"]}),
                                                                                           ttl: Lib.anonToDict({N: dateStr})})})})]})};
        var result = dynamo.batchWriteItem(request);
        trace("batch write, status code: " + result.get("ResponseMetadata").get("HTTPStatusCode"));
    }

    // private function canPaginate() {
    //     var result = dynamo.canPaginate("scan");
    //     trace("canPaginate(scan): " + result);
    // }

    private function scan() {
        var request = {TableName: TABLE_NAME,
                       Limit: 20,
                       ProjectionExpression: "#t,#y,#c",
                       FilterExpression: "#y > :y",
                       ExpressionAttributeNames: Lib.anonToDict({"#t": "title",
                                                                   "#y": "year",
                                                                   "#c": "categories"}),
                       ExpressionAttributeValues: Lib.anonToDict({":y": Lib.anonAsDict({N: "1950"})})};
        var result = dynamo.scan(request);
        trace("scan:");
        for( item in cast(result.get("Items"),Array<Dynamic>) ) {
            trace("  " + item.get("title").get("S")
                  + ", " + item.get("year").get("N")
                  + ", " + cast(item.get("categories").get("SS"),Array<Dynamic>).join("/"));
        }
    }

    private function updateItem() {
        var request = {TableName: TABLE_NAME,
                       Key: Lib.anonToDict({title: Lib.anonToDict({S: "A Man Called Ove"}),
                                            author: Lib.anonToDict({S: "Fredrik Backman"})}),
                       UpdateExpression: "ADD #c :c",
                       ExpressionAttributeNames: Lib.anonToDict({"#c": "categories"}),
                       ExpressionAttributeValues: Lib.anonToDict({":c": Lib.anonToDict({SS: ["Fiction"]})})};
        var result = dynamo.updateItem(request);
        trace("update: " + result.get("HTTPStatusCode"));
    }

    private function getItem() {
        var request = {TableName: TABLE_NAME,
                       Key: Lib.anonToDict({title: Lib.anonToDict({S: "A Man Called Ove"}),
                                            author: Lib.anonToDict({S: "Fredrik Backman"})})};
        var result = dynamo.getItem(request);
        trace("get: " + result.get("Item"));
    }

    private function batchGetItem() {
        var request = {RequestItems: Lib.anonToDict({"Books": Lib.anonToDict({Keys: [
                                                                                     Lib.anonToDict({title: Lib.anonToDict({S: "Man's Search for Meaning"}),
                                                                                                     author: Lib.anonToDict({S: "Viktor Frankl"})}),
                                                                                     Lib.anonToDict({title: Lib.anonToDict({S: "On Intelligence"}),
                                                                                                     author: Lib.anonToDict({S: "Jeff Hawkins"})})]})})};
        var result = dynamo.batchGetItem(request);
        trace("batch get:");
        for( item in cast(result.get("Responses").get(TABLE_NAME),Array<Dynamic>) ) {
            trace("  " + item.get("title").get("S")
                  + ", " + item.get("year").get("N")
                  + ", " + cast(item.get("categories").get("SS"),Array<Dynamic>).join("/"));
        }
    }

    private function query() {
        var request = {TableName: TABLE_NAME,
                       IndexName: "town-age-index",
                       KeyConditionExpression: "#a = :a",
                       ExpressionAttributeNames: Lib.anonToDict({"#a": "author"}),
                       ExpressionAttributeValues: Lib.anonToDict({":a": Lib.anonAsDict({S: "Neal Stephenson"})})};
        var result = dynamo.query(request);
        trace("query:");
        for( item in cast(result.get("Items"),Array<Dynamic>) ) {
            trace("  " + item.get("title").get("S")
                  + ", " + item.get("year").get("N")
                  + ", " + cast(item.get("categories").get("SS"),Array<Dynamic>).join("/"));
        }
    }

    private function updateTable() {
        var request = {"TableName": TABLE_NAME,
                       "ProvisionedThroughput": Lib.anonToDict({"ReadCapacityUnits": 2, "WriteCapacityUnits": 1})};
        var result = dynamo.updateTable(request);
        trace("updateTable: " + result.get("HTTPStatusCode"));
    }

    private function tagResource() {
        var request = {"ResourceArn": "arn:aws:dynamodb:us-east-1:356409446153:table/" + TABLE_NAME,
                       "Tags": [Lib.anonAsDict({"Key": "tag1", "Value": "testtag"})]};
        dynamo.tagResource(request);
        trace("tagged");
    }

    private function listTagsOfResource() {
        var request = {"ResourceArn": "arn:aws:dynamodb:us-east-1:356409446153:table/" + TABLE_NAME};
        var result = dynamo.listTagsOfResource(request);
        trace("listTagsOfResource: " + result.get("Tags"));
    }

    private function untagResource() {
        var request = {"ResourceArn": "arn:aws:dynamodb:us-east-1:356409446153:table/" + TABLE_NAME,
                       "TagKeys": ["tag1"]};
        dynamo.untagResource(request);
        trace("untagged");
    }

    private function createBackup() {
        var request = {"TableName": TABLE_NAME, "BackupName": TABLE_NAME+"-backup"};
        var result = dynamo.createBackup(request);
        backupArn = result.get("BackupDetails").get("BackupArn");
        trace("createBackup: " + result);
    }

    private function describeBackup() {
        var request = {"BackupArn": backupArn};
        var result = dynamo.describeBackup(request);
        trace("describeBackup: " + result);
    }

    private function describeContinuousBackups() {
        var request = {"TableName": TABLE_NAME};
        var result = dynamo.describeContinuousBackups(request);
        trace("describeContinuousBackups: " + result);
    }

    private function deleteItem() {
        var request = {TableName: TABLE_NAME,
                       Key: Lib.anonToDict({title: Lib.anonToDict({S: "Seveneves"}),
                                            author: Lib.anonToDict({S: "Neal Stephenson"})})};
        var result = dynamo.deleteItem(request);
        trace("delete item: " + result);
    }

    private function listBackups() {
        var date = Datetime.utcnow();
        var result = dynamo.listBackups({"TableName": TABLE_NAME,
                                         "Limit": 2,
                                         "TimeRangeUpperBound": date});
        trace("listBackups: " + result);
    }

    private function restoreTableFromBackup() {
        var result = dynamo.restoreTableFromBackup({"TargetTableName": TABLE_NAME,
                                                    "BackupArn": backupArn});
        trace("restoreTableFromBackup: " + result);
    }

    private function deleteBackup() {
        var result = dynamo.deleteBackup({"BackupArn": backupArn});
        trace("deleteBackup: " + result);
    }

    private function describeTimeToLive() {
        var result = dynamo.describeTimeToLive({"TableName": TABLE_NAME});
        trace("describeTimeToLive: " + result);
    }

    private function updateTTL() {
        var result = dynamo.updateTimeToLive({"TableName": TABLE_NAME,
                                              "TimeToLiveSpecification": Lib.anonToDict({"Enabled": true,
                                                                                         "AttributeName": "ttl"})});
        trace("updateTTL: " + result);
    }

    private function deleteTable() {
        var result = dynamo.deleteTable({"TableName": TABLE_NAME});
        trace("deleteTable: " + result.get("TableDescription").get("TableStatus"));
    }

    private function waitForTableDelete() {
        trace("  waiting for table deletion...");
        var waiter = dynamo.getWaiter("table_not_exists");
        waiter.wait({"TableName": TABLE_NAME});
        trace("  done waiting. table deleted");
    }
}
