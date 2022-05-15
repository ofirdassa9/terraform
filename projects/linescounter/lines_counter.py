import os
import json
import boto3
import uuid

def lambda_handler(event, context):
    try:
        s3 = boto3.client('s3')
        bucket_name = str(event["Records"][0]["s3"]["bucket"]["name"])
        key_name = str(event["Records"][0]["s3"]["object"]["key"])
        obj = s3.get_object(Bucket = bucket_name, Key = key_name)
        body_len = len(obj['Body'].read().decode('utf-8').split("\n"))
        dynamodb = boto3.resource('dynamodb')
        table = dynamodb.Table(os.environ['TABLE_NAME'])
        table.put_item(Item={
            "ID": str(uuid.uuid4()),
            "BucketName": bucket_name,
            "Key": key_name,
            "LinesCount": str(body_len)
        })
    except Exception as err:
        print(err)
    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }