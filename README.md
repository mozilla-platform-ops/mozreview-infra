Mozilla DevServices AWS Account Initialization
==============================================

https://mozreview.signin.aws.amazon.com/console

A Terraform configuration to set up a new AWS account.
- Creates an S3 bucket and enables (local) Cloudtrail and bucket logging
- Configures the IAM password policy
- Creates an (empty) group for administrators
- Creates a policy to require Multifactor Authentication
- Attaches MFA and AdministratorAccess policies to admin group
- Creates an S3 bucket for remote state, with SNS-to-email notifications

Helper scripts for working with MFA can be found at https://github.com/klibby/aws_mfa_scripts.git

Input Variables
---------------
- `account_id` - AWS Account ID
- `profile` - AWS profile to use for credentials
- `bucket` - S3 bucket name for Cloudtrail logs
- `region` - AWS region (default: us-west-2)

Variables should be provided either on the command line
e.g. `terraform apply -var 'account_id=XXXXXXXXXXX' -var 'profile=YYYYYYYYY'`

or by creating a terraform.tfvars file, e.g.:
```
account_id="XXXXXXXXXXXX"
profile="YYYYYYYYY"
```

Usage
-----
- Connect the cloudtrail module:
`terraform get -update=true`
- Create terraform.tfvars file, or add vars on command line (see above)
- Generate an execution plan:
`terraform plan`
- Apply the plan:
`terraform apply`

Note: applying the plan may return the following error while adding the S3 bucket policy: 
```
Error parsing JSON: invalid character '$' looking for beginning of value
```
If this occurrs, you will need to manually apply the policy first, and then continue:
```
terraform plan
terraform apply --target module.cloudtrail.template_file.logging_bucket_policy
terraform plan
terraform apply
```

Authors
=======
Created by [Kendall Libby](https://github.com/klibby)

