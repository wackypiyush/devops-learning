# Kubernetes Day 9
# CPU, Memory, Requests & Limits

---

# 1. Why Do We Need Resource Management?

A Kubernetes cluster has limited resources.

Every Node contains:

```text
CPU

Memory (RAM)

Storage
```

Multiple Pods share these resources.

---

Imagine a Node with:

```text
4 CPU

8 GB RAM
```

Initially, everything is fine.

Then traffic suddenly increases and one application starts consuming:

```text
4 CPU

7 GB RAM
```

Result:

```text
Other Pods Get Starved

Node Becomes Slow

Applications Start Failing
```

---

Kubernetes must answer two important questions:

```text
How Much Resource Does This Pod Need?

How Much Resource Should This Pod Be Allowed To Use?
```

These are solved using:

```text
Requests

Limits
```

---

# 2. What Is A Resource Request?

A Resource Request tells Kubernetes:

```text
This Is The Minimum Resource
I Need To Run Properly
```

Think:

```text
Reserved Resource

OR

Guaranteed Resource
```

---

## Example

```yaml
resources:
  requests:
    cpu: 500m
    memory: 256Mi
```

Meaning:

```text
I Need At Least

0.5 CPU

256 Mi Memory
```

---

## Why Does Kubernetes Need Requests?

The Scheduler must decide:

```text
Which Node Can Run This Pod?
```

Example:

Node Available:

```text
0.2 CPU
```

Pod Requests:

```text
0.5 CPU
```

Result:

```text
Pod Cannot Be Scheduled
On That Node
```

---

## Important

A Request Is NOT:

```text
Maximum Usage
```

A container may later use:

```text
1 CPU

512 Mi Memory
```

and still be fine if resources are available.

---

A Request Simply Means:

```text
Reserve At Least
This Much Resource For Me
```

```text
Used by the scheduler to decide whether a node has sufficient allocatable capacity. CPU requests also influence relative CPU allocation when containers compete for CPU.
A request is not a fixed amount of CPU execution time, nor does it mean the application must use that much resource.
```

---

## Summary

```text
Request
      ↓
Minimum Needed

Request
      ↓
Used By Scheduler

Request
      ↓
Guaranteed Resource
```

---

# 3. What Is A Resource Limit?

A Resource Limit tells Kubernetes:

```text
This Is The Maximum Resource
I Am Allowed To Consume
```

Think:

```text
Upper Boundary
```

---

## Example

```yaml
resources:
  limits:
    cpu: 1
    memory: 512Mi
```

Meaning:

```text
Maximum CPU
=
1 CPU

Maximum Memory
=
512 Mi
```

---

Kubernetes allows usage up to:

```text
1 CPU

512 Mi Memory
```

but not beyond that.

---

## Why Do We Need Limits?

Without limits:

```text
One Pod
      ↓
Consumes Everything
      ↓
Other Pods Suffer
```

---

Limits protect:

```text
Node Stability

Other Applications

Cluster Performance
```

---

## What Happens If A CPU Limit Is Reached?

Example:

```yaml
limits:
  cpu: 1
```

Application tries to use:

```text
2 CPU
```

Result:

```text
Container Is NOT Killed
```

Instead:

```text
CPU Usage Is Restricted
```

This is called:

```text
CPU Throttling
```

---

Think:

```text
Application:
I Need More CPU

Kubernetes:
Stay Within Your Limit
```

---

## What Happens If A Memory Limit Is Reached?

Example:

```yaml
limits:
  memory: 512Mi
```

Application tries to use:

```text
800Mi
```

---

Memory behaves differently from CPU.

Kubernetes cannot throttle memory.

Result:

```text
Container Gets Killed
```

Status:

```text
OOMKilled
```
```text
If a container's memory usage exceeds its enforced memory limit, the kernel can terminate processes in that container to enforce the limit. Kubernetes may then report the container's last termination reason as OOMKilled.
```
```text

OOMKilled is a termination reason, whereas CrashLoopBackOff is a waiting state that can occur when a container repeatedly fails and Kubernetes backs off before restarting it.
```
---

## What Does OOMKilled Mean?

OOM =

```text
Out Of Memory
```

Meaning:

```text
Container Exceeded
Its Memory Limit
```

and the operating system terminated it.

---

## Summary

