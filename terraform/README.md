# Terraform AWS Security Lab

## Overview

This lab demonstrates how to identify and remediate AWS infrastructure security misconfigurations using Terraform and Checkov.

The objective is to build a security-hardened AWS S3-based environment and validate the infrastructure against security best practices before deployment.

This lab is part of a broader DevSecOps pipeline where Infrastructure as Code (IaC) security scanning will be integrated into GitHub Actions.

---

## Architecture

The Terraform configuration contains:

* Primary S3 bucket for the DevSecOps lab
* Dedicated S3 bucket for access logs
* AWS KMS customer-managed key
* KMS key alias
* KMS key policy
* S3 server-side encryption using AWS KMS
* S3 bucket versioning
* S3 lifecycle management
* S3 access logging
* S3 public access blocking
* SNS topic for S3 object-created notifications
* SNS encryption using AWS KMS

### Security Flow

```text
                    ┌─────────────────────┐
                    │   Primary S3 Bucket │
                    │                     │
                    │ Encryption: KMS     │
                    │ Versioning: Enabled │
                    │ Logging: Enabled    │
                    └──────────┬──────────┘
                               │
                 Object Created│
                               ▼
                    ┌─────────────────────┐
                    │     SNS Topic       │
                    │                     │
                    │ Encryption: KMS     │
                    └─────────────────────┘


                    ┌─────────────────────┐
                    │   S3 Access Logs    │
                    │       Bucket        │
                    │                     │
                    │ Encryption: KMS     │
                    │ Versioning: Enabled │
                    │ Lifecycle: Enabled  │
                    └─────────────────────┘
```

---

## Security Controls Implemented

### 1. S3 Encryption

Both the primary bucket and logging bucket use AWS KMS encryption.

```text
SSE-KMS
```

This provides stronger key management and auditing capabilities compared with S3-managed encryption keys.

---

### 2. KMS Key Rotation

The customer-managed KMS key has automatic key rotation enabled.

```hcl
enable_key_rotation = true
```

This reduces the long-term exposure associated with using the same cryptographic key material indefinitely.

---

### 3. S3 Versioning

Versioning is enabled on the S3 buckets.

This helps protect against:

* Accidental object deletion
* Accidental overwrites
* Certain recovery scenarios

---

### 4. S3 Lifecycle Management

Lifecycle policies are configured to:

* Expire old objects
* Expire non-current object versions
* Abort incomplete multipart uploads

Incomplete multipart uploads are automatically cleaned up after 7 days.

This prevents abandoned uploads from unnecessarily consuming storage.

---

### 5. S3 Access Logging

The primary S3 bucket sends access logs to a dedicated logging bucket.

Separating the logging destination from the primary bucket provides a dedicated location for audit data.

---

### 6. S3 Public Access Protection

Public access blocking is enabled to reduce the risk of accidental public exposure.

The configuration prevents public ACLs and public bucket policies from exposing the bucket.

---

### 7. SNS Encryption

The SNS topic used for S3 event notifications is encrypted using the customer-managed KMS key.

This protects notification messages at rest.

---

## Checkov Security Validation

Checkov was used to scan the Terraform configuration for AWS security misconfigurations.

Command used:

```bash
checkov -d terraform
```

### Final Scan Result

```text
Passed checks: 43
Failed checks: 0
Skipped checks: 6
```

### Result Summary

| Result  | Count |
| ------- | ----: |
| Passed  |    43 |
| Failed  |     0 |
| Skipped |     6 |

The final scan contains **zero unresolved Checkov failures**.

---

# Findings and Remediation

## CKV_AWS_145 — S3 Bucket Encryption

### Finding

The logging bucket initially used AES256 encryption.

### Remediation

The logging bucket was changed to AWS KMS encryption:

```hcl
sse_algorithm     = "aws:kms"
kms_master_key_id = aws_kms_key.s3.arn
```

### Security Benefit

KMS provides centralized key management, access control and auditability.

---

## CKV_AWS_26 — SNS Topic Encryption

### Finding

The SNS topic was initially not encrypted.

### Remediation

KMS encryption was enabled:

```hcl
kms_master_key_id = aws_kms_key.s3.arn
```

### Security Benefit

Protects SNS messages at rest using a customer-managed KMS key.

