# vpc
variable "vpc_use_strategy" {
  type        = string
  description = <<-EOT
    Strategy for using vpc resources:
      'skip' to disable,
      'select' to use existing,
      or 'create' to generate new vpc resources.
    The default is 'create', which requires a vpc_name and vpc_cidr to be provided.
    When selecting a vpc, the vpc_name must be provided and a vpc that has a tag "Name" with the given name must exist.
    When skipping a vpc, the subnet, security group, and load balancer will also be skipped (automatically).
  EOT
  default     = "create"
  validation {
    condition     = contains(["skip", "select", "create"], var.vpc_use_strategy)
    error_message = "The vpc_use_strategy value must be one of 'skip', 'select', or 'create'."
  }
}
variable "vpc_name" {
  type        = string
  description = <<-EOT
    The name of the VPC to create or select.
  EOT
  default     = ""
}
variable "vpc_cidr" {
  type        = string
  description = <<-EOT
    This value sets the default private IP space for the created VPC.
    WARNING: AWS reserves the first four IP addresses and the last IP address in any CIDR block for its own use (cumulatively).
    This means that every VPC has 5 IP addresses that cannot be assigned to subnets, and every subnet assigned has 5 IP addresses that cannot be used.
    If you attempt to generate a VPC that has no usable addresses you will get an "invalid CIDR" error from AWS.
    If you attempt to generate a subnet that uses one of the addresses reserved by AWS in the VPC's CIDR, you will get an "invalid CIDR" error from AWS.
  EOT
  default     = ""
}

# subnet
variable "subnet_use_strategy" {
  type        = string
  description = <<-EOT
    Strategy for using subnet resources:
      'skip' to disable,
      'select' to use existing,
      or 'create' to generate new subnet resources.
    The default is 'create', which requires a subnet_name and subnet_cidr to be provided.
    When selecting a subnet, the subnet_name must be provided and a subnet with the tag "Name" with the given name must exist.
    When skipping a subnet, the security group and load balancer will also be skipped (automatically).
  EOT
  default     = "create"
  validation {
    condition     = contains(["skip", "select", "create"], var.subnet_use_strategy)
    error_message = "The subnet_use_strategy value must be one of 'skip', 'select', or 'create'."
  }
}
variable "subnets" {
  type = map(object({
    cidr              = string,
    availability_zone = string,
    public            = bool,
  }))
  description = <<-EOT
    A map of subnet objects to create or select.
    The key is the name of the subnet, and the value is an object with the following keys:
      cidr: the cidr of the subnet to create
      availability_zone: the availability zone to create the subnet in
      public: set this to true to enable the subnet to have public IP addresses
    WARNING: AWS reserves the first four IP addresses and the last IP address in any CIDR block for its own use (cumulatively).
    This means that every VPC has 5 IP addresses that cannot be assigned to subnets, and every subnet assigned has 5 IP addresses that cannot be used.
    If you attempt to generate a subnet that has no usable addresses you will get an "invalid CIDR" error from AWS.
    If you attempt to generate a subnet that uses one of the addresses reserved by AWS in the VPC's CIDR, you will get an "invalid CIDR" error from AWS.
    When skipping a subnet, the security group and load balancer will also be skipped (automatically).
    When selecting a subnet:
     - the name must be provided and a subnet with the tag "Name" with the given name must exist.
     - the values for cidr, availability_zone, and public will be ignored.
    When creating subnets, any values not supplied will be generated by the module.
     - the name will match the vpc name
     - The availability zone will be whatever the default is for your account.
     - The cidr will be generated based on the VPC's cidr and the number of subnets you are creating.
     - The public flag will be set to false.
    If you are expecting high availability, make sure there are at least three availability zones in the region you are deploying to.
    WARNING! The key for this argument must not be derived from a resource, it must be static.
  EOT
  default = { "default" = {
    cidr              = "", # will be generated based on the vpc cidr
    availability_zone = "", # just get the first one
    public            = false,
  } }
}

