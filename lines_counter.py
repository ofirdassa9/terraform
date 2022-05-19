import os
import json
import boto3
import uuid
import pymysql

def lambda_handler(event, context):
    try:
        table_name = os.environ["TABLE_NAME"]
        bucket_name = str(event["Records"][0]["s3"]["bucket"]["name"])
        key_name = str(event["Records"][0]["s3"]["object"]["key"])
        s3 = boto3.client('s3')
        # ~~~~~~works localy~~~~~~
        # session = boto3.Session(profile_name='personal')
        # s3 = session.resource('s3')
        # body_len = len(s3.Object(bucket_name, key_name).get()['Body'].read().decode('utf-8').split("\n"))
        # print(body_len)
        # ~~~~~~works localy~~~~~~
        # session = boto3.Session(profile_name='personal')
        # s3 = session.client('s3')
        # obj = s3.get_object(Bucket=bucket_name, Key=key_name)
        # body_len = len(obj['Body'].read().decode('utf-8').split("\n"))
        # print(type(body_len))
        # ~~~~~~works~~~~~~
        body_len = 30
        print(bucket_name, key_name, body_len)
        mydb = pymysql.connect(
            host=os.environ["DB_ENDPOINT"],
            user=os.environ["USERNAME"],
            password=os.environ["PASSWORD"],
            database=os.environ["DB_NAME"]
        )
        cur = mydb.cursor()
        sql = f"CREATE TABLE IF NOT EXISTS {table_name} (ID VARCHAR(50), BucketName VARCHAR(50), FileName VARCHAR(50), LinesCount VARCHAR(50));"
        print(f"QUERY: {sql}")
        cur.execute(sql)
        print(f"Created table {table_name}")
        sql = f"INSERT INTO {table_name} (ID, BucketName, FileName, LinesCount) VALUES (%s, %s, %s, %s)"
        val = (str(uuid.uuid4()), bucket_name, key_name, body_len)
        print(f"QUERY: {sql} VARS: {val}")
        cur.execute(sql, val)
        print(f"inserted data {bucket_name} {key_name} {body_len}")
        mydb.commit()
        cur.execute(f'SELECT * FROM {table_name}')
        rows = cur.fetchall()
        for row in rows:
            print(f"{row[0]} {row[1]} {row[2]} {row[3]}")
        mydb.close()
    except Exception as err:
        print(err.args)
    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }