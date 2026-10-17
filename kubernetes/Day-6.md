# Kubernetes Day 6
# ConfigMaps & Application Configuration

---

# 1. The Problem: Configuration Inside An Application

Imagine a developer writes:

```python
DB_HOST = "mysql-prod"
LOG_LEVEL = "debug"
```

inside application code.

---

## Problems

### Different Environments Need Different Values

Development:

```text
DB_HOST=dev-mysql
```

QA:

```text
DB_HOST=qa-mysql
```

Production:

```text
DB_HOST=prod-mysql
```

You do not want:

```text
Three Different Applications
```

You want:

```text
One Application

Different Configurations
```

---

### Configuration Changes More Often Than Code

Examples:

```text
Database Host

API Endpoint

Log Level

Feature Flags
```

may change regularly.

Application code usually changes less frequently.

---

### Golden Principle

```text
Code
     ≠
Configuration
```

Code should remain the same.

Configuration should change independently.

---

# 2. What Is A ConfigMap?

A ConfigMap is a Kubernetes object used to store:

```text
Non-Sensitive Configuration Data
```

as:

```text
Key-Value Pairs
```

---

Instead of storing values inside application code:

```python
DB_HOST = "mysql-prod"
LOG_LEVEL = "info"
```

store them inside Kubernetes:

```yaml
data:
  DB_HOST: mysql-prod
  LOG_LEVEL: info
```

---

## Real-Life Analogy

Without ConfigMap:

```text
Employee Memorizes Everything
```

If information changes:

```text
Retrain Employee
```

---

With ConfigMap:

```text
Employee
      ↓
Reads Company Notice Board
```

If information changes:

```text
Update Notice Board
```

The employee's behavior can change without changing the employee.

---

## Good Candidates For ConfigMaps

```text
Database Host

API Endpoint

Application Mode

Feature Flags

Log Levels
```

Example:

```text
APP_MODE=production

LOG_LEVEL=info

DB_HOST=mysql-service
```

---

## What Should NOT Go Into ConfigMaps?

Sensitive information such as:

```text
Passwords

API Keys

Tokens

Certificates

Private Keys
```

should go into:

```text
Secrets
```

not ConfigMaps.

---

# 3. What Are Environment Variables?

Environment variables are:

```text
Key-Value Pairs
Provided To A Running Process
```

---

Example:

```bash
export DB_HOST=mysql-prod
```

Any application started from that shell can read:

```text
DB_HOST
```

---

## Why Environment Variables Are Popular

Because virtually every language supports them.

Examples:

```python
os.getenv("DB_HOST")
```

```javascript
process.env.DB_HOST
```

```java
System.getenv("DB_HOST")
```

---

## Important

Environment variables are not a Kubernetes feature.

They are an operating system feature that Kubernetes can use.

---

# 4. ConfigMap vs Environment Variables

These are related, but not the same thing.

---

## ConfigMap Answers

```text
Where Is Configuration Stored?
```

Answer:

```text
Inside Kubernetes
```

---

## Environment Variables Answer

```text
How Does The Application Receive Configuration?
```

Answer:

```text
Through The Process Environment
```

---

## Most Common Relationship

```text
ConfigMap
      ↓
Environment Variables
      ↓
Container
      ↓
Application
```

---

Example:

### ConfigMap

```text
DB_HOST=mysql-service
```

↓

### Environment Variable Inside Container

```text
DB_HOST=mysql-service
```

↓

### Application

```text
Reads DB_HOST
```

↓

### Result

```text
Connects To mysql-service
```

---

## Easy Memory Trick

```text
ConfigMap
     =
Storage

Environment Variable
     =
Delivery Mechanism
```

---

# 5. Environment Variables Inside Deployment

You can define variables directly in a Deployment.

Example:

```yaml
env:
- name: DB_HOST
  value: mysql-prod

- name: LOG_LEVEL
  value: info
```

---

Nothing is wrong with this.

For small applications it is completely acceptable.

---

## Why Use ConfigMaps Then?

As configuration grows:

```text
Deployment
+
Configuration
```

become mixed together.

Using ConfigMaps separates responsibilities:

```text
Deployment
      ↓
How Application Runs

ConfigMap
      ↓
Application Settings
```

---

## Real Production Benefit

Suppose:

```text
20 Applications
```

need:

```text
API_URL=api.company.com
```

Without ConfigMaps:

```text
Edit 20 Deployments
```

With ConfigMaps:

```text
Update One ConfigMap
```

and let applications consume it.

---

# 6. Variable Precedence

A variable can come from multiple places.

---

## ConfigMap

Example:

```text
DB_HOST=mysql-dev
```

---

## Deployment env

Example:

```text
DB_HOST=mysql-prod
```

---

## Command Variable

Example:

```bash
DB_HOST=mysql-test ./app
```

---

## Winner

The most specific definition wins.

### Highest Priority

```text
Command Variable
```

↓

```text
Deployment env
```

↓

```text
ConfigMap (via envFrom/configMapRef)
```

### Lowest Priority

---

Example:

```text
ConfigMap     → mysql-dev

Deployment    → mysql-prod

Command       → mysql-test
```

Application receives:

```text
DB_HOST=mysql-test
```

---

# 7. Two Ways To Consume A ConfigMap

A ConfigMap is only storage.

Applications must consume it somehow.

---

## Method 1: Environment Variables

Most common approach.

Flow:

```text
ConfigMap
      ↓
Environment Variables
      ↓
Container
      ↓
Application
```

---

Benefits:

```text
Simple

Portable

Language Independent

Very Common
```

---

## Method 2: Mounted Files

Instead of environment variables, Kubernetes creates files.

Example ConfigMap:

```yaml
data:
  DB_HOST: mysql-service
  LOG_LEVEL: info
```

Mounted at:

```text
/etc/config
```

creates:

```text
/etc/config/DB_HOST

/etc/config/LOG_LEVEL
```

---

Flow:

```text
ConfigMap
      ↓
Files
      ↓
Container
      ↓
Application Reads Files
```

## How Mounted ConfigMap Files Update

When a ConfigMap is mounted as a volume:

```text
ConfigMap
      ↓
Mounted Files
      ↓
Container
```

Kubernetes updates the projected files when the ConfigMap changes.

---

### Important Clarification

The update is:

```text
Eventually Consistent
```

and may not happen instantly.

Think:

```text
ConfigMap Updated
      ↓
Kubernetes Refreshes Mounted Files
      ↓
Application Can See New Content
```

---

### Application Responsibility

Updating the file is Kubernetes' responsibility.

Using the updated value is the application's responsibility.

The application must:

```text
Re-read The Updated File
```

Depending on the application, this may require:

```text
Configuration Reload

or

Application Restart
```

---

### Important Exception: subPath

If a ConfigMap file is mounted using:

```text
subPath
```

automatic updates do NOT occur.

Example:

```yaml
volumeMounts:
- name: config
  mountPath: /app/config.json
  subPath: config.json
```

In this case:

```text
ConfigMap Updated
      ↓
Mounted File Does NOT Refresh
Automatically
```

A Pod restart is typically required.

---

# Addition To Section 13: Deployment That Uses ConfigMap

## Method 1: envFrom.configMapRef

Example:

```yaml
envFrom:
  - configMapRef:
      name: web-config
```

---

### What It Does

Imports all eligible keys from the referenced ConfigMap.

Example ConfigMap:

```yaml
data:
  APP_ENV: production
  LOG_LEVEL: WARN
```

Container receives:

```text
APP_ENV=production

LOG_LEVEL=WARN
```

---

### Use Case

Use when:

```text
Container Needs Most
Or All ConfigMap Values
```

---

### Flow

```text
ConfigMap
      ↓
All Keys Imported
      ↓
Environment Variables
      ↓
Container
```

---

---

## When To Use What?

### Environment Variables

Best For:

```text
Database Host

URLs

Log Levels

Feature Flags
```

---

### Files

Best For:

```text
JSON Files

Properties Files

NGINX Config Files

Large Configuration Files
```

---

# 8. How The Resources Fit Together

Before ConfigMap:

```text
Deployment
      ↓
Pod
      ↓
Container
      ↓
Hardcoded Configuration
```

---

After ConfigMap:

```text
ConfigMap
      ↓
Deployment Specification
      ↓
Pod
      ↓
Container
      ↓
Application
```

---

A more complete picture:

```text
ConfigMap
      ↓
Provides Configuration

Deployment
      ↓
Manages ReplicaSets

ReplicaSet
      ↓
Maintains Pods

Pods
      ↓
Run Containers

Service
      ↓
Provides Stable Networking
```

---

# 9. What Happens When A ConfigMap Changes?

The answer depends on how the ConfigMap is consumed.

---

## Case 1: Environment Variables

Flow:

```text
ConfigMap
      ↓
Environment Variables
      ↓
Container
```

Pod starts:

```text
DB_HOST=mysql-v1
```

---

ConfigMap changes:

```text
DB_HOST=mysql-v2
```

Running container still uses:

```text
mysql-v1
```

---

Why?

Because:

```text
Environment Variables
Are Read During Container Startup
```

and are not automatically refreshed.

---

To pick up changes:

```text
Restart Pod
```

or

```bash
kubectl rollout restart deployment/config-demo
```

---

## Case 2: Mounted Files

Flow:

```text
ConfigMap
      ↓
Mounted Files
      ↓
Container
```

Kubernetes updates the mounted files automatically.

---

Important:

```text
Kubernetes Updates Files

Application Must Re-read Them
```

Some applications do this automatically.

Others require reload or restart.

---

# 10. Create ConfigMap

```bash
kubectl create configmap web-config \
  --from-literal=APP_ENV=development \
  --from-literal=LOG_LEVEL=INFO
```

---

## kubectl create configmap

Creates:

```text
A ConfigMap Object
```

---

## web-config

ConfigMap name.

---

## --from-literal

Creates key-value entries.

---

### First Entry

```bash
--from-literal=APP_ENV=development
```

Creates:

```text
APP_ENV → development
```

---

### Second Entry

```bash
--from-literal=LOG_LEVEL=INFO
```

Creates:

```text
LOG_LEVEL → INFO
```

---

# 11. Verify And Describe

## Get ConfigMap

```bash
kubectl get configmap web-config
```

Output:

```text
NAME         DATA

web-config   2
```

Meaning:

```text
ConfigMap Contains Two Keys
```

---

## Describe ConfigMap

```bash
kubectl describe configmap web-config
```

Shows the stored key-value pairs.

Example:

```text
APP_ENV=development

LOG_LEVEL=INFO
```

---

# 12. YAML View

```bash
kubectl get configmap web-config -o yaml
```

Example:

```yaml
data:
  APP_ENV: development
  LOG_LEVEL: INFO
```

Important:

```text
ConfigMap Exists

But No Pod Is Using It Yet
```

---

# 13. Create Deployment That Uses ConfigMap

```yaml
envFrom:
  - configMapRef:
      name: web-config
```

---

## envFrom

Meaning:

```text
Import All Keys
From The Referenced Source
```

---

## configMapRef

Meaning:

```text
Use A ConfigMap
As The Source
```

---

## name: web-config

Meaning:

```text
Read From ConfigMap web-config
```

## Method 2: env.configMapKeyRef

Example:

```yaml
env:
  - name: APP_ENV
    valueFrom:
      configMapKeyRef:
        name: web-config
        key: APP_ENV
```

---

### What It Does

Imports only one specific key from the ConfigMap.

Example ConfigMap:

```yaml
data:
  APP_ENV: production
  LOG_LEVEL: WARN
```

Container receives:

```text
APP_ENV=production
```

but NOT:

```text
LOG_LEVEL
```

unless explicitly added.

---

### Environment Variable Name Can Differ

Example:

```yaml
env:
  - name: APPLICATION_MODE
    valueFrom:
      configMapKeyRef:
        name: web-config
        key: APP_ENV
```

