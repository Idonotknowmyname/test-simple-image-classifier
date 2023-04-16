locals {
  docker_context_path = "${path.cwd}/.."
}

locals {
  # Essentially a .dockerinclude file
  docker_context_files = setunion(
    fileset(local.docker_context_path, "api/{requirements.txt,setup.py}"),
    fileset(local.docker_context_path, "api/backend/**.py"),
    fileset(local.docker_context_path, "app/{public,src}/**"),
    fileset(local.docker_context_path, "app/{package-lock.json,package.json}")
  )
}

# Create container registry
resource "google_container_registry" "registry" {
  location = var.gcr_location
}

# Build docker image
resource "docker_image" "app" {
  name = "${lower(var.gcr_location)}.gcr.io/${var.gcp_project_id}/app"
  build {
    context = local.docker_context_path
    build_args = {
      "HOST_URL" : "${var.backend_host_url}"
    }
  }
  triggers = {
    dir_sha1 = sha1(join("", [for f in local.docker_context_files : filesha1("${local.docker_context_path}/${f}")]))
  }
}

# Push docker image
resource "docker_registry_image" "app" {
  name = docker_image.app.name
  triggers = {
    image_digest = docker_image.app.image_id
  }
}

# Deploy docker image to cloud run service
resource "google_cloud_run_v2_service" "default" {
  name     = "service-deployment"
  location = var.resources_region
  ingress  = "INGRESS_TRAFFIC_ALL"

  template {
    scaling {
      max_instance_count = 1
    }
    containers {
      image = "${docker_image.app.name}@${docker_registry_image.app.sha256_digest}"
      resources {
        limits = {
          cpu    = "2"
          memory = "1Gi"
        }
      }
    }
    max_instance_request_concurrency = 4
  }

  traffic {
    percent = 100
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
  }

  depends_on = [
    docker_registry_image.app
  ]
}

data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location = google_cloud_run_v2_service.default.location
  project  = google_cloud_run_v2_service.default.project
  service  = google_cloud_run_v2_service.default.name

  policy_data = data.google_iam_policy.noauth.policy_data
}
