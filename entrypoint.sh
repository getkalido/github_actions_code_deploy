#!/bin/sh

set -e

if [ -z "$AWS_S3_BUCKET" ]; then
  echo "AWS_S3_BUCKET is not set. Quitting."
  exit 1
fi

if [ -z "$AWS_ACCESS_KEY_ID" ]; then
  echo "AWS_ACCESS_KEY_ID is not set. Quitting."
  exit 1
fi

if [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
  echo "AWS_SECRET_ACCESS_KEY is not set. Quitting."
  exit 1
fi

if [ -z "$AWS_REGION" ]; then
  echo "AWS_REGION is not set. Quitting."
  exit 1
fi

if [ -z "$AWS_S3_LOCATION_KEY" ]; then
  echo "AWS_S3_LOCATION_KEY is not set. Quitting."
  exit 1
fi

if [ -z "$AWS_S3_BUNDLE_TYPE" ]; then
  echo "AWS_S3_BUNDLE_TYPE is not set. Quitting."
  exit 1
fi

if [ -z "$AWS_DEPLOYMENT_GROUP_NAME" ]; then
  echo "AWS_DEPLOYMENT_GROUP_NAME is not set. Quitting."
  exit 1
fi

if [ -z "$AWS_APPLICATION_NAME" ]; then
  echo "AWS_APPLICATION_NAME is not set. Quitting."
  exit 1
fi
  
# Create a dedicated profile for this action to avoid
# conflicts with other actions.
# https://github.com/jakejarvis/s3-sync-action/issues/1
aws configure --profile code-deploy-action <<-EOF > /dev/null 2>&1
${AWS_ACCESS_KEY_ID}
${AWS_SECRET_ACCESS_KEY}
${AWS_REGION}
text
EOF

aws deploy create-deployment --profile code-deploy-action \
              --application-name ${AWS_APPLICATION_NAME} \
              --deployment-group-name ${AWS_DEPLOYMENT_GROUP_NAME} \
              --s3-location bucket=${AWS_S3_BUCKET},bundleType=${AWS_S3_BUNDLE_TYPE},key=${AWS_S3_LOCATION_KEY} >> out.json
              
if [ -z "$WAIT_FOR_BUILD" ]; then
  exit 0
fi

export DEPLOY_ID=`head -2 out.json | tail -1 | cut -f4 -d\"`

aws deploy wait deployment-successful --deployment-id $DEPLOY_ID
