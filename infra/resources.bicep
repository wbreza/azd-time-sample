param environmentName string
param location string = resourceGroup().location
param principalId string = ''
param webImageName string = ''

// The application frontend
module swa './app/static-app.bicep' = {
  name: 'swa'
  params: {
    environmentName: environmentName
    location: location
  }
}

module appservice './app/app-service.bicep' = {
  name: 'appservice'
  params: {
    environmentName: environmentName
    location: location
    applicationInsightsName: monitoring.outputs.applicationInsightsName
    appServicePlanId: appServicePlan.outputs.appServicePlanId
  }
}

// module containerApps './core/host/container-apps.bicep' = {
//   name: 'container-apps'
//   params: {
//     environmentName: environmentName
//     location: location
//     logAnalyticsWorkspaceName: monitoring.outputs.logAnalyticsWorkspaceName
//   }
// }

// module containerapp './app/container-app.bicep' = {
//   name: 'containerapp'
//   params: {
//     environmentName: environmentName
//     location: location
//     imageName: webImageName
//     containerAppsEnvironmentName: containerApps.outputs.containerAppsEnvironmentName
//     containerRegistryName: containerApps.outputs.containerRegistryName
//   }
// }

// Create an App Service Plan to group applications under the same payment plan and SKU
module appServicePlan './core/host/appserviceplan.bicep' = {
  name: 'appserviceplan'
  params: {
    environmentName: environmentName
    location: location
    sku: {
      name: 'B1'
    }
  }
}

// Store secrets in a keyvault
module keyVault './core/security/keyvault.bicep' = {
  name: 'keyvault'
  params: {
    environmentName: environmentName
    location: location
    principalId: principalId
  }
}

// Monitor application with Azure Monitor
module monitoring './core/monitor/monitoring.bicep' = {
  name: 'monitoring'
  params: {
    environmentName: environmentName
    location: location
  }
}

output APPLICATIONINSIGHTS_CONNECTION_STRING string = monitoring.outputs.applicationInsightsConnectionString
output AZURE_KEY_VAULT_ENDPOINT string = keyVault.outputs.keyVaultEndpoint
