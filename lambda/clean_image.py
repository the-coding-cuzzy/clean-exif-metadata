#!/usr/bin/env python3

from PIL import Image
import logging
import io
import boto3
import os
import time
from pathlib import Path
from botocore.exceptions import ClientError

s3 = boto3.client('s3')
s3_resource = boto3.resource('s3')

logger = logging.getLogger(__name__)


def read_lambda_input(event):
    # Retrieve bucket and object names
    source_bucket = event['Records'][0]['s3']['bucket']['name']
    source_key = event['Records'][0]['s3']['object']['key']

    return source_bucket, source_key


def read_s3_object(bucket, key, stream):
    # Read the S3 object
    try:
        s3_object = s3_resource.Object(bucket, key)
        s3_object.download_fileobj(stream)
        stream.seek(0)
    except Exception as e:
        logger.error(f'error reading S3 object: {e}')
        raise e


def clean_image(stream):
    # Clean image using exif library
    try:
        image = Image.open(stream)
        data = list(image.getdata())
        cleaned_image = Image.new(image.mode, image.size)
        cleaned_image.putdata(data)
        return cleaned_image
    except Exception as e:
        print(f'error cleaning image: {e}')
        logger.error(f'error cleaning image: {e}')
        raise e


def upload_s3_file(bucket, key, content):
    # Upload clean image to S3
    try:
        s3.put_object(Body=content, Bucket=bucket,
                      Key=key, ContentType='image/jpeg')
    except Exception as e:
        logger.error(f'error uploading cleaned image to S3: {e}')
        raise e


def lambda_handler(event, context):
   # Get S3 bucket and key
    source_bucket, source_key = read_lambda_input(event)
    logger.info(f'New file uploaded to {source_bucket}')
    print(f'New file uploaded to {source_bucket}')

    # Read S3 object to stream
    with io.BytesIO() as stream:
        read_s3_object(source_bucket, source_key, stream)

        logger.info(f'Beginning cleaning of image {source_key}')
        print(f'Beginning cleaning of image {source_key}')
        cleaned_image = clean_image(stream)
        print('Successfully cleaned image')

    # Save cleaned image to new stream and get bytes array
    with io.BytesIO() as stream:
        print('Saving cleaned image')
        cleaned_image.save(stream, format='JPEG')
        cleaned_image_content = stream.getvalue()
        logger.info('Image successfully cleaned')
        print('Image successfully cleaned')

    # Upload to S3
    destination_bucket = os.environ['DESTINATION_BUCKET']
    logger.info(f'Uploading cleaned image to new bucket {destination_bucket}')
    print(f'Uploading cleaned image to new bucket {destination_bucket}')
    upload_s3_file(destination_bucket, source_key, cleaned_image_content)
    logger.info('Successfully uploaded cleaned image to new bucket')
    print('Successfully uploaded cleaned image to new bucket')
