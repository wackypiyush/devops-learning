# Kubernetes Day 8
# Probes: Startup, Readiness & Liveness

---

# 1. Why Do We Need Probes?

Consider the following:

```text
Deployment
      ↓
Pod
      ↓
Application
```

A Pod may show:

```text
STATUS = Running
```

But a very important question is:

```text
Does Running Mean The Application Is Ready?
```

Answer:

```text
No
```

---

## Problem 1: Slow Application Startup

Suppose a Java application needs:

```text
30 seconds
```

to become usable.

Timeline:

```text
0s
Pod Started

5s
Container Running

30s
Application Ready
```

Kubernetes sees:

```text
Container Running
```

long before:

```text
Application Ready
```

Without probes:

```text
Service
      ↓
Starts Sending Traffic Immediately
```

Result:

```text
Users Receive Errors
```

because the application is still starting.

---

## Problem 2: Application Hangs

Suppose:

```text
Pod = Running

Container = Running
```

but the application is stuck because of:

```text
Infinite Loop

Deadlock

Frozen Process

Hung Thread
```

The container still exists.

Kubernetes may think:

```text
Everything Is Fine
```

even though the application is unusable.

---

## Problem 3: Application Depends On Another Service

Suppose the application requires:

```text
MySQL
```

during startup.

Application starts:

```text
Pod Running
```

but:

```text
Database Not Ready
```

Without probes:

```text
Traffic Arrives
      ↓
Application Fails Requests
```

---

## Kubernetes Solution: Probes

A probe is a health check performed by Kubernetes.

Think of Kubernetes asking:

```text
Are You Ready?

Are You Alive?

Have You Finished Starting?
```
HTTP health endpoints: Prefer endpoints designed for health checks, such as /health, /ready, and /live, rather than assuming the homepage proves the application is healthy.
---

# 2. What Is A Probe?

A probe is a periodic check executed by Kubernetes against a container.

Its purpose is to determine:

```text
Container Health
```

and help Kubernetes decide:

```text
Send Traffic?

Restart Container?

Wait Longer?
```

---

## Real-Life Analogy

Without probes:

```text
Doctor Looks At Patient

Eyes Open

Conclusion:
Healthy
```

---

With probes:

```text
Doctor Performs Tests

Heartbeat?

Blood Pressure?

Temperature?
```

Now the doctor knows the real condition.

---

## Probe Flow

```text
Kubernetes
      ↓
Probe
      ↓
Application
      ↓
Health Result
      ↓
Action
```

---

# 3. The Three Probes Compared

Kubernetes provides:

```text
Startup Probe

Readiness Probe

Liveness Probe
```

Each answers a different question.

---

## Startup Probe

Question:

```text
Has The Application Finished Starting?
```

Purpose:

```text
Protect Slow Starting Applications
```

Examples:

```text
Java Applications

Spring Boot Applications

Enterprise Services

Applications Loading Large Data Sets
```

---

### Flow

```text
Pod Starts
      ↓
Startup Probe Runs
      ↓
Fails While Starting
      ↓
Keep Waiting
      ↓
Eventually Succeeds
      ↓
Normal Probes Begin
```

---

## Readiness Probe

Question:

```text
Can This Pod Serve Traffic Right Now?
```

Purpose:

```text
Control Traffic Flow
```

---

If readiness succeeds:

```text
Pod Receives Traffic
```

If readiness fails:

```text
Pod Stops Receiving Traffic
```

But:

```text
Pod Continues Running
```

---

## Liveness Probe

Question:

```text
Is The Application Still Healthy?
```

Purpose:

```text
Detect Broken Applications
```

Examples:

```text
Deadlocks

Hung Processes

Frozen Applications
```

---

If liveness succeeds:

```text
Keep Running
```

If liveness fails repeatedly:

```text
Kubernetes Restarts The Container
```

---

## Memory Trick

```text
Startup
      ↓
Can I Start?

Readiness
      ↓
Can I Serve?

Liveness
      ↓
Am I Alive?
```

---

# 4. How Readiness Works With A Service

A Service:

```text
Routes Traffic To Pods
```

Question:

```text
How Does A Service Decide
Which Pods Receive Traffic?
```

Answer:

```text
Only Ready Pods Receive Traffic
```

Readiness probes are the most common way Kubernetes determines Pod readiness.

---

## Example Without Readiness

```text
User
 │
 ▼
Service
 │
 ├── Pod-A
 ├── Pod-B
 └── Pod-C
```

Suppose:

```text
Pod-B Is Broken
```

Without readiness checks:

```text
Traffic Can Still Reach Pod-B
```

Result:

```text
Users Receive Errors
```

---

## Example With Readiness Probe

```text
Pod-A Ready ✅

Pod-B Not Ready ❌

Pod-C Ready ✅
```

Service endpoints:

```text
Pod-A

Pod-C
```

Only.

---

```text
User
 │
 ▼
Service
 │
 ├── Pod-A ✅
 └── Pod-C ✅
```

Pod-B:

```text
Still Running

Receives No Traffic
```

---

## Internally

If:

```text
Ready = True
```

Kubernetes adds the Pod to:

```text
Service Endpoints
```

If:

```text
Ready = False
```

Kubernetes removes the Pod from:

```text
Service Endpoints
```

---

# 5. Readiness vs Liveness

This is one of the most important Kubernetes concepts.

---

## Readiness Failure

```text
Pod Still Running ✅

Container Still Running ✅

Traffic Removed ✅

No Restart ✅
```

---

## Liveness Failure

```text
Container Restarted ✅

Pod Object Still Exists ✅
```

---

## Key Rule

```text
Service
      ↓
Sends Traffic
Only To Ready Pods
```

and

```text
Readiness Probe
      ↓
Determines Pod Readiness
```

---

## Interview Answers

### What Is A Probe?

```text
A health check performed by Kubernetes against a container to determine its state and take actions such as routing traffic or restarting containers.
```

---

### Why Are Probes Needed?

```text
Because a Running container does not necessarily mean the application is ready or healthy.
```

---

### Difference Between Startup, Readiness And Liveness?

```text
Startup:
Checks whether startup has finished.

Readiness:
Checks whether a Pod can receive traffic.

Liveness:
Checks whether the application is healthy.
```

---

# 6. Probe Mechanisms

Kubernetes provides three mechanisms for executing health checks:

```text
HTTP

TCP

Exec
```

Any probe type can use one of these mechanisms.

---

# Mechanism 1: HTTP Probe

Kubernetes sends an HTTP request.

Examples:

```text
GET /health

GET /ready

GET /live
```

---

Success:

```text
HTTP 200 to 399
```

Failure:

```text
HTTP 404

HTTP 500
```

---

### Flow

```text
Kubernetes
      ↓
HTTP GET /health
      ↓
Application
      ↓
200 OK
      ↓
Healthy
```

---

### Example

```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 8080
```

---

### Common Uses

```text
Web Applications

REST APIs

Spring Boot

Node.js

Python APIs
```

---

# Mechanism 2: TCP Probe

Kubernetes attempts to open a TCP connection.

---

Question:

```text
Can I Connect To This Port?
```

---

Success:

```text
Connection Established
```

Failure:

```text
Connection Failed
```

---

### Flow

```text
Kubernetes
      ↓
TCP Connect
      ↓
Port
      ↓
Success / Failure
```

---

### Example

```yaml
readinessProbe:
  tcpSocket:
    port: 3306
```

---

### Common Uses

```text
MySQL

Redis

MongoDB

Messaging Systems
```

---

### Limitation

TCP only verifies:

```text
Port Is Open
```

It does NOT verify:

```text
Application Logic

Database Queries

API Functionality
```

---

# Mechanism 3: Exec Probe

Kubernetes runs a command inside the container.

---

Example:

```bash
cat /tmp/healthy
```

---

Success:

```text
Exit Code 0
```

Failure:

```text
Non-Zero Exit Code
```

---

### Flow

```text
Kubernetes
      ↓
Execute Command
      ↓
Exit Code
      ↓
Success / Failure
```

---

### Example

```yaml
livenessProbe:
  exec:
    command:
      - cat
      - /tmp/healthy
```

---

### Common Uses

```text
Legacy Applications

Custom Health Checks

File-Based Checks
```

---

## Memory Trick

```text
HTTP
      ↓
Can You Answer?

TCP
      ↓
Can I Connect?

Exec
      ↓
Can You Run This Command?
```

