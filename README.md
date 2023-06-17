# About

The following repo is a complementary repo to [my blog post](https://www.nickminaev.com/posts/tf-lambda-env-vars-w-kms-encryption.html) about enabling in transit encryption in Lambda functions in AWS with the KMS service.

Note that for this tutorial you'd need:

- An AWS account.
- Basic knowledge of Hashicorp Terraform.
- AWS credentials configured, so you can deploy the resources described in the `main.tf` file.
- We won't use an actual database. But you're welcome to implement this tutorial on any service that you use.
- Some basic idea of what is [AWS KMS](https://docs.aws.amazon.com/kms/latest/developerguide/overview.html) is.

> ⚠️ Your operations might acrue costs in AWS. Use this tutorial wisely. Don't forget to `terraform destroy` in the end.

# Run the code

```bash
git clone https://github.com/nickminaev/tf-in-transit-encryption-in-aws-lambdas.git
cd tf-in-transit-encryption-in-aws-lambdas
sudo chmod 755 build.sh
./build.sh
```

