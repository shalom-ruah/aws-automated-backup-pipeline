# Automated AWS Backup Pipeline

An automated backup and audit pipeline built with AWS services, Bash scripting and Linux automation.

## Architecture

Deployed in AWS Europe (Stockholm), eu-north-1.

- Amazon VPC with public and private subnets.
- Bastion EC2 instance for controlled SSH access.
- Private EC2 application server with no public IP.
- Systemd service generating application log data.
- Bash backup script scheduled through cron.
- Private S3 access through a Gateway VPC Endpoint.
- EC2 IAM role with upload-only S3 permissions.
- S3 event notification invoking AWS Lambda.
- DynamoDB table storing backup audit records.
- CloudWatch storing Lambda execution logs.

## Backup workflow

1. A systemd service writes timestamped entries to `/var/app/data/app.log`.
2. `scripts/backup.sh` archives `/var/app/data`.
3. The archive is uploaded to the S3 bucket under `backups/`.
4. Backup outcomes are written to `/var/log/backup.log`.
5. Cron runs the script every ten minutes.
6. S3 object-created events invoke Lambda.
7. Lambda records the bucket, object key, event time and event type in DynamoDB.

## Security

The application server uses an attached EC2 IAM role instead of stored AWS access keys.

Its policy grants `s3:PutObject` only to the designated backup prefix. It does not grant `s3:DeleteObject`.

The private application server has no public IP. SSH access is routed through the bastion host.

An S3 Gateway VPC Endpoint provides private connectivity to S3 without requiring a NAT Gateway for backup traffic.

## Verification

The implementation was tested by:

- Checking the data-generator service and application log.
- Confirming backup uploads to S3.
- Confirming IAM denied backup deletion attempts.
- Confirming S3 events invoked Lambda.
- Confirming audit records appeared in DynamoDB.
- Checking Lambda execution logs in CloudWatch.
- Removing the NAT Gateway and confirming S3 uploads still worked while general external access failed.

## Repository contents

- `scripts/`: Bash backup automation.
- `systemd/`: Application data generator service.
- `lambda/`: S3 event processing function.
- `iam/`: Example IAM policy documents.
- `docs/images/`: Project screenshots and architecture illustration.

## Future improvements

- S3 Versioning and Object Lock where appropriate.
- Lifecycle policies and backup retention.
- Monitoring and failure alerts.
- Regular backup restoration tests.
- Terraform infrastructure provisioning.

## Implementation note

The original AWS infrastructure was configured through the AWS Management Console. Terraform was not used in that deployment. A future Terraform implementation will be a separate project.
