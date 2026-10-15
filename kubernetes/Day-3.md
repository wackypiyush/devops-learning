# Kubernetes Day 3 Notes
# Pods, Pod Lifecycle & Basic Pod Troubleshooting

---

# Troubleshooting Mental Model

Before troubleshooting Kubernetes, identify **which layer has the problem**.

Think:

```text
Cluster   = City

Node      = Building

Pod       = Apartment

Container = Person
```

Always ask:

```text
At which layer is the problem?
```

---

## When The Application Is Not Accessible

Example:

```text
Website Not Opening
```

Start from the Pod level.

```bash
kubectl get pods
```

Check:

```text
STATUS

READY

RESTARTS
```

---

## When Application Crashes Repeatedly

This is usually a:

```text
Container / Application Problem
```

Commands:

```bash
kubectl logs <pod-name>
```

or

```bash
kubectl describe pod <pod-name>
```

Examples:

```text
Database Connection Failed

Configuration Missing

Port Already In Use

Null Pointer Exception
```

---

## When Pod Stays In Pending State

This is usually a:

```text
Node / Scheduling Problem
```

Check:

```bash
kubectl describe pod <pod-name>
```

Look for:

```text
Insufficient CPU

Insufficient Memory

Scheduling Errors
```

---

## When Storage Or Memory Is Running Low

Look at the Node.

```bash
kubectl describe node <node-name>
```

Check:

```text
MemoryPressure

DiskPressure
```

---

## When The Entire Cluster Feels Broken

Check cluster health.

```bash
kubectl cluster-info

kubectl get nodes
```

Look for:

```text
API Server Reachability

Node Status
```

---

## When You Need To Check Ports

### Container Port

```bash
kubectl describe pod <pod-name>
```

Look for:

```text
ContainerPort
```

---

### Service Port

```bash
kubectl get svc
```

Shows:

```text
Cluster Port

Target Port

NodePort (if applicable)
```

---

## When DNS Is Not Working

Check CoreDNS.

```bash
kubectl get pods -n kube-system
```

Verify:

```text
coredns
```

is healthy and running.

---

## When Pods Are Not Starting Anywhere

Check node health.

```bash
kubectl get nodes
```

Look for:

```text
Ready

NotReady
```

---

## When Kubernetes Components Are Broken

Check system pods.

```bash
kubectl get pods -n kube-system
```

Important system components:

```text
kube-apiserver

etcd

kube-scheduler

kube-controller-manager

coredns
```

---

# Quick Troubleshooting Cheat Sheet

| Problem | Check |
|----------|----------|
| Cluster not responding | `kubectl cluster-info` |
| Node unhealthy | `kubectl get nodes` |
| Detailed node issue | `kubectl describe node` |
| Application not running | `kubectl get pods` |
| Why pod failed | `kubectl describe pod` |
| Application logs | `kubectl logs <pod-name>` |
| DNS issue | `kubectl get pods -n kube-system` |
| Storage shortage | `kubectl describe node` |
| Memory shortage | `kubectl describe node` |
| Port issue | `kubectl describe pod`, `kubectl get svc` |
| Scheduling issue | `kubectl describe pod` |
| Cluster component issue | `kubectl get pods -n kube-system` |

---

# 1. What Is A Pod?

Pods are the most important object in Kubernetes.

---

## Kubernetes Hierarchy

```text
Cluster
 |
 +-- Node
       |
       +-- Pod
              |
              +-- Container
                     |
                     +-- Image
```

Read bottom-up:

```text
Image
   ↓
Container
   ↓
Pod
   ↓
Node
   ↓
Cluster
```

---

## Step 1: Container Image

A Container Image is:

```text
A Read-Only Template
```

Created from:

```dockerfile
Dockerfile
```

Examples:

```text
nginx:alpine

redis

mysql

python:3.11
```

---

## Step 2: Container

A Container is:

```text
A Running Instance Of An Image
```

Example:

```text
nginx:alpine image
       ↓
nginx container
```

---

## Step 3: Pod

Kubernetes does NOT deploy containers directly.

Kubernetes deploys:

```text
Pods
```

A Pod contains:

```text
One Or More Containers
```

Most common case:

```text
1 Pod
   ↓
1 Container
```

---

## Step 4: Node

A Node is:

```text
A Machine Running Pods
```

Examples:

```text
Virtual Machine

Physical Server

Cloud Instance

Docker Container (Kind)
```

---

## Step 5: Cluster

A Cluster is:

```text
A Collection Of Nodes
```

---

## Example: Deploying Nginx

```text
Cluster
 |
Node
 |
Pod
 |
Nginx Container
 |
Nginx Image
```

---

# 2. Why Kubernetes Does Not Run Containers Directly

Docker runs containers directly.

Example:

```bash
docker run nginx
```

---

Kubernetes needs additional features:

```text
Networking

Storage

Scheduling

Recovery

Shared Configuration

Lifecycle Management
```

Containers alone are not enough.

---

## Questions Kubernetes Must Solve

```text
Which IP belongs to the workload?

How do containers share storage?

How do workloads move across nodes?

How are failed workloads recovered?
```

---

## Solution: Pod

Pods provide the abstraction Kubernetes needs.

---

## What A Pod Gives Kubernetes

### Networking

Pods receive IP addresses.

Example:

```text
Pod IP
10.244.0.5
```

Containers inside the Pod share the Pod IP.

---

### Storage

Containers inside a Pod can share storage volumes.

```text
Container A
      |
Shared Volume
      |
Container B
```

---

### Scheduling

The Scheduler schedules:

```text
Pods
```

NOT containers.

---

### Recovery

Kubernetes monitors and recreates Pods when needed.

---

## Golden Rule

```text
You Do Not Ask Kubernetes To Run Containers.

You Ask Kubernetes To Run Pods.
```

---

# 3. Pod Lifecycle

Pods are temporary objects.

Every Pod goes through a lifecycle.

---

## Pending

Meaning:

```text
Pod Exists

Not Running Yet
```

Possible reasons:

```text
Waiting For Scheduling

Pulling Image

Insufficient Resources
```

---

## Running

Meaning:

```text
Pod Scheduled

Container Running

Application Running
```

Healthy state.

---

## Succeeded

Meaning:

```text
Pod Finished Successfully
```

Common for:

```text
Jobs

Scripts

Backups
```

---

## Failed

Meaning:

```text
Pod Could Not Finish Successfully
```

Due to:

```text
Application Errors

Startup Failures

Dependency Failures
```

---

## CrashLoopBackOff

Not a Pod phase, but a common status.

Meaning:

```text
Container Starts
      ↓
Crashes
      ↓
Restarts
      ↓
Crashes Again
```

Repeated continuously.

---

## Pod Deletion

Command:

```bash
kubectl delete pod nginx
```

Pod enters:

```text
Terminating
```

and Kubernetes shuts it down gracefully.

---

## Important Behavior

If a Deployment manages the Pod:

```text
Pod Deleted
      ↓
Deployment Notices
      ↓
New Pod Created
```

because desired state must be maintained.

---

## Pod Lifecycle Diagram

```text
Pending
   |
Running
   |
   +--> Succeeded
   |
   +--> Failed
   |
   +--> CrashLoopBackOff
   |
Terminating
```

---

# 4. Understanding `kubectl describe pod nginx`

Think:

```bash
kubectl get pods
```

as:

```text
Pod Summary
```

and:

```bash
kubectl describe pod nginx
```

as:

```text
Complete Pod Report
```

---

## Basic Information

```text
Name: nginx

Namespace: default

Status: Running
```

Meaning:

```text
Pod Name      = nginx

Namespace     = default

Current State = Running
```

---

## Node & Pod IP

```text
Node:
devops-lab-control-plane

IP:
10.244.0.5
```

Meaning:

```text
This Pod Runs On:

devops-lab-control-plane
```

and owns IP:

```text
10.244.0.5
```

---

### Important

```text
Pod Gets An IP

Container Does Not
```

Other pods communicate using the Pod IP.

---

## Container Information

```text
Container:
nginx
```

Pod contains:

```text
1 Container
```

named:

```text
nginx
```

---

## Runtime & Image

```text
Container ID:
containerd://...
```

means:

```text
Runtime = containerd
```

---

```text
Image:
nginx:alpine
```

Container was created using:

```text
nginx:alpine
```

image.

---

## Port

```text
Port: 80/TCP
```

Means:

```text
Nginx Is Listening On Port 80
```

inside the container.

---

## State

```text
State: Running
```

Container started successfully.

---

## Ready

```text
Ready: True
```

Means:

```text
Application Ready To Serve Traffic
```

---

## Restart Count

```text
Restart Count: 0
```

Meaning:

```text
Container Has Never Crashed
```

---

High restart counts should be investigated.

---

# Pod Conditions

```text
PodScheduled=True

Initialized=True

ContainersReady=True

Ready=True
```

---

## PodScheduled=True

```text
Scheduler Assigned A Node
```

---

## Initialized=True

```text
Pod Initialization Complete
```

---

## ContainersReady=True

```text
Containers Running Correctly
```

---

## Ready=True

```text
Pod Ready To Receive Traffic
```

Most important condition.

---

# QoS Class

```text
BestEffort
```

Meaning:

```text
No CPU Requests Defined

No Memory Requests Defined
```

Kubernetes uses resources if available.

---

# Events Section

Events show the actual startup sequence.

---

Example:

```text
Scheduled

Pulling

Pulled

Created

Started
```

Meaning:

```text
Scheduler Chose A Node
      ↓
Image Download Started
      ↓
Image Download Finished
      ↓
Container Created
      ↓
Container Started
```

---

## Real Pod Startup Flow

```text
Create Pod
      ↓
Scheduled
      ↓
Pull Image
      ↓
Create Container
      ↓
Start Container
      ↓
Running
```

---

# 5. Understanding `kubectl logs`

Command:

```bash
kubectl logs nginx
```

