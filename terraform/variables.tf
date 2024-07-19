variable "aws_access_key" {
  description = "AWS access key"
  type        = string
}

variable "aws_secret_key" {
  description = "AWS secret key"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "key_name" {
  description = "Name of the key pair"
  type        = string
}

variable "public_key_path" {
  description = "Path to the public key"
  type        = string
}

variable "ssh_user" {
  description = "SSH user"
  type        = string
  default     = "ubuntu"
}

variable "ssh_private_key_path" {
  description = "Path to the private key"
  type        = string
}

variable "my_ip" {
  description = "Your IP address for SSH access"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for the instances"
  type        = string
  default     = "ami-0075013580f6322a1"
}

variable "jenkins_master_instance_type" {
  description = "Instance type for Jenkins master"
  type        = string
  default     = "m4.2xlarge"
}

variable "jenkins_slave_instance_type" {
  description = "Instance type for Jenkins slave"
  type        = string
  default     = "t3.medium"
}

variable "jenkins_slave_count" {
  description = "Number of Jenkins slave instances"
  type        = number
  default     = 2
}
