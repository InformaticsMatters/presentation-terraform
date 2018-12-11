# Define your GitLab Personal Access Token and the project
# in the following environment variables...
#
# TF_VAR_gitlab_token
# TF_VAR_gitlab_project

variable "gitlab_token" {}
variable "gitlab_project" {}

variable "add_discussion" {
  default = false
}

provider "gitlab" {
  token = "${var.gitlab_token}"
}

resource "gitlab_label" "fixme" {
  project = "${var.gitlab_project}"
  name = "FixMe"
  description = "Issues that need to be fixed"
  color = "cadetblue"
}

resource "gitlab_label" "discussion" {
  project = "${var.gitlab_project}"
  name = "Discussion"
  description = "Issues that need a round of discussion priro to action"
  color = "forestgreen"
  count = "${var.add_discussion ? 1 : 0}"
}
