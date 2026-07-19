# SCOPE — `tf-mod-azuredevops-boards`

> **Module type:** `aggregation`  ·  **Provider:** `microsoft/azuredevops` (`>= 1.0, < 2.0`)  ·  **Scope:** project-scoped

Boards configuration aggregation: area-path permissions, iteration permissions, and dashboards. No primary resource. DISCOVERY: the azuredevops_area and azuredevops_iteration node-creation RESOURCES do not exist in provider v1.15.1 (they are data sources only); classification-node creation is out of scope. Consumes project_id.

---

## In-scope resources

**No primary `this` resource.** Each resource type is an independently-optional, named `for_each` collection. Callers use any, all, or none of the collections.

- `azuredevops_area_permissions`
- `azuredevops_iteration_permissions`
- `azuredevops_dashboard`

## Out-of-scope resources (consumed by ID)

- `azuredevops_project` — provided as `project_id` by `tf-mod-azuredevops-project`.
- Group/team subject descriptors — provided by `tf-mod-azuredevops-group` / `tf-mod-azuredevops-team`.

## Consumes

| Input | Type | Source module |
|---|---|---|
| `project_id` | string | `tf-mod-azuredevops-project` |
| `principal` | string | tf-mod-azuredevops-group / tf-mod-azuredevops-team (for area/iteration permissions) |

## Required Azure DevOps scopes / auth

| Scope / Role | PAT scope | Service-principal role | Required for |
|---|---|---|---|
| Work tracking node security | Work Items (Read, Write & Manage) + Project and Team (Read, Write & Manage) | **Project Administrators** (membership, not a PAT scope) | `area_permissions`, `iteration_permissions` — editing ACEs on the CSS / Iteration security namespaces requires the identity to administer the node |
| Dashboards | Work Items (Read & Write) | **Project Administrators** (project dashboards) or **Team Administrator** + team membership (team dashboards) | `dashboards` — creating/editing a project- or team-scoped dashboard |

> ⚠️ Editing classification-node ACEs is governed by **group membership, not a PAT scope**: the running identity must belong to **Project Administrators** (or hold node-level *Edit this node* / *Create child nodes*). A correctly-scoped PAT held by a non-administrator identity still returns 403. Granting a service principal these rights org-wide is a **Project Collection Administrator** action.

## Emits

| Output | Description | Consumed by |
|---|---|---|
| `<role>_ids` | Maps of dashboard IDs and area/iteration permission IDs keyed by role | downstream modules / audit |
| `ids` | Flattened map of all managed resource IDs | audit / access review |

## Provider gotchas

- DISCOVERY: provider v1.15.1 exposes NO azuredevops_area / azuredevops_iteration RESOURCE (data sources only) — classification-node creation is out of scope; this module manages area/iteration PERMISSIONS and dashboards.
- `area_permissions` / `iteration_permissions` target an EXISTING classification-node path. `path` is optional — omit (or `"/"`) for the root node. There is no provider resource to create the node itself.
- `principal` must be a **group subject descriptor**, not a plain group name — wire it from `tf-mod-azuredevops-group` / `tf-mod-azuredevops-team` (or a `data.azuredevops_group`).
- `permissions` action states are constrained to `Allow` / `Deny` / `NotSet` (validated in `variables.tf`).
- `replace` defaults to **`true`** on both permission collections: the ACE set is REPLACED, not merged. Set `replace = false` to merge into ACEs managed outside Terraform.
- Permission resources expose **no `timeouts`** block. Only `azuredevops_dashboard` supports `timeouts` (create/read/update/delete) — rendered per-dashboard only when a value is set.
- `dashboards`: `project_id` is immutable (ForceNew). `team_id` sets a team-scoped dashboard; omitting it makes it project-scoped. `refresh_interval` accepts only `0` or `5` (minutes; validated). Team dashboards must have unique names; project dashboards may share a name.
- `dashboard.owner_id` (exported) resolves to the owning project or team.
- No collection carries a secret — no output is marked `sensitive`.
- `project_id` is immutable across all collections.

## Design decisions

- Aggregation: after discovery removed the non-existent azuredevops_area keystone, the module groups area/iteration permissions + dashboards with no dominant resource.
- Classification-node CREATION intentionally out of scope (no provider resource exists in v1.15.1).

---

> Regenerate the RAG index after editing this file: `ingest_internal_standards_azuredevops.py`.
