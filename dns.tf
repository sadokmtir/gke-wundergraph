resource "google_project_service" "dns" {
  project = var.project_id
  service = "dns.googleapis.com"
}

# Create a DNS managed zone
resource "google_dns_managed_zone" "wundergaph_zone" {
  name        = "wundergraph-zone"
  dns_name    = "${var.domain_name}."
  description = "Managed zone for ${var.domain_name}"
}

# Add DNS records
resource "google_dns_record_set" "a_record" {
  name         = "${var.domain_name}."
  type         = "A"
  ttl          = 300
  managed_zone = google_dns_managed_zone.wundergaph_zone.name
  rrdatas      = [local.urls["app"]]
}



