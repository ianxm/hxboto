package boto3;

import haxe.extern.EitherType;
import haxe.io.BytesData;
import python.KwArgs;
import python.Dict;
import python.lib.datetime.Datetime;

/**
   this is the main entry point.
   start by either getting a client here or getting a session and then a client.
**/
@:pythonImport("boto3")
@:native("boto3")
extern class Boto3 {
    static function client(service_name :String, ?options :KwArgs<Boto3ClientOptions>) :Dynamic;

    // @:native("get_paginator")
    // static function getPaginator(name :String) :EitherType<ListTablesPaginator,EitherType<QueryPaginator,ScanPaginator>>;

    @:native("get_waiter")
    static function getWaiter(name :String) :Waiter;

    @:native("session.Session")
    static function session(?options :KwArgs<Boto3SessionOptions>) :Session;
}

/**
   this is for creating clients using custom sessions
**/
@:native("boto3.session.Session")
extern class Session {
    @:native("available_profiles")
    var availableProfiles :List<String>;

    function client(service_name :String, ?options :KwArgs<SessionClientOptions>) :DynamoDBClient;

    @:native("get_available_partitions")
    function getAvailablePartitions() :List<String>;

    @:native("get_available_regions")
    function getAvailableRegions(serviceName :String, partitionName :String, allowNonRegional :Bool) :List<String>;

    @:native("get_available_services")
    function getAvailableServices() :List<String>;

    @:native("get_credentials")
    function getCredentials() :Credentials;

    @:native("profile_name")
    var profileName :String;

    @:native("region_name")
    var regionName :String;
}

typedef Boto3SessionOptions = {
    @:native("aws_access_key_id")
    @:optional var awsAccessKeyId :String;

    @:native("aws_secret_access_key_id")
    @:optional var awsSecretAccessKeyId :String;

    @:native("aws_session_token")
    @:optional var awsSessionToken :String;

    @:native("region_name")
    @:optional var regionName :String;

    @:native("botocore_session")
    @:optional var botocoreSession :Session;

    @:native("profile_name")
    @:optional var profileName :String;
}

typedef SessionClientOptions = {
    @:native("service_name")
    @:optional var serviceName :String;

    @:native("region_name")
    @:optional var regionName :String;

    @:native("api_version")
    @:optional var apiVersion :String;

    @:native("use_ssl")
    @:optional var useSsl :Bool;

    @:native("verify")
    @:optional var verify :EitherType<Bool,String>;

    @:native("endpoint_url")
    @:optional var endpointUrl :String;

    @:native("aws_access_key_id")
    @:optional var awsAccessKeyId :String;

    @:native("aws_secret_access_key_id")
    @:optional var awsSecretAccessKeyId :String;

    @:native("aws_session_token")
    @:optional var awsSessionToken :String;
}

/**
   credentials class
**/
// @:pythonImport("botocore.credentials")
// @:native("botocore.credentials.Credentials")
extern class Credentials {
}

@:pythonImport("botocore.exceptions", "ClientError")
extern class ClientError {
    var response :Dict<String,Dynamic>;
}

/**
   paginators are not supported
**/

// @:native("DynamoDB.Paginator.ListTables")
// extern class ListTablesPaginator {
//     function paginate(options :KwArgs<PaginatedListTablesOptions>) :Dict<String,Dynamic>;
// }
// @:native("DynamoDB.Paginator.Query")
// extern class QueryPaginator {
//     function paginate(options :KwArgs<PaginatedQueryOptions>) :Dict<String,Dynamic>;
// }
// @:native("DynamoDB.Paginator.Scan")
// extern class ScanPaginator {
//     function paginate(options :KwArgs<PaginatedScanOptions>) :Dict<String,Dynamic>;
// }

/**
   these classes define waiters
   using this class for either DynamoDB.Waiter.TableExists or DynamoDB.Waiter.TableNotExists
**/
extern class Waiter {
    function wait(options :KwArgs<WaitOptions>) :Void;
}

typedef WaitOptions = {
    var TableName :String;
    @:optional var WaiterConfig :Dict<String,Int>;
}


