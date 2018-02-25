package boto3;

import boto3.Boto3;

import python.Dict;
import python.Lib;
import sys.io.File;

/**
   WARNING these tests access aws!

   we create a client using the default profile, then use it to look up our account id.
 **/
class StsTests {
    /** lambda client made using default session */
    private var sts : STSClient;

    public var accountId(default,null) :String;

    /**
       init session and client objects
     **/
    public function new() {
        sts = Boto3.client("sts");
    }

    /**
       get my aws account id
     **/
    public function run() {
        trace("");
        trace("StsTests");
        getCallerIdentity();
    }

    private function getCallerIdentity() {
        var result = sts.getCallerIdentity();
        accountId = result.get("Account");
        trace("  identity: " + accountId);
    }
}
