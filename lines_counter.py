import os
import json
import boto3
import uuid
import pymysql

def lambda_handler(event, context):
    try:
        s3 = boto3.client('s3')
        bucket_name = str(event["Records"][0]["s3"]["bucket"]["name"])
        key_name = str(event["Records"][0]["s3"]["object"]["key"])
        obj = s3.get_object(Bucket = bucket_name, Key = key_name)
        body_len = len(obj['Body'].read().decode('utf-8').split("\n"))
        print(bucket_name, key_name, body_len)
        mydb = pymysql.connect(
            host=os.environ["END_POINT"],
            user=os.environ["USER_NAME"],
            password=os.environ["PASSOWRD"],
            database=os.environ["DB_NAME"]
        )
        cur = mydb.cursor()
        sql = "CREATE TABLE IF NOT EXISTS " + os.environ["TABLE_NAME"] + """
        ID VARCHAR(50),
        BucketName VARCHAR(50),
        Key VARCHAR(50),
        LinesCount VARCHAR(50);
        """
        cur.execute(sql)
        sql = "INSERT INTO " + os.environ["TABLE_NAME"] + " (ID, BucketName, Key, LinesCount) VALUES (%s, %s, %s, %s)"
        val = (str(uuid.uuid4()), bucket_name, key_name, body_len)
        cur.execute(sql, val)
        mydb.commit()
        sql = "SELECT * FROM " + os.environ["TABLE_NAME"]
        print(cur.execute(sql))
        print(cur.rowcount, "record inserted.")
    except Exception as err:
        print(err)
    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }