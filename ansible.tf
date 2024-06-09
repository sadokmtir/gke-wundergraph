resource "local_file" "vars_file" {
  content = yamlencode({
    cluster    = module.cluster.name
    region     = var.region
    project_id = module.project.project_id
    app_url    = local.urls["app"]
  })
  filename        = "${path.module}/ansible/vars/vars.yaml"
  file_permission = "0644"
}

resource "local_file" "gssh_file" {
  content = templatefile("${path.module}/templates/gssh.sh.tpl", {
    project_id = module.project.project_id
    zone       = local.zone
  })
  filename        = "${path.module}/ansible/gssh.sh"
  file_permission = "0755"
}
