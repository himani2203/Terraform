# Azure Functions Integrated with Azure Container Registry

Azure Functions is a serverless solution that allows you to write less code, maintain less infrastructure, and save on costs.

	Create a service plan and storage account first to deploy function app
  https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan

Note:  Elastic and Consumption SKUs (Y1, EP1, EP2, and EP3) are for use with Function Apps.

	Create ACR with Premium SKU to have retention policy and other benefits.
  https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry
  File Reference: workspace\environment\development\main-acr.tf

  Please Note: Here we are creating with Public access since we are running from Azure Pools, but we can disable public access and make use of selected network and private endpoint.
  However, we need to have self-hosted agent and allow VM subnet to access ACR else we will get 403 unauthorized error.

	Create a function app using below link:
  https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_function_app
  File Reference: workspace\environment\development\main-function-app.tf

	Azure Function apps can be configured to use an Azure Container Registry (ACR) to pull and run container images. However, configuring this via the Azure portal can be a bit tricky as it requires some additional setup steps.
  Here are the general steps to configure an Azure Function app to use an ACR:
  1.	Create an Azure Function App's identity and give it the AcrPull role to the ACR,
  2.	Add below code in site config with registry details
 
	Since our code is running on port 5000, we need to change WEBSITES_PORT to 5000  from app setting (default is 80). Please add below code in iac.

	We need to automate the deployment, so if new docker image is pushed to acr, we should see the changes on function app. Here I am using webhooks in ACR and can be deploy using below link
  https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry_webhook
  File Reference: workspace\environment\development\main-function-deployment.tf
  
  We can validate from ACR under Services, we have Webhooks, click on particular webhook created for function apps push event. Also for testing you can ping and see the  202 events.

