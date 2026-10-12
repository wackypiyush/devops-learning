# Kubernetes Day 1 Notes
# Introduction to Kubernetes

---

# 1. Why Do We Need Kubernetes?

Docker solved a major problem:

```text
Build Once
Run Anywhere
```

An application packaged inside a Docker image can run consistently across different environments.

---

## Docker Works Well For A Few Containers

Example:

```text
Frontend Container
       |
Backend Container
       |
Redis Container
       |
MySQL Container
```

Managing 4 containers manually is still manageable.

---

## Real Problem Starts At Scale

As traffic increases:

```text
Backend-1
Backend-2
Backend-3
```

Now questions appear:

```text
Who creates new containers?

Who distributes traffic?

Who replaces failed containers?

Who updates applications?

Who decides where containers run?
```

Docker alone does not automatically solve these problems.

---

## What If A Container Crashes?

Example:

```text
Backend Container Crashes
```

Without an orchestration platform:

```text
Someone must manually restart it.
```

Recovery becomes operational work.

---

## What If A Server Crashes?

Example:

```text
Server-1

├── Frontend
├── Backend
└── MySQL
```

If the server dies:

```text
Application becomes unavailable.
```

Docker cannot automatically move workloads to another server.

---

## What About Multiple Servers?

As the company grows:

```text
Server-1
Server-2
Server-3
Server-4
Server-5
```

Now new problems appear:

```text
Which server should run a container?

How do we scale?

How do we recover from failures?

How do we update without downtime?

How do we monitor everything?
```

Docker is a container runtime platform, not a large-scale orchestration platform.

---

## Why Kubernetes Exists

Kubernetes is a:

```text
Container Orchestration Platform
```

Think:

```text
Docker
   ↓
Creates Containers

Kubernetes
   ↓
Manages Containers At Scale
```

---

## Real Analogy

```text
Docker
   =
A Car

Kubernetes
   =
Fleet Management System
```

Driving one car is easy.

Managing thousands of cars requires automation.

---

## Interview Answer

### Why Do We Need Kubernetes?

Docker can run containers, but managing large numbers of containers across multiple servers becomes difficult. Kubernetes automates deployment, scaling, networking, load balancing, self-healing, and application updates.

---

# 2. What Problems Does Kubernetes Solve?

---

## Auto Healing

Container crashes:

```text
Container
     ↓
Crash
     ↓
Kubernetes Detects Failure
     ↓
Creates Replacement
```

---

## Auto Scaling

Traffic increases:

```text
3 Pods
   ↓
10 Pods
```

Traffic decreases:

```text
10 Pods
   ↓
3 Pods
```

Scaling can be manual or automatic.

---

## Load Balancing

User requests get distributed:

```text
Request 1 → Backend-1

Request 2 → Backend-2

Request 3 → Backend-3
```

---

## Rolling Updates

Application upgrade:

```text
v1
 ↓
v2
```

Kubernetes gradually replaces old instances with new ones without downtime.

---

## Multi-Server Management

Kubernetes decides:

```text
Which node should run a workload?
```

No manual placement required.

---

## Key Definition

Kubernetes is a container orchestration platform that automates deployment, scaling, networking, load balancing, self-healing, and management of containerized applications.

---

# 3. Kubernetes vs Docker

## Docker Responsibilities

```text
Build Images

Run Containers
```

Example:

```bash
docker build

docker run
```

---

## Kubernetes Responsibilities

```text
Deploy Workloads

Scale Workloads

Restart Failed Workloads

Load Balance Traffic

Manage Multiple Machines
```

---

## Important Limitation

Kubernetes is not magic.

It cannot automatically guarantee:

```text
Correct Application Code

Correct Business Logic

Healthy Database Data

Unlimited Resources
```

It manages infrastructure, not application correctness.

---

# 4. Kubernetes Cluster

## Definition

A Kubernetes Cluster is:

```text
A Group Of Machines
Running Kubernetes
```

that work together as a single system.

---

## Smallest Cluster

Even a single machine can be a cluster:

```text
Machine
   |
Kubernetes
```

---

## Production Cluster

```text
Server-1

Server-2

Server-3

Server-4

Server-5
```

