# Kubernetes Day 12
# Rolling Updates, Rollbacks & Deployment History

---

# 1. Rolling Updates

## What Problem Does It Solve?

Suppose your application is running:

```text
web:v1
```

with:

```text
3 Pods
```

Now you want to deploy:

```text
web:v2
```

Question:

```text
Should Kubernetes Delete All Old Pods First

Then Create New Pods?
```

If that happens:

```text
Delete Pod-1
Delete Pod-2
Delete Pod-3

No Pods Running
```

Result:

```text
Application Downtime
```

---

Kubernetes solves this using:

```text
Rolling Update
```

---

## What Is A Rolling Update?

A Rolling Update gradually replaces old Pods with new Pods.

Example:

```text
Pod-1 v1
      ↓
Pod-1 v2

Pod-2 v1
      ↓
Pod-2 v2

Pod-3 v1
      ↓
Pod-3 v2
```

One batch at a time.

---

## Result

```text
Rolling Updates are designed
to maintain application availability.

However, zero downtime is NOT guaranteed.

Availability depends on:

Readiness Probes

Application Health

Cluster Capacity

Deployment Configuration

Update Strategy
```

---

## Visual

```text
Before

v1 v1 v1

        ↓

v2 v1 v1

        ↓

v2 v2 v1

        ↓

v2 v2 v2
```

---

## Default Deployment Behavior

Deployments use:

```text
RollingUpdate
```

by default.

Verify:

```bash
kubectl describe deployment web-app
```

Output:

```text
StrategyType: RollingUpdate
```

---

# 2. Rollout History

Every Deployment keeps track of previous revisions.

Think of it as:

```text
Version History
```

for Deployments.

---

## Example

```text
Revision 1
nginx:1.25

Revision 2
nginx:1.26

Revision 3
nginx:1.27
```

---

## Why Is Rollout History Useful?

Suppose:

```text
Revision 3
      ↓
Production Broken
```

You can inspect previous revisions and restore a previous Deployment state.

---

## View Rollout History

```bash
kubectl rollout history deployment/web-app
```

Example Output:

```text
deployment.apps/web-app

REVISION

1

2

3
```

---

## View Specific Revision

```bash
kubectl rollout history deployment/web-app \
  --revision=2
```

Shows details stored in revision 2.

---

## What Creates A New Revision?

Every Pod Template change creates a new revision.

Examples:

```text
Image Change

Environment Variable Change

Label Change

Annotation Change In Pod Template

Resource Request Change

Resource Limit Change

Volume Change
```

---

## What Does NOT Create A New Revision?

Scaling replicas.

Example:

```bash
kubectl scale deployment web-app \
  --replicas=5
```

Reason:

```text
Pod Template Did Not Change

Only Replica Count Changed
```

---

## Revision History Is Not Unlimited

Kubernetes stores historical ReplicaSets using:

```yaml
revisionHistoryLimit
```

Default:

```text
10
```

---

After the limit is exceeded:

```text
Older ReplicaSets

May Be Removed

Automatically
```

---

Therefore:

```text
Do Not Assume Every Historical Revision
Will Always Be Available Forever
```

---

## Check Revision History Limit

```bash
kubectl get deployment rollout-demo -n dev \
  -o jsonpath='Revision history limit: {.spec.revisionHistoryLimit}{"\n"}'
```

---

# 3. Rollbacks

## What Is A Rollback?

Rollback means:

```text
Restore A Previous
Deployment Pod Template
```

---

Example:

```text
Revision 1 ✅

Revision 2 ✅

Revision 3 ❌
```

Rollback:

```text
Revision 3
      ↓
Revision 2 Configuration
```

---

## Important

A rollback does NOT guarantee:

```text
The Previous Version Is Healthy
```

Always verify:

```text
Rollout Status

Pod Health

Application Availability

After A Rollback
```

---

## Rollback To Previous Revision

```bash
kubectl rollout undo deployment/web-app
```

---

## Rollback To A Specific Revision

```bash
kubectl rollout undo deployment/web-app \
  --to-revision=2
```

Meaning:

```text
Restore Revision 2 Configuration
```

even if newer revisions exist.

---

## Why Rollbacks Matter

Example:

```text
Friday Evening

Production Release

New Version Fails
```

Rollback can restore a known previous Deployment configuration within seconds.

---

# 4. Update Strategy

Deployment strategy determines:

```text
How Updates Happen
```

---

Kubernetes supports:

```text
RollingUpdate

Recreate
```

---

# RollingUpdate Strategy

Default strategy.

Behavior:

```text
Gradually Replace Pods
```

---

Example:

```text
Old Pods Removed Gradually

New Pods Added Gradually
```

---

Result:

```text
Designed To Maintain Availability
With Minimal Service Interruption
```

---

Configuration:

```yaml
strategy:
  type: RollingUpdate
```

---

# Recreate Strategy

Behavior:

```text
Delete Everything

Then Create New Version
```

---

Visual:

```text
v1 v1 v1

      ↓

No Pods Running

      ↓

v2 v2 v2
```

---

Result:

```text
Downtime Occurs
```

---

Configuration:

```yaml
strategy:
  type: Recreate
```

---

## When Is Recreate Useful?

Use Recreate when:

```text
Old Version

AND

New Version

Must NOT Run Simultaneously
```

Examples:

```text
Applications Using Exclusive File Locks

Applications Requiring Single Active Instance

Applications With Version-Incompatible State
```

Expect:

```text
Temporary Service Interruption
```

during deployment.

---

# 5. Important Rollout Commands

---

## Check Rollout Status

```bash
kubectl rollout status deployment/web-app
```

Example:

```text
deployment "web-app" successfully rolled out
```

---

## View Rollout History

```bash
kubectl rollout history deployment/web-app
```

---

## View Specific Revision

```bash
kubectl rollout history deployment/web-app \
  --revision=2
```

---

## Rollback To Previous Revision

```bash
kubectl rollout undo deployment/web-app
```

---

## Rollback To Specific Revision

```bash
kubectl rollout undo deployment/web-app \
  --to-revision=2
```

---

## Pause Rollout

```bash
kubectl rollout pause deployment/web-app
```

Meaning:

```text
Temporarily Stop Deployment Updates
```

---

## Resume Rollout

```bash
kubectl rollout resume deployment/web-app
```

Meaning:

```text
Continue Deployment Updates
```

---

# 6. maxSurge & maxUnavailable

These settings control:

```text
How Fast
A Rolling Update Happens
```

---

# maxSurge

Defines:

```text
How Many Extra Pods
Can Be Created Above
Desired Replica Count
```

during an update.

---

## Example

Deployment:

```text
Replicas = 4
```

Configuration:

```yaml
maxSurge: 1
```

During update:

```text
4 Desired Pods

+1 Extra Pod

= 5 Pods Maximum
```

---

## Percentage Example

```yaml
maxSurge: 25%
```

Replicas:

```text
4
```

25% of 4:

```text
1
```

Kubernetes can temporarily run:

```text
5 Pods
```

during rollout.

---

# maxUnavailable

Defines:

```text
How Many Desired Replicas

May Become Unavailable

Because Of The Rolling Update
```

---

Example:

```yaml
maxUnavailable: 1
```

Deployment:

```text
Replicas = 4
```

---

Kubernetes attempts to keep:

```text
3 Desired Replicas Available
```

during the update.

---

## Important

This is NOT an application availability guarantee.

Additional failures may still reduce availability:

```text
Application Crashes

Node Failures

Readiness Probe Failures

Resource Exhaustion

Network Issues
```

---

## Visual

```text
Desired Pods = 4

Unavailable Allowed = 1

Target Available Pods = 3
```

---

# Together

Example:

```yaml
strategy:
  type: RollingUpdate

  rollingUpdate:
    maxSurge: 1
    maxUnavailable: 1
```

Replicas:

```text
4
```

Possible update sequence:

```text
4 Old Pods

        ↓

5 Pods
(4 Old + 1 New)

        ↓

4 Pods
(3 Old + 1 New)

        ↓

5 Pods
(3 Old + 2 New)

        ↓

Continue Until Complete
```

