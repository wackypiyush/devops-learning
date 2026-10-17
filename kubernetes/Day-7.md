# Kubernetes Day 7
# Secrets & Sensitive Configuration

---

# 1. What Is A Kubernetes Secret?

Applications often need sensitive values such as:

```text
Database Passwords

API Tokens

JWT Secrets

AWS Access Keys

SSH Keys

Certificates
```

Storing these values inside a ConfigMap is not recommended because ConfigMaps are intended for non-sensitive configuration.

---

## Kubernetes Solution: Secret

A Secret is a Kubernetes object designed to store:

```text
Sensitive Information
```

such as:

```text
Passwords

Tokens

API Keys

SSH Keys

Certificates
```

---

## ConfigMap vs Secret

ConfigMap:

```yaml
data:
  APP_ENV: production
```

Secret:

```yaml
data:
  DB_PASSWORD: bXlwYXNzd29yZA==
```

Both store key-value data.

The difference is their intended purpose.

---

### ConfigMap

```text
Application Settings
```

Examples:

```text
DB_HOST

API_URL

LOG_LEVEL

APP_MODE
```

---

### Secret

```text
Credentials
```

Examples:

```text
DB_PASSWORD

API_TOKEN

JWT_SECRET

SSH_KEY
```

---

## Example

Store:

```text
DB_HOST
```

inside a:

```text
ConfigMap
```

Store:

```text
DB_PASSWORD
```

inside a:

```text
Secret
```

---

# 2. What Is Base64 Encoding?

Many beginners assume:

```text
Secret
      ↓
Encrypted
```

This is incorrect.

---

## Example Secret

```yaml
data:
  PASSWORD: c3VwZXJzZWNyZXQ=
```

This looks encrypted but is actually:

```text
Base64 Encoded
```

---

## What Is Base64?

Base64 is:

```text
An Encoding Scheme
```

It is NOT encryption.

---

## Example

Original:

```text
mypassword
```

Base64:

```text
bXlwYXNzd29yZA==
```

---

### Encoding

```text
mypassword
      ↓
bXlwYXNzd29yZA==
```

---

### Decoding

```text
bXlwYXNzd29yZA==
      ↓
mypassword
```

Anyone can decode it.

---

## Important Rule

```text
Base64
≠
Encryption
```

---

## Why Does Kubernetes Use Base64?

Kubernetes stores Secret values as Base64 strings because it safely represents:

```text
Text

Special Characters

Binary Data
```

inside:

```text
YAML

JSON
```

documents.

---

## Interview Question

### Are Kubernetes Secrets encrypted?

Answer:

```text
Not Automatically.

Secret values are Base64 encoded.

Encoding is NOT encryption.
```

---

## Real Production Security

Production clusters commonly add:

```text
etcd Encryption

KMS

HashiCorp Vault

External Secret Managers
```

for stronger protection.

---

# 3. How Does A Pod Consume A Secret?

A Secret stores data.

Pods consume that data.

The two most common consumption methods are:

```text
Method A:
Environment Variables

Method B:
Mounted Files
```

---

# Method A - Secret As Environment Variables

Suppose the Secret contains:

```text
DB_USERNAME=admin

DB_PASSWORD=secret123
```

Kubernetes injects:

```text
DB_USERNAME=admin

DB_PASSWORD=secret123
```

into the container environment.

---

Application reads them like any other environment variable.

---

## Flow

```text
Secret
      ↓
Environment Variables
      ↓
Container
      ↓
Application
```

---

## When To Use

Best for:

```text
Database Passwords

API Tokens

Cloud Credentials

Application Secrets
```

---

# Method B - Secret As Mounted Files

Instead of environment variables:

```text
Secret
      ↓
Volume Mount
      ↓
Files
```

---

Suppose Secret contains:

```text
USERNAME=admin

PASSWORD=secret123
```

Mounted at:

```text
/etc/secrets
```

Kubernetes creates:

```text
/etc/secrets/USERNAME

/etc/secrets/PASSWORD
```

---

Example:

```text
/etc/secrets/USERNAME
```

contains:

```text
admin
```

---

```text
/etc/secrets/PASSWORD
```

contains:

```text
secret123
```

---

Application reads the files.

---

## Flow

```text
Secret
      ↓
Files
      ↓
Container
      ↓
Application
```

---

## When To Use

Best for:

```text
TLS Certificates

Private Keys

SSH Keys

Certificate Chains

File-Based Credentials
```

---

## Environment Variables vs Mounted Files

### Environment Variables

Best For:

```text
Passwords

API Keys

Database Credentials

Tokens
```

---

### Mounted Files

Best For:

```text
TLS Certificates

Private Keys

SSH Keys

Configuration Files
```