---

# 7. Important Probe Settings

Probes run repeatedly.

These settings control probe behavior.

---

## initialDelaySeconds

```text
How Long Before The First Probe Runs?
```

Example:

```yaml
initialDelaySeconds: 10
```

Meaning:

```text
Wait 10 Seconds

Then Start Probing
```

---

## periodSeconds

```text
How Often Should The Probe Run?
```

Example:

```yaml
periodSeconds: 5
```

Meaning:

```text
Run Every 5 Seconds
```

---

## timeoutSeconds

```text
How Long Should Kubernetes Wait For A Response?
```

Example:

```yaml
timeoutSeconds: 2
```

If the application does not respond within:

```text
2 Seconds
```

the probe fails.

---

## successThreshold

```text
How Many Consecutive Successes
Before Marking The Probe Successful?
```
For liveness and startup probes, it must be 1; readiness probes can use a higher value.

Example:

```yaml
successThreshold: 3
```

Commonly used for:

```text
Readiness Probes
```

---

## failureThreshold

```text
How Many Consecutive Failures
Before Taking Action?
```

Example:

```yaml
failureThreshold: 3
```

```text
Fail Once
      ↓
Ignore

Fail Twice
      ↓
Ignore

Fail Third Time
      ↓
Take Action
```

---

## Example

```yaml
readinessProbe:
  httpGet:
    path: /ready
    port: 8080
  initialDelaySeconds: 10
  periodSeconds: 5
  timeoutSeconds: 2
  failureThreshold: 3
```

Meaning:

```text
Wait 10 Seconds

Check Every 5 Seconds

Wait Maximum 2 Seconds

Fail 3 Times Before Marking Not Ready
```

---

# 8. How Startup Probes Protect Slow Applications

Suppose an application needs:

```text
60 Seconds
```

to start.

Timeline:

```text
0s
Container Starts

10s
Still Loading

20s
Still Loading

40s
Still Loading

60s
Ready
```

---

## Without Startup Probe

Only a liveness probe exists.

Kubernetes begins checking:

```text
/health
```

Application is not ready.

Probe fails.

Eventually:

```text
Kubernetes Restarts Container
```

The application starts again from the beginning.

Result:

```text
Restart Loop
```

The application never becomes ready.

---

## Startup Probe Solution

Startup probe tells Kubernetes:

```text
This Application Is Slow

Give It Time
```

---

### Flow

```text
Container Starts
      ↓
Startup Probe Runs
      ↓
Fails
      ↓
Keep Waiting
      ↓
Eventually Succeeds
      ↓
Readiness Probe Becomes Active
      ↓
Liveness Probe Becomes Active
```

---

## Important Rule

When a Startup Probe exists:

```text
Kubernetes does not run the liveness and readiness probes until the startup probe succeeds.
```

until the startup probe succeeds.

This prevents premature failures and restarts.

---

## Example

```yaml
startupProbe:
  httpGet:
    path: /startup
    port: 8080
  failureThreshold: 30
  periodSeconds: 2
```

Startup window:

```text
30 × 2

=
60 Seconds
```

---

# 9. Probe Selection Guidelines

A probe should test the correct thing.

---

## Good Liveness Checks

Ask:

```text
Would Restarting Fix This?
```

Examples:

```text
Application Frozen

Deadlock

Hung Process
```

If a restart could help, it may belong in a liveness probe.

---

## Good Readiness Checks

Ask:

```text
Can This Instance Serve Requests Right Now?
```

Examples:

```text
Database Reachable

Cache Reachable

Dependencies Available

Application Finished Loading
```

If not, the Pod should temporarily stop receiving traffic.

---

## Bad Practice

Avoid making liveness heavily dependent on external systems.

Example:

```text
Application
      ↓
Depends On MySQL

MySQL Down
      ↓
Liveness Fails
      ↓
Container Restarts
      ↓
MySQL Still Down
```

Restarting did not solve the problem.

---

## Better Approach

```text
MySQL Down
      ↓
Readiness Fails
      ↓
Pod Removed From Service
      ↓
No Restart
      ↓
MySQL Recovers
      ↓
Pod Becomes Ready Again
```

---

## Easy Rule

