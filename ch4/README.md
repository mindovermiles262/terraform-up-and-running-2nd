## Chapter 4
## Modules

## Up and Running

#### Terraform Backend

1. Add your AWS IAM Credentials provided in `~/.aws/credentials`
1. Set up the S3 backend:
  * Edit the `global/s3/main.tf` file and remove the `terraform {}` resource
  * From the `ch4` root, run `[ch4] $ terraform init global/s3`
  * Once initialized, create the resources: `[ch4]$ terraform [plan/apply] global/s3`
1. Go back and uncomment the `terraform {}` resource in `global/s3/main.tf`
1. Re-initialize the backend: `[ch4]$ terraform init global/s3`

#### MySQL

Once the AWS Backend is provisioned and configured, you'll need to create the Database that the webservers will rely on. Configuration is in the `[staging/prod]/data-stores/mysql` folder (Note: prod isn't configured yet so only staging/data-stores/mysql will work)

1. Initialize the folder: `[ch4]$ terraform init staging/data-stores/mysql`
1. Plan and Apply the resource: `[ch4]$ terraform [plan/apply] staging/data-stores/mysql`


### Terraform Tips

* `providers` should not be included in modules. They should be set by the user.

