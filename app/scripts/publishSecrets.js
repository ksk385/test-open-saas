const fs = require('fs');
const dotenv = require('dotenv');
const AWS = require('aws-sdk');

// Load environment variables from .env file
dotenv.config({ path: '../.env.server.prod' });

// AWS credentials and region
const awsAccessKeyId = process.env.AWS_S3_IAM_ACCESS_KEY;
const awsSecretAccessKey = process.env.AWS_S3_IAM_SECRET_KEY;
const awsRegion = process.env.AWS_S3_REGION;

// Set AWS credentials and region
AWS.config.update({
  accessKeyId: awsAccessKeyId,
  secretAccessKey: awsSecretAccessKey,
  region: awsRegion,
});

// Initialize AWS SSM client
const ssm = new AWS.SSM();

// Path to the .env file
const dotenvFilePath = '../.env.server.prod';

// Read secrets from the .env file and populate into AWS SSM Parameter Store
fs.readFile(dotenvFilePath, 'utf8', (err, data) => {
  if (err) {
    console.error(`Error reading ${dotenvFilePath}: ${err}`);
    return;
  }

  const SECRET_PREFIX = '/opensaas/prod/';
  const lines = data.split('\n');
  lines.forEach((line) => {
    if (line.trim() && !line.startsWith('#') && line.includes('=')) {
      const [key, value] = line.trim().split('=');
      const params = {
        Name: `${SECRET_PREFIX}${key}`,
        Value: value,
        Type: 'SecureString', // You can change the type as required
        Overwrite: true,
      };

      ssm.putParameter(params, (err, data) => {
        if (err) {
          console.error(`Failed to populate parameter '${SECRET_PREFIX}${key}': ${err}`);
        } else {
          console.log(`Parameter '${key}' populated into AWS SSM Parameter Store.`);
        }
      });
    }
  });
});
