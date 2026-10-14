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

If you set `credentials_k8s_secret`, the secret is mounted with `envFrom`, so **every key
in the secret is mapped 1:1 to an environment variable with the same name**. The
ilert-kube-agent reads `ILERT_API_KEY` and `HTTP_AUTHORIZATION_KEY` from the environment,
so the secret keys must use those exact names. The credentials are not passed as command
line args in this case.

```tf
module "ilert-kube-agent" {
  source  = "path/to/this/module"

  credentials_k8s_secret = "ilert-kube-agent-secrets"
}
```

Example secret (key names must match the expected environment variables):

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: ilert-kube-agent-secrets
  namespace: kube-system
type: Opaque
stringData:
  ILERT_API_KEY: "<YOUR API KEY HERE>"
  HTTP_AUTHORIZATION_KEY: "<YOUR HTTP AUTHORIZATION KEY HERE>"
```

Omit `HTTP_AUTHORIZATION_KEY` from the secret if you don't need it.



