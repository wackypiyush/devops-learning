# Kubernetes Day 2 Notes
# Local Kubernetes Setup, Cluster Basics, kubectl, Namespaces & Cluster Health

---

# 1. Why Do We Need A Local Kubernetes Cluster?

The purpose of a local Kubernetes cluster is to:

```text
Learn Kubernetes Safely
Practice Kubernetes Commands
Deploy Applications
Experiment Without Affecting Production
```

Instead of learning directly on:

```text
Production Servers
```

we create a small Kubernetes cluster on our laptop.

---

## Our Setup

```text
Windows
   |
WSL2
   |
Docker
   |
Kind Cluster
   |
Kubernetes
```

---

## Create Cluster

```bash
kind create cluster \
  --name devops-lab
```

---

## Verify Cluster

```bash
kubectl get nodes
```

Output:

```text
NAME                       STATUS   ROLES           VERSION

devops-lab-control-plane   Ready    control-plane   v1.34.3
```

This confirms that the Kubernetes cluster is running.

---

# 2. What Is Kind?

## Definition

```text
Kind = Kubernetes IN Docker
```

Kind allows us to run Kubernetes locally using Docker containers.

Instead of needing:

```text
Physical Servers
Virtual Machines
Cloud Machines
```

Kind creates:

```text
Docker Containers
```

that behave like:

```text
Kubernetes Nodes
```

---

## Why Use Kind?

### Lightweight

```text
No Virtual Machines Required
```

---

### Fast

Clusters are created in seconds.

Example:

```text
Ready after 22 seconds
```

---

### Great For Learning

```text
Safe
Easy To Destroy
Easy To Recreate
```

---

### Commonly Used For

```text
Learning

Development

Testing

CI/CD Pipelines

DevOps Labs
```

---

# 3. How Kind Uses Docker To Run Kubernetes

When we ran:

```bash
kind create cluster
```

we did NOT create:

```text
Physical Server
```

Instead Kind created a Docker container:

```text
devops-lab-control-plane
```

Inside that container Kind installed:

```text
kube-apiserver

etcd

kube-scheduler

kube-controller-manager

kubelet

containerd
```

---

## Physical Architecture

```text
Windows
   |
WSL2
   |
Docker
   |
Kind Node Container
   |
Kubernetes Components
```

---

## Proof

Command:

```bash
kubectl get pods -A
```

Output included:

```text
etcd-devops-lab-control-plane

kube-apiserver-devops-lab-control-plane

kube-controller-manager-devops-lab-control-plane

kube-scheduler-devops-lab-control-plane
```

These are core Kubernetes components running inside the Kind cluster.

---

# 4. Docker vs Kind vs Kubernetes vs kubectl

## Docker

Role:

```text
Container Engine
```

Responsibilities:

```text
Build Images

Run Containers
```

---

## Kubernetes

Role:

```text
Container Orchestrator
```

Responsibilities:

```text
Manage Containers

Scale Applications

Self-Heal Applications

Networking

Scheduling
```

---

## Kind

Role:

```text
Local Kubernetes Environment
```

Responsibilities:

```text
Create Kubernetes Clusters
Using Docker Containers
```

---

## kubectl

Role:

```text
Client Tool / Remote Control
```

Responsibilities:

```text
Talk To Kubernetes

View Resources

Create Resources

Update Resources

Delete Resources
```

---

## Easy Memory Trick

```text
Docker
    ↓
Runs Containers

Kind
    ↓
Runs Kubernetes In Docker

Kubernetes
    ↓
Manages Containers

kubectl
    ↓
Talks To Kubernetes
```

---

# 5. What Is A Kubernetes Cluster?

## Definition

A Kubernetes Cluster is:

```text
A Group Of Machines
Managed By Kubernetes
```

that work together to run applications.

---

Think:

```text
One Big Computer
```

even though multiple machines may exist underneath.

---

## Production Example

```text
Users
   |
Kubernetes Cluster
   |
--------------------------------
|              |             |
Node-1       Node-2       Node-3
```

Users see one application, not multiple machines.

---

## Important

Command:

```bash
kubectl get pods -n kube-system
```

shows Kubernetes Control Plane components running in the cluster.

---

# 6. What Is A Node?

## Definition

A Node is:

```text
A Machine Participating In A Kubernetes Cluster
```

that provides resources to run workloads.

---

## A Node Can Be

```text
Physical Server

Virtual Machine

Cloud Instance

Docker Container (Kind)
```

---

## Node Structure

```text
Node
 |
 +-- Pod
 |
 +-- Pod
 |
 +-- Pod
```

---

## Example

Command:

```bash
kubectl describe node devops-lab-control-plane
```