/**
   this is the main dynamo low level client interface.
**/
@:native("DynamoDB.Client")
extern class DynamoDBClient {
    @:native("batch_get_item")
    function batchGetItem(options :KwArgs<BatchGetItemOptions>) :Dict<String,Dynamic>;

    @:native("batch_write_item")
    function batchWriteItem(options :KwArgs<BatchWriteItemOptions>) :Dict<String,Dynamic>;

    // @:native("can_paginate")
    // function canPaginate(operation :String) :Dict<String,Dynamic>;

    @:native("create_backup")
    function createBackup(options :KwArgs<CreateBackupOptions>) :Dict<String,Dynamic>;

    @:native("create_global_table")
    function createGlobalTable(options :KwArgs<CreateGlobalTableOptions>) :Dict<String,Dynamic>;

    @:native("create_table")
    function createTable(options :KwArgs<CreateTableOptions>) :Dict<String,Dynamic>;

    @:native("delete_backup")
    function deleteBackup(options :KwArgs<DeleteBackupOptions>) :Dict<String,Dynamic>;

    @:native("delete_item")
    function deleteItem(options :KwArgs<DeleteItemOptions>) :Dict<String,Dynamic>;

    @:native("delete_table")
    function deleteTable(options :KwArgs<DeleteTableOptions>) :Dict<String,Dynamic>;

    @:native("describe_backup")
    function describeBackup(options :KwArgs<DescribeBackupOptions>) :Dict<String,Dynamic>;

    @:native("describe_continuous_backups")
    function describeContinuousBackups(options :KwArgs<DescribeContinuousBackupsOptions>) :Dict<String,Dynamic>;

    @:native("describe_limits")
    function describeLimits() :Dict<String,Dynamic>;

    @:native("describe_table")
    function describeTable(options :KwArgs<DescribeTableOptions>) :Dict<String,Dynamic>;

    @:native("describe_time_to_live")
    function describeTimeToLive(options :KwArgs<DescribeTimeToLiveOptions>) :Dict<String,Dynamic>;

    @:native("generate_presigned_url")
    function generatePresignedUrl(options :KwArgs<GeneratePresignedUrlOptions>) :String;

    @:native("get_item")
    function getItem(options :KwArgs<GetItemOptions>) :Dict<String,Dynamic>;

    // @:native("get_paginator")
    // function getPaginator(operation :String) :EitherType<ListTablesPaginator,EitherType<QueryPaginator,ScanPaginator>>;

    @:native("get_waiter")
    function getWaiter(waiterName :String) :Waiter;

    @:native("list_backups")
    function listBackups(options :KwArgs<ListBackupsOptions>) :Dict<String,Dynamic>;

    @:native("list_global_tables")
    function listGlobalTables(options :KwArgs<ListGlobalTablesOptions>) :Dict<String,Dynamic>;

    @:native("list_tables")
    function listTables(options :KwArgs<ListTablesOptions>) :Dict<String,Dynamic>;

    @:native("list_tags_of_resource")
    function listTagsOfResource(options :KwArgs<ListTagsOfResourceOptions>) :Dict<String,Dynamic>;

    @:native("put_item")
    function putItem(options :KwArgs<PutItemOptions>) :Dict<String,Dynamic>;

    function query(options :KwArgs<QueryOptions>) :Dict<String,Dynamic>;

    @:native("restore_table_from_backup")
    function restoreTableFromBackup(options :KwArgs<RestoreTableFromBackupOptions>) :Dict<String,Dynamic>;

    function scan(options :KwArgs<ScanOptions>) :Dict<String,Dynamic>;

    @:native("tag_resource")
    function tagResource(options :KwArgs<TagResourceOptions>) :Void;

    @:native("untag_resource")
    function untagResource(options :KwArgs<UntagResourceOptions>) :Void;

    @:native("update_global_table")
    function updateGlobalTable(options :KwArgs<UpdateGlobalTableOptions>) :Dict<String,Dynamic>;

    @:native("update_item")
    function updateItem(options :KwArgs<UpdateItemOptions>) :Dict<String,Dynamic>;

    @:native("update_table")
    function updateTable(options :KwArgs<UpdateTableOptions>) :Dict<String,Dynamic>;

    @:native("update_time_to_live")
    function updateTimeToLive(options :KwArgs<UpdateTimeToLiveOptions>) :Dict<String,Dynamic>;
}

