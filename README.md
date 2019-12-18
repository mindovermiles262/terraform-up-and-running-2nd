# Terraform Up and Running
### 2nd Edition

This repo is my code for `Terraform Up and Running 2nd Edition`. As I work through this book I will be typing out the code to learn better.

I hope to be able to use terraform in my next engagement and this book will teach me how to use it.


## Up and Running

1. Download [Terraform](https://www.terraform.io/downloads.html) and place in PATH
2. Once installed, add your AWS Credentials inside `~/.aws/credentials`

```
[default]
aws_access_key_id=AKIAIOSFODNN7EXAMPLE
aws_secret_access_key=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
```


## Running commands

1. `cd` into the chapter directory (ex. `ch2`)
1. Then run `terraform init folder-name` which will initialize TF in the chapter root directory
1. Run each `main.tf` module by running `terraform [command] [folder]`
  * `[ch2]$ terraform plan cluster-server/`

