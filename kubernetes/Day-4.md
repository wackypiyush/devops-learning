# Kubernetes Day 4 - Part 1
# Deployments, ReplicaSets & Desired State

---

# 1. Why Do We Need Deployments and ReplicaSets?

So far, we have been creating Pods directly.

Example:

```yaml
apiVersion: v1
kind: Pod
```

This works for learning, but in real environments standalone Pods create several problems.

---

## Problem 1: Pod Gets Deleted

Example:

```bash
kubectl delete pod nginx
```

Result:

```text
Pod Removed
```

No replacement Pod is created because there is no controller managing it.

---

## Problem 2: Node Failure

Example:

```text
Node
 |
nginx Pod
```

If the node fails:

```text
Pod Becomes Unavailable
```

A standalone Pod has no workload controller responsible for recreating it elsewhere.

---

### Important Clarification

If the Pod is managed by a Deployment:

```text
Deployment
      ↓
ReplicaSet
      ↓
Pod
```

Kubernetes can create replacement Pods on another healthy node if:

```text
Control Plane Is Healthy

Suitable Nodes Are Available

Resources Exist
```

---

## Problem 3: Need Multiple Copies

Suppose traffic increases.

Need:

```text
nginx-1

nginx-2

nginx-3
```

Creating Pods manually is:

```text
Error Prone

Hard To Manage

Not Scalable
```

---

## Problem 4: Application Updates

Current Version:

```text
v1
```

Need:

```text
v2
```

With standalone Pods:

```text
Delete Old Pod

Create New Pod
```

This creates operational risk and can result in service disruption.

---

## Problem 5: Desired State Is Not Maintained

Desired:

```text
3 Pods
```

Actual:

```text
2 Pods
```

Who notices?

Who creates the missing Pod?

A standalone Pod cannot solve this problem.

---

# Kubernetes Solution

Kubernetes introduces workload controllers:

```text
Deployment
      ↓
ReplicaSet
      ↓
Pods
```

Together they continuously work toward:

```text
Desired State
```

---

## Desired State Example

Desired:

```text
3 Pods
```

Actual:

```text
2 Pods
```

Kubernetes notices:

```text
Desired ≠ Actual
```

and works to restore:

```text
3 Pods
```

This process is called:

```text
Reconciliation
```

---

# 2. What Is A Deployment?

## Definition

A Deployment is a Kubernetes resource that manages stateless application rollouts through ReplicaSets.

It provides:

```text
Scaling

Rolling Updates

Rollbacks

Self-Healing

Version Management
```

---

## Think Of Deployment As

```text
Application Manager
```

You normally manage:

```text
Deployment
```

not:

```text
Pods
```

---

## What Deployment Manages

Deployment manages:

```text
ReplicaSets
```

and ReplicaSets manage:

```text
Pods
```

Actual relationship:

```text
Deployment
      ↓
ReplicaSet
      ↓
Pods
```

---

# Deployment Responsibilities

## Scaling

Increase:

```text
2 Pods
      ↓
5 Pods
```

or

Decrease:

```text
5 Pods
      ↓
2 Pods
```

using a single command.

---

## Self-Healing

If a Pod disappears:

```text
Desired = 2

Actual = 1
```

Kubernetes creates a replacement Pod.

---

## Rolling Updates

Suppose:

```text
nginx:v1
```

must become:

```text
nginx:v2
```

Deployment performs a rollout.

---

### Important Clarification

Deployments support rolling updates, but:

```text
Rolling Update
≠
Guaranteed Zero Downtime
```

Whether downtime occurs depends on:

```text
Readiness Probes

Replica Count

Update Strategy

Application Behaviour

Available Resources
```

---

## Rollbacks

Suppose:

```text
v2
```

is broken.

Deployment allows:

```text
v2
 ↓
v1
```

rollback.

---

# One Very Important Concept

Many people think:

```text
Deployment
      ↓
Updates Pods
```

Not exactly.

A Deployment manages versions through:

```text
ReplicaSets
```

---

# How Deployment Manages Versions

Initial version:

```text
Deployment
      |
      +-- ReplicaSet-v1
              |
              +-- Pods
```

---

New version:

```text
nginx:v1
      ↓
nginx:v2
```

Deployment creates:

```text
Deployment
      |
      +-- ReplicaSet-v1
      |
      +-- ReplicaSet-v2
```

---

During rollout:

```text
Scale Down
ReplicaSet-v1

Scale Up
ReplicaSet-v2
```

Gradually.

---

# Why Rollbacks Work

Because old ReplicaSets still exist.

Deployment can:

```text
Scale Up Old ReplicaSet

Scale Down New ReplicaSet
```

This is how rollbacks actually work internally.

---

# 3. What Is A ReplicaSet?

## Definition

A ReplicaSet ensures that a specified number of matching Pods exist.

Its primary responsibility is:

```text
Maintain Desired Pod Replica Count
```

---

## Think Of ReplicaSet As

```text
Pod Manager
```

or

```text
Pod Counter
```

---

# Example

Desired:

```yaml
replicas: 3
```

Desired State:

```text
Pod-1

Pod-2

Pod-3
```

Actual:

```text
Pod-1

Pod-2
```

ReplicaSet detects:

```text
Desired = 3

Actual = 2
```

Creates:

```text
Pod-3
```

---

# If A Pod Crashes

Before:

```text
Pod-1

Pod-2

Pod-3
```

Pod-2 disappears.

Actual:

```text
Pod-1

Pod-3
```

ReplicaSet notices mismatch and creates:

```text
Replacement Pod
```

---

# If Too Many Pods Exist

Desired:

```text
3
```

Actual:

```text
4
```

ReplicaSet removes one Pod.

---

# More Accurate View Of ReplicaSet

ReplicaSet does more than simply count Pods.

It uses:

```text
Selectors

Labels

Pod Templates
```

to determine:

```text
Which Pods Belong To Me
```

and

```text
How New Pods Should Be Created
```

---

# What ReplicaSet Does NOT Do

ReplicaSet does NOT handle:

```text
Rollbacks

Version Management

Application Rollouts
```

Those responsibilities belong to:

```text
Deployment
```

---

## Analogy

```text
Deployment
      =
Application Manager

ReplicaSet
      =
Pod Manager
```

---

# 4. Understanding The Relationship

Many diagrams show:

```text
Cluster
 |
Node
 |
Deployment
 |
ReplicaSet
 |
Pod
```

This is useful conceptually but is NOT a physical hierarchy.

---

## More Accurate Understanding

### Infrastructure Side

```text
Cluster
 |
 +-- Nodes
```

Nodes provide compute resources.

---

### Application Side

```text
Namespace
 |
Deployment
 |
ReplicaSet
 |
Pods
```

Pods are eventually scheduled onto nodes.

---

## Ownership Chain

```text
Deployment
      ↓
ReplicaSet
      ↓
Pods
      ↓
Containers
      ↓
Image
```

This is an ownership and management chain.

---

# Example

Deployment:

```yaml
replicas: 3
image: nginx:alpine
```

Result:

```text
Deployment
      ↓
ReplicaSet
      ↓
Pod-1
Pod-2
Pod-3
      ↓
nginx Container
      ↓
nginx:alpine Image
```

---

# Why Don't We Create Pods Directly In Production?

You can manually create multiple Pods.

Example:

```bash
kubectl run pod1
kubectl run pod2
kubectl run pod3
```

So technically standalone Pods can "scale" manually.

---

The real problem is they do NOT provide:

```text
Controller Managed Scaling

Self-Healing

Desired State Management

Rolling Updates

Rollbacks
```

This is why production workloads are almost always created through:

```text
Deployments
```

instead of standalone Pods.

---

# Day 4 Part 1 - Golden Rules

```text
Deployment
      ↓
Manages ReplicaSets

ReplicaSet
      ↓
Maintains Matching Pods

Pods
      ↓
Run Containers

Containers
      ↓
Run Images

--------------------------------

Deployment
      =
Application Manager

ReplicaSet
      =
Pod Manager

--------------------------------

Desired State
      ↓
Target

Actual State
      ↓
Reality

Kubernetes Continuously Works
To Make Reality Match Target
```
# Kubernetes Day 4 - Part 2
# Deployments In Action, Scaling, Self-Healing & Resource Relationships

---

# 5. Creating A Deployment

Instead of creating standalone Pods, we create a Deployment.

---

## Create Deployment

```bash
kubectl create deployment web-app \
  --image=nginx:alpine \
  --replicas=2
```

Meaning:

```text
Deployment Name = web-app

Image = nginx:alpine

Desired Replicas = 2
```

---

## What Happens Internally?

When you run:

```bash
kubectl create deployment web-app \
  --image=nginx:alpine \
  --replicas=2
```

Kubernetes performs:

```text
Deployment Created
        ↓
ReplicaSet Created
        ↓
2 Pods Created
        ↓
Scheduler Assigns Nodes
        ↓
kubelet Starts Containers
```

---

## Resource Chain Created

```text
Deployment
      ↓
ReplicaSet
      ↓
Pod-1

Pod-2
      ↓
Containers
```

---

# 6. Check Deployments

Command:

```bash
kubectl get deployments
```

Example:

```text
NAME      READY   UP-TO-DATE   AVAILABLE   AGE

web-app   2/2     2            2           30s
```

---

## READY

```text
2/2
```

Means:

```text
Desired Replicas = 2

Ready Replicas = 2
```

---

### Important Clarification

```text
READY = 2/2
```

does NOT guarantee:

```text
Users Are Happy

Application Is Returning Correct Results

Business Logic Works
```

It only means:

```text
Pods Are Reporting Ready
```

---

## UP-TO-DATE

```text
2
```

Means:

```text
2 Pods Are Running
The Latest Deployment Configuration
```

---

## AVAILABLE

```text
2
```

Means:

```text
2 Pods Are Available
For Traffic
```

according to Kubernetes readiness information.

---

# 7. Check ReplicaSets

Command:

```bash
kubectl get replicasets
```

Example:

```text
NAME                   DESIRED   CURRENT   READY

web-app-74f8d7f6f6     2         2         2
```

---

## DESIRED

```text
Desired Pod Count
```

ReplicaSet target:

```text
2 Pods
```

---

## CURRENT

```text
Currently Existing Pods
```

ReplicaSet currently owns:

```text
2 Pods
```

---

## READY

```text
Pods Reporting Ready
```

Current value:

```text
2
```

---

# 8. Check Pods

Command:

```bash
kubectl get pods -o wide
```

Example:

```text
NAME                              READY   STATUS

web-app-74f8d7f6f6-abcde          1/1     Running

web-app-74f8d7f6f6-xyz12          1/1     Running
```

---

## Naming Convention

### Deployment

```text
web-app
```

creates

### ReplicaSet

```text
web-app-74f8d7f6f6
```

creates

### Pods

```text
web-app-74f8d7f6f6-abcde

web-app-74f8d7f6f6-xyz12
```

---

# Visual Ownership Chain

```text
Deployment
      |
      ▼
ReplicaSet
      |
      ▼
Pods
```

---

# 9. Test Self-Healing

One of Kubernetes' most important capabilities.

---

## Step 1

View Pods

```bash
kubectl get pods
```

Example:

```text
web-app-74f8d7f6f6-abcde

web-app-74f8d7f6f6-xyz12
```

---

## Step 2

Delete One Pod

```bash
kubectl delete pod web-app-74f8d7f6f6-abcde
```

---

## Step 3

Watch Continuously

```bash
kubectl get pods -w
```

`-w` means:

```text
Watch
```

---

You may see:

```text
web-app-74...abcde    Terminating

web-app-74...new123   Pending

web-app-74...new123   Running
```

---

# What Happened Internally?

Before deletion:

```text
Desired = 2

Actual = 2
```

---

After deletion:

```text
Desired = 2

Actual = 1
```

---

ReplicaSet sees:

```text
Desired ≠ Actual
```

and creates a replacement Pod.

---

Result:

```text
Desired = 2

Actual = 2
```

again.

---

# Verify Deployment

```bash
kubectl get deployments
```

Expected:

```text
READY

2/2
```

---

# Verify ReplicaSet

```bash
kubectl get replicasets
```

Expected:

```text
DESIRED = 2

CURRENT = 2

READY = 2
```

---

# Verify Pods

```bash
kubectl get pods -o wide
```

You will notice:

```text
Old Pod Removed

New Pod Created
```

The Pod name changes because:

```text
Replacement Pod
≠
Original Pod
```

Pods are disposable.

---

# What Did We Just Prove?

```text
Pods Are Disposable

ReplicaSets Maintain Pod Count

Deployments Maintain Application State
```

---

# 10. Scale Up And Scale Down

One of the biggest advantages of Deployments is easy scaling.

---

# Scale Up

Current:

```text
2 Pods
```

Increase to:

```text
5 Pods
```

Command:

```bash
kubectl scale deployment web-app \
  --replicas=5
```

---

## Internally

```text
Deployment
      ↓
ReplicaSet
      ↓
Creates 3 More Pods
```

---

## Verify

```bash
kubectl get deployments

kubectl get replicasets

kubectl get pods
```

Expected:

```text
5 Pods
```

---

# Scale Down

Reduce:

```text
5 Pods
      ↓
2 Pods
```

Command:

```bash
kubectl scale deployment web-app \
  --replicas=2
```

---

## Internally

```text
Deployment
      ↓
ReplicaSet
      ↓
Deletes Extra Pods
```

---

# Important Clarification

Scaling means:

```text
Adjusting Desired Replica Count
```

It does NOT mean:

```text
Adding Servers

Adding Nodes
```

---

# Scaling Flow

```text
Deployment
      ↓
ReplicaSet
      ↓
Adjusts Pod Count
```

---

# 11. Understanding Resource Relationships

One of the most important Kubernetes concepts.

---

## View Relationships

Command:

```bash
kubectl get deployment,replicaset,pod
```

---

## View Labels

Command:

```bash
kubectl get deployment,replicaset,pod --show-labels
```

Example:

```text
deployment.apps/web-app

replicaset.apps/web-app-xxx

pod/web-app-xxx-yyy
```

with labels:

```text
app=web-app
```

---

# What Do Labels Do?

Labels help resources identify matching resources.

Example:

```text
Deployment Selector
       ↓
Finds ReplicaSet

ReplicaSet Selector
       ↓
Finds Matching Pods
```

---

# Important Clarification

Labels do NOT create ownership.

Ownership is tracked using:

```text
Owner References
```

inside Kubernetes metadata.

---

Labels and selectors help resources:

```text
Find Matching Resources
```

---

# Relationship Model

```text
Deployment
      |
      | Selector
      ▼
ReplicaSet
      |
      | Selector
      ▼
Pods
```

---

# 12. View Full Pod Definition

Command:

```bash
kubectl get pods -o yaml
```

Shows:

```text
Labels

Annotations

Container Configuration

Volumes

Node Assignment

Pod Status

Conditions
```

This is the complete object definition stored inside Kubernetes.

---

# Day 4 Part 2 - Golden Rules

```text
Deployment
      ↓
Manages ReplicaSets

ReplicaSet
      ↓
Maintains Matching Pods

Delete Pod
      ↓
ReplicaSet Recreates It

Scale Deployment
      ↓
ReplicaSet Adjusts Pod Count

Labels
      ↓
Help Match Resources

Owner References
      ↓
Define Ownership

Pods
      ↓
Are Disposable

Deployment
      ↓
Maintains Desired State
```
# Kubernetes Day 4 - Part 3
# YAML, Describe, Logs, Troubleshooting & kubectl exec

---

# 13. Understanding Deployment Configuration

One of the most important Kubernetes skills is learning how to read YAML.

Most Kubernetes resources are stored as YAML objects inside the Kubernetes API.

---

## View Deployment YAML

```bash
kubectl get deployment web-app -o yaml
```

This command shows the complete Deployment object stored in Kubernetes.

Think:

```text
Deployment YAML
      ↓
Blueprint
```

