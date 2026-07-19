###############################################################################
# tf_mod_azuredevops_boards — outputs
#
# AGGREGATION module outputs are MAPS keyed by the caller's collection key. An
# unused collection yields an empty map ({}), never an error. No collection in
# this module carries secrets, so no output is marked sensitive.
###############################################################################

output "area_permission_ids" {
 description = "Map of area-permission key => resource ID."
 value = { for k, v in azuredevops_area_permissions.area_permissions: k => v.id }
}

output "iteration_permission_ids" {
 description = "Map of iteration-permission key => resource ID."
 value = { for k, v in azuredevops_iteration_permissions.iteration_permissions: k => v.id }
}

output "dashboard_ids" {
 description = "Map of dashboard key => dashboard ID."
 value = { for k, v in azuredevops_dashboard.dashboards: k => v.id }
}

output "dashboard_owner_ids" {
 description = "Map of dashboard key => owner ID (the owning project or team)."
 value = { for k, v in azuredevops_dashboard.dashboards: k => v.owner_id }
}

output "ids" {
 description = "Flattened map of every managed resource ID, keyed as \"<collection>/<key>\" — for audit / access review."
 value = merge({ for k, v in azuredevops_area_permissions.area_permissions: "area_permissions/${k}" => v.id },
 { for k, v in azuredevops_iteration_permissions.iteration_permissions: "iteration_permissions/${k}" => v.id },
 { for k, v in azuredevops_dashboard.dashboards: "dashboards/${k}" => v.id },)
}
