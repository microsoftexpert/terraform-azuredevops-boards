###############################################################################
# tf_mod_azuredevops_boards — main
#
# AGGREGATION module: no primary `this`. Each resource type is a named, totally
# optional `for_each` collection. `main.tf` is a thin, total renderer — no
# business logic, just a projection of the typed input onto provider blocks.
###############################################################################

# Area-path (Component) permissions on existing classification nodes.
resource "azuredevops_area_permissions" "area_permissions" {
 for_each = var.area_permissions

 project_id = var.project_id
 principal = each.value.principal
 permissions = each.value.permissions
 path = try(each.value.path, null)
 replace = try(each.value.replace, true)
}

# Iteration-path (Sprint) permissions on existing classification nodes.
resource "azuredevops_iteration_permissions" "iteration_permissions" {
 for_each = var.iteration_permissions

 project_id = var.project_id
 principal = each.value.principal
 permissions = each.value.permissions
 path = try(each.value.path, null)
 replace = try(each.value.replace, true)
}

# Project- or team-scoped Boards dashboards.
resource "azuredevops_dashboard" "dashboards" {
 for_each = var.dashboards

 project_id = var.project_id
 name = each.value.name
 description = try(each.value.description, null)
 team_id = try(each.value.team_id, null)
 refresh_interval = try(each.value.refresh_interval, 0)

 dynamic "timeouts" {
 for_each = anytrue([for v in values(each.value.timeouts): v != null]) ? [each.value.timeouts]: []
 content {
 create = try(timeouts.value.create, null)
 read = try(timeouts.value.read, null)
 update = try(timeouts.value.update, null)
 delete = try(timeouts.value.delete, null)
 }
 }
}
