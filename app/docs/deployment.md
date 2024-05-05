### Deploying the app

#### Backend on AWS App Runner

1. Publish the secrets to AWS Systems Manager Parameter Store using the script `publishSecrets.js` in the `scripts` directory.

   _Note: Some issue with the script include the DATABASE_URL not being set corrently because of "" in the `.env` file._

2. Create a private repository on Elastic Container Registry (ECR) using the command `aws ecr create-repository --repository-name <repository-name> --region us-east-1` or using the console.

3. Authenticate local docker to push to Elastic Container Registry (ECR) using the command `aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 373010202891.dkr.ecr.us-east-1.amazonaws.com`.

4. Navigate to the `app/.wasp/build/` directory and build the docker image using the command `docker build -t <repository-uri>:<tag> .` where `<repository-uri>` is the URI of the ECR repository and `<tag>` is the tag of the image. Example: `docker build --platform=linux/amd64 -t test-open-saas:latest .`.

5. Tag the docker image and get it ready to be pushed to ECR using the command `docker tag test-open-saas:latest 373010202891.dkr.ecr.us-east-1.amazonaws.com/test-open-saas:lates`.

6. Push the docker image to ECR using the command `docker push 373010202891.dkr.ecr.us-east-1.amazonaws.com/test-open-saas:latest`.

7. Provision a new service on AWS App Runner using the ECR repository as the source using the terraform script in the `infra/prod.tf`. Run the typical `teraform init`, `terraform plan`, and `terraform apply` commands.

8. The backend should now be deployed on AWS App Runner.