Together they form:

```text
Kubernetes Cluster
```

---

# Cluster Architecture

A Kubernetes cluster consists of:

```text
Control Plane
      +
Worker Nodes
```

---

## Control Plane

The:

```text
Brain Of Kubernetes
```

Responsibilities:

```text
Scheduling

Decision Making

Cluster State Management

Desired State Management
```

---

## Worker Nodes

Machines that actually run workloads.

Example:

```text
Control Plane
      |
-----------------------
|          |          |
Node-1   Node-2    Node-3
```

Applications run on:

```text
Node-1

Node-2

Node-3
```

---

## Why Is It Called A Cluster?

Because multiple machines behave like:

```text
One System
```

instead of many individual servers.

---

## Benefits

### High Availability

```text
Node Failure
      ↓
Application Still Runs
```

---

### Scalability

Add more nodes:

```text
Node-4

Node-5
```

Cluster grows.

---

### Better Resource Usage

Kubernetes schedules workloads efficiently.

---

### Fault Tolerance

Node failure does not automatically mean application failure.

---

## Example

```text
Users
   |
Kubernetes Cluster
   |
----------------------------------
|               |               |
Node-1       Node-2        Node-3
|               |               |
Backend      Backend       Backend
```

---

## Interview Answer

### What Is A Kubernetes Cluster?

A Kubernetes cluster is a group of machines managed by Kubernetes, consisting of a control plane and worker nodes, working together to run and manage applications.

---

# 5. What Is A Pod?

## Docker Container ≠ Kubernetes Pod

A Pod is NOT a container.

A Pod is:

```text
A Wrapper Around One Or More Containers
```

---

## Why Did Kubernetes Create Pods?

Kubernetes needed an object that could:

```text
Manage Containers

Provide Networking

Provide Storage

Support Scheduling

Support Recovery
```

The result was:

```text
Pod
```

---

## Definition

A Pod is:

```text
The Smallest Deployable Unit In Kubernetes
```

A Pod contains:

```text
One Or More Containers
```

---

## Typical Case

Most applications:

```text
1 Pod ≈ 1 Container
```

Example:

```text
Pod
 |
nginx Container
```

---

## Multiple Containers

Possible:

```text
Pod
 |
 +--- Application Container
 |
 +--- Log Collector Container
```

---

## Why Multiple Containers?

They need to work very closely together.

Containers inside a Pod share:

```text
Network

Storage
```

---

## Pod Gets IP, Not Container

### Docker

```text
Container
     |
Gets IP
```

### Kubernetes

```text
Pod
   |
Gets IP
```

Example:

```text
Pod IP = 10.244.1.15

Container A
Container B
```

Both containers share the Pod IP.

---

## Analogy

```text
Pod = House

Containers = People

IP = House Address
```

The house gets an address.

The people do not.

---

## Pod Lifecycle

```text
Pod Created
      ↓
Containers Start
      ↓
Container Crashes
      ↓
Kubernetes Restarts It
```

If the Pod itself is lost:

```text
Kubernetes Creates A New Pod
```

---

## Important Rule

Never think:

```text
I deploy containers
```

In Kubernetes, you deploy:

```text
Pods
```

and the Pod runs containers.

---

## Interview Answer

A Pod is the smallest deployable unit in Kubernetes. It is a wrapper around one or more containers that share storage and networking resources.

---

# 6. Control Plane Components

The Control Plane is:

```text
Brain Of Kubernetes
```

Core components:

```text
kube-apiserver

etcd

kube-scheduler

kube-controller-manager
```

---

## kube-apiserver

Main entry point of Kubernetes.

Everything talks to:

```text
kube-apiserver
```

Example:

```bash
kubectl get pods

kubectl apply -f app.yaml
```

All requests go through the API Server.

---

### Analogy

```text
Reception Desk
```

Every request enters through reception.

---

## etcd

The Kubernetes database.

Stores:

```text
Deployments

Pods

Services

Secrets

Cluster Configuration
```

---

### Example

Desired:

```text
Replicas = 3
```

Stored inside etcd.

---

### Important

If etcd is lost:

```text
Cluster State Is Lost
```

This is why backups are critical.

---

### Analogy

