variable "org_id" {
  description = "The organization ID"
  type        = string
}

variable "project" {
  description = "The project ID"
  type        = string
}

variable "region" {
  description = "The region to deploy resources"
  type        = string
}

variable "zone" {
  description = "The zone to deploy resources"
  type        = string
}

variable "cluster_name" {
  description = "Name of the GKE cluster"
  type        = string
}

variable "network" {
  description = "The VPC network"
  type        = string
}

variable "subnetwork" {
  description = "The subnetwork for GKE nodes"
  type        = string
}

variable "cluster_secondary_range_name" {
  description = "The name of the secondary range for pods"
  type        = string
}

variable "services_secondary_range_name" {
  description = "The name of the secondary range for services"
  type        = string
}

variable "master_authorized_cidr" {
  description = "CIDR block for master authorized networks"
  type        = string
}

variable "master_ipv4_cidr_block" {
  description = "CIDR block for the master's private IP range"
  type        = string
}

variable "node_machine_type" {
  description = "Machine type for GKE nodes"
  type        = string
}

variable "node_disk_size" {
  description = "Disk size for GKE nodes in GB"
  type        = number
}

variable "node_disk_type" {
  description = "Disk type for GKE nodes"
  type        = string
}

variable "node_image_type" {
  description = "Image type for GKE nodes"
  type        = string
}

variable "node_count" {
  description = "Number of nodes in the GKE cluster"
  type        = number
}

variable "max_pods_per_node" {
  description = "Maximum pods per node"
  type        = number
}

variable "cluster_version" {
  description = "Version of GKE cluster"
  type        = string
}

variable "billing_account_id" {
  description = "Billing account ID"
  type        = string
}

# Add variables for shared VPC host project
variable "host_project_id" {
  description = "The shared VPC host project ID"
  type        = string
  default     = "the1-share-stg"  # Based on your network path
}

# Add variable for specific cloudservices account
variable "cloudservices_account" {
  description = "The specific cloudservices account"
  type        = string
  default     = "741477686952@cloudservices.gserviceaccount.com"  # Based on your previous error
}

# Variables for permission propagation wait times
variable "permission_propagation_wait_time" {
  description = "Time to wait for permission propagation"
  type        = string
  default     = "5m"
}

variable "cluster_initialization_wait_time" {
  description = "Time to wait for cluster initialization"
  type        = string
  default     = "5m"
}