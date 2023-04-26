variable "resource" {
    type = object({
        tags = map(string), naming = object({
            environment = string, region = string
        })
    })
}

variable "environment" {
    type = object({
        metadata = object({
            sequence = string, primary_key = string, contact = string, source = string
        })
    })
}

variable "enable_webhooks" {
    type = bool
    default = true
}

variable "WhiteListedCIDRRange" {
  type = list(string)
}

variable "image" {
  type = string
}