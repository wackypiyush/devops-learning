# Kubernetes Day 11
# Labels, Selectors & Annotations

---

# 1. What Are Labels?

Imagine you have many Pods:

```text
web-app

mysql

redis

api-server

nginx
```

Question:

```text
How Can Kubernetes Identify And Group Them?
```

Kubernetes solves this using:

```text
Labels
```

---

## Definition

A Label is a key-value pair attached to a Kubernetes object.

Example:

```yaml
labels:
  app: web-app
```

---

Think of Labels as:

```text
Tags

OR

Stickers
```

attached to resources.

---

## Real-Life Analogy

Luggage stickers at an airport:

```text
Destination = Mumbai

Priority = High
```

These stickers help identify and sort luggage.

Labels work exactly the same way.

---

## Example Pod

```yaml
metadata:
  name: web-app
  labels:
    app: web-app
    env: dev
```

Meaning:

```text
Key          Value

app      →   web-app

env      →   dev
```

---

## Why Are Labels Important?

Without labels:

```text
Pod-A

Pod-B

Pod-C

Pod-D
```

No logical grouping exists.

---

With labels:

```text
Pod-A
app=web

Pod-B
app=web

Pod-C
app=mysql

Pod-D
app=mysql
```

Kubernetes can now group similar resources.

---

## Common Labels

```yaml
app: nginx

env: dev

env: prod

tier: frontend

tier: backend

version: v1
```

---

## Labels Can Be Attached To

```text
Pods

Deployments

Services

Namespaces

Nodes

ConfigMaps

Secrets

ReplicaSets
```

Almost every Kubernetes object can have labels.

---

# 2. Namespace VS Label

This is one of the most commonly confused topics.

---

## Namespace

Namespace provides:

```text
Logical Separation
```

It answers:

```text
Where Does This Resource Live?
```

Examples:

```text
dev

staging

prod
```

---

## Label

Label provides:

```text
Classification
```

It answers:

```text
What Kind Of Resource Is This?
```

---

## Example

```yaml
labels:
  app: web-app
  env: dev
  tier: frontend
```

Now Kubernetes knows:

```text
This Is A Web Application

Running In Dev

Frontend Tier
```

---

## Real Example

Namespace:

```text
dev
```

Contains:

```text
web-app-1

web-app-2

mysql

redis
```

---

Add labels:

```text
web-app-1
app=web

web-app-2
app=web

mysql
app=mysql

redis
app=redis
```

Now:

```text
Namespace
      ↓
Groups Resources

Labels
      ↓
Classify Resources
```

---

## Why Not Use Only Namespaces?

Suppose everything is inside:

```text
dev
```

namespace.

You want only web Pods.

Namespace cannot help because all Pods are already inside the same namespace.

Labels help:

```bash
kubectl get pods -n dev -l app=web
```

Result:

```text
Only Web Pods
```

---

## Easy Memory Trick

```text
Namespace
      ↓
Where Am I?

Label
      ↓
Who Am I?
```

---

# 3. What Are Selectors?

Labels identify resources.

Selectors find resources.

---

## Definition

A Selector is a query used to find Kubernetes objects based on labels.

---

Think:

```text
Labels
      ↓
Give Identity

Selectors
      ↓
Search By Identity
```

---

## Example

Pods:

```text
Pod-A
app=web

Pod-B
app=web

Pod-C
app=db
```

Selector:

```text
app=web
```

Matches:

```text
Pod-A

Pod-B
```

---

Not:

```text
Pod-C
```

---

## Example Command

```bash
kubectl get pods -l app=web
```

Meaning:

```text
Show Pods

Where

app=web
```

---

# 4. What Are Annotations?

Labels and Annotations are NOT the same.

---

## Definition

Annotations are key-value pairs attached to Kubernetes objects.

Just like labels.

However, their purpose is different.

---

## Labels Are Used For

```text
Identification

Grouping

Selection
```

