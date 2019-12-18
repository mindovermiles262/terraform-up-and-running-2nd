## Chapter 3

This chapter introduces backend configurations for terraform.

There is no way to set this up in one shot, so a two step approach is needed.

### Setting up the TF Backend

1. Make sure the `terraform` resource block is commented out inside `main.tf` of the global/s3 directory
1. Run `terraform init` inside global/s3 if you haven't already
1. Run `terraform apply`. This will create the S3 and DynamoDB resources you need.
1. Uncomment the `terraform` resource block inside `main.tf`
1. Run `terraform init` to initialize the backend. TF will prompt you for a 'yes'

### Removing the TF Backend

Removing/Deleting the TF Backend is the opposite of setting it up. Again, it's a two step process.

1. Open your `main.tf` and comment out the `terraform` backend resource block to stop using the TF Backend.
1. Run `terraform init` to copy the state back to your local machine.
1. Run `terraform destroy` to remove the S3 bucket and the DynamoDB

* Note

You may also need to change the S3 bucket's `lifecycle` policy to allow destruction