---

# 4. The Key YAML Fields

A typical Secret:

```yaml
apiVersion: v1
kind: Secret

metadata:
  name: db-secret

type: Opaque

data:
  DB_USERNAME: YWRtaW4=
  DB_PASSWORD: c2VjcmV0MTIz
```

---

## apiVersion

```yaml
apiVersion: v1
```

Specifies:

```text
Which Kubernetes API Version
This Resource Uses
```

For Secrets:

```text
v1
```

is the common value.

---

## kind

```yaml
kind: Secret
```

Tells Kubernetes:

```text
Create A Secret Object
```

---

## metadata

```yaml
metadata:
  name: db-secret
```

Defines the Secret identity.

Secret name:

```text
db-secret
```

Pods reference this name later.

---

## type

```yaml
type: Opaque
```

Specifies:

```text
What Kind Of Secret Is This?
```

---

### Opaque

Most common type.

```text
General Purpose Secret
```

Used for:

```text
Passwords

Usernames

Tokens

API Keys
```

---

## data

```yaml
data:
```

Stores Secret values.

Important:

```text
Values In data
Must Be Base64 Encoded
```

Example:

```yaml
data:
  DB_PASSWORD: c2VjcmV0MTIz
```

---

## stringData

Alternative input field.

Example:

```yaml
stringData:
  DB_USERNAME: admin
  DB_PASSWORD: secret123
```

---

Kubernetes automatically converts:

```text
stringData
```

into:

```text
data
```

during creation.

---

## Recommendation

When writing Secret YAML manually:

```text
Use stringData
```

because it is easier to read and edit.

---

# 5. What Happens When A Secret Changes?

The answer depends on how the Secret is consumed.

---

# Case 1 - Secret As Environment Variables

Flow:

```text
Secret
      ↓
Environment Variables
      ↓
Container
```

Container starts:

```text
DB_PASSWORD=secret123
```

---

Secret changes:

```text
DB_PASSWORD=secret456
```

---

Running container still uses:

```text
DB_PASSWORD=secret123
```

---

## Why?

Because:

```text
Environment Variables
Are Loaded During Container Startup
```

and do not automatically refresh.

---

## To Pick Up Changes

Restart:

```text
Pod
```

or

```text
Deployment
```

Example:

```bash
kubectl rollout restart deployment my-app
```

---

# Case 2 - Secret As Mounted Files

Flow:

```text
Secret
      ↓
Mounted Files
      ↓
Application
```

---

When the Secret changes:

```text
Kubernetes Updates
The Mounted Files Automatically
```

---

However:

```text
Application Must Re-read The Files
```

to use the new values.

---

Some applications:

```text
Reload Automatically
```

Others:

```text
Require Restart
```

---

## Important Exception

Just like ConfigMaps:

```text
subPath Mounts
Do NOT Auto-Update
```

Example:

```yaml
mountPath: /app/password
subPath: password
```

A Pod restart is usually required.

---

# 6. Security Rules To Remember

---

## Rule 1

### Secret ≠ Encryption

Secrets are:

```text
Base64 Encoded
```

not automatically encrypted.

Remember:

```text
Base64
≠
Encryption
```

Anyone with Secret read access can decode the values.

---

## Rule 2

### Never Put Passwords In ConfigMaps

Bad:

```yaml
kind: ConfigMap

data:
  DB_PASSWORD: secret123
```

Good:

```yaml
kind: Secret
```

---

## Rule 3

### Avoid Hardcoding Secrets

Bad:

```python
PASSWORD = "secret123"
```

Bad:

```yaml
env:
  - name: PASSWORD
    value: secret123
```

Better:

```text
Secret
      ↓
Environment Variable
      ↓
Application
```

---

## Rule 4

### Give Access Only To Those Who Need It

Not every Pod should receive every Secret.

Example:

```text
Backend
      ↓
Needs Database Password

Frontend
      ↓
Does Not
```

---

## Rule 5

### Be Careful With Logs

Bad:

```python
print(DB_PASSWORD)
```

Reason:

```text
Secrets Can Leak Into Logs
```

---

## Rule 6

### Be Careful During Troubleshooting

Avoid copying credentials into:

```text
Chats

Tickets

Emails

Documents
```

---

## Rule 7

### Prefer Mounted Files For Certificates

Examples:

```text
TLS Certificates

Private Keys

SSH Keys
```

These are often easier and safer to manage as files.

---

## Rule 8

### Enable Encryption At Rest

Where supported:

```text
Enable Encryption At Rest
For Secret Storage
```

to better protect data stored in etcd.

---

## Rule 9

### Do Not Store Credentials In Git