---

## Annotations Are Used For

```text
Information

Metadata

Documentation
```

---

## Example

```yaml
metadata:
  annotations:
    owner: piyush
    description: frontend application
```

---

## Important

Labels:

```text
✅ Selectable
```

Annotations:

```text
❌ Not Selectable
```

Selectors cannot match annotations.

---

## Real-Life Analogy

Label:

```text
Destination=Mumbai
```

Used for sorting luggage.

---

Annotation:

```text
Fragile

Handle Carefully
```

Used for additional information.

---

## Common Annotation Data

```text
Owner Name

Description

Build Information

Git Commit

Documentation URL

Deployment Notes
```

---

## Important

Annotations are useful to:

```text
Humans

Automation Tools

CI/CD Pipelines
```

Kubernetes does not use them to select resources.

---

# 5. Understanding The Relationship

This is the most important Day 11 concept.

---

## Labels Create Identity

Example:

```yaml
labels:
  app: web
```

---

## Selectors Find Identity

Example:

```yaml
selector:
  app: web
```

---

Relationship:

```text
Labels
      ↓
Attached To Pods

Selectors
      ↓
Find Matching Pods
```

---

## Deployment Example

Deployment:

```yaml
selector:
  matchLabels:
    app: web
```

Pod Template:

```yaml
labels:
  app: web
```

---

Flow:

```text
Deployment
      ↓
Selector

app=web
      ↓
Matches Pod Labels

app=web
```

---

## Service Example

Service:

```yaml
selector:
  app: web
```

Pods:

```yaml
labels:
  app: web
```

---

Flow:

```text
Service
      ↓
Selector

app=web
      ↓
Find Matching Pods
      ↓
Route Traffic
```

---

## Why Is This Powerful?

Pods are temporary.

Today:

```text
web-app-abc
```

Tomorrow:

```text
web-app-xyz
```

Pod names change.

---

Labels defined inside the Pod Template remain consistent across replacement Pods.

Therefore:

```text
Service Continues Routing

Deployment Continues Managing Pods
```

---

# 6. Labels In Practice

Example:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: web-app
  labels:
    app: web
    env: dev
    tier: frontend
```

Labels:

```text
app=web

env=dev

tier=frontend
```

---

## View Labels

```bash
kubectl get pods --show-labels
```

Example Output:

```text
NAME      STATUS    LABELS

web-app   Running   app=web,env=dev,tier=frontend
```

---

## Add Label To Existing Resource

```bash
kubectl label pod web-app version=v1
```

New label:

```text
version=v1
```

---

# 7. Selectors: Equality And Set-Based Matching

Selectors search resources using labels.

---

# A) Equality-Based Selectors

---

## Equal To

```bash
kubectl get pods -l app=web
```

Meaning:

```text
Find Pods

Where

app=web
```

---

## Multiple Conditions

```bash
kubectl get pods -l app=web,env=dev
```

Meaning:

```text
app=web

AND

env=dev
```

Both conditions must match.

---

# B) Set-Based Selectors

Operators:

```text
in

notin

exists

does not exist
```

---

## IN Operator

```bash
kubectl get pods -l 'env in (dev,test)'
```

Meaning:

```text
env=dev

OR

env=test
```

---

## NOT IN Operator

```bash
kubectl get pods -l 'env notin (prod)'
```

Meaning:

```text
env Is Not prod

OR

env Label Does Not Exist
```

---

Example:

```text
Pod A
env=dev

Pod B
env=test

Pod C
(no env label)
```

Selector:

```text
env notin (prod)
```

Matches:

```text
Pod A

Pod B

Pod C
```

---

If you want the label to exist:

```bash
kubectl get pods -l 'env,env notin (prod)'
```

Meaning:

```text
env Label Must Exist

AND

env Must Not Be prod
```

---

## EXISTS

```bash
kubectl get pods -l env
```

Meaning:

```text
Find Pods