```text
Cluster Memory
```

---

## kube-scheduler

Responsible for:

```text
Choosing Which Node Runs A Pod
```

Considers:

```text
CPU

Memory

Constraints

Taints/Tolerations

Node Labels
```

---

### Analogy

```text
Hotel Room Allocator
```

Chooses the best room for the guest.

---

## kube-controller-manager

Responsible for:

```text
Maintaining Desired State
```

Continuously compares:

```text
Desired State

vs

Actual State
```

and takes corrective action.

---

### Analogy

```text
Quality Inspector
```

---

# Control Plane Flow

```text
kubectl
    |
API Server
    |
etcd

Controller Watches

Scheduler Places Pods

Controller Ensures Desired State
```

---

# 7. Worker Node Components

Worker nodes are where workloads actually run.

---

## Architecture

```text
Worker Node

├── kubelet

├── kube-proxy

└── Container Runtime
```

---

## kubelet

Most important worker node component.

Acts as:

```text
Node Agent
```

Responsibilities:

```text
Run Pods

Delete Pods

Restart Pods
```

Works on instructions received from the Control Plane.

---

### Analogy

```text
Factory Worker
```

Receives instructions and performs work.

---

## Container Runtime

Actually runs containers.

Examples:

```text
containerd

CRI-O
```

Responsibilities:

```text
Pull Images

Create Containers

Start Containers

Stop Containers
```

---

### Flow

```text
kubelet
     |
containerd
     |
Container Starts
```

---

### Analogy

```text
Engine
```

that actually runs containers.

---

## kube-proxy

Handles cluster networking.

Responsibilities:

```text
Pod Communication

Service Networking

Load Balancing
```

---

### Analogy

```text
Traffic Police
```

Directs traffic to the correct destination.

---

# Worker Node Flow

```text
Control Plane
      |
Run Pod
      |
kubelet
      |
containerd
      |
Container Starts

Networking
      |
kube-proxy
```

---

# 8. Complete Kubernetes Architecture

```text
                    Control Plane
                           |
 ---------------------------------------------------
 |               |              |                 |
API Server     etcd      Scheduler     Controller Manager
                           |
 ---------------------------------------------------
 |                         |                       |
Worker-1              Worker-2                Worker-3
 |                         |                       |
kubelet                kubelet                 kubelet
 |                         |                       |
containerd            containerd             containerd
 |                         |                       |
Pods                  Pods                   Pods
```

---

# 9. Why Kubernetes Uses containerd Instead Of Docker

## Common Misconception

```text
Docker removed from Kubernetes
      ↓
Docker images can't run
```

❌ Wrong

Docker-format images work perfectly.

---

## Docker Internals

Docker itself uses:

```text
Docker CLI
     |
dockerd
     |
containerd
     |
runc
     |
Container
```

---

## containerd

Actual container runtime.

Responsible for:

```text
Pull Images

Create Containers

Start Containers

Stop Containers
```

---

## runc

Low-level runtime.

Actually creates Linux containers using:

```text
Namespaces

Cgroups

Filesystem

Networking
```

---

## Old Kubernetes Flow

```text
Kubernetes
      |
Docker
      |
containerd
      |
runc
```

---

## Modern Kubernetes Flow

```text
Kubernetes
      |
containerd
      |
runc
```

---

## Why?

Kubernetes already provides:

```text
Scheduling

Scaling

Networking

Deployments

Self-Healing
```

It only needs:

```text
A Container Runtime
```

containerd provides exactly that.

---

## Docker vs containerd

### Docker

```text
Build Images ✅

Run Containers ✅

Compose ✅

Registry Integration ✅

Developer Tooling ✅
```

---

### containerd

```text
Build Images ❌

Compose ❌

Developer Tooling ❌

Run Containers ✅

Image Management ✅
```

---

## Why Do Developers Still Use Docker?

Because developers need:

```text
docker build

docker compose

docker push

docker pull
```

containerd is too low level for development tasks.

---

## Interview Answer

Kubernetes does not need Docker's build, compose, and developer tooling. It only needs a container runtime. Since Docker itself uses containerd internally, Kubernetes communicates directly with containerd and avoids an extra layer.

---

