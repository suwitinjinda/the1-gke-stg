# Project data source
data "google_project" "current" {
  project_id = var.project
}

# Permission propagation delay
# resource "time_sleep" "permission_propagation" {
#   create_duration = var.permission_propagation_wait_time
# }

# Host project service account permissions
# resource "google_project_iam_member" "gke_shared_vpc_perms" {
#   project = var.host_project_id
#   role    = "roles/container.hostServiceAgentUser"
#   member  = "serviceAccount:service-${data.google_project.current.number}@container-engine-robot.iam.gserviceaccount.com"
# }

# resource "google_project_iam_member" "gke_network_user" {
#   project = var.host_project_id
#   role    = "roles/compute.networkUser"
#   member  = "serviceAccount:service-${data.google_project.current.number}@container-engine-robot.iam.gserviceaccount.com"
# }

# resource "google_project_iam_member" "gke_sa_user" {
#   project = var.host_project_id
#   role    = "roles/container.serviceAgent"
#   member  = "serviceAccount:service-${data.google_project.current.number}@container-engine-robot.iam.gserviceaccount.com"
# }

# # Subnet permissions
# resource "google_compute_subnetwork_iam_member" "gke_subnet_user" {
#   project    = var.host_project_id
#   region     = var.region
#   subnetwork = split("/", var.subnetwork)[5]  # Extract subnet name from full path
#   role       = "roles/compute.networkUser"
#   member     = "serviceAccount:service-${data.google_project.current.number}@container-engine-robot.iam.gserviceaccount.com"
# }

# # Specific cloudservices account permission
# resource "google_compute_subnetwork_iam_member" "specific_cloudservices" {
#   project    = var.host_project_id
#   region     = var.region
#   subnetwork = split("/", var.subnetwork)[5]  # Extract subnet name from full path
#   role       = "roles/compute.networkUser"
#   member     = var.cloudservices_account
# }

# # Service project permissions
# resource "google_project_iam_member" "gke_service_agent" {
#   project = var.project
#   role    = "roles/container.serviceAgent"
#   member  = "serviceAccount:service-${data.google_project.current.number}@container-engine-robot.iam.gserviceaccount.com"
# }

# # Compute default service account permission
# resource "google_compute_subnetwork_iam_member" "compute_default_subnet_user" {
#   project    = var.host_project_id
#   region     = var.region
#   subnetwork = split("/", var.subnetwork)[5]  # Extract subnet name from full path
#   role       = "roles/compute.networkUser"
#   member     = "serviceAccount:${data.google_project.current.number}-compute@developer.gserviceaccount.com"
# }

# # Ensure service project is attached to shared VPC
# resource "google_compute_shared_vpc_service_project" "service_project" {
#   host_project    = var.host_project_id
#   service_project = var.project
# }

# GKE cluster
resource "google_container_cluster" "primary_standard" {
  name                     = var.cluster_name
  location                 = var.zone
  initial_node_count       = 1  # Reduced to 1 for initial pool that will be removed
  remove_default_node_pool = true
  enable_shielded_nodes    = true
  network                  = var.network
  subnetwork               = var.subnetwork
  min_master_version       = var.cluster_version

  ip_allocation_policy {
    cluster_secondary_range_name  = var.cluster_secondary_range_name
    services_secondary_range_name = var.services_secondary_range_name
  }

  release_channel {
    channel = "REGULAR"
  }

  private_cluster_config {
    enable_private_nodes    = true
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
    enable_private_endpoint = false
  }

  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = var.master_authorized_cidr
      display_name = "authorized-network"
    }
  }

  addons_config {
    horizontal_pod_autoscaling {
      disabled = false
    }
    http_load_balancing {
      disabled = false
    }
    gce_persistent_disk_csi_driver_config {
      enabled = true
    }
    dns_cache_config {
      enabled = true
    }
  }

  logging_config {
    enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
  }

  monitoring_config {
    enable_components = [
      "SYSTEM_COMPONENTS",
      "STORAGE",
      "POD",
      "DEPLOYMENT",
      "STATEFULSET",
      "DAEMONSET",
      "HPA"
    ]
    managed_prometheus {
      enabled = true
    }
  }

  workload_identity_config {
    workload_pool = "${var.project}.svc.id.goog"
  }

  binary_authorization {
    evaluation_mode = "DISABLED"
  }

  security_posture_config {
    mode               = "BASIC"
    vulnerability_mode = "VULNERABILITY_DISABLED"
  }

  datapath_provider = "ADVANCED_DATAPATH"

  dns_config {
    cluster_dns        = "CLOUD_DNS"
    cluster_dns_scope  = "CLUSTER_SCOPE"
    cluster_dns_domain = "cluster.local"
  }

  # Comprehensive dependencies
  # depends_on = [
  #   google_project_iam_member.gke_shared_vpc_perms,
  #   google_project_iam_member.gke_network_user,
  #   google_project_iam_member.gke_sa_user,
  #   google_project_iam_member.gke_service_agent,
  #   google_compute_subnetwork_iam_member.gke_subnet_user,
  #   google_compute_subnetwork_iam_member.specific_cloudservices,
  #   google_compute_subnetwork_iam_member.compute_default_subnet_user,
  #   google_compute_shared_vpc_service_project.service_project,
  #   time_sleep.permission_propagation
  # ]
}

# Add a longer wait time after cluster creation
# resource "time_sleep" "cluster_initialization" {
#   depends_on      = [google_container_cluster.primary_standard]
#   create_duration = var.cluster_initialization_wait_time
# }

# Create a node pool since we set remove_default_node_pool = true
# resource "google_container_node_pool" "primary_nodes" {
#   name       = "default-pool"
#   location   = var.zone
#   cluster    = google_container_cluster.primary_standard.name
#   node_count = var.node_count
#   version    = var.cluster_version

#   # Wait for cluster and permissions to be fully set up
#   depends_on = [time_sleep.cluster_initialization]

#   node_config {
#     machine_type = var.node_machine_type
#     disk_size_gb = var.node_disk_size
#     disk_type    = var.node_disk_type
#     image_type   = var.node_image_type
    
#     metadata = {
#       disable-legacy-endpoints = "true"
#     }
    
#     shielded_instance_config {
#       enable_integrity_monitoring = true
#       enable_secure_boot          = false
#     }
#   }

#   max_pods_per_node = var.max_pods_per_node
  
#   management {
#     auto_upgrade = true
#     auto_repair  = true
#   }
  
#   upgrade_settings {
#     max_surge       = 1
#     max_unavailable = 0
#   }
# }