---

# Example Deployment YAML

```yaml
apiVersion: apps/v1
kind: Deployment

metadata:
  name: web-app

spec:
  replicas: 2

  selector:
    matchLabels:
      app: web-app

  template:
    metadata:
      labels:
        app: web-app

    spec:
      containers:
      - name: nginx
        image: nginx:alpine

status:
  availableReplicas: 2
```

---

# Understanding The Deployment YAML

---

## apiVersion

```yaml
apiVersion: apps/v1
```

Defines:

```text
Which Kubernetes API Version
Understands This Resource
```

---

## kind

```yaml
kind: Deployment
```

Defines:

```text
Object Type
```

Examples:

```text
Pod

Deployment

Service

ConfigMap

Secret
```

---

## metadata

```yaml
metadata:
  name: web-app
```

Identity section.

Contains:

```text
Name

Namespace

Labels

Annotations
```

---

## spec

```yaml
spec:
```

Most important section.

Spec means:

```text
Desired State
```

---

## replicas

```yaml
replicas: 2
```

Meaning:

```text
Kubernetes Should Attempt
To Maintain
Two Matching Pod Replicas
```

---

### Important Clarification

This does NOT mean:

```text
Exactly Two Running Pods
Every Millisecond
```

Because Pods may temporarily be:

```text
Pending

Starting

Terminating

Not Ready
```

while Kubernetes reconciles actual state toward desired state.

---

## selector

```yaml
selector:
```

Defines:

```text
Which Pods Belong To This Deployment
```

Example:

```yaml
matchLabels:
  app: web-app
```

---

## template

```yaml
template:
```

Most important Deployment field.

Think:

```text
Pod Factory Blueprint
```

Whenever a Pod is needed:

```text
ReplicaSet
      ↓
Uses Template
      ↓
Creates Pod
```

---

## containers

```yaml
containers:
- image: nginx:alpine
```

Defines:

```text
Container Image

Container Settings

Ports

Environment Variables

Volume Mounts
```

---

## status

```yaml
status:
```

Represents:

```text
Current Reality
```

Example:

```yaml
availableReplicas: 2
```

means:

```text
Currently
2 Available Pod Replicas Exist
```

---

# Easy Deployment YAML Model

```text
metadata
      ↓
Who Am I?

spec
      ↓
What Do You Want?

status
      ↓
What Actually Exists?
```

---

# 14. Understanding Pod YAML

---

## View Pod YAML

```bash
kubectl get pods -o yaml
```

or

```bash
kubectl get pod <pod-name> -o yaml
```

---

# Example Pod YAML

```yaml
apiVersion: v1

kind: Pod

metadata:
  name: nginx
  namespace: default

spec:
  containers:
  - name: nginx
    image: nginx:alpine
    ports:
    - containerPort: 80

status:
  phase: Running
  podIP: 10.244.0.5
```

---

# Understanding Pod YAML

---

## apiVersion

```yaml
apiVersion: v1
```

Defines Kubernetes API version.

---

## kind

```yaml
kind: Pod
```

Object type.

---

## metadata

```yaml
metadata:
```

Identity of the Pod.

Contains:

```text
Name

Namespace

Labels

Annotations
```

---

## spec

```yaml
spec:
```

Desired Pod configuration.

Contains:

```text
Containers

Volumes

Scheduling Information

Security Settings
```

---

## containers

```yaml
containers:
```

Defines:

```text
What Should Run Inside The Pod
```

---

## containerPort

```yaml
containerPort: 80
```

Means:

```text
This Container Is Expected
To Listen On Port 80
```

---

### Important Clarification

This does NOT guarantee:

```text
Application Is Actually Listening

Traffic Is Working

Application Is Healthy
```

It is a declaration in the Pod specification.

---

## status

```yaml
status:
```

Represents:

```text
Actual State Of The Pod
```

---

## phase

```yaml
phase: Running
```

Current Pod phase.

---

### Important Clarification

```text
Running
```

does NOT guarantee:

```text
Application Healthy

Application Functional

Business Logic Correct
```

Always verify:

```text
Readiness

Logs

Application Behaviour
```

---

## podIP

```yaml
podIP: 10.244.0.5
```

Pod network address.

---

# Important Networking Clarification

Many beginners think:

```text
Every Container Gets An IP
```

Incorrect.

In Kubernetes:

```text
Pod Gets IP
```

Example:

```text
Pod
 |
 +-- Container A
 |
 +-- Container B

Pod IP = 10.244.0.5
```

Both containers share:

```text
Network Namespace

IP Address

Port Space
```

---

# Easy Pod YAML Model

```text
metadata
      ↓
Who Am I?

spec
      ↓
What Should Run?

status
      ↓
What Is Actually Happening?
```

---

# 15. Understanding Relationships Between Resources

---

## Show Labels

```bash
kubectl get deployment,replicaset,pod --show-labels
```

Example:

```text
deployment.apps/web-app

replicaset.apps/web-app-xxxx

pod/web-app-xxxx-yyyy
```

---

# What Labels Do

Labels help resources identify matching resources.

Example:

```text
Deployment Selector
       ↓
Matches ReplicaSet

ReplicaSet Selector
       ↓
Matches Pods
```

---

# Important Clarification

A common misconception:

```text
Labels Create Ownership
```

Not exactly.

---

Ownership is tracked using:

```text
Owner References
```

inside Kubernetes metadata.

---

Labels and selectors are used for:

```text
Matching Resources
```

---

# Relationship Diagram

```text
Deployment
      |
      ▼
ReplicaSet
      |
      ▼
Pods
```

Ownership:

```text
Owner References
```

Matching:

```text
Labels + Selectors
```

---

# 16. YAML vs Describe vs Logs

These three commands answer completely different questions.

---

# YAML

Command:

```bash
kubectl get deployment web-app -o yaml
```

Answers:

```text
How Is This Resource Configured?
```

Think:

```text
Blueprint
```

Contains:

```text
Desired State

Configuration

Specification
```

---

# Describe

Command:

```bash
kubectl describe pod <pod>
```

Answers:

```text
What Does Kubernetes Know
About This Resource Right Now?
```

Think:

```text
Medical Report
```

Contains:

```text
Current State

Conditions

Events

Scheduling Information
```

---

# Logs

Command:

```bash
kubectl logs <pod>
```

Answers:

```text
What Is The Application Saying?
```

Think:

```text
Application Diary
```

Contains:

```text
stdout

stderr
```

generated by the application.

---

# Important Clarification

Logs come from:

```text
Application
```

Describe information comes from:

```text
Kubernetes
```

---

## Another Important Clarification

`kubectl logs` shows:

```text
stdout

stderr
```

It may NOT show:

```text
Application Log Files
```

such as:

```text
/var/log/app.log

/app/logs/error.log
```

unless the application forwards those logs to stdout/stderr.

---

# Quick Comparison

```text
YAML
     ↓
Configuration

Describe
     ↓
Current State + Events

Logs
     ↓
Application Output
```

---

# 17. Troubleshooting Commands

---

## Describe Deployment

```bash
kubectl describe deployment web-app
```

Answers:

```text
What Is Happening
With The Deployment?
```

Shows:

```text
Replicas

Conditions

Update Strategy

Events
```

Use when:

```text
Rollout Failed

Scaling Failed

Deployment Stuck
```

---

## Describe ReplicaSet

```bash
kubectl describe replicaset <rs-name>
```

Answers:

```text
Is ReplicaSet Maintaining Pods Correctly?
```

Shows:

```text
Desired Pods

Current Pods

Selectors

Labels

Events
```

---

## Describe Pod

```bash
kubectl describe pod <pod-name>
```

Answers:

```text
Why Is This Pod
Behaving This Way?
```

Shows:

```text
Node

Container Information

Conditions

Events

Volumes

Ports
```

Use when:

```text
Pending

Failed

CrashLoopBackOff

Not Starting
```

---

# Describe Pod Example

Events may show:

```text
Scheduled

Pulled

Created

Started
```

Actual lifecycle:

```text
Pod Created
      ↓
Scheduled
      ↓
Image Pulled
      ↓
Container Created
      ↓
Container Started
```

---

# Logs

Command:

```bash
kubectl logs <pod>
```

Use when:

```text
Application Crashing

Database Connection Errors

Startup Failures

Runtime Exceptions
```

---

# Important CrashLoopBackOff Clarification

Many people think:

```text
CrashLoopBackOff
```

is a Pod phase.

Incorrect.

Actual Pod phases:

```text
Pending

Running

Succeeded

Failed

Unknown
```

---

CrashLoopBackOff is:

```text
Container Status
```

Meaning:

```text
Container Starts
      ↓
Crashes
      ↓
Restarts
      ↓
Crashes Again
      ↓
Kubernetes Waits Longer Before Retrying
```

---

# 18. Real Troubleshooting Flow

Application not working:

---

## Step 1

Check Pods

```bash
kubectl get pods
```

Look for:

```text
Running

Pending

CrashLoopBackOff
```

---

## Step 2

Inspect Pod

```bash
kubectl describe pod <pod>
```

Check:

```text
Events

Conditions

Scheduling Problems
```

---

## Step 3

Check Application Logs

```bash
kubectl logs <pod>
```

Check:

```text
Errors

Exceptions

Connection Failures
```

---

## Step 4

Verify Configuration

```bash
kubectl get deployment web-app -o yaml
```

Verify:

```text
Image

Replicas

Labels

Environment Variables

Ports
```

---

# 19. Pod vs Container

---

## Container

Container runs:

```text
Application Process
```

Examples:

```text
nginx

redis

java

python
```

---

## Pod

Pod is:

```text
Smallest Deployable
And Schedulable Unit
In Kubernetes
```

---

## Very Important

```text
Container
      ↓
Runs Process

Pod
      ↓
Runs Container(s)

Kubernetes
      ↓
Deploys Pods
```

---

# 20. kubectl exec

In Docker:

```bash
docker exec
```

In Kubernetes:

```bash
kubectl exec
```

---

## Single Container Pod

```bash
kubectl exec -it nginx -- sh
```

or

```bash
kubectl exec -it nginx -- bash
```

---

## Multi-Container Pod

```bash
kubectl exec -it mypod \
-c app-container \
-- sh
```

---

# Why Enter A Container?

Most troubleshooting should start with:

```text
Logs

Describe

Events
```

but sometimes direct inspection is necessary.

---

## Verify Files

Example:

```text
config.yaml not found
```

---

## Check Environment Variables

Example:

```text
Application Cannot Reach Database
```

---

## Debug Networking

Example:

```text
Application Cannot Reach Redis
```

---

## Verify Mounted Volumes

Example:

```text
Expected Files Missing
```

---

## Verify Running Processes

Example:

```text
Is nginx actually running?
```

---

## Check DNS Resolution

Example:

```text
Can service names be resolved?
```

---

# Production Best Practice

Troubleshooting order:

```text
1. kubectl get pods

2. kubectl describe pod

3. kubectl logs

4. kubectl exec
```

Use `exec` only when necessary.

---

## Why?

```text
Logs Are Safer

Exec Requires Shell Access

Exec Can Modify State

Most Issues Can Be Solved
Without Entering The Container
```

---

# Important Reality

Many production images are minimal:

```text
distroless

scratch

minimal alpine
```

These may not contain:

```text
bash
```

and sometimes not even:

```text
sh
```

Therefore:

```bash
kubectl exec -it <pod> -- bash
```

may fail.

---

# Day 4 Part 3 - Golden Rules

```text
YAML
      ↓
Blueprint

Describe
      ↓
Kubernetes View

Logs
      ↓
Application View

--------------------------------

Running
      ↓
Does Not Always Mean Healthy

Ready
      ↓
Does Not Always Mean Successful

Container Port
      ↓
Does Not Prove Application Is Listening

--------------------------------

Pod
      ↓
Smallest Deployable Unit

Container
      ↓
Runs Application Process

--------------------------------

Most Troubleshooting:

get
 ↓
describe
 ↓
logs
 ↓
exec
```
