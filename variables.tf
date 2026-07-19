###############################################################################
# tf_mod_azuredevops_boards — variables
#
# AGGREGATION module: there is NO primary `this` resource. Each resource type is
# an independently-optional, named `for_each` collection. Callers may use any,
# all, or none of the collections. This module is PROJECT-scoped — every managed
# resource hangs off a single parent `project_id`.
###############################################################################

variable "project_id" {
 description = <<EOT
The Azure DevOps project that owns every Boards resource managed by this module.
IMMUTABLE — changing this forces destroy/recreate of the dashboards and
re-application of the area/iteration permissions. Wire from
tf_mod_azuredevops_project (project_id output).
EOT
 type = string

 validation {
 condition = length(trimspace(var.project_id)) > 0
 error_message = "project_id must be a non-empty Azure DevOps project ID."
 }
}

variable "area_permissions" {
 description = <<EOT
Area-path (Component) permission assignments, keyed by a caller-supplied stable
string. Each entry grants/denies a group principal on a classification-node path.
{
 "<key>" = {
 principal = string # group subject descriptor (from tf_mod_azuredevops_group / _team)
 permissions = map(string) # action => one of "Allow" | "Deny" | "NotSet"
 path = optional(string) # area path; omit or "/" for the root area
 replace = optional(bool, true) # true = replace existing ACEs; false = merge
 }
}
Available actions: GENERIC_READ, GENERIC_WRITE, CREATE_CHILDREN, DELETE,
WORK_ITEM_READ, WORK_ITEM_WRITE, MANAGE_TEST_PLANS, MANAGE_TEST_SUITES,
WORK_ITEM_SAVE_COMMENT. Targets an EXISTING area node — this module does not
create classification nodes.
EOT
 type = map(object({
 principal = string
 permissions = map(string)
 path = optional(string)
 replace = optional(bool, true)
 }))
 default = {}

 validation {
 condition = alltrue([
 for k, v in var.area_permissions: alltrue([
 for action, state in v.permissions: contains(["Allow", "Deny", "NotSet"], state)
 ])
 ])
 error_message = "Every area_permissions permission state must be one of: Allow, Deny, NotSet."
 }
}

variable "iteration_permissions" {
 description = <<EOT
Iteration-path (Sprint) permission assignments, keyed by a caller-supplied stable
string. Each entry grants/denies a group principal on a classification-node path.
{
 "<key>" = {
 principal = string # group subject descriptor (from tf_mod_azuredevops_group / _team)
 permissions = map(string) # action => one of "Allow" | "Deny" | "NotSet"
 path = optional(string) # iteration path; omit or "/" for the root iteration
 replace = optional(bool, true) # true = replace existing ACEs; false = merge
 }
}
Available actions: GENERIC_READ, GENERIC_WRITE, CREATE_CHILDREN, DELETE. Targets
an EXISTING iteration node — this module does not create classification nodes.
EOT
 type = map(object({
 principal = string
 permissions = map(string)
 path = optional(string)
 replace = optional(bool, true)
 }))
 default = {}

 validation {
 condition = alltrue([
 for k, v in var.iteration_permissions: alltrue([
 for action, state in v.permissions: contains(["Allow", "Deny", "NotSet"], state)
 ])
 ])
 error_message = "Every iteration_permissions permission state must be one of: Allow, Deny, NotSet."
 }
}

variable "dashboards" {
 description = <<EOT
Boards dashboards, keyed by a caller-supplied stable string. A dashboard is
project-scoped by default, or team-scoped when team_id is set. NOTE: project-level
dashboards may share a name, but a team's dashboards must each have a unique name.
{
 "<key>" = {
 name = string # dashboard display name
 description = optional(string) # dashboard description
 team_id = optional(string) # team ID for a team-scoped dashboard; omit for project-scoped
 refresh_interval = optional(number, 0) # client auto-refresh minutes; one of 0 or 5
 timeouts = optional(object({
 create = optional(string)
 read = optional(string)
 update = optional(string)
 delete = optional(string)
 }), {})
 }
}
EOT
 type = map(object({
 name = string
 description = optional(string)
 team_id = optional(string)
 refresh_interval = optional(number, 0)
 timeouts = optional(object({
 create = optional(string)
 read = optional(string)
 update = optional(string)
 delete = optional(string)
 }), {})
 }))
 default = {}

 validation {
 condition = alltrue([
 for k, v in var.dashboards: contains([0, 5], v.refresh_interval)
 ])
 error_message = "dashboards refresh_interval must be either 0 or 5 (minutes)."
 }
}