Shows:

```text
Application Stdout

Application Stderr
```

from inside the container.

---

This is usually the FIRST place to investigate application problems.

Examples:

```text
Database Connection Failed

Configuration Missing

Port Already In Use

Application Exception
```

---

# 6. Understanding `kubectl port-forward`

Pod IPs belong to the Kubernetes internal network.

Example:

```text
10.244.0.5
```

is not directly reachable from your browser.

---

## Port Forward

Command:

```bash
kubectl port-forward pod/nginx 8080:80
```

Meaning:

```text
Laptop Port 8080
        ↓
Forward To
        ↓
Pod Port 80
```

---

## Diagram

```text
Browser
   |
localhost:8080
   |
kubectl port-forward
   |
Pod
   |
Nginx:80
```

---

Now you can access:

```text
http://localhost:8080
```

and reach the Nginx container.

---

# 7. Understanding `kubectl delete pod`

Command:

```bash
kubectl delete pod nginx
```

Meaning:

```text
Delete This Pod
```

---

Output:

```text
pod "nginx" deleted
```

---

## Why Was It NOT Recreated?

Because it was a:

```text
Standalone Pod
```

There was:

```text
No Deployment

No ReplicaSet
```

managing it.

---

## If Managed By A Deployment

Flow:

```text
Pod Deleted
      ↓
Deployment Notices
      ↓
New Pod Created
```

Desired state is restored automatically.

---

# Biggest Day 3 Takeaway

```text
Image
  ↓
Container
  ↓
Pod
  ↓
Node
  ↓
Cluster

--------------------------------

Docker Runs Containers

Kubernetes Runs Pods

Pods Run Containers

--------------------------------

When Troubleshooting:

Cluster Issue?   → Check Cluster

Node Issue?      → Check Node

Pod Issue?       → Check Pod

App Issue?       → Check Logs
```


# Important Clarifications & Common Misconceptions

These points refine some concepts and prevent common misunderstandings.

---

## 1. Running Does NOT Guarantee Application Health

Many beginners assume:

```text
STATUS = Running
```

means:

```text
Application Is Healthy
```

❌ Not necessarily.

A Pod can be:

```text
STATUS = Running
```

while:

```text
Application returning errors

Database connections failing

Application stuck

Application serving bad responses
```

Always verify:

```text
Ready Status

Readiness Probes

Application Logs

Application Behaviour
```

Commands:

```bash
kubectl get pods

kubectl logs <pod-name>
```

---

## 2. Containers Do NOT Normally Have Separate IP Addresses

A common misconception:

```text
Every Container Gets An IP
```

❌ Not inside a Kubernetes Pod.

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

This is one of the reasons Kubernetes schedules Pods instead of individual containers.

---

## 3. Container Port Does NOT Prove The Application Is Listening

Command:

```bash
kubectl describe pod nginx
```

Output:

```text
Port: 80/TCP
```

This only shows:

```text
Declared Container Port
```

It does NOT prove:

```text
Application Is Actually Listening

Application Is Healthy

Traffic Is Being Served
```

Always verify using:

```bash
kubectl logs <pod-name>
```

or actual connectivity tests.

---

## 4. kubectl logs Has Limitations

Command:

```bash
kubectl logs <pod-name>
```

Shows:

```text
stdout

stderr
```

from the container.

---

However it may NOT show:

```text
Application Log Files
```

Example:

```text
/var/log/app.log

/app/logs/error.log
```

unless the application writes those logs to:

```text
stdout

stderr
```

which is considered the Kubernetes best practice.

---

## 5. CrashLoopBackOff Is NOT A Pod Phase

Many people think:

```text
Pending

Running

Succeeded

Failed

CrashLoopBackOff
```

are all Pod phases.

❌ Incorrect.

Actual Pod phases are:

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
A Pod Status / Container State
```

indicating:

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

The "BackOff" means Kubernetes is intentionally slowing restart attempts.

---

## 6. MemoryPressure=False Does NOT Mean Plenty Of Memory

From:

```bash
kubectl describe node
```

you may see:

```text
MemoryPressure=False
```

This does NOT mean:

```text
Lots Of Free Memory Available
```

❌

It only means:

```text
Node Is Not Currently Reporting
Memory Pressure
```

The node may still be using a large amount of memory.

The same applies to:

```text
DiskPressure=False

PIDPressure=False
```

These are:

```text
Health Conditions

NOT Resource Utilization Metrics
```

For actual usage monitoring, use tools such as:

```text
Metrics Server

kubectl top

Prometheus

Grafana
```

---

# Golden Rule

Always separate:

```text
Declared State
        vs
Actual Behaviour
```

Examples:

```text
Running
≠ Healthy

Port Declared
≠ Port Listening

Pod Exists
≠ Application Working

MemoryPressure=False
≠ Plenty Of Free Memory

Deployment
≠ Direct Pod Management
```

Kubernetes tells you what it knows about resources, but verifying application behaviour often requires checking readiness, logs, metrics, connectivity, and actual application responses.
