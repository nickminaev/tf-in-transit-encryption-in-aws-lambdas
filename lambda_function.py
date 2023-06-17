import boto3
import botocore
import os
import base64

SECRET = 'SECRET'
AWS_LAMBDA_FUNCTION_NAME = 'AWS_LAMBDA_FUNCTION_NAME'
LAMBDA_FUNCTION_NAME = "LambdaFunctionName"

def decrypt_key(os_env_key_name, kms_client):
    raw_cipher_text = os.environ.get(os_env_key_name)
    aws_function_name = os.environ.get(AWS_LAMBDA_FUNCTION_NAME)
    if raw_cipher_text is None:
        return "error", "Could not get the environment variable"
    try:
        ciphertext=base64.b64decode(raw_cipher_text.encode()) # encode to UTF-8
        response = kms_client.decrypt(CiphertextBlob=ciphertext,
                                           EncryptionContext = {
                                             LAMBDA_FUNCTION_NAME:aws_function_name
                                           })
        if 'Plaintext' in response:
            plain_text = response['Plaintext']
            return "OK", plain_text
        return "error", "There's no plain text in the response."
    except botocore.exceptions.ClientError as error:
        return "error", str(error)

def handler(event, context):
    response_body = 'the key was decrypted successfully'
    response_status_code = 200
    kms_client = boto3.client('kms')
    decryption_result, decryption_response = decrypt_key(SECRET, kms_client)
    if decryption_result == "error":
        response_body = decryption_response
        response_status_code = 400
    return {
        'body': response_body,
        'headers': {'Content-Type': 'application/json'},
        'statusCode': response_status_code,
    }