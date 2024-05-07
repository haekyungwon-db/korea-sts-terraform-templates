# korea-sts-terraform-templates

## Procedure

### AWS BYOVPC

#### Install tfenv
```bash
$ brew install tfenv

$ tfenv install 1.8.2

$ tfenv use 1.8.2

$ tfenv list
```

#### Login to the AWS account (i.e execute aws sso login command)

#### Execute Terraform command
```bash
$ terraform init

$ terraform plan --var-file=input.tfvars

$ terraform apply --var-file=input.tfvars
```

#### Rollback
```bash
$ terraform destroy
```