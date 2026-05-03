# Set variables
ACCOUNT_ID=426063972414
REGION=us-east-1
FUNCTION_NAME=my-web-app
ROLE_NAME=lambda-basic-role
API_NAME=lambda-http-api

# Get API ID
API_ID=$(aws apigatewayv2 get-apis --region $REGION \
  --query "Items[?Name=='$API_NAME'].ApiId" --output text)

# Delete API Gateway
if [ ! -z "$API_ID" ]; then
  aws apigatewayv2 delete-api --api-id $API_ID --region $REGION
fi

# Remove Lambda permission (ignore error if not exists)
aws lambda remove-permission \
  --function-name $FUNCTION_NAME \
  --statement-id apigateway-invoke \
  --region $REGION 2>/dev/null

# Delete Lambda function
aws lambda delete-function \
  --function-name $FUNCTION_NAME \
  --region $REGION

# Detach IAM policy
aws iam detach-role-policy \
  --role-name $ROLE_NAME \
  --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole

# Delete IAM role
aws iam delete-role \
  --role-name $ROLE_NAME

# Cleanup local files
rm -rf lambda-webapp