# security group
variable "security_group_use_strategy" {
  type        = string
  description = <<-EOT
    Strategy for using security group resources:
      'skip' to disable,
      'select' to use existing,
      or 'create' to generate new security group resources.
    The default is 'create'.
    When selecting a security group, the security_group_name must be provided and a security group with the given name must exist.
    When skipping a security group, the load balancer will also be skipped (automatically).
  EOT
  default     = "create"
  validation {
    condition     = contains(["skip", "select", "create"], var.security_group_use_strategy)
    error_message = "The security_group_use_strategy value must be one of 'skip', 'select', or 'create'."
  }
}
variable "security_group_name" {
  type        = string
  description = <<-EOT
    The name of the ec2 security group to create or select.
    When choosing the "create" or "select" strategy, this is required.
    When choosing the "skip" strategy, this is ignored.
    When selecting a security group, the security_group_name must be provided and a security group with the given name must exist.
    When creating a security group, the name will be used to tag the resource, and security_group_type is required.
    The types are located in modules/security_group/types.tf.
  EOT
  default     = ""
}
variable "security_group_type" {
  type        = string
  description = <<-EOT
    The type of the ec2 security group to create.
    We provide opinionated options for the user to select from.
    Leave this blank if you would like to select a security group rather than generate one.
    The types are located in ./modules/security_group/types.tf.
    If specified, must be one of: project, egress, or public.
  EOT
  default     = "project"
  validation {
    condition     = contains(["project", "egress", "public"], var.security_group_type)
    error_message = "The security_group_type value must be one of 'project', 'egress', or 'public'."
  }
}

# load balancer
variable "load_balancer_use_strategy" {
  type        = string
  description = <<-EOT
    Strategy for using load balancer resources:
      'skip' to disable,
      'select' to use existing,
      or 'create' to generate new load balancer resources.
    The default is 'create'.
    When selecting a load balancer, the load_balancer_name must be provided and a load balancer with the "Name" tag must exist.
    When skipping a load balancer, the domain will also be skipped (automatically).
  EOT
  default     = "create"
  validation {
    condition     = contains(["skip", "select", "create"], var.load_balancer_use_strategy)
    error_message = "The load_balancer_use_strategy value must be one of 'skip', 'select', or 'create'."
  }
}
variable "load_balancer_name" {
  type        = string
  description = <<-EOT
    The name of the Load Balancer, there must be a 'Name' tag on it to be found.
    When generating a load balancer, this will be added as a tag to the resource.
    This tag is how we will find it again in the future.
    If a domain and a load balancer name is given, we will create a domain record pointing to the load balancer.
  EOT
  default     = ""
}
variable "load_balancer_access_cidrs" {
  type = map(object({
    port     = number
    cidrs    = list(string)
    protocol = string
  }))
  description = <<-EOT
    A map of access information objects.
    The port is the port to expose on the load balancer.
    The cidrs is a list of external cidr blocks to allow access to the load balancer.
    The protocol is the network protocol to expose on, this can be 'udp' or 'tcp'.
    Example:
    {
      test = {
        port = 443
        cidrs = ["1.1.1.1/32"]
        protocol = "tcp"
      }
    }
  EOT
  default     = null
}

# domain
variable "domain_use_strategy" {
  type        = string
  description = <<-EOT
    Strategy for using domain resources:
      'skip' to disable,
      'select' to use existing,
      or 'create' to generate new domain resources.
    The default is 'create', which requires a domain name to be provided.
    When selecting a domain, the domain must be provided and a domain with the matching name must exist.
    When adding a domain, it will be attached to all load balancer ports with a certificate for secure access.
  EOT
  default     = "create"
  validation {
    condition     = contains(["skip", "select", "create"], var.domain_use_strategy)
    error_message = "The domain_use_strategy value must be one of 'skip', 'select', or 'create'."
  }
}
variable "domain" {
  type        = string
  description = <<-EOT
    The domain name to retrieve or create.
    Part of creating the domain is assigning it to the load balancer and generating a tls certificate.
    This should enable secure connections for your project.
    To make use of this feature, you must generate load balancer target group associations in other further stages.
    We output the arn of the load balancer for this purpose.
  EOT
  default     = ""
}
variable "domain_zone" {
  type        = string
  description = <<-EOT
    The domain zone to create.
    This is only required if you want to create a new domain zone.
    If you are using an existing domain zone, you can leave this blank.
  EOT
  default     = ""
}
