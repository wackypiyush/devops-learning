# Kubernetes Day 5 Notes
# Kubernetes Services, Service Discovery & Service DNS

---

# 1. The Problem: Pods Have Changing IPs

Pods receive IP addresses when they are created.

Example:

```text
Pod-A → 10.244.0.5

Pod-B → 10.244.0.6

Pod-C → 10.244.0.7
```

---

## Problem 1: Pod IPs Are Temporary

Suppose:

```text
Pod-A → 10.244.0.5
```

Pod crashes.

ReplicaSet creates a replacement Pod:

```text
Pod-A-New → 10.244.0.9
```

Old IP:

```text
10.244.0.5
```

no longer exists.

Applications using the old IP will fail.

---

## Problem 2: Multiple Pod Replicas

Suppose Deployment creates:

```text
Pod-A → 10.244.0.5

Pod-B → 10.244.0.6

Pod-C → 10.244.0.7
```

Question:

```text
Which IP Should Clients Use?
```

---

## Problem 3: Scaling Changes The Pod List

Current:

```text
3 Pods
```

Scale:

```bash
kubectl scale deployment web-app --replicas=5
```

Now new Pods and new IPs appear.

Applications cannot continuously track Pod IPs.

---

## Problem 4: Load Balancing

Suppose:

```text
3 Backend Pods
```

Incoming traffic:

```text
Request-1

Request-2

Request-3
```

How should requests be distributed?

Pods themselves do not solve this.

---

# Kubernetes Solution: Service

Instead of:

```text
Application
      ↓
Pod IP
```

we use:

```text
Application
      ↓
Service
      ↓
Pods
```

---

## Analogy

```text
Pods
      =
Employees

Service
      =
Reception Desk
```

Users call the reception desk.

The reception desk routes requests to employees.

---

# 2. What Is A Kubernetes Service?

## Definition

A Service is a Kubernetes resource that provides:

```text
Stable Network Identity

Stable IP Address

Stable DNS Name

Load Balancing
```

for a group of Pods.

---

## Why Services Exist

Services solve:

```text
Changing Pod IPs

Pod Discovery

Load Balancing

Stable Communication
```

---

## With A Service

Instead of:

```text
Frontend
      ↓
10.244.0.5
```

we use:

```text
Frontend
      ↓
web-service
      ↓
Pods
```

Pods may change.

Service remains.

---

## How Services Find Pods

Services use:

```text
Labels

Selectors
```

---

### Example Pod

```yaml
labels:
  app: web-app
```

---

### Example Service

```yaml
selector:
  app: web-app
```

---

Meaning:

```text
Send Traffic To
All Pods With:

app=web-app
```

---

## Important Clarification

A Service:

```text
Does NOT Own Pods
```

Ownership is maintained through:

```text
Owner References
```

Services simply use:

```text
Selectors
```

to find matching Pods.

---

## Traffic Flow

```text
User
  |
Service
  |
-------------------
|        |        |
Pod-1   Pod-2   Pod-3
```

---

# Benefits Of Services

## Stable Endpoint

```text
Pods Change

Service Stays
```

---

## Service Discovery

Applications use:

```text
web-service
```

instead of Pod IPs.

---

## Load Balancing

Traffic automatically distributes across Pods.

---

## Decoupling

Applications don't need to know:

```text
Which Pod?

Which IP?

How Many Replicas?
```

Service handles it.

---

# 3. Three Main Service Types

Kubernetes provides three commonly used Service types:

```text
ClusterIP

NodePort

LoadBalancer
```

---

# Service Type 1: ClusterIP

## Default Service Type

If no type is specified:

```text
ClusterIP
```

is used.

---

## Accessibility

```text
Inside Cluster ✅

Outside Cluster ❌
```

---

## Example

```text
Frontend
      ↓
backend-service
      ↓
Backend Pods
```

Only Pods inside Kubernetes can use it.

---

## Typical Use Cases

```text
Frontend → Backend

Backend → Database

Internal Microservices
```

---

## Diagram

```text
Pods
  |
ClusterIP Service
  |
Other Pods
```

---

# Service Type 2: NodePort

## Purpose

Expose an application outside the cluster.

---

## Example

```text
User
      ↓
NodeIP:30080
      ↓
Service
      ↓
Pods
```

---

### Detailed Example

Nodes:

```text
Node-1 → 192.168.1.10

Node-2 → 192.168.1.11

Node-3 → 192.168.1.12
```

NodePort:

```text
30080
```