Output:

```text
cpu: 8

memory: 3942780Ki

pods: 110
```

Meaning:

```text
8 CPUs

~4 GB RAM

Maximum 110 Pods
```

These are not necessarily the physical resources available to windows or wsl2 as a whole.

---

# 7. Understanding A Single-Node Kind Cluster

Production usually has:

```text
Control Plane

Worker-1

Worker-2

Worker-3
```

---

Kind creates:

```text
1 Node Cluster
```

where the same node acts as BOTH:

```text
Control Plane
     +
Worker Node
```

---

## Our Cluster

```text
devops-lab-control-plane
```

contains:

```text
API Server

Scheduler

Controller Manager

etcd

kubelet

containerd

Pods
```

All running on the same node.

---

# 8. kubectl Fundamentals

## What Is kubectl?

```text
kubectl = Kubernetes Command Line Client
```

Used to interact with Kubernetes.

---

## Common Commands

### View Nodes

```bash
kubectl get nodes
```

---

### View Pods

```bash
kubectl get pods
```

---

### Create Resources

```bash
kubectl apply -f deployment.yaml
```

---

### Delete Resources

```bash
kubectl delete pod my-pod
```

---

# How kubectl Communicates

Everything goes through the API Server.

```text
kubectl
     |
API Server
     |
Kubernetes Cluster
```

---

# Node Status

Command:

```bash
kubectl get nodes
```

Possible status values:

```text
Ready

NotReady

Unknown
```

---

# More Detailed Node Information

```bash
kubectl get nodes -o wide
```

Example:

```text
INTERNAL-IP:
172.18.0.2

OS-IMAGE:
Debian GNU/Linux 12

CONTAINER-RUNTIME:
containerd://2.2.0
```

---

# Deep Node Inspection

```bash
kubectl describe node devops-lab-control-plane
```

Shows:

```text
Node Identity

Labels

Conditions

Addresses

Capacity

Allocatable Resources

Container Runtime

PodCIDR

Running Pods

Events
```

---

# Cluster Endpoint Information

Command:

```bash
kubectl cluster-info
```

Output:

```text
Kubernetes control plane is running at:

https://127.0.0.1:38711
```

This is the API Server endpoint.

---

## CoreDNS

Output also includes:

```text
CoreDNS
```

CoreDNS provides:

```text
DNS Resolution Inside Kubernetes
```

---

## Important Questions

### What does kubectl cluster-info show?

It shows important cluster endpoints such as:

```text
API Server

CoreDNS
```

---

### How does kubectl communicate?

```text
kubectl
     |
API Server
     |
Cluster
```

---

### What does kubectl get nodes show?

```text
Node Name

Status

Roles

Age

Version
```

---

# 9. Kubernetes Contexts

## What Is A Context?

A Context is:

```text
A Saved Connection Profile
```

that tells kubectl:

```text
Which Cluster?

Which User?

Which Namespace? (Optionally)
```

to use.

---

## Why Contexts Exist?

Without contexts, every command would require:

```text
Server Address

Credentials

Namespace
```

manually.

---

## Current Context

Command:

```bash
kubectl config current-context
```

Output:

```text
kind-devops-lab
```

Meaning:

```text
kubectl is connected to our Kind cluster.
```

---

## Command Execution Flow

```text
kubectl get nodes
       |
Current Context
       |
kind-devops-lab
       |
API Server
       |
Cluster
```

---

## List All Contexts

```bash
kubectl config get-contexts
```

---

## Switch Context

```bash
kubectl config use-context dev-cluster
```

---

## Why It Matters

Example:

```text
dev-cluster

prod-cluster
```

If the current context is:

```text
prod-cluster
```

and you execute:

```bash
kubectl delete deployment backend
```

you might delete a production deployment.

---

## Safe Habit

Always check:

```bash
kubectl config current-context
```

before making important changes.

---

# 10. Kubernetes Namespaces

## What Is A Namespace?

A Namespace is:

```text
A Logical Partition Inside A Kubernetes Cluster
```

used to organize and isolate resources.

---

Namespaces help organize resources, and support access-control policies, but a namespace alone is not a security boundary.

## Structure

```text
Cluster
 |
 +-- Namespace A
 |
 +-- Namespace B
 |
 +-- Namespace C
```

---

Each namespace may contain:

```text
Pods

Deployments

Services

ConfigMaps

Secrets
```

---

## Why We Need Namespaces

Different teams can share one cluster:

```text
Development

Testing

Production
```

without mixing resources.

---

# Default Namespace

Kubernetes creates a namespace called:

```text
default
```

---

Nothing special about it.

It is simply:

```text
The Namespace Used When None Is Specified
```

---

