import boto3

def lambda_handler(event, context):
    # Create an S3 client
    s3 = boto3.client('s3')
    
    # List all S3 buckets
    response = s3.list_buckets()
    
    # Get the list of bucket names
    buckets = [bucket['Name'] for bucket in response['Buckets']]
    
    # Log the bucket names
    print("S3 Buckets:")
    for bucket in buckets:
        print(bucket)
    
    # Return the list of bucket names
    return {
        'statusCode': 200,
        'body': buckets
    }
