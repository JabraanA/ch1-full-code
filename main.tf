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
        
  entry_point                 = "app"
  https_trigger_url           = "https://us-central1-challenge1-310911.cloudfunctions.net/app"
  ingress_settings            = "ALLOW_ALL"
   environment_variables =   {"FIREBASE_CONFIG" = jsonencode(
   {
     databaseURL   = "https://challenge1-310911-default-rtdb.firebaseio.com"
     locationId    = "europe-west2"
     projectId     = "challenge1-310911"
     storageBucket = "challenge1-310911.appspot.com"
   }
  )}

  labels = {
    deployment-tool = "cli-firebase"
  }
  
}

#################################################
// Cloud Function deployed via TF
resource "google_storage_bucket" "bucket2" {
  name = "function-bucket2"
  location      = "europe-west2"
}

resource "google_storage_bucket_object" "archive" {
  name   = "code.zip"
  bucket = "function-bucket2"
  source = "/home/jabraan/ch1/code.zip"
}

resource "google_cloudfunctions_function" "tf-function" {
  name        = "tf-function"
  description = "My Cloud function deployed via TF"
  runtime     = "nodejs12"
  region      = "europe-west2"
  service_account_email = "challenge1-310911@appspot.gserviceaccount.com"
  available_memory_mb   = 256
  source_archive_bucket = "function-bucket2"
  source_archive_object = "code.zip"
  trigger_http          = true
  entry_point           = "app"
  timeout = 60
  ingress_settings      = "ALLOW_ALL"
  labels = {
    deployment-tool = "cli-firebase"
  }
  environment_variables =   {"FIREBASE_CONFIG" = jsonencode(
   {
     databaseURL   = "https://challenge1-310911-default-rtdb.firebaseio.com"
     locationId    = "europe-west2"
     projectId     = "challenge1-310911"
     storageBucket = "challenge1-310911.appspot.com"
   }
  )}
}

# IAM entry for all users to invoke the function
resource "google_cloudfunctions_function_iam_member" "invoker" {
  project        = "challenge1-310911"
  region         = "europe-west2"
  cloud_function = "tf-function"

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}




/* IGNORE: Cloud Function (Imported) */
resource "google_cloudfunctions_function" "app1" {
  region = "us-central1"
  name                  = "app"
  project               = "challenge1-310911"
  runtime               = "nodejs12"
  service_account_email = "challenge1-310911@appspot.gserviceaccount.com"
  timeout               = 60
  trigger_http          = true

  available_memory_mb         = 256
        
  entry_point                 = "app"
  https_trigger_url           = "https://us-central1-challenge1-310911.cloudfunctions.net/app"
  ingress_settings            = "ALLOW_ALL"
   environment_variables =   {"FIREBASE_CONFIG" = jsonencode(
   {
     databaseURL   = "https://challenge1-310911-default-rtdb.firebaseio.com"
     locationId    = "europe-west2"
     projectId     = "challenge1-310911"
     storageBucket = "challenge1-310911.appspot.com"
   }
  )}

  labels = {
    deployment-tool = "cli-firebase"
  }
  
}

######################################
/* Firestore Documents (Imported) */
 
resource "google_firestore_document" "counter" {
 project     = "challenge1-310911"
 collection  = "counter"
 document_id = "views"
 fields      = "{\"count\":{\"integerValue\":\"949\"}}"
}


################################################
// Using Variables

resource "google_storage_bucket" "newBucket" {
  name = var.BucketName
  location = var.region
}


####################################################
/* Networking */

# DNS Zone
resource "google_dns_managed_zone" "zone" {
  name        = "jabraan-dns"
  dns_name    = "jabraan.cts-gcp.com."
  description = ""
}

# Record Types
resource "google_dns_record_set" "recordset" {
  provider = "google-beta"
  managed_zone = "jabraan-dns"
  name         = "jabraan.cts-gcp.com."
  type         = "A"
  rrdatas      = ["34.120.78.160"]
  ttl          = 21600
}


# Load Balancer (click on advanced menu to see all)

// Forwarding Rules
resource "google_compute_global_forwarding_rule" "forward-rule" {
  project               = "challenge1-310911"
  provider              = google-beta
  name                  = "frontend"
  ip_address            = "34.120.78.160"
  ip_protocol           = "TCP"
  target                = "https://www.googleapis.com/compute/beta/projects/challenge1-310911/global/targetHttpsProxies/loadb-target-proxy"
  port_range            = "443-443"
  labels                = {}  
}

// Target Proxy
resource "google_compute_target_https_proxy" "target-proxy" {
  name             = "loadb-target-proxy"
  url_map          = google_compute_url_map.url-map.name
  ssl_certificates = [google_compute_managed_ssl_certificate.ssl.name]
}

// SSL
resource "google_compute_managed_ssl_certificate" "ssl" {
  name        = "cert"
  managed {
    domains = ["jabraan.cts-gcp.com"]
  }
}

// Url-Map
resource "google_compute_url_map" "url-map" {
  name        = "loadb"
  description = ""
  default_service = google_compute_backend_bucket.backend-bucket.name
}

// Backend
resource "google_compute_backend_bucket" "backend-bucket" {
  name        = "buck"
  bucket_name = google_storage_bucket.website.name
  enable_cdn  = true
}