# 10. Kubernetes Request Flow

Kubernetes revolves around:

```text
Desired State Management
```

You declare:

```text
What You Want
```

Kubernetes figures out:

```text
How To Make It Happen
```

---

## Example

```yaml
spec:
  replicas: 3
```

Meaning:

```text
I want 3 Pods
Running
At All Times
```

---

## Complete Flow

```text
kubectl apply
      |
API Server
      |
etcd
      |
Controllers
      |
Scheduler
      |
Worker Node
      |
kubelet
      |
containerd
      |
Pods Running
```

---

## Step 1 - Submit Desired State

```bash
kubectl apply -f deployment.yaml
```

You are declaring:

```text
Desired State = 3 Replicas
```

---

## Step 2 - API Server

Performs:

```text
Validation

Authentication

Authorization

Request Processing
```

---

## Step 3 - Store Cluster State

State written to:

```text
etcd
```

At this moment:

```text
Pods May Not Exist Yet
```

Only desired state exists.

---

## Step 4 - Controllers Reconcile

Controller sees:

```text
Need 3 Pods
```

Creates:

```text
ReplicaSet
```

ReplicaSet creates:

```text
Pods
```

---

## Step 5 - Scheduler Assigns Nodes

Pods start as:

```text
Pending
```

Scheduler chooses suitable nodes.

Based on:

```text
CPU

Memory

Labels

Taints/Tolerations

Constraints
```

---

## Step 6 - kubelet And Runtime

Node receives Pod assignment.

```text
kubelet
     |
containerd
     |
Containers Start
```

---

## Step 7 - Continuous Reconciliation

Kubernetes continuously checks:

```text
Desired State

vs

Actual State
```

Example:

```text
Desired = 3 Pods

Actual = 2 Pods
```

Kubernetes creates another Pod.

---

# 11. Asynchronous Nature Of Kubernetes

Kubernetes components work asynchronously.

---

## Synchronous Example

```text
Order Coffee
      ↓
Wait
      ↓
Coffee Ready
      ↓
Go Home
```

Each step waits for the previous step.

---

## Kubernetes Example

You run:

```bash
kubectl apply -f deployment.yaml
```

API Server:

```text
Stores Desired State

Returns Success
```

immediately.

Meanwhile:

```text
Controllers

Scheduler

kubelet

containerd
```

continue working independently.

---

## Important Result

Creating a Deployment does NOT mean:

```text
Pods Are Running
```

immediately.

---

## Always Verify

```bash
kubectl rollout status deployment/<name>

kubectl get pods

kubectl get events

kubectl describe pod <pod-name>
```

---

# Most Important Kubernetes Concept

## Reconciliation

Definition:

```text
Continuous Process Of Making
Actual State Match Desired State
```

Example:

```text
Desired = 3 Pods

Actual = 2 Pods
```

Kubernetes creates:

```text
1 New Pod
```

to restore the desired state.

---

# 12. What Kubernetes Does NOT Automatically Solve

Kubernetes solves infrastructure problems.

It does NOT automatically solve application problems.

---

## Cannot Fix Application Bugs

Example:

```python
x = 10 / 0
```

Pod crashes.

Kubernetes restarts it.

Bug still exists.

---

## Cannot Fix Business Logic

Example:

```text
Login Always Fails
```

Application runs.

Users unhappy.

Kubernetes sees:

```text
Healthy Pods
```

---

## Cannot Protect Pod Filesystem Data

Example:

```text
Pod
 |
customers.db
```

Pod dies.

New Pod created.

Data lost.

Reason:

```text
Pod Storage Is Ephemeral
```

---

## Cannot Guarantee Database Health

Database process running:

```text
Healthy Pod
```

Database corrupted:

```text
Users Still Have Problems
```

Kubernetes cannot automatically repair application data.

---

## Cannot Guarantee Application Correctness

Application may:

```text
Return Wrong Results
```

Pods can still be healthy.

---

## Cannot Fix Wrong Configuration

Example:

```text
DB_HOST=wrong-server
```

Pods run.

Application fails.

---

## Services Don't Guarantee Connectivity

Possible issues:

```text
Wrong Selector

Wrong Port

Network Policy Block

Firewall Problems
```

