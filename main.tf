/* Providers */
provider "google" {
  version = "3.68.0"
  project = "challenge1-310911"
}

/* Storage Bucket (Imported) */
resource "google_storage_bucket" "website" {
  name     = "jabraan-cv" // name of bucket
  location = "europe-west1"

  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
}

/* Storage Bucket Objects */

// Error page
resource "google_storage_bucket_object" "errorPage" {
  name   = "404.html"
  source = "/home/jabraan/ch1/404.html"
  bucket = "jabraan-cv"
}

// Main Page
resource "google_storage_bucket_object" "mainPage" {
  name   = "index.html"
  source = "/home/jabraan/ch1/index.html"
  bucket = "jabraan-cv"
}

// Styles 
resource "google_storage_bucket_object" "styles" {
  name   = "styles.css"
  source = "/home/jabraan/ch1/styles.css"
  bucket = "jabraan-cv"
}

// Script
resource "google_storage_bucket_object" "script" {
  name   = "script.js"
  source = "/home/jabraan/ch1/script.js"
  bucket = "jabraan-cv"
}


/* API Gateway */
resource "google_api_gateway_api" "api_gw" {
  project = "challenge1-310911"
  provider = google-beta
  api_id = "test-api" 
}

resource "google_api_gateway_api_config" "api_gw" {
  project = "challenge1-310911"
  provider = google-beta
  api = google_api_gateway_api.api_gw.api_id
  api_config_id = "api-test-config"

  openapi_documents {
    document {
      path = "/home/jabraan/ch1/api-new.yaml"
      contents = filebase64("api-new.yaml")
    }
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "google_api_gateway_gateway" "api_gw" {
  project = "challenge1-310911"
  provider = google-beta
  api_config = google_api_gateway_api_config.api_gw.id
  gateway_id = "gateway-test"
  region = "europe-west1"
}

/* Cloud Functions (Imported) */

resource "google_cloudfunctions_function" "app" {
  region = "us-central1"
  name                  = "app"
  project               = "challenge1-310911"
  runtime               = "nodejs12"
  service_account_email = "challenge1-310911@appspot.gserviceaccount.com"
  timeout               = 60
  trigger_http          = true

  available_memory_mb         = 256

  environment_variables =   {"FIREBASE_CONFIG" = jsonencode(
    {
      databaseURL   = "https://challenge1-310911-default-rtdb.firebaseio.com"
      locationId    = "europe-west2"
      projectId     = "challenge1-310911"
      storageBucket = "challenge1-310911.appspot.com"
    }
  )}
        
  entry_point                 = "main"
  https_trigger_url           = "https://us-central1-challenge1-310911.cloudfunctions.net/app"
  ingress_settings            = "ALLOW_ALL"
  labels = {
    deployment-tool = "cli-gcloud"
  }
}

/* Firestore Documents (Imported) */

resource "google_firestore_document" "count" {
  project     = "challenge1-310911"
  collection  = "counter"
  document_id = "views"
  fields      = "{\"count\":{\"integerValue\":\"668\"}}"
}