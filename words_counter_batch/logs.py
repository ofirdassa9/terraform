from elasticsearch import Elasticsearch
from datetime import datetime
import uuid

def counter_log(bucket_name, words_count, object):
    try:
        es = Elasticsearch('http://elasticsearch-master.default:9200')
        doc = {
            'level': 'INFO',
            'timestamp': round(datetime.now().timestamp())*1000,
            'file_path': f'{bucket_name}/{object.key}',
            'words_cound': words_count,
            'file_size': object.get()['ContentLength'],
        }
        es.index(index="words-counter-batch", id=str(uuid.uuid4()), document=doc)
    except Exception as err:
        print(err.args)

def log(text):
    try:
        es = Elasticsearch('http://elasticsearch-master.default:9200')
        doc = {
            'level': 'INFO',
            'timestamp': round(datetime.now().timestamp())*1000,
            'message': text,
        }
        es.index(index="script-logs", id=str(uuid.uuid4()), document=doc)
    except Exception as err:
        print(err.args)