Avoid committing secrets directly to repositories.

Production environments often use:

```text
Vault

External Secret Managers

Managed Secret Stores
```

---

# 7. Create Secret

```bash
kubectl apply -f - <<'EOF'
apiVersion: v1
kind: Secret
metadata:
  name: app-secret
type: Opaque
stringData:
  DB_USER: demo_user
  DB_PASSWORD: demo-only-password-123
EOF
```

Output:

```text
secret/app-secret created
```

Meaning:

```text
A Secret Named app-secret
Was Created Successfully
```

---

# 8. Verify Secret Exists

```bash
kubectl get secret app-secret
```

Output:

```text
NAME         TYPE     DATA

app-secret   Opaque   2
```

---

## Meaning

```text
DATA = 2
```

means:

```text
Two Keys Exist
```

inside the Secret.

---

# 9. Describe Secret

```bash
kubectl describe secret app-secret
```

Output:

```text
DB_PASSWORD: 22 bytes

DB_USER: 9 bytes
```

---

Notice:

```text
Actual Values Are Hidden
```

Kubernetes shows:

```text
Data Size
```

instead of displaying the secret values.

---

# 10. View Secret YAML

```bash
kubectl get secret app-secret -o yaml
```

Output:

```yaml
data:
  DB_PASSWORD: ZGVtby1vbmx5LXBhc3N3b3JkLTEyMw==
  DB_USER: ZGVtb191c2Vy
```

---

Important observations:

```text
stringData Is Gone

Kubernetes Stored data Instead

Values Are Base64 Encoded
```

---

# 11. Decode Secret

```bash
kubectl get secret app-secret \
  -o jsonpath='{.data.DB_PASSWORD}' | base64 --decode
```

Output:

```text
demo-only-password-123
```

---

## Understanding The Command

### jsonpath

Extracts:

```text
.data.DB_PASSWORD
```

from the Secret.

Result:

```text
ZGVtby1vbmx5LXBhc3N3b3JkLTEyMw==
```

---

### base64 --decode

Converts:

```text
Encoded Value
```

back into:

```text
Original Secret Value
```

---

## What Does This Prove?

```text
Base64
≠
Encryption
```

---

# 12. Create Deployment That Uses Secret

Example:

```yaml
env:
  - name: DB_USER
    valueFrom:
      secretKeyRef:
        name: app-secret
        key: DB_USER

  - name: DB_PASSWORD
    valueFrom:
      secretKeyRef:
        name: app-secret
        key: DB_PASSWORD
```

---

## secretKeyRef

Meaning:

```text
Take A Specific Key
From A Secret
```

and create an environment variable.

Example:

```text
Secret Key

DB_USER
```

↓

```text
Environment Variable

DB_USER
```

---

## Flow

```text
Secret
      ↓
secretKeyRef
      ↓
Environment Variable
      ↓
Container
```

---

# 13. Deployment Rollout

```bash
kubectl rollout status deployment/secret-demo
```

Output:

```text
deployment "secret-demo" successfully rolled out
```

Meaning:

```text
Deployment Finished Creating Pods

Desired Pods Are Running
```

---

# 14. Describe Deployment

```bash
kubectl describe deployment secret-demo
```

Output:

```text
DB_USER:
<set to the key 'DB_USER' in secret 'app-secret'>

DB_PASSWORD:
<set to the key 'DB_PASSWORD' in secret 'app-secret'>
```

---

Notice:

```text
Kubernetes Does NOT Show
The Secret Values
```

Instead it shows:

```text
References To The Secret
```

for security.

---

# 15. Verify Secret Values Inside Container

```bash
kubectl exec deployment/secret-demo -- sh -c \
'echo "DB_USER=$DB_USER"; echo "DB_PASSWORD=$DB_PASSWORD"'
```

Output:

```text
DB_USER=demo_user

DB_PASSWORD=demo-only-password-123
```

---

This proves:

```text
Secret
      ↓
Environment Variables
      ↓
Container
      ↓
Application
```

worked successfully.

---

# Day 7 Golden Rules

```text
ConfigMap
      ↓
Non-Sensitive Data

Secret
      ↓
Sensitive Data

--------------------------------

Base64
      ↓
Encoding

NOT Encryption

--------------------------------

Secret
      ↓
Stores Credentials

--------------------------------

Secrets Can Be Consumed As

1. Environment Variables

2. Mounted Files

--------------------------------

Environment Variables
      ↓
Require Restart After Change

Mounted Files
      ↓
Auto-Update Eventually

Application Must Re-read Files

subPath Mounts
      ↓
Do NOT Auto-Update

--------------------------------

Configuration
      ↓
ConfigMap

Credentials
      ↓
Secret
```
