packer {
  required_plugins {
    amazon = {
      version = ">= 1"                        # Specifies the minimum version of the Amazon plugin for Packer
      source  = "github.com/hashicorp/amazon" # Source location of the Amazon plugin
    }
  }
}

# Variables to be used in the template
variable "aws_region" {
  type    = string
  default = ""
}

variable "source_ami" {
  type    = string
  default = ""
}

variable "ssh_username" {
  type    = string
  default = ""
}

variable "subnet_id" {
  type    = string
  default = ""
}

variable "ami_users" {
  type = string
  default = ""
}

# Source block to define the image to be built
source "amazon-ebs" "csye6225-ami" {
  region          = var.aws_region
  ami_name        = "csye6225-ami-${formatdate("YYYY_MM_DD_hh_mm_ss", timestamp())}"
  ami_description = "CSYE6225 Assignment-04"

  aws_polling {
    delay_seconds = 120
    max_attempts  = 50
  }

  ami_users     = [var.ami_users]
  instance_type = "t2.micro"                 # Instance type to be used for the build
  source_ami    = var.source_ami          # The source AMI from which to create the new AMI
  ssh_username  = var.ssh_username         # SSH username for the instance
  subnet_id     = var.subnet_id            # Subnet ID for network configuration

  # Block to define the EBS volume settings
  launch_block_device_mappings {
    delete_on_termination = true        # Delete the EBS volume when the instance is terminated
    device_name           = "/dev/sda1" # Device name for the root volume
    volume_size           = 8           # Size of the root volume in GB
    volume_type           = "gp2"       # Type of the EBS volume
  }
}

# Build block where the sources and provisioners are defined
build {
  sources = [
    "source.amazon-ebs.csye6225-ami" # Reference to the source defined above
  ]

  #Provisioner to upload application files to the instance
  provisioner "file" {
   source      = "webapp.zip"  # Path to the web application zip file
  destination = "~/"  # Destination path on the instance
  }

   #Provisioner to run shell commands from an external script
  provisioner "shell" {
   script = "installing_dependencies.sh"  # Reference to the external shell script for setup tasks
  }
}
