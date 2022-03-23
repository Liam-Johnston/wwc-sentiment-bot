variable "function_entry_point" {
  type        = string
  description = "Entry point for the function"
}

variable "function_name" {
  type        = string
  description = "Function name"
}

variable "project_id" {
  type        = string
  description = "The id of the project that this function will be deployed into"
}

variable "build_file" {
  type        = string
  description = "The location of the build file for this function"
}
