### Deploying the app

#### Backend on AWS App Runner

0. Build the wasp project using the command `wasp build` in the `app` directory. This will create a `.wasp` directory in the `app` directory with the build artifacts. Below are some manual updates:

   - In the `src/server/workers/canculateDailyStats.ts` file, update the imports to disable plausible and enable google analytics.
   - In `globalMiddledware.ts` file, update the morgan logger to use the combined format: `['logger', logger('combined')]`
   - In the `.env.server.prod` file, add in a random `JWT_SECRET` if you are using WASP Auth (Google Social Auth)

1. Publish the secrets to AWS Systems Manager Parameter Store using the script `publishSecrets.js` in the `scripts` directory.

   _Note: Some issue with the script include the DATABASE_URL not being set corrently because of "" in the `.env` file._

2. Create a private repository on Elastic Container Registry (ECR) using the command `aws ecr create-repository --repository-name <repository-name> --region us-east-1` or using the console.

3. Authenticate local docker to push to Elastic Container Registry (ECR) using the command `aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 373010202891.dkr.ecr.us-east-1.amazonaws.com`.

4. Navigate to the `app/.wasp/build/` directory and build the docker image using the command `docker build -t <repository-uri>:<tag> .` where `<repository-uri>` is the URI of the ECR repository and `<tag>` is the tag of the image. Example: `docker build --platform=linux/amd64 -t test-open-saas:latest .`.

5. Tag the docker image and get it ready to be pushed to ECR using the command `docker tag test-open-saas:latest 373010202891.dkr.ecr.us-east-1.amazonaws.com/test-open-saas:latest`.

6. Push the docker image to ECR using the command `docker push 373010202891.dkr.ecr.us-east-1.amazonaws.com/test-open-saas:latest`.

7. Provision a new service on AWS App Runner using the ECR repository as the source using the terraform script in the `infra/prod.tf`. Run the typical `teraform init`, `terraform plan`, and `terraform apply` commands.

8. Setup the custom domain on AWS App Runner from the Custom Domain tab in the AWS App Runner console. You will need to add some DNS records to your domain provider.

9. The backend should now be deployed on AWS App Runner.

#### Deploy the Frontend on Netlify

1. Navigate to the `app/.wasp/build/web-app` directory and build the frontend using the command `npm install && REACT_APP_API_URL=<url_to_wasp_backend> npm run build` where `<url_to_wasp_backend>` comes from the AWS App Runner deployment.

2. Update the netlify.toml file to inclue the correct `base = "app/.wasp/build/web-app"` directory since it was erroring out with `Error: The deploy directory "/Users/karankrishnani/projects/experiments/test-open-saas/app/build" has not been found. Did you forget to run 'netlify build'?`

3. Deploy the frontend on Netlify using the command `netlify deploy` and then after preview using the `--prod` option.

4. Setup your custom domain on Netlify and point it to the Netlify deployment. Follow the instructions on the Netlify dashboard.

5. Setup HTTPs on Netlify using the instructions on the Netlify dashboard.

6. The frontend should now be deployed on Netlify.
