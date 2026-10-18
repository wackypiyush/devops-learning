# Kubernetes Day 10
# Namespaces

---

# 1. What Is A Namespace?

Imagine a Kubernetes cluster used by multiple teams:

```text
Frontend Team

Backend Team

DevOps Team

QA Team
```

All teams create resources:

```text
Pods

Deployments

Services

ConfigMaps

Secrets
```

Question:

```text
How Do We Organize Everything?
```

Kubernetes solves this using:

```text
Namespaces
```

---

## Definition

A Namespace is a logical partition inside a Kubernetes cluster.

Think of it as a:

```text
Virtual Folder

OR

Virtual Workspace
```

inside the cluster.

---

## Without Namespaces

```text
Cluster

├── Pod
├── Pod
├── Service
├── Secret
├── Deployment
├── ConfigMap
```

Everything is mixed together.

---

## With Namespaces

```text
Cluster

├── frontend
│   ├── Pods
│   ├── Services
│
├── backend
│   ├── Pods
│   ├── Secrets
│
└── qa
    ├── Pods
    ├── Deployments
```

Much cleaner and easier to manage.

---

## Important

A Namespace is:

```text
NOT

A Separate Cluster
```

All namespaces still share:

```text
Same Kubernetes Cluster

Same Control Plane

Same Nodes

Same Physical Resources
```

Think:

```text
One House

Many Rooms
```

Not:

```text
Many Houses
```

---

## Why Do We Need Namespaces?

Namespaces provide:

```text
Organization

Logical Isolation

Access Control

Resource Management
```

---

# 2. Namespaces Are Scoped Names

This is the most important namespace concept.

---

## Without Namespaces

Deployment names must be unique.

Example:

```text
web-app
```

can exist only once.

---

## With Namespaces

The same name can exist in different namespaces.

Examples:

```text
frontend/web-app

backend/web-app
```

Both are valid.

---

Kubernetes treats them as:

```text
namespace/resource-name
```

Examples:

```text
frontend/web-app

backend/web-app
```

Different resources because they belong to different namespaces.

---

## Example

You can have:

```text
dev/mysql

staging/mysql

prod/mysql
```

simultaneously.

This is called:

```text
Namespace Scoping
```

---

# 3. The Default Namespace

When Kubernetes is installed, several namespaces already exist.

Typical namespaces:

```text
default

kube-system

kube-public

kube-node-lease
```

---

## What Is The Default Namespace?

If no namespace is specified:

```bash
kubectl create deployment web-app --image=nginx
```

Kubernetes automatically uses:

```text
default
```

namespace.

---

## Example

When you run:

```bash
kubectl get deployments
```

it actually means:

```bash
kubectl get deployments -n default
```

---

Most beginner labs run inside:

```text
default
```

namespace.

---

## Easy Rule

```text
kubectl uses the namespace configured in the current context; in your current context, that is default.
Verify it with:
kubectl config view --minify \
  -o jsonpath='{..namespace}'

If the command prints nothing, the context has no explicit namespace configured, and kubectl defaults to default.
```
---

# 4. Security Isolation

Namespaces are NOT complete security boundaries.

---

## Wrong Thinking

```text
Different Namespace
      ↓
Fully Isolated
```

This is:

```text
False
```

---

Namespaces provide:

```text
Logical Isolation
```

not complete security isolation.

---

## What Namespaces Help Isolate

### Resources

Examples:

```text
Pods

Deployments

Services

Secrets

ConfigMaps
```

---

### Access Control

Using RBAC we can allow:

```text
Developer A
      ↓
Access Only dev Namespace
```

while blocking access to:

```text
Production Namespace
```

---

### Resource Quotas

One namespace can be limited to:

```text
4 CPU

8 Gi Memory
```

while another may receive:

```text
16 CPU

32 Gi Memory
```

---

## What Namespaces Do NOT Fully Isolate

Namespaces still share:

```text
Nodes

Linux Kernel

Network Infrastructure

Control Plane
```

Therefore:

```text
Namespace
      ≠
Separate Cluster
```

---

# 5. Essential Namespace Commands

---

## List Namespaces

```bash
kubectl get namespaces
```

or

```bash
kubectl get ns
```

---

## Create Namespace

```bash
kubectl create namespace dev
```

---

## Delete Namespace

```bash
kubectl delete namespace dev
```

Warning:

```text
Deleting A Namespace
Deletes All Resources Inside It
```

---

## View Resources In A Namespace

Pods:

```bash
kubectl get pods -n dev
```

Deployments:

```bash
kubectl get deployments -n dev
```

Services:

```bash
kubectl get services -n dev
```

---

## Create Resource In A Namespace

```bash
kubectl create deployment nginx \
  --image=nginx \
  -n dev
```

---

## Describe Namespace

```bash
kubectl describe namespace dev
```

Shows:

```text
Labels

Annotations

Status

Resource Quotas

LimitRanges
```

---

## See Current Namespace

```bash
kubectl config view --minify | grep namespace
```

If nothing is shown:

```text
default Namespace Is Being Used
```

---

## Show Pods From Every Namespace

```bash
kubectl get pods -A
```

or

```bash
kubectl get pods --all-namespaces
```

---

## Show Common Resources In One Namespace

```bash
kubectl get all -n dev
```

Useful for answering:

```text
What Is Running
Inside This Namespace?
```

Your notes call it “common resources,” which is correct. Keep that wording prominent: it does not display every resource type, such as Secrets, ConfigMaps, or every possible custom resource.

## Inspect a resource's namespace
```bash
kubectl get deployment web-app -n dev \
  -o jsonpath='{.metadata.namespace}{"\n"}'
```

Expected output: dev
```text
This is useful when troubleshooting similarly named resources.
```
---

# 6. Cluster-Scoped vs Namespace-Scoped Resources

Not all Kubernetes resources belong to namespaces.

Resources are divided into:

```text
Namespace-Scoped Resources

Cluster-Scoped Resources
```

---

# Namespace-Scoped Resources

These resources live inside namespaces.

Examples:

```text
Pods

Deployments

ReplicaSets

Services

ConfigMaps

Secrets

Jobs

CronJobs

Ingresses
```

---

Example:

```text
Cluster

├── dev
│   ├── web-app
│   └── mysql
│
└── prod
    ├── web-app
    └── mysql
```

No naming conflict occurs because names are scoped to namespaces.

---

# Cluster-Scoped Resources

These resources belong to the entire cluster.

They do NOT belong to any namespace.

Examples:

```text
Nodes

Namespaces

PersistentVolumes (PV)

StorageClasses

ClusterRoles

ClusterRoleBindings
```

---

Example:

```text
Node:
devops-lab-control-plane
```

belongs to the entire cluster.

It does not belong to:

```text
default

dev

prod
```

---

## Interview Questions

### Is a Pod cluster-scoped or namespace-scoped?

```text
Namespace-Scoped
```

---

### Is a Node cluster-scoped or namespace-scoped?

```text
Cluster-Scoped
```

---

### Is a Namespace itself namespace-scoped?

```text
No

Namespace Is Cluster-Scoped
```

---

# 7. Built-In Namespaces In The Cluster

During the lab the cluster contained:

```text
default

kube-system

kube-public

kube-node-lease

local-path-storage
```

---

## default

Used for:

```text
User Workloads
```

Examples:

```text
config-demo

secret-demo

resource-demo

web-app
```

---

## kube-system

Contains Kubernetes system components.

Examples:

```text
coredns

etcd

kube-apiserver

kube-controller-manager

kube-scheduler

kube-proxy
```

---

## kube-public

Public cluster information.

---

## kube-node-lease

Used for node heartbeat and availability tracking.

---

## local-path-storage

Contains the local storage provisioner used by Kind.

---

# 8. Create A New Namespace

Command:

```bash
kubectl apply -f - <<'EOF'
apiVersion: v1
kind: Namespace
metadata:
  name: dev
EOF
```

Output:

```text
namespace/dev created
```

---

Meaning:

A new namespace named:

```text
dev
```

was created.

---

Verify:

```bash
kubectl get namespaces
```

Output included:

```text
dev
```

---

## Describe Namespace

Command:

```bash
kubectl describe namespace dev
```

Output:

```text
Status: Active

No resource quota.

No LimitRange resource.
```

Meaning:

```text
Namespace Is Ready

No Resource Quotas Configured

No Default Resource Limits Configured
```

---

# 9. Deploy Application Into dev Namespace

Command:

```bash
kubectl apply -n dev ...
```

Important:

```bash
-n dev
```

means:

```text
Create Resources
Inside dev Namespace
```

---

Resources Created:

```text
Deployment:
web-app

Service:
web-service
```

---

Verify:

```bash
kubectl get deployments -n dev
```

Output:

```text
web-app
```

---

Rollout Check:

```bash
kubectl rollout status deployment/web-app -n dev
```

Output:

```text
deployment "web-app" successfully rolled out
```

Meaning:

```text
Deployment Created

ReplicaSet Created

Pod Created

Container Running
```

---

# 10. Same Resource Name In Different Namespaces

Default Namespace already contained:

```text
web-app
```

Deployment.

---

Dev Namespace also contains:

```text
web-app
```

Deployment.

---

Both coexist:

```text
default/web-app

dev/web-app
```

---

This proves:

```text
Namespaces Scope Resource Names
```

Same name.

Different namespace.

No conflict.

---

The same applies to Services:

```text
default/web-service

dev/web-service
```

---

# 11. Compare Resources Across Namespaces

Default Deployments:

```bash
kubectl get deployments -n default
```

---

Dev Deployments:

```bash
kubectl get deployments -n dev
```

---

Default Services:

```bash
kubectl get services -n default
```

---

Dev Services:

```bash
kubectl get services -n dev
```

---

Observe:

```text
Same Names

Different Objects

Different Cluster IPs
```

---

# 12. View Only Resources In dev

Command:

```bash
kubectl get all -n dev
```

Output included:

```text
Pod

Service

Deployment

ReplicaSet
```

---

Meaning:

```text
Show Common Resources
Only In Namespace dev
```

---

# 13. View Resources Across Entire Cluster

Command:

```bash
kubectl get all -A
```

Meaning:

```text
Show Resources
From All Namespaces
```

---

Namespaces shown:

```text
default

dev

kube-system

local-path-storage
```

---

This is a common troubleshooting command.

---

# 14. Label Selector Inside Namespace

Command:

```bash
kubectl get pods -n dev -l app=web-app
```

Meaning:

```text
Get Pods

Inside Namespace dev

Having Label

app=web-app
```

Output:

```text
web-app-677dcb4ffc-59sbc
```

---

# 15. View Deployment YAML

Command:

```bash
kubectl get deployment web-app -n dev -o yaml
```

Important Section:

```yaml
metadata:
  name: web-app
  namespace: dev
```

This proves:

```text
Deployment Belongs To
dev Namespace
```

---

# 16. Create A Test Pod

Command:

```bash
kubectl run namespace-test \
  -n dev \
  --image=busybox:1.36 \
  --restart=Never \
  --command -- sleep 3600
```

Purpose:

```text
Temporary Pod
Used For Namespace Networking Tests
```

---

Wait For Readiness:

```bash
kubectl wait -n dev \
  --for=condition=Ready pod/namespace-test \
  --timeout=120s
```

---

# 17. Access Service Inside Same Namespace

Command:

```bash
kubectl exec -n dev namespace-test -- \
  wget -S -O- -T 5 http://web-service
```

Result:

```text
HTTP/1.1 200 OK
```

---

Why Did This Work?

Because both:

```text
namespace-test

and

web-service
```

are inside:

```text
dev Namespace
```

---

Kubernetes DNS automatically resolves:

```text
web-service
```

to:

```text
web-service.dev.svc.cluster.local
```

---

# 18. Access Service In Another Namespace

Command:

```bash
kubectl exec -n dev namespace-test -- \
  wget -S -O- -T 5 \
  http://web-service.default.svc.cluster.local
```

Result:

```text
HTTP/1.1 200 OK
```

---

Meaning:

```text
Pod In dev Namespace

Successfully Reached

Service In default Namespace
```

---

This proves:

```text
Pods Can Communicate
Across Namespaces
```

unless restricted by:

```text
Network Policies
```

---

## DNS Naming Convention

Same namespace:

```text
web-service
```

---

Fully qualified service name:

```text
web-service.dev.svc.cluster.local
```

---

Cross namespace:

```text
web-service.default.svc.cluster.local
```

---

# 19. View Resources Across Namespaces

Deployments:

```bash
kubectl get deployments -A
```

Services:

```bash
kubectl get services -A
```

Pods:

```bash
kubectl get pods -A
```

---

Purpose:

```text
Verify Resources
Across Entire Cluster
```

---

# 20. Cleanup

Delete temporary pod:

```bash
kubectl delete pod namespace-test -n dev
```

Output:

```text
pod "namespace-test" deleted
```

Meaning:

```text
Temporary Testing Pod Removed
```

---

# Interview Questions

### What Is A Namespace?

```text
A logical partition inside a Kubernetes cluster used to organize and isolate resources.
```

---

### What Happens If No Namespace Is Specified?

```text
Kubernetes Uses The default Namespace.
```

---

### Can Two Deployments Have The Same Name?

```text
Yes

If They Are In Different Namespaces.
```

Example:

```text
default/web-app

dev/web-app
```

---

### Do Namespaces Provide Complete Security Isolation?

```text
No

Namespaces Provide Logical Isolation
But Share The Same Cluster Infrastructure.
```

---

### Can Pods Communicate Across Namespaces?

```text
Yes

Using Service DNS Names

Unless Restricted By Network Policies.
```

---

### What Is The Difference Between Namespace-Scoped And Cluster-Scoped Resources?

```text
Namespace-Scoped:
Pods, Deployments, Services, Secrets

Cluster-Scoped:
Nodes, Namespaces, PersistentVolumes, StorageClasses
```

---

# Day 10 Golden Rules

```text
Namespace
      ↓
Logical Workspace

--------------------------------

One Cluster
      ↓
Many Namespaces

--------------------------------

Namespace
      ≠
Separate Cluster

--------------------------------

Same Resource Name
      ↓
Allowed In Different Namespaces

--------------------------------

default/web-app

dev/web-app

Both Can Exist Together

--------------------------------

No Namespace Specified
      ↓
default Namespace Used

--------------------------------

kubectl get pods -A
      ↓
All Pods
Across Cluster

--------------------------------

kubectl get all -n dev
      ↓
Common Resources
Inside dev Namespace

--------------------------------

Pods
Deployments
Services
      ↓
Namespace Scoped

--------------------------------

Nodes
Namespaces
PVs
StorageClasses
      ↓
Cluster Scoped

--------------------------------

web-service
      ↓
Current Namespace

--------------------------------

web-service.default.svc.cluster.local
      ↓
Specific Namespace

--------------------------------

Namespaces
      ↓
Logical Isolation

NOT

Complete Security Isolation
```