Having Label Key "env"
```

Value does not matter.

---

## DOES NOT EXIST

```bash
kubectl get pods -l '!env'
```

Meaning:

```text
Find Pods

Without env Label
```

---

# Selector Cheat Sheet

```text
env=dev
      ↓
env Exists And Equals dev

--------------------------------

env!=prod
      ↓
env Is Not prod
OR Label Missing

--------------------------------

env in (dev,test)
      ↓
env Exists And Is
dev OR test

--------------------------------

env notin (prod)
      ↓
env Is Not prod
OR Label Missing

--------------------------------

env
      ↓
Label Exists

--------------------------------

!env
      ↓
Label Does Not Exist
```

---

# 8. How Services And Deployments Use Selectors

This is where labels become extremely important.

---

# Service → Pod Relationship

Service:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-service

spec:
  selector:
    app: web
```

Service says:

```text
I Am Looking For

app=web
```

Pods:

```yaml
labels:
  app: web
```

---

Flow:

```text
Service
      ↓
Selector

app=web
      ↓
Find Matching Pods
      ↓
Create EndpointSlices
      ↓
Route Traffic
```

---

## Important

A Service selects:

```text
Pod Labels
```

It does NOT select:

```text
Deployment Labels
```

---

# Deployment → ReplicaSet → Pod Relationship

Many beginners say:

```text
Deployment Manages Pods
```

This is partially true but not technically accurate.

Actual architecture:

```text
Deployment
      ↓ manages
ReplicaSet
      ↓ maintains
Pods
```

---

Deployment Example:

```yaml
selector:
  matchLabels:
    app: web
```

Pod Template:

```yaml
labels:
  app: web
```

---

Flow:

```text
Deployment
      ↓
Selector

app=web
      ↓
ReplicaSet

app=web
      ↓
Pods

app=web
```

---

## Why Is This Needed?

Pods may disappear and be recreated.

Names change:

```text
web-app-abc

web-app-def

web-app-xyz
```

but Pod-template labels remain consistent.

Therefore:

```text
ReplicaSet Still Finds Pods

Deployment Still Manages ReplicaSets

Service Still Routes Traffic
```

---

# 9. Add Labels To Deployment

Command:

```bash
kubectl label deployment label-demo \
  environment=dev team=platform \
  -n dev
```

Output:

```text
deployment.apps/label-demo labeled
```

---

Important:

This labels only the:

```text
Deployment Object
```

NOT the Pods.

---

Visual:

```text
Deployment
      ↓
environment=dev

team=platform

--------------------------------

Pods
      ↓
No New Labels Yet
```

---

# 10. Patch Pod Template Labels

Command:

```bash
kubectl patch deployment label-demo -n dev \
  --type=merge \
  -p '{"spec":{"template":{"metadata":{"labels":{"environment":"dev","team":"platform"}}}}}'
```

Meaning:

```text
Add Labels To Future Pods
Created By This Deployment
```

---

Important:

```text
Deployment Labels

AND

Pod Labels

Are Different Things
```

---

After patch:

```text
Deployment Labels
      ↓
environment=dev

team=platform

--------------------------------

Pod Template Labels
      ↓
environment=dev

team=platform
```

---

Changing the Pod Template triggers:

```text
New ReplicaSet

New Pods

Rolling Update
```

---

# 11. Verify Deployment Labels

Command:

```bash
kubectl get deployment label-demo \
  -n dev \
  --show-labels
```

Output:

```text
app=label-demo

environment=dev

team=platform
```

Shows Deployment labels.

---

# 12. Verify Pod Labels

Command:

```bash
kubectl get pods \
  -n dev \
  -l app=label-demo \
  --show-labels
```

Output:

```text
app=label-demo

environment=dev

team=platform
```

for all Pods.

---

This proves Pods inherited labels from:

```text
Deployment Pod Template
```

---