Now all work:

```text
192.168.1.10:30080

192.168.1.11:30080

192.168.1.12:30080
```

---

## Important

NodePort:

```text
Does NOT Create A New IP
```

It opens:

```text
The Same Port
On Every Node
```

---

## Accessibility

```text
Inside Cluster ✅

Outside Cluster ✅
```

---

## Common Uses

```text
Learning

Testing

Development Labs
```

---

## Diagram

```text
Browser
      ↓
NodeIP:30080
      ↓
Service
      ↓
Pods
```

---

# Service Type 3: LoadBalancer

## Purpose

Expose applications through a cloud load balancer.

---

## Example

```text
Internet
      ↓
Cloud Load Balancer
      ↓
Service
      ↓
Pods
```

---

## Accessibility

```text
Inside Cluster ✅

Outside Cluster ✅
```

---

## Benefit

Users see:

```text
One Public IP
```

instead of individual node IPs.

---

## Diagram

```text
Users
   |
Public IP
   |
Load Balancer
   |
Service
   |
Pods
```

---

# Service Type Comparison

| Service Type | Internal Access | External Access | Typical Usage |
|-------------|----------------|----------------|---------------|
| ClusterIP | ✅ | ❌ | Internal communication |
| NodePort | ✅ | ✅ | Labs & testing |
| LoadBalancer | ✅ | ✅ | Production access |

---

# Easy Summary

## ClusterIP

```text
Problem Solved:
Changing Pod IPs

Provides:
Stable Service Name

Used By:
Other Pods
```

---

## NodePort

```text
Problem Solved:
External Access

Provides:
Same Port On Every Node

Used By:
Testing And Labs
```

---

## LoadBalancer

```text
Problem Solved:
Production Internet Access

Provides:
Single Public IP

Used By:
Real Users
```

---

# 4. Port Forward And Services

Port forwarding and Services are separate concepts.

---

## Service

Permanent Kubernetes networking object.

```text
Pods
      ↓
Service
      ↓
Stable Networking
```

---

## Port Forward

Temporary tunnel created by kubectl.

```text
Laptop
      ↓
kubectl
      ↓
Pod / Service
```

---

## Service

```text
Permanent

Managed By Kubernetes
```

---

## Port Forward

```text
Temporary

Stops When Terminal Closes

Mostly Used For Debugging
```

---

# 5. Create Your First Service

Command:

```bash
kubectl expose deployment web-app \
  --name=web-service \
  --port=80 \
  --target-port=80 \
  --type=ClusterIP
```

---

## What Does kubectl expose Mean?

```text
Deployment Exists
      ↓
Create Service In Front Of It
```

Instead of writing Service YAML manually.

---

## deployment web-app

```text
Create Service
For Deployment web-app
```

Kubernetes automatically discovers matching Pods.

---

## --name=web-service

Service name:

```text
web-service
```

Other Pods can use:

```text
http://web-service
```

instead of Pod IPs.

---

## --port=80

Service Port.

Clients communicate with:

```text
web-service:80
```

---

## --target-port=80

Traffic is forwarded to:

```text
Container Port 80
```

Flow:

```text
Service:80
      ↓
Container:80
```

---

## --type=ClusterIP

Creates:

```text
Internal Service
```

Accessible only inside Kubernetes.

---

## What Gets Created?

```text
Deployment
      ↓
ReplicaSet
      ↓
Pods

      ▲
      |
Service
(web-service)
```

---

# 6. Check Services

Command:

```bash
kubectl get services
```

Example:

```text
NAME          TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)

kubernetes    ClusterIP   10.96.0.1       <none>        443/TCP

web-service   ClusterIP   10.96.141.55    <none>        80/TCP
```

---

## NAME

```text
web-service
```

Service name.

Used for DNS.

---

## TYPE

```text
ClusterIP
```

Service type.

---

## CLUSTER-IP

Example:

```text
10.96.141.55
```

Stable Service IP.

Applications usually use:

```text
web-service
```

rather than the IP directly.

---

## EXTERNAL-IP

```text
<none>
```

Because ClusterIP is internal.

---

## PORT(S)

```text
80/TCP
```

Service listens on Port 80.

---

# 7. Describe Service

Command:

```bash
kubectl describe service web-service
```

Example:

```text
Name:         web-service
Namespace:    default
Selector:     app=web-app
Type:         ClusterIP
IP:           10.96.141.55
Port:         80/TCP
TargetPort:   80/TCP
Endpoints:    10.244.0.5:80,10.244.0.6:80
```

