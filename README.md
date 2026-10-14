# terraform-kubernetes-ilert-kube-agent

Terraform module for ilert-kube-agent. Our official documentation see [here](https://docs.ilert.com/integrations/kubernetes)

## Configure kubernetes provider

```tf
provider "kubernetes" {
  // ...
  experiments {
    manifest_resource = true
  }
}
```

## Usage

### Passing the API key directly

```tf
module "ilert-kube-agent" {
  source  = "path/to/this/module"

  api_key = "<YOUR API KEY HERE>"
}
```

### Passing the credentials via an existing Kubernetes Secret

If you set `credentials_k8s_secret`, the API key and the HTTP authorization key are injected as
environment variables (`ILERT_API_KEY` and `HTTP_AUTHORIZATION_KEY`) from the given
secret, instead of being passed as command line args.

```tf
module "ilert-kube-agent" {
  source  = "path/to/this/module"

  credentials_k8s_secret = {
    secret_name     = "ilert-kube-agent-secrets"
    ilert_token_key = "api-key"
  }
}
```

| Field                    | Description                                                                                     |
|--------------------------|-------------------------------------------------------------------------------------------------|
| `secret_name`            | Name of the existing Kubernetes Secret (required)                                               |
| `ilert_token_key`        | Key within the secret that holds the iLert API key (required)                                   |
| `http_authorization_key` | Key within the secret that holds the HTTP authorization key (optional, set `""` to omit it)      |

Example secret:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: ilert-kube-agent-secrets
  namespace: kube-system
type: Opaque
stringData:
  api-key: "<YOUR API KEY HERE>"
  http-authorization-key: "<YOUR HTTP AUTHORIZATION KEY HERE>"
```

Set `http_authorization_key = ""` if you only want the API key to be injected from the
secret.