/**
   these types are used for method parameters
**/

typedef Boto3ClientOptions = {
    @:optional var region_name :String;
    @:optional var api_version :String;
    @:optional var use_ssl :Bool;
}

typedef BatchGetItemOptions = {
    var RequestItems :Dict<String,Array<BatchGetItemElement>>;
    @:optional var ConsistentRead :Bool;
    @:optional var ReturnConsumedCapacity :String;
}

typedef BatchGetItemElement = {
    @:optional var ConsistentRead :Bool;
    @:optional var ExpressionAttributeNames :Dict<String,Dynamic>;
    @:optional var Keys :Dict<String,Dynamic>;
    @:optional var ProjectionExpression :String;
}

typedef BatchWriteItemOptions = {
    var RequestItems :Dict<String,Array<Dict<String,EitherType<BatchWritePutElement,BatchWriteDeleteElement>>>>;
    @:optional var ReturnConsumedCapacity :String;
    @:optional var ReturnItemCollectionMetrics :String;
}

typedef BatchWritePutElement = {
    var Item :Dict<String,Dynamic>;
}

typedef BatchWriteDeleteElement = {
    var Key :Dict<String,Dynamic>;
}

typedef CreateBackupOptions = {
    var TableName :String;
    var BackupName :String;
}

typedef CreateGlobalTableOptions = {
    var GlobalTableName :String;
    var ReplicationGroup :Array<Dict<String,String>>; // {RegionName:string}
}

typedef CreateTableOptions = {
    var AttributeDefinitions :Array<Dict<String,String>>; // {AttributeName:string, AttributeType:string}
    var TableName :String;
    var KeySchema :Array<Dict<String,String>>; // {AttributeName:string,KeyType:string}
    @:optional var LocalSecondaryIndexes :Array<Dict<String,Dynamic>>;
    @:optional var GlobalSecondaryIndexes :Array<Dict<String,Dynamic>>;
    var ProvisionedThroughput :Dict<String,Int>;
    @:optional var StreamSpecification :Dict<String,EitherType<Bool,String>>;
}

typedef DeleteBackupOptions = {
    var BackupArn :String;
}

typedef DeleteItemOptions = {
    var TableName :String;
    var Key :Dict<String,Dynamic>;
    @:optional var ReturnValues :String;
    @:optional var ReturnConsumedCapacity :String;
    @:optional var ReturnItemCollectionMetrics :String;
    @:optional var ExpressionAttributeNames :Dict<String,Dynamic>;
    @:optional var ExpressionAttributeValues :Dict<String,Dynamic>;
}

typedef DeleteTableOptions = {
    var TableName :String;
}

typedef DescribeBackupOptions = {
    var BackupArn :String;
}

typedef DescribeContinuousBackupsOptions = {
    var TableName :String;
}

typedef DescribeTableOptions = {
    var TableName :String;
}

typedef DescribeTimeToLiveOptions = {
    var TableName :String;
}

typedef GeneratePresignedUrlOptions = {
    var ClientMethod :String;
    var Params :Dict<String,String>;
    var ExpiresIn :Int;
    var HttpMethod :String;
}

typedef GetItemOptions = {
    var TableName :String;
    @:optional var Key :Dict<String,Dynamic>;
    @:optional var ConsistentRead :Bool;
    @:optional var ReturnConsumedCapacity :String;
    @:optional var ProjectionExpression :String;
    @:optional var ExpressionAttributeNames :Dict<String,Dynamic>;
}

typedef ListBackupsOptions = {
    @:optional var TableName :String;
    @:optional var Limit :Int;
    @:optional var TimeRangeLowerBound :Datetime;
    @:optional var TimeRangeUpperBound :Datetime;
    @:optional var ExclusiveStartBackupArn :String;
}

