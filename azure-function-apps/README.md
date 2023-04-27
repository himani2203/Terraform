# Azure Functions Integrated with Azure Container Registry

Azure Functions is a serverless solution that allows you to write less code, maintain less infrastructure, and save on costs.

### Below steps require to create Azure Functions Apps using ACR :

#### 	Create a service plan and storage account to deploy function app
  https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan
  https://registry.terraform.io/providers/hashicorp/Azurerm/latest/docs/resources/storage_account

#### Note:  Elastic and Consumption SKUs (Y1, EP1, EP2, and EP3) are for use with Function Apps.

#### 	Create ACR with Premium SKU to have retention policy and other benefits.
  https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry
  File Reference: azure-function-apps\workspace\environment\development\main-acr.tf

  Please Note: Here we are creating with Public access, but we can disable public access and make use of selected network and private endpoint.
  However, we need to have self-hosted agent and allow VM/agent subnet to access ACR and storage backend(tfstste file) else we will get 403 unauthorized error.

#### 	Create a function app using below link:
  https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_function_app
  File Reference: azure-function-apps\workspace\environment\development\main-function-app.tf

#### 	Azure Function apps can be configured to use an Azure Container Registry (ACR) to pull and run container images. However, configuring this via the Azure portal can be a bit tricky as it requires some additional setup steps.
  Here are the general steps to configure an Azure Function app to use an ACR:
  1.	Create an Azure Function App's identity and give it the AcrPull role to the ACR,
  2.	Add docker block under application_stack{} in site config with registry and image details
 
	Since our code/application is running on port 5000, we need to change WEBSITES_PORT to 5000  from app setting (default is 80). Please add below code in iac.

	We need to automate the deployment, so if new docker image is pushed to acr, we should see the changes on function app. Here I am using webhooks in ACR.
  https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry_webhook
  File Reference: azure-function-apps\workspace\environment\development\main-function-deployment.tf

#### 	Create service principal and assign AcrPush Role to it
  File Reference: azure-function-apps\workspace\environment\development\main-acr-app.tf

### Please Note: Once above code or Infrastructure is deployed, we can get the acr_username and acr_password from the state file which will help us to create Service Connection using Docker Registry from the other tab in Azure DevOps.

	We can also test code locally by setting environment variables and are good to run terraform init/plan/apply just we need to traverse location: azure-function-apps\workspace\environment\development where we have our *.tf files.

##### Refer Link to see how to set environment variables:
https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret#configuring-the-service-principal-in-terraform

However, we can create pipeline using existing yaml from Azure DevOps to deploy our Infrastructure(Azure Functions Apps).
##### File Reference: azure-function-apps\Infrastructure-Pipeline\azure-pipelines.yml

#### 	Once we have infrastructure ready, we can run deployment pipeline which will build our image and push to ACR.
Location: https://github.com/himani2203/Deploy-Apps/blob/main/azure-function-apps/Pipelines-cloud/One-Click-Build-Deploy.yml

1)	For this we will first create Service Connection using above Service principal username and password.
2)	We can create pipeline using existing yaml(file location given above) and run which will push an image to ACR. 
3)	We can now verify from webhooks to see push events.

#### Please Note: Function app will give an application error once we deploy initially since there is no image:tag found in ACR. Once we have image pushed into ACR, we can refresh function-apps default site url and validate the code.
