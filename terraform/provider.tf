terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.61.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.2"
    }
  }

  backend "gcs" {
    bucket = "oca-terraform-state"
    prefix = "state"
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.resources_region
}

data "google_client_config" "default" {}

provider "docker" {

  registry_auth {
    address  = "${lower(var.gcr_location)}.gcr.io"
    username = "oauth2accesstoken"
    password = data.google_client_config.default.access_token
  }
}
