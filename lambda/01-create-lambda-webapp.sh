# Set variables
ACCOUNT_ID=426063972414
REGION=us-east-1
FUNCTION_NAME=my-web-app
ROLE_NAME=lambda-basic-role
API_NAME=lambda-http-api

mkdir lambda-webapp && cd lambda-webapp

# Create Lambda code
cat <<EOF > index.js
exports.handler = async (event) => {
    return {
        statusCode: 200,
        headers: { "Content-Type": "text/html" },
        body: "<h1>Hello from AWS Lambda Web App 🚀</h1>"
    };
};
EOF

zip function.zip index.js

# Create IAM trust policy
cat <<EOF > trust-policy.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "Service": "lambda.amazonaws.com" },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

# Create IAM Role
aws iam create-role \
  --role-name $ROLE_NAME \
  --assume-role-policy-document file://trust-policy.json

# Attach logging policy
aws iam attach-role-policy \
  --role-name $ROLE_NAME \
  --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole

# Wait for IAM propagation
sleep 10

# Create Lambda
aws lambda create-function \
  --function-name $FUNCTION_NAME \
  --runtime nodejs18.x \
  --handler index.handler \
  --zip-file fileb://function.zip \
  --role arn:aws:iam::$ACCOUNT_ID:role/$ROLE_NAME \
  --region $REGION

# Create API Gateway (HTTP API)
API_ID=$(aws apigatewayv2 create-api \
  --name "$API_NAME" \
  --protocol-type HTTP \
  --target arn:aws:lambda:$REGION:$ACCOUNT_ID:function:$FUNCTION_NAME \
  --region $REGION \
  --query 'ApiId' --output text)

# Allow API Gateway to invoke Lambda
aws lambda add-permission \
  --function-name $FUNCTION_NAME \
  --statement-id apigateway-invoke \
  --action lambda:InvokeFunction \
  --principal apigateway.amazonaws.com \
  --region $REGION

# Print endpoint
echo "Your API endpoint:"
echo "https://$API_ID.execute-api.$REGION.amazonaws.com"