typedef ListGlobalTablesOptions = {
    @:optional var ExclusiveStartGlobalTableName :String;
    @:optional var Limit :Int;
    @:optional var RegionName :String;
}

typedef ListTablesOptions = {
    @:optional var ExclusiveStartTableName :String;
    @:optional var Limit :Int;
}

// typedef PaginatedListTablesOptions = {
//     @:optional var PaginationConfig :Dict<String,EitherType<Int,String>>;
// }

typedef ListTagsOfResourceOptions = {
    var ResourceArn :String;
    @:optional var NextToken :String;
}

typedef PutItemOptions = {
    var TableName :String;
    var Item :Dict<String,Dynamic>;
    @:optional var ReturnValues :String;
    @:optional var ReturnConsumedCapacity :String;
    @:optional var ReturnItemCollectionMetrics :String;
    @:optional var ConditionalExpression :String;
    @:optional var ExpressionAttributeNames :Dict<String,Dynamic>;
    @:optional var ExpressionAttributeValues :Dict<String,Dynamic>;
}

typedef RestoreTableFromBackupOptions = {
    var TargetTableName :String;
    var BackupArn :String;
}

typedef QueryOptions = {
    var TableName :String;
    @:optional var IndexName :String;
    @:optional var Select :String;
    @:optional var Limit :Int;
    @:optional var ConsistentRead :Bool;
    @:optional var ScanIndexForward :Bool;
    @:optional var ExclusiveStartKey :Dict<String,Dynamic>;
    @:optional var ReturnConsumedCapacity :String;
    @:optional var ProjectionExpression :String;
    @:optional var FilterExpression :String;
    @:optional var KeyConditionExpression :String;
    @:optional var ExpressionAttributeNames :Dict<String,Dynamic>;
    @:optional var ExpressionAttributeValues :Dict<String,Dynamic>;
}

// typedef PaginatedQueryOptions = {
//     var TableName :String;
//     @:optional var IndexName :String;
//     @:optional var Select :String;
//     @:optional var ConsistentRead :Bool;
//     @:optional var ScanIndexForward :Bool;
//     @:optional var ReturnConsumedCapacity :String;
//     @:optional var ProjectionExpression :String;
//     @:optional var FilterExpression :String;
//     @:optional var KeyConditionExpression :String;
//     @:optional var ExpressionAttributeNames :Dict<String,Dynamic>;
//     @:optional var ExpressionAttributeValues :Dict<String,Dynamic>;
//     @:optional var PaginationConfig :Dict<String,EitherType<Int,String>>;
// }

typedef ScanOptions = {
    var TableName :String;
    @:optional var IndexName :String;
    @:optional var Limit :Int;
    @:optional var Select :Bool;
    @:optional var ExclusiveStartKey :Dict<String,Dynamic>;
    @:optional var ReturnConsumedCapacity :String;
    @:optional var TotalSegments :Int;
    @:optional var Segment :Int;
    @:optional var ProjectionExpression :String;
    @:optional var FilterExpression :String;
    @:optional var ExpressionAttributeNames :Dict<String,Dynamic>;
    @:optional var ExpressionAttributeValues :Dict<String,Dynamic>;
    @:optional var ConsistentRead :Bool;
}

// typedef PaginatedScanOptions = {
//     var TableName :String;
//     @:optional var IndexName :String;
//     @:optional var Select :Bool;
//     @:optional var ReturnConsumedCapacity :String;
//     @:optional var TotalSegments :Int;
//     @:optional var Segment :Int;
//     @:optional var ProjectionExpression :String;
//     @:optional var FilterExpression :String;
//     @:optional var ExpressionAttributeNames :Dict<String,Dynamic>;
//     @:optional var ExpressionAttributeValues :Dict<String,Dynamic>;
//     @:optional var ConsistentRead :Bool;
//     @:optional var PaginationConfig :Dict<String,EitherType<Int,String>>;
// }

typedef TagResourceOptions = {
    var ResourceArn :String;
    var Tags :Array<Dict<String,String>>;
}

typedef UntagResourceOptions = {
    var ResourceArn :String;
    var TagKeys :Array<String>;
}