---

## Selector

```text
app=web-app
```

Tells the Service:

```text
Which Pods To Send Traffic To
```

---

## IP

```text
10.96.141.55
```

Stable Service IP.

---

## Port

```text
80
```

Clients connect here.

---

## TargetPort

```text
80
```

Containers receive traffic here.

---

## Endpoints

Example:

```text
10.244.0.5:80

10.244.0.6:80
```

Shows:

```text
Which Pods
Are Behind The Service
```

---

## Important

When Pods are added or removed:

```text
Endpoints Update Automatically
```

---

# Visual Flow

```text
web-service
      |
      ▼
--------------------
|                  |
Pod-A            Pod-B
10.244.0.5       10.244.0.6
```

---

# 8. Service IP vs Pod IP

## Pod IP

Example:

```text
10.244.0.5
```

Characteristics:

```text
Temporary

Changes When Pod Is Recreated
```

---

## Service IP

Example:

```text
10.96.141.55
```

Characteristics:

```text
Stable

Exists As Long As Service Exists
```

---

# 9. Service Port vs TargetPort

This is a very important concept.

---

## Service Port

Port exposed by the Service.

Clients connect here.

Example:

```yaml
port: 80
```

Client uses:

```text
web-service:80
```

---

## TargetPort

Port inside the container.

Example:

```yaml
targetPort: 8080
```

Application receives traffic here.

---

## Example

```yaml
port: 80
targetPort: 8080
```

Flow:

```text
Client
      |
web-service:80
      |
Service
      |
Container:8080
```

---

# 10. Port Forward Using Service

Earlier:

```bash
kubectl port-forward pod/nginx 8080:80
```

Flow:

```text
Laptop
      ↓
Pod
```

---

Now:

```bash
kubectl port-forward service/web-service 8080:80
```

Flow:

```text
Laptop
      ↓
Service
      ↓
Pods
```

---

## Why Is Service Port Forward Better?

### Pod Port Forward

```text
One Specific Pod
```

If Pod disappears:

```text
Port Forward Breaks
```

---

### Service Port Forward

```text
Works Through Service
```

Service automatically tracks Pods.

---

# 11. Service DNS Names

When a Service is created, Kubernetes registers it in:

```text
CoreDNS
```

CoreDNS is Kubernetes' DNS server.

---

# Fully Qualified Service DNS Name (FQDN)

Format:

```text
service-name.namespace.svc.cluster.local
```

Example:

```text
web-service.default.svc.cluster.local
```

---

# Short DNS Name

If Pods are in the same namespace:

```text
web-service
```

is enough.

Kubernetes resolves it automatically.

---

# 12. DNS Test

Command:

```bash
kubectl run dns-test \
  --image=busybox:1.36 \
  --restart=Never \
  --rm -it \
  -- nslookup web-service
```

---

## kubectl run

Creates a temporary Pod.

---

## dns-test

Pod name.

---

## --image=busybox:1.36

Tiny Linux image.

Contains tools like:

```text
nslookup

wget

ping

sh
```

---

## --restart=Never

Create regular Pod.

Not Deployment.

---

## --rm

Delete Pod automatically when completed.

---

## -it

Interactive session.

---

## nslookup web-service

Runs:

```bash
nslookup web-service
```

inside the temporary Pod.

---

# 13. DNS Test Output

Example:

```text
Server:
10.96.0.10
```

---

## What Is 10.96.0.10?

CoreDNS Service IP.

Meaning:

```text
DNS Query Sent To CoreDNS
```

---

## Successful Resolution

Output:

```text
Name:
web-service.default.svc.cluster.local

Address:
10.96.106.192
```

---

Important:

```text
10.96.106.192
```

is:

```text
Service IP
```

NOT:

```text
Pod IP
```

---

## What Did We Prove?

```text
CoreDNS Works

Service Exists

DNS Resolution Works
```

inside Kubernetes.

---

# 14. HTTP Test

Command:

```bash
kubectl run http-test \
  --image=busybox:1.36 \
  --restart=Never \
  --rm -it \
  -- wget -S -O- http://web-service
```

---

## wget

Like curl.

Used to make HTTP requests.

---

## -S

Show HTTP headers.

---

## -O-

Print response to terminal.

---

# 15. HTTP Test Result

Output:

```text
Connecting to web-service
(10.96.106.192:80)
```

This proves:

```text
DNS Resolution Worked
```

because:

```text
web-service
      ↓
10.96.106.192
```

---

Next:

```text
HTTP/1.1 200 OK
```

Meaning:

```text
Request Successful
```

---

Example:

```text
Server: nginx/1.31.6
```

Meaning:

```text
Nginx Responded
```

---

The HTML content displayed is Nginx's default page.

---

# Request Flow

```text
BusyBox Pod
      ↓
DNS Lookup

web-service
      ↓
Service IP

ClusterIP Service
      ↓
One Of The Nginx Pods
      ↓
Container Port 80
      ↓
HTTP Response
```

---

# What Did We Prove?

```text
DNS Works

Service Works

Endpoints Exist

Pods Respond

Application Works
```

---

# Complete Communication Flow

```text
BusyBox Pod
      |
      | nslookup web-service
      |
      ▼

CoreDNS
      |
      ▼

web-service
      |
      ▼

Service IP
      |
      ▼

ClusterIP Service
      |
      ▼

Nginx Pod
      |
      ▼

Container Port 80
      |
      ▼

HTTP 200 OK
```

---

# Day 5 Golden Rules

```text
Pods Have Temporary IPs

Services Have Stable IPs

Applications Should Use Services,
Not Pod IPs

--------------------------------

Service Finds Pods
Using Labels And Selectors

--------------------------------

ClusterIP
      ↓
Internal Communication

NodePort
      ↓
External Access Through Node IP

LoadBalancer
      ↓
External Access Through Public IP

--------------------------------

Service Port
      ↓
Client Connects Here

TargetPort
      ↓
Container Receives Traffic Here

--------------------------------

CoreDNS
      ↓
Service Name → Service IP

--------------------------------

nslookup
      ↓
Tests DNS

wget/curl
      ↓
Tests Connectivity
```

# Important Service Clarifications

---

## Service Load Balancing Is Not Guaranteed To Be Perfectly Even

A Service distributes traffic to eligible backend Pods.

Example:

```text
Service
   |
   +-- Pod-A
   |
   +-- Pod-B
   |
   +-- Pod-C
```

However:

```text
Do NOT Assume

Strict Round-Robin

Perfectly Equal Distribution

Exactly Same Requests Per Pod
```

Kubernetes routes traffic to available endpoints, but actual distribution depends on factors such as:

```text
Network Implementation

Connection Reuse

Client Behavior

Kubernetes Networking Components
```

For learning purposes, think:

```text
Service
    ↓
Distributes Traffic Across Matching Pods
```

---

## ClusterIP Is Internal, But Port Forward Still Works

ClusterIP is designed for:

```text
Pod-To-Pod Communication
```

and is normally accessible only from inside the cluster.

Example:

```text
Frontend Pod
      ↓
backend-service
      ↓
Backend Pods
```

However, during development and troubleshooting you can still access a ClusterIP Service from your laptop using:

```bash
kubectl port-forward service/web-service 8080:80
```

Flow:

```text
Laptop
    ↓
kubectl port-forward
    ↓
ClusterIP Service
    ↓
Pods
```

So:

```text
ClusterIP
      ↓
Internal Service

Port Forward
      ↓
Temporary Debug Access
```

---

## LoadBalancer Does Not Automatically Mean A Public IP

Many beginners assume:

```text
LoadBalancer
      ↓
Always Gets Public IP
```

Not necessarily.

A LoadBalancer Service depends on the cluster infrastructure.

Examples:

```text
AWS

Azure

Google Cloud
```

can automatically provision external load balancers.

On local clusters such as:

```text
Kind

Minikube

Docker Desktop Kubernetes
```

a LoadBalancer Service often remains:

```text
EXTERNAL-IP = <pending>
```

because there is no cloud load balancer available.

Think:

```text
LoadBalancer Service
       ↓
Requests External Load Balancer

Cloud Provider
       ↓
May Provision Public IP
```

Only when the underlying platform supports it will you receive an external IP address.

---

# Revised Service Mental Model

```text
ClusterIP
      ↓
Stable Internal Access

NodePort
      ↓
Same Port Opened On Every Node

LoadBalancer
      ↓
Single External Entry Point
(If Infrastructure Supports It)

--------------------------------

Services
      ↓
Provide Stable Networking

Port Forward
      ↓
Provides Temporary Debug Access

--------------------------------

Service
      ↓
Distributes Traffic

Not Necessarily Perfectly Even

--------------------------------

Applications Should Talk To Services

Not Directly To Pod IPs
```
