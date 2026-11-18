import boto3
import urllib.parse

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('backup-log')


def lambda_handler(event, context):
    for record in event['Records']:
        bucket = record['s3']['bucket']['name']
        object_key = urllib.parse.unquote_plus(
            record['s3']['object']['key']
        )

        if not object_key.startswith('backups/'):
            continue

        backup_id = object_key
        event_time = record['eventTime']
        event_name = record['eventName']

        table.put_item(
            Item={
                'backup_id': backup_id,
                'bucket': bucket,
                'object_key': object_key,
                'event_time': event_time,
                'event_name': event_name
            }
        )

        print(f"Backup logged: {object_key}")

    return {
        'statusCode': 200,
        'body': 'Backup event processed successfully'
    }
