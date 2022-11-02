param environmentName string
param location string = resourceGroup().location

param containerAppsEnvironmentName string = ''
param containerRegistryName string = ''
param imageName string = ''
param serviceName string = 'react-containerapp'

module web '../core/host/container-app.bicep' = {
  name: '${serviceName}-container-app-module'
  params: {
    environmentName: environmentName
    location: location
    containerAppsEnvironmentName: containerAppsEnvironmentName
    containerRegistryName: containerRegistryName
    imageName: !empty(imageName) ? imageName : 'nginx:latest'
    serviceName: serviceName
    targetPort: 80
  }
}

output WEB_NAME string = web.outputs.name
output WEB_URI string = web.outputs.uri