# 13. Add Annotations

Command:

```bash
kubectl annotate deployment label-demo \
  owner=platform-team \
  purpose=day-29-lab \
  -n dev
```

Output:

```text
deployment.apps/label-demo annotated
```

Annotations added:

```text
owner=platform-team

purpose=day-29-lab
```

---

# 14. Verify Annotations

Command:

```bash
kubectl get deployment label-demo -n dev \
-o jsonpath='{.metadata.annotations}'
```

Output:

```text
owner=platform-team

purpose=day-29-lab
```

---

# 15. Describe Deployment Shows Labels, Annotations And Selector

Command:

```bash
kubectl describe deployment label-demo -n dev
```

Shows:

```text
Labels

Annotations

Selector
```

Example:

```text
Labels:
  app=label-demo
  environment=dev
  team=platform

Annotations:
  owner=platform-team
  purpose=day-29-lab

Selector:
  app=label-demo
```

---

# 16. Verify Labels And Selector Relationship

Command:

```bash
kubectl get deployment label-demo -n dev \
-o jsonpath='Deployment labels: {.metadata.labels}{"\n"}Pod template labels: {.spec.template.metadata.labels}{"\n"}Selector: {.spec.selector.matchLabels}{"\n"}'
```

Output:

```text
Deployment labels:
app=label-demo
environment=dev
team=platform

Pod template labels:
app=label-demo
environment=dev
team=platform

Selector:
app=label-demo
```

---

This proves:

```text
Deployment Has Labels

Pods Have Labels

Deployment Uses Selector

Selector Matches Pod Labels
```

---

# Important Interview Questions

## What Is A Label?

```text
A key-value pair attached to a Kubernetes object for identification, grouping, and selection.
```

---

## What Is A Selector?

```text
A query used to find Kubernetes objects based on labels.
```

---

## What Is An Annotation?

```text
A key-value pair used to store metadata that is not used for selection.
```

---

## Can Selectors Match Annotations?

```text
No.

Selectors Work Only With Labels.
```

---

## Why Do Services Use Labels?

```text
Services use selectors to find Pods with matching labels and route traffic to them.
```

---

## Does A Service Select Pods Using Deployment Labels?

```text
No.

A Service Selects Pods Using
Pod Labels Only.
```

---

## Can A Deployment Selector Be Changed?

```text
No.

For apps/v1 Deployments,
.spec.selector is immutable after creation.
```

Plan Deployment selectors carefully.

---

## What Is The Difference Between Label And Namespace?

```text
Namespace = Where Resource Lives

Label = What Resource Is
```

---

# Day 11 Golden Rules

```text
Namespace
      ↓
Where Does The Resource Live?

--------------------------------

Labels
      ↓
What Is This Resource?

--------------------------------

Selectors
      ↓
Which Resources Match?

--------------------------------

Annotations
      ↓
Additional Metadata

--------------------------------

Deployment
      ↓
Manages ReplicaSets

ReplicaSets
      ↓
Maintain Pods

--------------------------------

Deployment Selector
      ↓
Matches Pod Template Labels

--------------------------------

Service Selector
      ↓
Matches Pod Labels

--------------------------------

Service
      ↓
Creates EndpointSlices
      ↓
Routes Traffic

--------------------------------

Selectors Match Labels

NOT

Names

NOT

Annotations

--------------------------------

Pod Names Can Change

Pod Template Labels
Are Applied To Replacement Pods

--------------------------------

-l app
      ↓
Label Exists

--------------------------------

-l '!app'
      ↓
Label Does Not Exist

--------------------------------

env in (dev,test)
      ↓
dev OR test

--------------------------------

env notin (prod)
      ↓
Not prod
OR Label Missing

--------------------------------

Namespace
      ↓
Where Am I?

Labels
      ↓
Who Am I?

Selectors
      ↓
Who Am I Looking For?

Annotations
      ↓
Extra Information
```
