from datetime import datetime, timedelta, date
from dateutil.tz import tzutc, UTC
import boto3
import os
import pymysql

try:
    mydb = pymysql.connect(
        host=os.environ["DB_ENDPOINT"],
        user=os.environ["USERNAME"],
        password=os.environ["PASSWORD"],
        database=os.environ["DB_NAME"]
    )
    session = boto3.Session(
        aws_access_key_id=os.environ["AWS_ACCESS_KEY_ID"],
        aws_secret_access_key=os.environ["AWS_SECRET_ACCESS_KEY"]
    )
    s3 = session.resource('s3')
    bucket_name = os.environ["BUCKET_NAME"]
    table_name = os.environ["TABLE_NAME"]
    run_date = str(date.today())
    bucket = s3.Bucket(bucket_name)
    for object in bucket.objects.all():
        words_count = 0
        if object.last_modified > datetime.now(tzutc()) - timedelta(hours = 24):
            words_count = words_count + len(object.get()['Body'].read().decode('utf-8').split())
            print(f"{bucket_name}/{object.key} {run_date} {words_count}")
        print(f"the word count of {object.key} is {words_count}")
        cur = mydb.cursor()
        sql = f"CREATE TABLE IF NOT EXISTS {table_name} (ObjectPath VARCHAR(50), Date DATE, AmountOfWords INT(50));"
        print(f"QUERY: {sql}")
        cur.execute(sql)
        print(f"Created table {table_name}")
        sql = f"INSERT INTO {table_name} (ObjectPath, Date, AmountOfWords) VALUES (%s, %s, %s)"
        val = (f"{bucket_name}/{object.key}", run_date, words_count)
        print(f"QUERY: {sql} VARS: {val}")
        cur.execute(sql, val)
        print(f"inserted data {bucket_name}/{object.key} {run_date} {words_count}")
        mydb.commit()
except Exception as err:
    print(err.args)