typedef UpdateGlobalTableOptions = {
    var GlobalTableName :String;
    var ReplicatUpdates :Array<Dict<String,Dict<String,String>>>;
}

typedef UpdateItemOptions = {
    var TableName :String;
    var Key :Dict<String,Dynamic>;
    @:optional var ReturnValues :String;
    @:optional var ReturnConsumedCapacity :String;
    @:optional var ReturnItemCollectionMetrics :String;
    @:optional var UpdateExpression :String;
    @:optional var ConditionExpression :String;
    @:optional var ExpressionAttributeNames :Dict<String,Dynamic>;
    @:optional var ExpressionAttributeValues :Dict<String,Dynamic>;
}

typedef UpdateTableOptions = {
    @:optional var AttributeDefinitions :Array<Dict<String,String>>;
    var TableName :String;
    @:optional var ProvisionedThroughput :Dict<String,Int>;
    @:optional var GlobalSecondaryIndexUpdates :Array<Dict<String,EitherType<EitherType<UpdateTableUpdateGSI,UpdateTableCreateGSI>,UpdateTableDeleteGSI>>>;
    @:optional var StreamSpecification :Dict<String,EitherType<Bool,String>>;
}

typedef UpdateTableUpdateGSI = {
    var IndexName :String;
    var ProvisionedThroughput :Dict<String,Int>;
}

typedef UpdateTableCreateGSI = {
    var IndexName :String;
    var KeySchema :Array<Dict<String,String>>;
    var Projection :Dict<String,EitherType<String,Array<String>>>;
    var ProvisionedThroughput :Dict<String,Int>;
}

typedef UpdateTableDeleteGSI = {
    var IndexName :String;
}

typedef UpdateTimeToLiveOptions = {
    var TableName :String;
    var TimeToLiveSpecification :Dict<String,EitherType<Bool,String>>;
}

/**
   this is the main lambda low level client interface.
**/
@:native("Lambda.Client")
extern class LambdaClient {
    @:native("add_permission")
    function addPermission(options :KwArgs<AddPermissionOptions>) :Dict<String,String>;

    @:native("can_paginate")
    function canPaginate(operationName :String) :Void;

    @:native("create_alias")
    function createAlias(options :KwArgs<CreateAliasOptions>) :Dict<String,Dynamic>;

    @:native("create_function")
    function createFunction(options :KwArgs<CreateFunctionOptions>) :Dict<String,Dynamic>;

    @:native("delete_alias")
    function deleteAlias(options :KwArgs<DeleteAliasOptions>) :Void;

    @:native("delete_function")
    function deleteFunction(options :KwArgs<DeleteFunctionOptions>) :Void;

    @:native("generate_presigned_url")
    function generatePresignedUrl(options :KwArgs<GeneratePresignedUrlOptions>) :String;

    @:native("get_account_settings")
    function getAccountSettings() :Dict<String,Dynamic>;

    @:native("get_alias")
    function getAlias(options :KwArgs<GetAliasOptions>) :Dict<String,Dynamic>;

    @:native("get_function")
    function getFunction(options :KwArgs<GetFunctionOptions>) :Dict<String,Dynamic>;

    @:native("get_function_configuration")
    function getFunctionConfiguration(options :KwArgs<GetFunctionOptions>) :Dict<String,Dynamic>;

    @:native("get_waiter")
    function getWaiter(waiterName :String) :Waiter;

    @:native("get_policy")
    function getPolicy(options :KwArgs<GetPolicyOptions>) :Dict<String,Dynamic>;

    @:native("invoke")
    function invoke(options :KwArgs<InvokeOptions>) :Dict<String,Dynamic>;

    @:native("list_aliases")
    function listAliases(options :KwArgs<ListAliasesOptions>) :Dict<String,Dynamic>;

    @:native("list_functions")
    function listFunctions(options :KwArgs<ListFunctionsOptions>) :Dict<String,Dynamic>;

    @:native("list_versions_by_function")
    function listVersionsByFunction(options :KwArgs<ListVersionsByFunctionOptions>) :Dict<String,Dynamic>;

    @:native("list_tags")
    function listTags(options :KwArgs<ListTagsOptions>) :Dict<String,Dynamic>;

    @:native("remove_permission")
    function removePermission(options :KwArgs<RemovePermissionOptions>) :Void;

    @:native("tag_resource")
    function tagResource(options :KwArgs<TagResourceLambdaOptions>) :Void;

    @:native("untag_resource")
    function untagResource(options :KwArgs<UntagResourceLambdaOptions>) :Void;

    @:native("update_alias")
    function updateAlias(options :KwArgs<UpdateAliasOptions>) :Dict<String,Dynamic>;
}