Service exists.

Connectivity still fails.

---

## Cannot Create Resources Out Of Thin Air

Cluster:

```text
10 CPUs
```

Workload requires:

```text
100 CPUs
```

Pods remain pending.

---

## Cannot Replace Capacity Planning

Kubernetes schedules resources efficiently.

It does not create:

```text
New CPU

New RAM

New Hardware
```

---

# Kubernetes Guarantees

```text
Desired State Management

Scheduling

Networking

Self-Healing

Scaling

Deployments
```

---

# Kubernetes Does Not Guarantee

```text
Correct Code

Correct Business Logic

Correct Data

Correct Configuration

Infinite Capacity
```

---

# Golden Rule

```text
Kubernetes Manages Infrastructure.

Kubernetes Does NOT Manage Application Quality.
```

Or:

```text
Kubernetes Can Restart A Broken Application.

It Cannot fix a broken application.

# Additional Important Concepts

---

# 13. Scheduler Does NOT Create Pods

A very common misconception:

```text
Scheduler Creates Pods
```

❌ Wrong

The scheduler never creates Pods.

---

## Who Creates Pods?

Controllers create Pods.

Example:

```text
Deployment
     ↓
ReplicaSet
     ↓
Pods Created
```

The Deployment Controller and ReplicaSet Controller are responsible for ensuring the required Pods exist.

---

## Then What Does The Scheduler Do?

A Pod is first created without a node assignment.

Example:

```text
Pod-1 → No Node

Pod-2 → No Node

Pod-3 → No Node
```

These are unscheduled Pods.

---

The Scheduler's job is:

```text
Find A Suitable Worker Node
```

and assign the Pod.

Example:

```text
Pod-1 → Worker-1

Pod-2 → Worker-2

Pod-3 → Worker-3
```

---

## Correct Flow

```text
kubectl apply
      ↓
API Server
      ↓
etcd
      ↓
Deployment Controller
      ↓
ReplicaSet
      ↓
Pods Created
      ↓
Scheduler Assigns Nodes
      ↓
kubelet Starts Pods
```

---

## Interview Question

### Does kube-scheduler create Pods?

No.

Controllers create Pods.

The Scheduler only assigns eligible unscheduled Pods to suitable worker nodes.

---

# 14. What Is A Deployment?

A Deployment is one of the most commonly used Kubernetes resources.

---

## Definition

A Deployment manages stateless application rollouts through ReplicaSets.

It helps:

```text
Maintain The Desired Number Of Replicas

Perform Rolling Updates

Support Rollbacks

Replace Failed Pods
```

---

## Example

Deployment:

```yaml
spec:
  replicas: 3
```

Desired state:

```text
3 Running Pods
```

Deployment continuously works with ReplicaSets and controllers to maintain that state.

---

## Deployment Hierarchy

```text
Deployment
      ↓
ReplicaSet
      ↓
Pods
      ↓
Containers
```

---

## Why Use Deployments?

Without Deployment:

```text
Need To Manage Pods Manually
```

With Deployment:

```text
Automatic Self-Healing

Automatic Scaling

Rolling Updates

Rollbacks
```

---

## Rolling Update Example

Current Version:

```text
v1
```

New Version:

```text
v2
```

Deployment performs:

```text
Old Pod Removed Gradually
          ↓
New Pod Added Gradually
```

without downtime.

---

## Rollback Example

New release:

```text
v2
```

causes issues.

Deployment can rollback:

```text
v2
     ↓
v1
```

quickly.

---

## Interview Answer

### What is a Deployment?

A Deployment is a Kubernetes resource that manages stateless application rollouts through ReplicaSets. It maintains the desired number of Pod replicas and supports rolling updates, rollbacks, and self-healing.

---

# Final Architecture Hierarchy

```text
Cluster
   ↓
Control Plane
   ↓
Deployment
   ↓
ReplicaSet
   ↓
Pods
   ↓
Containers
```

# Golden Rules

```text
Controllers Create Pods

Scheduler Assigns Pods To Nodes

kubelet Runs Pods On Nodes

Deployment Manages ReplicaSets

ReplicaSets Maintain Pod Count

Pods Run Containers
```