Example:

```bash
kubectl get pods
```

equals:

```bash
kubectl get pods -n default
```

---

# View Namespaces

```bash
kubectl get namespaces
```

Output:

```text
default

kube-node-lease

kube-public

kube-system

local-path-storage
```

---

# kube-system Namespace

Contains Kubernetes system components.

Command:

```bash
kubectl get pods -n kube-system
```

Output:

```text
coredns

etcd

kube-apiserver

kube-controller-manager

kube-scheduler

kube-proxy
```

These are Kubernetes internal components.

---

## Other Built-In Namespaces

### kube-public

```text
Public Cluster Information
```

---

### kube-node-lease

```text
Node Heartbeats
```

Used internally.

---

### local-path-storage

Created by Kind.

Used for local storage provisioning.

---

# Pods Across All Namespaces

```bash
kubectl get pods -A
```

`-A` means:

```text
All Namespaces
```

---

# Why Namespaces Matter

```text
Organization

Isolation

Security

Access Control

Multi-Team Usage
```

---

# 11. Inspecting Cluster Health

## Pod Health Columns

Example:

```text
READY   STATUS    RESTARTS   AGE

1/1     Running   0          10m
```

---

### READY

```text
1/1
```

means:

```text
1 Container Ready
Out Of
1 Total Container
```

---

### STATUS

Common values:

```text
Running
Pending
Completed
CrashLoopBackOff
```

---

### RESTARTS

```text
0
```

means healthy.

---

```text
15
```

means:

```text
Container Crashed

Kubernetes Restarted It 15 Times
```

Investigate high restart counts.

---

### AGE

Shows how long the Pod has existed.

Examples:

```text
10m

2h

3d
```

---

# Why System Pods Exist Before My Application?

Because Kubernetes itself needs to run.

Examples:

```text
CoreDNS

etcd

API Server

Scheduler

Controller Manager
```

Without them:

```text
Cluster Cannot Function
```

---

# Node Conditions

Command:

```bash
kubectl describe node
```

Output:

```text
Ready          = True

MemoryPressure = False

DiskPressure   = False

PIDPressure    = False
```

---

## Ready

```text
Node Healthy
```

---

## MemoryPressure

```text
False
```

means sufficient memory available.

---

## DiskPressure

```text
False
```

means sufficient disk space available.

---

## PIDPressure

```text
False
```

means process limits are not exhausted.

---

# Capacity vs Allocatable

## Capacity

Total resources on the node.

Example:

```text
8 CPU

4 GB RAM
```

---

## Allocatable

Resources Kubernetes can allocate to Pods.

Production example:

```text
Capacity     = 8 CPU

Allocatable  = 7.5 CPU
```

because Kubernetes reserves some resources for itself.

---

## Formula

```text
Capacity
    -
Reserved Resources
    =
Allocatable
```

---

# 12. Kubernetes Events

Events explain:

```text
What Happened In The Cluster
```

and are extremely useful for troubleshooting.

---

## Common Events

### RegisteredNode

```text
Node Successfully Joined Cluster
```

---

### NodeReady

```text
Node Became Healthy
```

---

### NodeHasSufficientMemory

```text
Node Has Enough RAM
```

---

### NodeHasNoDiskPressure

```text
Node Has Enough Disk Space
```

---

## View Events

Cluster-wide:

```bash
kubectl get events
```

---

Specific Resource:

```bash
kubectl describe pod <pod-name>

kubectl describe node <node-name>
```

---

# Cluster Health Checklist

## Check Cluster

```bash
kubectl cluster-info
```

---

## Check Nodes

```bash
kubectl get nodes
```

Expected:

```text
STATUS = Ready
```

---

## Check System Pods

```bash
kubectl get pods -n kube-system
```

Expected:

```text
READY  = 1/1

STATUS = Running
```

---

## Check Node Conditions

```bash
kubectl describe node <node-name>
```

Expected:

```text
Ready          = True

MemoryPressure = False

DiskPressure   = False

PIDPressure    = False
```

---

## Check Events

```bash
kubectl get events
```

Look for:

```text
Warnings

Failures

Scheduling Issues
```

---

# Day 2 Golden Rules

```text
Kind = Kubernetes In Docker

kubectl Talks To Kubernetes Through API Server

Cluster = Group Of Nodes

Node = Machine Running Workloads

Pod = Smallest Deployable Unit

Namespaces Organize Resources

default = Application Namespace

kube-system = Kubernetes Components

Capacity = Total Resources

Allocatable = Resources Available To Pods

Events = What Happened In The Cluster

Healthy Cluster:
    Nodes Ready
    System Pods Running
    No Pressure Conditions
    No Critical Events
```
