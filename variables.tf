variable "api_key" {
  description = "The iLert alert source api key. Optional if secret_name is set, in that case the key is read from the secret."
  type        = string
  default     = ""
  sensitive   = true
}

variable "http_authorization_key" {
  description = "The HTTP authorization key for in-cluster routes. Optional if secret_name is set, in that case the key is read from the secret."
  type        = string
  default     = ""
  sensitive   = true
}

variable "credentials_k8s_secret" {
  description = "If set, the iLert credentials are injected as environment variables (ILERT_API_KEY / HTTP_AUTHORIZATION_KEY) from an existing Kubernetes Secret, instead of command line args. `ilert_token_key` is the key within the secret that holds the API key, and `http_authorization_key` is the key within the secret that holds the HTTP authorization key (set to \"\" to omit it)."
  type = object({
    secret_name            = string
    ilert_token_key        = string
    http_authorization_key = optional(string, "")
  })
  default = null

  validation {
    condition     = var.credentials_k8s_secret == null || var.credentials_k8s_secret.secret_name != ""
    error_message = "credentials_k8s_secret.secret_name must not be empty."
  }

  validation {
    condition     = var.credentials_k8s_secret == null || var.credentials_k8s_secret.ilert_token_key != ""
    error_message = "credentials_k8s_secret.ilert_token_key must not be empty."
  }
}

variable "name" {
  description = "Kubernetes name."
  type        = string
  default     = "ilert-kube-agent"
}

variable "namespace" {
  description = "Kubernetes namespace."
  type        = string
  default     = "kube-system"
}

variable "replicas" {
  description = "Amount of replicas to be created."
  type        = number
  default     = 1
}

variable "port" {
  description = "The http port for health check and metrics."
  type        = number
  default     = 9092
}

variable "image" {
  description = "The ilert-kube-agent image to use. See https://github.com/iLert/ilert-kube-agent/releases for available versions"
  type        = string
  default     = "ilert/ilert-kube-agent:v1.7.1"
}

variable "pod_annotations" {
  description = "Additional annotations to be added to the pods."
  type        = map(string)
  default = {
    "prometheus.io/scrape" = "true"
    "prometheus.io/port"   = 9092
  }
}

variable "pod_labels" {
  description = "Additional labels to be added to the pods."
  type        = map(string)
  default     = {}
}

variable "pod_envs" {
  description = "Additional envs to be added to the pods."
  type        = map(string)
  default     = {}
  # default = {
  #   "LOG_LEVEL" = "info"
  # }
}

variable "cpu_request" {
  description = "The pod CPU resource request."
  type        = string
  default     = "20m"
}

variable "cpu_limit" {
  description = "The pod CPU resource limit."
  type        = string
  default     = "100m"
}

variable "memory_request" {
  description = "The pod memory resource request."
  type        = string
  default     = "32Mi"
}

variable "memory_limit" {
  description = "The pod memory resource limit."
  type        = string
  default     = "128Mi"
}

variable "config" {
  description = "The ilert-kube-agent config. See https://github.com/iLert/ilert-kube-agent/blob/master/config.yaml for available options"
  type = object({
    settings = object({
      electionID    = string
      checkInterval = string
      log = object({
        level = string
        json  = bool
      })
    })

    alarms = object({
      cluster = object({
        enabled  = bool
        priority = string
      })
      pods = object({
        enabled = bool
        terminate = object({
          enabled  = bool
          priority = string
        })
        waiting = object({
          enabled  = bool
          priority = string
        })
        restarts = object({
          enabled   = bool
          priority  = string
          threshold = number
        })
        resources = object({
          enabled = bool
          cpu = object({
            enabled   = bool
            priority  = string
            threshold = number
          })
          memory = object({
            enabled   = bool
            priority  = string
            threshold = number
          })
        })
      })
      nodes = object({
        enabled = bool
        terminate = object({
          enabled  = bool
          priority = string
        })
        resources = object({
          enabled = bool
          cpu = object({
            enabled   = bool
            priority  = string
            threshold = number
          })
          memory = object({
            enabled   = bool
            priority  = string
            threshold = number
          })
        })
      })
    })

    links = object({
      pods  = map(string)
      nodes = map(string)
    })
  })

  default = {
    settings = {
      electionID    = "ilert-kube-agent"
      checkInterval = "30s"
      log = {
        level = "info"
        json  = false
      }
    }

    alarms = {
      cluster = {
        enabled  = true
        priority = "HIGH"
      }
      pods = {
        enabled = true
        terminate = {
          enabled  = true
          priority = "HIGH"
        }

        waiting = {
          enabled  = true
          priority = "LOW"
        }

        restarts = {
          enabled   = true
          priority  = "LOW"
          threshold = 10
        }

        resources = {
          enabled = true
          cpu = {
            enabled   = true
            priority  = "LOW"
            threshold = 90
          }
          memory = {
            enabled   = true
            priority  = "LOW"
            threshold = 90
          }
        }
      }

      nodes = {
        enabled = true

        terminate = {
          enabled  = true
          priority = "HIGH"
        }

        resources = {
          enabled = true
          cpu = {
            enabled   = true
            priority  = "LOW"
            threshold = 90
          }
          memory = {
            enabled   = true
            priority  = "LOW"
            threshold = 90
          }
        }
      }
    }

    links = {
      pods  = {}
      nodes = {}
    }
  }
}
