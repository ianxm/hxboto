package boto3;

import boto3.Boto3;

import python.Dict;
import python.Lib;
import sys.io.File;
import haxe.Json;
import haxe.io.Bytes;
import haxe.zip.Compress;

/**
   WARNING these tests access aws!

   we create a client using the default profile, then create a function (Greeter), view it, invoke
   it, then delete it.

   if the test function already exists the tests will not run.
 **/
class LambdaTests {
    static var LAMBDA_NAME = "Greeter";
    static var ALIAS_NAME = "Greeter-alias";

    /** lambda client made using default session */
    private var lambda :LambdaClient;

    /** aws account id, looked up in the sts test */
    private var accountId :String;

    /**
       init session and client objects
     **/
    public function new(accountId :String) {
        lambda = Boto3.client("lambda");
        this.accountId = accountId;
    }

    /**
       Books
       properties: title (s), author (n), year (s), categories (ss)
       table: title (hash), author (range)
       index: author (hash), year (range)
     **/
    public function run() {
        trace("");
        trace("LambdaTests");
        getAccountSettings();
        generatePresignedUrl();

        // make sure the test function doesn't already exist
        quitIfTestFunctionExists();

        createFunction();

        listFunctions();
        getFunction();
        getFunctionConfiguration();
        // addPermission(); // not tested
        // getPolicy(); // not tested

        createAlias();
        listAliases();
        getAlias();
        updateAlias();
        deleteAlias();

        // tagResource(); // not tested
        // listTags(); // not tested
        // untagResource(); // not tested

        invoke();

        deleteFunction();
    }

    private function listFunctions() {
        var request = {};
        var result = lambda.listFunctions(request);
        trace("  functions:");
        for( item in cast(result.get("Functions"),Array<Dynamic>) ) {
            trace("    " + item.get("FunctionName") + ", " + item.get("FunctionArn"));
        }
    }

    private function getAccountSettings() {
        var result = lambda.getAccountSettings();
        trace("  account settings: " + result);
    }

    private function generatePresignedUrl() {
        var request = {ClientMethod: "list_functions",
                       Params: Lib.anonToDict({}),
                       ExpiresIn: 60,
                       HttpMethod: "GET"};
        var result = lambda.generatePresignedUrl(request);
        trace("  example presigned url: " + result);
    }

    private function quitIfTestFunctionExists() {
        var request = {FunctionName: LAMBDA_NAME};
        try {
            var result = lambda.getFunction(request);
        } catch (e: ClientError) {
            trace("  no test function, good: " + Type.getClassName(Type.getClass(e)));
        }
    }

    private function createFunction() {
        var fname = "data/greeter.zip";
        var lambdaFile = File.read(fname, true);
        var lambdaZip = lambdaFile.readAll();

        var request = {FunctionName: LAMBDA_NAME,
                       Runtime: "python3.6",
                       Role: 'arn:aws:iam::$accountId:role/lambda_basic_execution',
                       Handler: "greeter.run",
                       Code: Lib.anonToDict({ZipFile: lambdaZip.getData()}),
                       Description: "Test lambda",
                       Timeout: 10,
                       MemorySize: 128};

        var result = lambda.createFunction(request);
        trace("  create function ($LAMBDA_NAME): " + result.get("FunctionArn"));
    }

    private function getFunction() {
        var request = {FunctionName: LAMBDA_NAME};
        var result = lambda.getFunction(request);
        trace("  getFunction: " + result.get("Configuration").get("FunctionName"));
    }

    private function getFunctionConfiguration() {
        var request = {FunctionName: LAMBDA_NAME};
        var result = lambda.getFunctionConfiguration(request);
        trace("  getFunctionConfiguration: " + result.get("FunctionName") + " size: " + result.get("CodeSize"));
    }

    // not tested
    private function getPolicy() {
        var request = {FunctionName: LAMBDA_NAME};
        var result = lambda.getPolicy(request);
        trace("  getPolicy: " + result.get("policy"));
    }

    private function createAlias() {
        var request = {FunctionName: LAMBDA_NAME,
                       Name: ALIAS_NAME,
                       FunctionVersion: "$LATEST",
                       Description: "original description"};
        var result = lambda.createAlias(request);
        trace("  createAlias: " + result.get("Name"));
    }

    private function listAliases() {
        var request = {FunctionName: LAMBDA_NAME};
        var result = lambda.listAliases(request);
        trace("  listAliases: ");
        for( alias in cast(result.get("Aliases"),Array<Dynamic>) ) {
            trace("    " + alias.get("Name"));
        }
    }

    private function getAlias() {
        var request = {FunctionName: LAMBDA_NAME,
                       Name: ALIAS_NAME};
        var result = lambda.getAlias(request);
        trace("  getAlias: " + result.get("Name") + " " + result.get("Description"));
    }

    private function updateAlias() {
        var request = {FunctionName: LAMBDA_NAME,
                       Name: ALIAS_NAME,
                       Description: "updated description"};
        var result = lambda.updateAlias(request);
        trace("  updateAlias: " + result.get("Name") + " " + result.get("Description"));
    }

    private function deleteAlias() {
        var request = {FunctionName: LAMBDA_NAME,
                       Name: ALIAS_NAME};
        lambda.deleteAlias(request);
        trace("  deleteAlias");
    }

    private function tagResource() {
        var request = {Resource: 'arn:aws:lambda:us-east-1:$accountId:function/' + LAMBDA_NAME,
                       Tags: Lib.anonAsDict({tag1: "testtag"})};
        lambda.tagResource(request);
        trace("  tagged");
    }

    private function listTags() {
        var request = {Resource: 'arn:aws:lambda:us-east-1:$accountId:function/' + LAMBDA_NAME};
        var result = lambda.listTags(request);
        trace("  listTagsOfResource: " + result.get("Tags"));
    }

    private function untagResource() {
        var request = {Resource: 'arn:aws:lambda:us-east-1:$accountId:function/' + LAMBDA_NAME,
                       TagKeys: ["tag1"]};
        lambda.untagResource(request);
        trace("  untagged");
    }

    private function invoke() {
        var params = '{"name": "bub"}';
        var request = {FunctionName: LAMBDA_NAME,
                       Payload: Bytes.ofString(params).getData()};
        var response = lambda.invoke(request);
        var responsePayload = response.get("Payload").read();
        trace("  invoked: " + Bytes.ofData(responsePayload).toString());
    }

    private function deleteFunction() {
        var request = {FunctionName: LAMBDA_NAME};
        lambda.deleteFunction(request);
        trace("  deleted function");
    }
}
