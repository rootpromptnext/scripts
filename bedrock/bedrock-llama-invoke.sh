cat <<'EOF' > bedrock-test.sh
#!/bin/bash

REGION=us-east-1
MODEL_ID=meta.llama3-8b-instruct-v1:0

# Create request payload
cat <<EOT > request.json
{
  "prompt": "Explain Kubernetes in 3 simple lines",
  "max_gen_len": 200,
  "temperature": 0.7
}
EOT

# Call Bedrock
aws bedrock-runtime invoke-model \
  --region $REGION \
  --model-id $MODEL_ID \
  --content-type application/json \
  --accept application/json \
  --body fileb://request.json \
  response.json

cat response.json
EOF