---

## Default Values

If not specified:

```text
maxSurge = 25%

maxUnavailable = 25%
```

---

## Difference Between The Two

### maxSurge

Controls:

```text
How Many Extra Pods
Can Be Added
```

---

### maxUnavailable

Controls:

```text
How Many Existing Pods
May Become Unavailable
```

---

# 7. Rolling Update & Rollback Flow

```text
Create Deployment
        ↓
Rolling Update
        ↓
Deployment Revisions
        ↓
Failed Release
        ↓
Rollback
        ↓
Recovery
```

---

# What Happens During A Failed Update?

Suppose:

```text
Revision 2

Image = nginx:stable-alpine
```

Working correctly.

---

You release:

```text
Revision 3

Image = nginx:invalid-image
```

A new ReplicaSet is created.

New Pods fail:

```text
ErrImagePull

ImagePullBackOff
```

---

Meanwhile:

```text
Revision 2 Pods
      ↓
Still Running
```

---

Visual:

```text
Revision 2 Pods
      ↓
Still Running

Revision 3 Pods
      ↓
Failed
```

---

Result:

```text
Application Often Remains Available
Because Existing Healthy Pods
Continue Serving Traffic
```

---

## Failed Revision Still Gets Recorded

Even failed updates are stored in deployment history.

Example:

```text
Revision 1 ✅

Revision 2 ✅

Revision 3 ❌
```

History:

```text
1
2
3
```

Revision 3 exists even though deployment failed.

---

## Rollback Example

Command:

```bash
kubectl rollout undo deployment/web-app
```

Rollback restores an earlier Deployment Pod Template.

After rollback:

```text
Verify:

Rollout Status

Deployment Health

Application Functionality
```

---

# Why History May Show 1, 3, 4

Many beginners expect:

```text
1
2
3
```

after rollback.

Instead they see:

```text
1
3
4
```

---

## Reason

Rollback creates a new revision.

Kubernetes does NOT move backward to an old revision number.

Instead:

```text
Revision 4

Restores The Same Pod Template

Previously Used By Revision 2
```

---

## More Precise Explanation

```text
Rollback Restores
A Previous Pod Template

And Records The Resulting State
As A New Revision
```

Kubernetes may:

```text
Reuse An Existing ReplicaSet
```

instead of creating a brand-new ReplicaSet.

---

## Example

```text
Revision 1
nginx:alpine

Revision 2
nginx:stable-alpine

Revision 3
broken image

Rollback
      ↓

Revision 4
restored nginx:stable-alpine configuration
```

---

Important:

```text
Rollback Creates A New Revision

It Does NOT Re-Activate
The Old Revision Number
```

---

# Deployment History & ReplicaSets

## Deployment History

Rule:

```text
Every Pod Template Change

↓

Creates A New Revision
```

---

## ReplicaSets

Rule:

```text
A Changed Pod Template

Normally Creates

A New ReplicaSet
```

---

However:

```text
During Rollback

Kubernetes May Reuse
An Existing ReplicaSet
```

instead of creating a new one.

---

## Example From The Lab

Before rollback:

```text
Revision 2

rollout-demo-d5854666d
```

After rollback:

```text
rollout-demo-d5854666d
```

returned to:

```text
3 Replicas
```

instead of Kubernetes creating:

```text
rollout-demo-newhash
```

This proves:

```text
Existing ReplicaSets
May Be Reused
```

---

## Example Revision Mapping

```text
Revision 1
ReplicaSet A

Revision 2
ReplicaSet B

Revision 3
ReplicaSet C
```

---

Kubernetes generally scales old ReplicaSets to:

```text
0 Replicas
```

instead of deleting them immediately.

This enables rollbacks.

---

# Failed Rollouts

Important behavior:

```text
Failed Rollouts

Do NOT Immediately Destroy

Healthy Existing Pods
```

---

Example:

```text
Current Version ✅

New Version ❌
```

Result:

```text
Healthy Pods Continue Running

Application May Remain Available
```

until you:

```text
Fix The Deployment

OR

Perform A Rollback
```

---

# Practical Incident-Response Commands

## Inspect Update Strategy

```bash
kubectl get deployment rollout-demo -n dev \
  -o jsonpath='Strategy: {.spec.strategy.type}{"\n"}Max surge: {.spec.strategy.rollingUpdate.maxSurge}{"\n"}Max unavailable: {.spec.strategy.rollingUpdate.maxUnavailable}{"\n"}'
```

Useful for:

```text
Troubleshooting Slow Rollouts

Understanding Deployment Behavior
```

---

## Check Revision History Limit

```bash
kubectl get deployment rollout-demo -n dev \
  -o jsonpath='Revision history limit: {.spec.revisionHistoryLimit}{"\n"}'
```

---

## Inspect Deployment Events

```bash
kubectl describe deployment rollout-demo -n dev
```

Useful for:

```text
Failed Rollouts

Image Pull Errors

Progress Deadline Issues

ReplicaSet Events
```

---

## Inspect ReplicaSets, Revisions And Images

```bash
kubectl get rs -n dev -l app=rollout-demo \
  -o custom-columns='NAME:.metadata.name,REVISION:.metadata.annotations.deployment\.kubernetes\.io/revision,IMAGE:.spec.template.spec.containers[0].image,DESIRED:.spec.replicas'
```

This command shows:

```text
ReplicaSet

Revision Number

Image

Desired Replica Count
```

all in one view.

---

# Interview Questions

### What Is A Rolling Update?

```text
A Deployment strategy that gradually replaces old Pods with new Pods while attempting to keep the application available.
```

---

### What Is Deployment History?

```text
Deployment history stores previous revisions so earlier configurations can be inspected or restored.
```

---

### What Creates A New Revision?

```text
Any Pod Template Change.
```

Examples:

```text
Image Change

Environment Variable Change

Resource Change

Label Change
```

---

### Does Scaling Create A New Revision?

```text
No.

Scaling Changes Replica Count,

Not The Pod Template.
```

---

### What Is revisionHistoryLimit?

```text
The Number Of Old ReplicaSets
Kubernetes Retains For Rollback Purposes.

Default = 10
```

---

### What Is A Rollback?

```text
Rollback Restores
A Previous Deployment Pod Template.

Always Verify Deployment Health
After Rollback.
```

---

### What Happens To Failed Revisions?

```text
Failed Revisions Are Still Stored
In Deployment History.
```

---

### What Does maxSurge Control?

```text
How Many Extra Pods
May Be Created During A Rolling Update.
```

---

### What Does maxUnavailable Control?

```text
How Many Desired Replicas
May Become Unavailable
During A Rolling Update.
```

---

### Does Rollback Restore The Original Revision Number?

```text
No.

Rollback Creates A New Revision
That Represents The Restored State.
```

---

# Day 12 Golden Rules

```text
Rolling Update
      ↓
Gradually Replace Pods

--------------------------------

Rolling Updates
      ↓
Improve Availability

But Do NOT Guarantee
Zero Downtime

--------------------------------

Rollout History
      ↓
Stores Deployment Revisions

--------------------------------

Every Pod Template Change
      ↓
Creates New Revision

--------------------------------

A Changed Pod Template
Usually Creates
A New ReplicaSet

--------------------------------

Rollback
      ↓
May Reuse Existing ReplicaSets

--------------------------------

Scaling Replicas
      ↓
Does NOT Create Revision

--------------------------------

Rollback
      ↓
Restores Previous Pod Template

--------------------------------

Rollback
      ↓
Creates New Revision

--------------------------------

revisionHistoryLimit
      ↓
Controls Revision Retention

--------------------------------

maxSurge
      ↓
Extra Pods Allowed

--------------------------------

maxUnavailable
      ↓
Desired Replicas Allowed
To Become Unavailable

--------------------------------

Failed Rollouts
      ↓
Do Not Immediately Remove
Healthy Existing Pods

--------------------------------

Deployment
      ↓
Manages ReplicaSets

ReplicaSets
      ↓
Manage Pods
```
