param environmentName string
param location string = resourceGroup().location

param serviceName string = 'react-appservice'
param appCommandLine string = 'pm2 serve /home/site/wwwroot --no-daemon --spa'
param applicationInsightsName string = ''
param appServicePlanId string
param appSettings object = {}

module web '../core/host/appservice.bicep' = {
  name: '${serviceName}-appservice-node-module'
  params: {
    environmentName: environmentName
    location: location
    serviceName: serviceName
    appCommandLine: appCommandLine
    applicationInsightsName: applicationInsightsName
    appServicePlanId: appServicePlanId
    appSettings: appSettings
    runtimeName: 'node'
    runtimeVersion: '16-lts'
  }
}

output WEB_IDENTITY_PRINCIPAL_ID string = web.outputs.identityPrincipalId
output WEB_NAME string = web.outputs.name
output WEB_URI string = web.outputs.uri