---

## CKV2_AWS_62 — S3 Event Notifications

### Finding

The primary S3 bucket did not initially have an event notification configuration.

### Remediation

An S3 notification was configured for object creation events:

```hcl
events = [
  "s3:ObjectCreated:*"
]
```

The notification sends events to the encrypted SNS topic.

### Security Benefit

Provides an event-driven mechanism that can later be integrated with monitoring, alerting or automated response workflows.

---

## Lifecycle Security Findings

Lifecycle controls were added to both buckets.

The configuration includes:

```hcl
abort_incomplete_multipart_upload {
  days_after_initiation = 7
}
```

Non-current object versions are also automatically expired after the configured retention period.

This reduces unnecessary storage accumulation and improves lifecycle hygiene.

---

# Accepted Checkov Exceptions

Not every Checkov recommendation needs to be implemented in every environment.

Six checks were intentionally skipped because they are not required for the scope of this development lab.

## 1. CKV_AWS_109

### Reason

The KMS key policy uses account-root permissions for key administration.

This follows the standard AWS KMS account-level administration model used by the lab.

---

## 2. CKV_AWS_111

### Reason

The KMS administration policy intentionally permits full KMS management through the owning AWS account.

This is required for key administration in this lab.

---

## 3. CKV_AWS_356

### Reason

The KMS key policy uses:

```text
Resource = "*"
```

for the key policy statements.

The principal is restricted to the owning AWS account root, so this is an intentional KMS policy design choice for the lab.

---

## 4. CKV_AWS_144 — Primary S3 Bucket

### Reason

Cross-region replication was not implemented.

Cross-region replication would require additional infrastructure including:

* Secondary AWS region
* Replication IAM role
* Replication policies
* Additional KMS considerations
* Additional storage and transfer costs

The objective of this lab is IaC security validation rather than disaster recovery architecture.

---

## 5. CKV_AWS_144 — Logging Bucket

### Reason

Cross-region replication is also not required for the dedicated logging bucket in this development lab.

Production environments with strict audit or disaster recovery requirements may require replication.

---

## 6. CKV2_AWS_62 — Logging Bucket

### Reason

Event notifications are not required for the dedicated S3 access-log destination.

Adding notifications to the logging bucket would create additional event-processing complexity without providing meaningful value for the purpose of this lab.

---

# Security Decision

The skipped findings were intentionally documented rather than blindly suppressed.

The decision process was:

```text
Checkov Finding
      │
      ▼
Understand the finding
      │
      ▼
Determine security impact
      │
      ▼
Can the control be implemented?
      │
      ├── Yes ──► Remediate
      │
      └── No / Not required
                  │
                  ▼
          Document exception
                  │
                  ▼
            Add Checkov skip
```

This demonstrates a key DevSecOps principle:

> Security scanning should support informed risk decisions rather than simply targeting a zero-finding score.

---

# Files

```text
terraform/
├── main.tf
├── kms.tf
├── encryption.tf
├── lifecycle.tf
├── logging.tf
├── logs-security.tf
├── notifications.tf
├── security.tf
├── versioning.tf
├── .terraform.lock.hcl
└── README.md
```

Terraform state files and local Terraform/plugin directories are intentionally excluded from Git using `.gitignore`.

---

# Validation

The following validation was performed before committing the Terraform configuration.

### Terraform Formatting

```bash
terraform fmt
```

### Terraform Validation

```bash
terraform validate
```

### Checkov Scan

```bash
checkov -d terraform
```

Final security result:

```text
43 Passed
0 Failed
6 Skipped
```

---

# DevSecOps Integration

The next step is to integrate this Checkov scan into GitHub Actions.

The intended pipeline will contain four security gates:

```text
Developer Push
      │
      ▼
┌─────────────────┐
│ Secrets Scanning│
└────────┬────────┘
         ▼
┌─────────────────┐
│ SAST            │
└────────┬────────┘
         ▼
┌─────────────────┐
│ Container Scan  │
└────────┬────────┘
         ▼
┌─────────────────┐
│ IaC / Checkov   │
└────────┬────────┘
         ▼
      Build/Deploy
```

The Terraform Checkov scan implemented in this lab will become the **IaC security gate** of the GitHub Actions pipeline.