typedef AddPermissionOptions = {
    var FunctionName :String;
    var StatementId :String;
    var Action :String;
    var Principal :String;
    @:optional var SourceArn :String;
    @:optional var SourceAccount :String;
    @:optional var EventSourceToken :String;
    @:optional var Qualifier :String;
    @:optional var RevisionId :String;
}

typedef CreateAliasOptions = {
    var FunctionName :String;
    var Name :String;
    var FunctionVersion :String;
    @:optional var Description :String;
    @:optional var RoutingConfig :Dict<String,Dynamic>;
}

typedef CreateFunctionOptions = {
    var FunctionName :String;
    var Runtime :String;
    var Role :String;
    var Handler :String;
    var Code :Dict<String,Dynamic>;
    @:optional var Description :String;
    @:optional var Timeout :Int;
    @:optional var MemorySize :Int;
    @:optional var Publish :Bool;
    @:optional var VpcConfig :Dict<String,Dynamic>;
    @:optional var DeadLetterConfig :Dict<String,String>;
    @:optional var Environment :Dict<String,Dict<String,String>>;
    @:optional var KMSKeyArn :String;
    @:optional var TracingConfig :Dict<String,String>;
    @:optional var Tags :Dict<String,String>;
}

typedef DeleteAliasOptions = {
    var FunctionName :String;
    var Name :String;
}

typedef DeleteFunctionOptions = {
    var FunctionName :String;
    @:optional var Qualifier :String;
}

typedef GetAliasOptions = {
    var FunctionName :String;
    var Name :String;
}

typedef GetFunctionOptions = {
    var FunctionName :String;
    @:optional var Qualifier :String;
}

typedef GetPolicyOptions = {
    var FunctionName :String;
    @:optional var Qualifier :String;
}

typedef InvokeOptions = {
    var FunctionName :String;
    @:optional var InvocationType :String;
    @:optional var LogType :String;
    @:optional var ClientContext :String;
    @:optional var Payload :BytesData;
    @:optional var Qualifier :String;
}

typedef ListAliasesOptions = {
    var FunctionName :String;
    @:optional var FunctionVersion :String;
    @:optional var Marker :String;
    @:optional var MaxItems :Int;
}

typedef ListFunctionsOptions = {
    @:optional var MasterRegion :String;
    @:optional var FunctionVersion :String;
    @:optional var Marker :String;
    @:optional var MaxItems :Int;
}

typedef ListVersionsByFunctionOptions = {
    var FunctionName :String;
    @:optional var Marker :String;
    @:optional var MaxItems :Int;
}

typedef ListTagsOptions = {
    var Resource :String;
}

typedef RemovePermissionOptions = {
    var FunctionName :String;
    var StatementId :String;
    @:optional var Qualifier :String;
    @:optional var RevisionId :String;
}

typedef TagResourceLambdaOptions = {
    var Resource :String;
    var Tags :Dict<String,String>;
}

typedef UntagResourceLambdaOptions = {
    var Resource :String;
    var TagKeys :Array<String>;
}

typedef UpdateAliasOptions = {
    var FunctionName :String;
    var Name :String;
    @:optional var FunctionVersion :String;
    @:optional var Description :String;
    @:optional var RoutingConfig :Dict<String,Dynamic>;
    @:optional var RevisionId :String;
}

/**
   this is the main sts low level client interface.
**/
@:native("STS.Client")
extern class STSClient {
    @:native("get_caller_identity")
    function getCallerIdentity() :Dict<String,String>;
}