```text
Would Restarting Fix It?
      ↓
Use Liveness

--------------------------------

Can The Pod Serve Traffic?
      ↓
Use Readiness
```

---

# 10. Lab: Add All Three Probes

```bash
kubectl patch deployment probe-demo --type=strategic -p '
spec:
  template:
    spec:
      containers:
      - name: nginx
        startupProbe:
          httpGet:
            path: /
            port: 80
          periodSeconds: 2
          failureThreshold: 30
        readinessProbe:
          httpGet:
            path: /
            port: 80
          periodSeconds: 5
          timeoutSeconds: 2
          failureThreshold: 3
        livenessProbe:
          httpGet:
            path: /
            port: 80
          periodSeconds: 10
          timeoutSeconds: 2
          failureThreshold: 3
'
```

---

### Startup Probe

```text
GET /

Every 2 Seconds

Maximum Startup Window:
60 Seconds
```

---

### Readiness Probe

```text
GET /

Every 5 Seconds
```

---

### Liveness Probe

```text
GET /

Every 10 Seconds
```

---

# 11. Rollout Status

```bash
kubectl rollout status deployment/probe-demo
```

Output:

```text
successfully rolled out
```

Meaning:

```text
Pod Created

Startup Probe Passed

Readiness Probe Passed

Deployment Available

```

```text
More Clearly:
kubectl rollout status confirms the Deployment has completed its rollout according to its availability requirements; it does not independently prove that every configured probe passed at that exact moment.
Check the Pod's conditions and events to investigate probe behavior.
```
---

# 12. Pod Description

```text
Ready: True
```

Meaning:

```text
Kubernetes Currently Considers
The Pod Ready To Receive Traffic
```

In this lab:

```text
Readiness Probe Passed
```

---

You also saw:

```text
Startup
Readiness
Liveness
```

configured in the Pod.

This proves:

```text
All Three Probes Exist
```

---

# 13. Test Service

```bash
wget http://probe-service
```

Output:

```text
Welcome to nginx!
```

Meaning:

```text
Service
      ↓
Ready Pod
      ↓
Nginx
```

is working correctly.

---

# 14. Readiness Failure Demo

Broken readiness probe:

```yaml
readinessProbe:
  httpGet:
    path: /healthz-missing
    port: 80
```

Nginx returns:

```text
404 Not Found
```

---

Pod status:

```text
Ready: False
```

Event:

```text
Readiness probe failed:
HTTP probe failed with statuscode: 404
```

---

Important:

```text
Container Running ✅

Pod Running ✅

Pod Ready ❌
```

---

### Result

```text
Pod Removed From Service Endpoints

No Traffic Sent

No Restart
```

---

## Key Lesson

```text
Pod Running
      ≠
Pod Ready
```

---

# 15. Why Rollout Appeared Stuck

Deployment rollout waits for:

```text
Pods To Become Ready
```

The readiness probe never succeeded.

Therefore:

```text
Rollout Could Not Complete
```

---

# 16. Liveness Failure Demo

Good readiness.

Broken liveness:

```yaml
livenessProbe:
  httpGet:
    path: /healthz-missing
    port: 80
```

Result:

```text
HTTP 404
```

---

Pod events:

```text
Liveness probe failed

HTTP probe failed with statuscode: 404
```

---

Kubernetes action:

```text
Liveness Failure
      ↓
Restart Container
```

Eventually:

```text
CrashLoopBackOff
```

because the probe keeps failing.

---

## Key Lesson

```text
Readiness Failure
      ↓
No Traffic

--------------------------------

Liveness Failure
      ↓
Restart Container
```

---

# Day 8 Golden Rules

```text
Running
      ≠
Ready

--------------------------------

Startup Probe
      ↓
Protects Slow Startup

--------------------------------

Readiness Probe
      ↓
Controls Traffic

--------------------------------

Liveness Probe
      ↓
Triggers Restarts

--------------------------------

Readiness Failure
      ↓
Remove From Service

No Restart

--------------------------------

Liveness Failure
      ↓
Restart Container

--------------------------------

Service
      ↓
Sends Traffic
Only To Ready Pods

--------------------------------

Would Restarting Fix It?
      ↓
Use Liveness

--------------------------------

Can This Pod Serve Traffic?
      ↓
Use Readiness
```
