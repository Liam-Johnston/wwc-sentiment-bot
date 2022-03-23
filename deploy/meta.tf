terraform {
  required_version = ">= 1.1.6"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.11.0"
    }
  }

  backend "gcs" {
    prefix = "terraform/state"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}
