param environmentName string
param location string = resourceGroup().location

param containerAppsEnvironmentName string = ''
param containerRegistryName string = ''
param env array = []
param external bool = true
param imageName string
param keyVaultName string = ''
param managedIdentity bool = !(empty(keyVaultName))
param targetPort int = 80
param serviceName string

@description('CPU cores allocated to a single container instance, e.g. 0.5')
param containerCpuCoreCount string = '0.5'

@description('Memory allocated to a single container instance, e.g. 1Gi')
param containerMemory string = '1.0Gi'

var abbrs = loadJsonContent('../../abbreviations.json')
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))
var tags = { 'azd-env-name': environmentName }

resource app 'Microsoft.App/containerApps@2022-03-01' = {
  name: '${abbrs.appContainerApps}${serviceName}-${resourceToken}'
  location: location
  tags: union(tags, { 'azd-service-name': serviceName })
  identity: { type: managedIdentity ? 'SystemAssigned' : 'None' }
  properties: {
    managedEnvironmentId: containerAppsEnvironment.id
    configuration: {
      activeRevisionsMode: 'single'
      ingress: {
        external: external
        targetPort: targetPort
        transport: 'auto'
      }
      secrets: [
        {
          name: 'registry-password'
          value: containerRegistry.listCredentials().passwords[0].value
        }
      ]
      registries: [
        {
          server: '${containerRegistry.name}.azurecr.io'
          username: containerRegistry.name
          passwordSecretRef: 'registry-password'
        }
      ]
    }
    template: {
      containers: [
        {
          image: imageName
          name: 'main'
          env: env
          resources: {
            cpu: json(containerCpuCoreCount)
            memory: containerMemory
          }
        }
      ]
    }
  }
}

resource containerAppsEnvironment 'Microsoft.App/managedEnvironments@2022-03-01' existing = {
  name: !empty(containerAppsEnvironmentName) ? containerAppsEnvironmentName : '${abbrs.appManagedEnvironments}${resourceToken}'
}

// 2022-02-01-preview needed for anonymousPullEnabled
resource containerRegistry 'Microsoft.ContainerRegistry/registries@2022-02-01-preview' existing = {
  name: !empty(containerRegistryName) ? containerRegistryName : '${abbrs.containerRegistryRegistries}${resourceToken}'
}

output identityPrincipalId string = managedIdentity ? app.identity.principalId : ''
output name string = app.name
output uri string = 'https://${app.properties.configuration.ingress.fqdn}'
