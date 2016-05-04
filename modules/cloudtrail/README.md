Terraform Cloudtrail logging module
========================

A Terraform module to create an S3 bucket for, and enable, Cloudtrail logging.

Input Variables
---------------
- `account_id` - AWS Account ID
- `bucket_name` - Name of the S3 bucket


Usage
-----

```js
module "cloudtrail" {
  source = "github.com/klibby/tf_cloudtrail"

  account_id = "123456789"
  bucket_name = "my-s3-bucket"

}
```

Outputs
-------
- `bucket_id` - S3 bucket name
- `bucket_arn` - S3 bucket ARN
- `cloudtrail_id` - Cloudtrail id
- `cloudtrail_arn` - Cloudtrail ARN


Authors
=======

Created by [Kendall Libby](https://github.com/klibby)

License
=======
Mozilla Public License, version 2.0. See LICENSE for full details.
