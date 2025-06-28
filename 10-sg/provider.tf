terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.98.0"
    }
  }

  backend "s3" {
    bucket = "84s-tf-remote-state-dev"
    key    = "roboshop-dev-sg" #any string
    region = "us-east-1"
    #dynamodb_table = "84s-tf-remote-state" # as we enabled native s3 locking, we dont need this, this is deprecated
    encrypt      = true #if anybody opens file, it will be encrypted
    use_lockfile = true #use native locking in s3
  }

}


provider "aws" {
  # Configuration options
  #define our default region
  region = "us-east-1"
}