Container receives:

```text
APPLICATION_MODE=production
```

---

### Use Case

Use when:

```text
Application Needs
Only Selected Values
From A ConfigMap
```

---

### Flow

```text
ConfigMap
      ↓
Selected Key
      ↓
Environment Variable
      ↓
Container
```

---


---

# 14. Deployment Rollout

```bash
kubectl rollout status deployment/config-demo
```

Output:

```text
successfully rolled out
```

Meaning:

```text
Deployment Completed Successfully

Desired Pods Are Running
```

---

# 15. Describe Deployment

```bash
kubectl describe deployment config-demo
```

Important section:

```text
Environment Variables from:
  web-config ConfigMap
```

Meaning:

```text
Environment Variables
Will Be Imported
From ConfigMap web-config
```

---

Initially:

```text
Environment: <none>
```

because there were no directly defined Deployment environment variables.

---

# 16. Verify Environment Variables

```bash
kubectl exec deployment/config-demo -- printenv
```

Output:

```text
APP_ENV=development

LOG_LEVEL=INFO
```

Proves:

```text
ConfigMap
      ↓
Environment Variables
      ↓
Container
```

worked successfully.

---

## Additional Variables

You may also see:

```text
KUBERNETES_SERVICE_HOST

WEB_SERVICE_SERVICE_HOST

WEB_SERVICE_PORT
```

These are Kubernetes-generated Service environment variables.

---

# 17. Update ConfigMap

```bash
kubectl create configmap web-config \
  --from-literal=APP_ENV=production \
  --from-literal=LOG_LEVEL=WARN \
  --dry-run=client -o yaml | kubectl apply -f -
```

---

Why?

Because:

```text
web-config Already Exists
```

and `kubectl create` alone would fail.

---

This command:

```text
Generates YAML
      ↓
Applies Changes
```

to the existing ConfigMap.

---

# 18. Important Observation

After updating the ConfigMap:

```text
APP_ENV=production

LOG_LEVEL=WARN
```

the running Pod still shows:

```text
APP_ENV=development

LOG_LEVEL=INFO
```

because environment variables are loaded only when the container starts.

---

## Restart Deployment

```bash
kubectl rollout restart deployment/config-demo
```

Meaning:

```text
Update Pod Template Annotation
      ↓
Creates New ReplicaSet
      ↓
Creates New Pods
```

The new Pods read the latest ConfigMap values.

---

# 19. Add Direct Deployment Variable

```bash
kubectl set env deployment/config-demo FEATURE_FLAG=true
```

Meaning:

```text
Modify Deployment Spec

Add Environment Variable
```

---

This changes the Pod template, therefore Kubernetes creates:

```text
New ReplicaSet
      ↓
New Pods
```

---

Describe output changes from:

```text
Environment: <none>
```

to:

```text
Environment:
  FEATURE_FLAG=true
```

Meaning:

```text
FEATURE_FLAG
Comes Directly
From Deployment Configuration
```

while:

```text
APP_ENV

LOG_LEVEL
```

still come from:

```text
ConfigMap web-config
```

---

# Day 6 Golden Rules

```text
ConfigMap
      ↓
Stores Non-Sensitive Configuration

--------------------------------

Environment Variables
      ↓
Deliver Configuration
To Applications

--------------------------------

ConfigMap Consumption

envFrom.configMapRef
      ↓
Imports All Eligible Keys

--------------------------------

env.configMapKeyRef
      ↓
Imports One Specific Key

--------------------------------

Volume Mount
      ↓
Exposes Configuration As Files

Files Update Eventually

Application May Need
To Re-read Them

subPath Mounts
Do NOT Auto-Update

--------------------------------

ConfigMap Changes

Environment Variables
      ↓
Require Pod Restart

Mounted Files
      ↓
Updated Automatically
(Application Must Re-read)

--------------------------------

Deployment
      ↓
Application Lifecycle

ConfigMap
      ↓
Application Settings

Service
      ↓
Networking
```