```text
Limit
      ↓
Maximum Allowed

CPU Limit Reached
      ↓
CPU Throttling

Memory Limit Reached
      ↓
OOMKilled
```

---

# 4. Resource Request VS Resource Limit

This is the most important Day 9 concept.

---

## Resource Request

Answers:

```text
What Do I Need?
```

Used For:

```text
Scheduling
```

Represents:

```text
Minimum Resource
```

---

## Resource Limit

Answers:

```text
What Is My Maximum?
```

Used For:

```text
Runtime Enforcement
```

Represents:

```text
Maximum Resource
```

---

## Example

```yaml
resources:
  requests:
    cpu: 500m
    memory: 256Mi

  limits:
    cpu: 1
    memory: 512Mi
```

Meaning:

```text
Guaranteed CPU
=
0.5 CPU

Maximum CPU
=
1 CPU

Guaranteed Memory
=
256 Mi

Maximum Memory
=
512 Mi
```

---

## How Kubernetes Thinks

```text
Request
      ↓
Can This Pod Fit On A Node?

Limit
      ↓
How Far May This Pod Grow?
```

---

## Summary

```text
Request
      ↓
Minimum Needed

Limit
      ↓
Maximum Allowed

--------------------------------

Request
      ↓
Scheduling

Limit
      ↓
Runtime Enforcement
```

---

# 5. Understand CPU Units And Memory Units

---

# CPU Units

CPU is measured in:

```text
CPU Cores

OR

Millicpu (m)
```

---

## Conversion

```text
1 CPU
=
1 Core
=
1000m
```

---

Examples:

```text
100m
=
0.1 CPU

250m
=
0.25 CPU

500m
=
0.5 CPU

1000m
=
1 CPU

2000m
=
2 CPU
```

---

## Example

```yaml
requests:
  cpu: 250m
```

Meaning:

```text
Request 25% Of One CPU Core
```

---

# Memory Units

Kubernetes commonly uses:

```text
Mi

Gi
```

---

## Mi

```text
Mi
=
Mebibyte
```

For learning purposes:

```text
1 Mi ≈ 1 MB
```

---

## Gi

```text
Gi
=
Gibibyte
```

For learning purposes:

```text
1 Gi ≈ 1 GB
```

---

Important:

```text
1024Mi
=
1Gi
```

---

Examples:

```text
128Mi

256Mi

512Mi

1Gi

2Gi
```

---

## Easy Memory Tricks

```text
1000m
=
1 CPU

1024Mi
=
1Gi
```

---

# 6. Resource Requests Affect Scheduling

```text
the scheduler evaluates the node's allocatable resources and existing scheduled requests, alongside other scheduling constraints. It does not simply subtract current live CPU usage from the node's capacity
```
Suppose a Node has:

```text
2 CPU

4 Gi Memory
```

---

Pod Requests:

```yaml
resources:
  requests:
    cpu: 500m
    memory: 512Mi
```

---

Scheduler checks:

```text
Does This Node Have

0.5 CPU

512 Mi Memory

Available?
```

---

If Yes:

```text
Pod Scheduled
```

If No:

```text
Pod Remains Pending
```

---

## Scheduling Flow

```text
Pod Created
      ↓
Read Requests
      ↓
Find Node
With Enough Capacity
      ↓
Schedule Pod
```

---

## What Causes Pending Pods?

### Requests Too Large

Node:

```text
2 CPU
```

Pod Request:

```text
8 CPU
```

Result:

```text
Pending
```

---

### Memory Request Too Large

Node:

```text
4 Gi RAM
```

Pod Request:

```text
10 Gi RAM
```

Result:

```text
Pending
```

---

### Cluster Capacity Exhausted

Node:

```text
4 CPU
```

Already Reserved:

```text
3.8 CPU
```

New Pod Requests:

```text
500m CPU
```

Result:

```text
Pending
```

because enough allocatable CPU is not available.

---

## Important

Schedulers mainly look at:

```text
Requests
```

during placement.

Not limits.

Example:

```yaml
requests:
  cpu: 500m

limits:
  cpu: 4
```

The Scheduler cares about:

```text
500m
```

while choosing a Node.

---

# 7. Configure CPU And Memory Requests/Limits

Command:

```bash
kubectl set resources deployment/resource-demo \
  --requests=cpu=100m,memory=64Mi \
  --limits=cpu=200m,memory=128M
```

Output:

```text
deployment.apps/resource-demo resource requirements updated
```

---

Meaning:

The Deployment was updated with:

### Requests

```text
CPU = 100m

Memory = 64Mi
```

---

### Limits

```text
CPU = 200m

Memory = 128M
```

---

Interpretation:

```text
Guaranteed CPU
=
0.1 CPU

Maximum CPU
=
0.2 CPU

Guaranteed Memory
=
64 Mi

Maximum Memory
=
128 MB
```

---

# 8. Store Pod Name In A Variable

Command:

```bash
POD=$(kubectl get pods -l app=resource-demo \
  -o jsonpath='{.items[0].metadata.name}')
```

Purpose:

```text
Save Pod Name
Into Shell Variable POD
```

Example:

```text
POD=resource-demo-8455466556-sl9fs
```

---

Benefit:

```text
Avoids Typing
Long Pod Names Repeatedly
```

---

# 9. Describe The Pod

Command:

```bash
kubectl describe pod "$POD"
```

Important Section:

```text
Limits:
  cpu:     200m
  memory:  128M

Requests:
  cpu:     100m
  memory:  64Mi
```

---

This proves Kubernetes stored:

### Requests

```text
CPU = 100m

Memory = 64Mi
```

---

### Limits

```text
CPU = 200m

Memory = 128M
```

exactly as configured.

---

# 10. Understanding QoS Class

Inside the describe output:

```text
QoS Class: Burstable
```

---

Why?

Because:

```text
Requests Exist

AND

Limits Exist

BUT

Request ≠ Limit
```

---

You configured:

```text
Request CPU = 100m
Limit CPU = 200m

Request Memory = 64Mi
Limit Memory = 128M
```

Since they are different:

```text
QoS Class = Burstable
```

---

# Kubernetes QoS Classes

## Guaranteed

```text
Requests Exist

Limits Exist

Request = Limit
```

Example:

```yaml
requests:
  cpu: 500m
  memory: 256Mi

limits:
  cpu: 500m
  memory: 256Mi
```

---

## Burstable

```text
Requests Exist

Limits Exist

Request < Limit
```

Example:

```yaml
requests:
  cpu: 100m

limits:
  cpu: 500m
```

---

## BestEffort

```text
No Requests

No Limits
```

Example:

```yaml
resources: {}
```

---

# 11. Verify Resources Using JSONPath

Command:

```bash
kubectl get pod "$POD" \
  -o jsonpath='{range .spec.containers[*]}Container: {.name}{"\n"}Requests: {.resources.requests}{"\n"}Limits: {.resources.limits}{"\n"}{end}'
```

Output:

```text
Container: nginx

Requests:
{"cpu":"100m","memory":"64Mi"}

Limits:
{"cpu":"200m","memory":"128M"}
```

---

Purpose:

```text
Display Container Resource Configuration
Directly From Pod Specification
```

without using:

```bash
kubectl describe
```

---

# 12. Verify Resource Configuration In Deployment

Command:

```bash
kubectl get deployment resource-demo \
  -o jsonpath='{.spec.template.spec.containers[0].resources}'
```

Output:

```json
{
  "limits":{"cpu":"200m","memory":"128M"},
  "requests":{"cpu":"100m","memory":"64Mi"}
}
```

---

This proves the Deployment template contains:

```text
CPU Request = 100m

Memory Request = 64Mi

CPU Limit = 200m

Memory Limit = 128M
```

---

Any future Pod created by this Deployment will automatically inherit these values.

---

# Day 9 Golden Rules

```text
Request
      ↓
Minimum Needed

Request
      ↓
Used By Scheduler

--------------------------------

Limit
      ↓
Maximum Allowed

Limit
      ↓
Used At Runtime

--------------------------------

CPU Limit Hit
      ↓
CPU Throttling

--------------------------------

Memory Limit Hit
      ↓
OOMKilled

--------------------------------

Scheduler
      ↓
Uses Requests

--------------------------------

No Node Can Satisfy Requests
      ↓
Pod Remains Pending

--------------------------------

Guaranteed QoS
      ↓
Request = Limit

--------------------------------

Burstable QoS
      ↓
Request < Limit

--------------------------------

BestEffort QoS
      ↓
No Requests
No Limits
```
