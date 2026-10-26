# Kubernetes Day 13
# Jobs & CronJobs

---

# Introduction

So far, most workloads we have created in Kubernetes were:

```text
Deployments
```

A Deployment is designed for:

```text
Long-Running Applications
```

Examples:

```text
Nginx

Frontend Applications

Backend APIs

Grafana

Jenkins
```

---

However, not every workload should run forever.

Examples:

```text
Database Backup

Generate Reports

Send Emails

Data Import

Database Migration

Cleanup Scripts
```

These workloads should:

```text
Start
 ↓
Do Work
 ↓
Finish
```

and then stop.

This is where:

```text
Jobs

CronJobs
```

are used.

---

# 1. Deployment vs Job vs CronJob

---

# Deployment

Purpose:

```text
Run Applications Continuously
```

A Deployment maintains the desired number of application Pods.

---

Flow:

```text
Start Pod
      ↓
Keep Running
      ↓
If Pod Dies
      ↓
Create New Pod
```

---

Examples:

```text
Nginx

Frontend

Backend

Grafana

Jenkins
```

---

# Job

Purpose:

```text
Run A Task Until Completion
```

Example:

```text
Database Backup
```

---

Flow:

```text
Start Pod
      ↓
Run Task
      ↓
Task Complete
      ↓
Exit Successfully
```

---

When a Job finishes successfully:

```text
The Task Stops Running

The Job Resource Usually Remains In The Cluster

Completed Pods May Still Exist

Logs May Still Be Available

Resources Can Later Be Deleted
Manually Or By Cleanup Policies
```

Example from the lab:

```text
day31-hello

STATUS = Complete
```

but the Job resource still existed.

---

Examples:

```text
Backup

Data Import

Database Migration

Batch Processing
```

---

# CronJob

Purpose:

```text
Run Jobs On A Schedule
```

Think:

```text
Job + Timer
```

---

Flow:

```text
12:00 AM
      ↓
Create Job
      ↓
Run Backup
      ↓
Complete

Next Day
      ↓
Run Again
```

---

Examples:

```text
Nightly Backup

Weekly Cleanup

Monthly Reports

Log Archiving
```

---

# Easy Comparison

```text
Deployment
      ↓
Runs Continuously

--------------------------------

Job
      ↓
Runs Until Completion

--------------------------------

CronJob
      ↓
Creates Jobs
On A Schedule
```

---

# CronJob + Job Relationship

Very Important Interview Concept:

```text
CronJob
      ↓
Creates Jobs
      ↓
Jobs Manage Pods
      ↓
Task Completes Or Fails
```

---

# 2. Job Concepts You Need To Know

A Job is much more than:

```text
Run A Pod
```

Several settings control its behavior.

---

# completions

Defines:

```text
How Many Successful Task Completions
Are Required
```

before the Job is considered complete.

---

Example:

```yaml
completions: 5
```

Meaning:

```text
Task Must Successfully Complete
5 Times
```

---

Visual:

```text
Success #1

Success #2

Success #3

Success #4

Success #5

Job Complete
```

---

# parallelism

Defines:

```text
How Many Pods
Can Run Simultaneously
```

---

Example:

```yaml
completions: 10
parallelism: 2
```

Meaning:

```text
Need 10 Successful Runs

Only 2 Pods
Can Run At The Same Time
```

---

Visual:

```text
Pod 1
Pod 2

Finish

Pod 3
Pod 4

Finish
```

Continue until:

```text
10 Successful Completions
```

are achieved.

---

# Difference Between Completions And Parallelism

```text
completions
      ↓
Total Successes Needed

--------------------------------

parallelism
      ↓
How Many Pods Run Together
```

---

Example:

```yaml
completions: 20
parallelism: 5
```

Meaning:

```text
Need 20 Successes

Run 5 At A Time
```

---

# backoffLimit

Defines:

```text
How Many Retries Kubernetes Allows

Before Marking The Job Failed
```

---

Important:

```text
backoffLimit Controls Retries

It Does NOT Always Mean
A New Pod Per Retry
```

---

With:

```yaml
restartPolicy: Never
```

failed attempts typically use:

```text
New Pods
```

---

With:

```yaml
restartPolicy: OnFailure
```

Kubernetes can:

```text
Restart The Container

Inside The Same Pod
```

---

## Lab Example

```yaml
backoffLimit: 2
```

Result:

```text
1 Initial Attempt

+

2 Retries

=

3 Failed Attempts
```

Observed:

```text
3 Failed Pods

Job Failed

BackoffLimitExceeded
```

---

# activeDeadlineSeconds

Defines:

```text
Maximum Time
A Job Is Allowed To Run
```

---

Example:

```yaml
activeDeadlineSeconds: 300
```

Meaning:

```text
Maximum Runtime

300 Seconds

=

5 Minutes
```

---

If exceeded:

```text
Active Pods May Be Terminated

Job Is Marked Failed
```

---

Useful when:

```text
Jobs Must Not Run Forever
```

---

# restartPolicy

Controls:

```text
What Happens
When A Container Exits
```

---

Supported values:

```text
Never

OnFailure
```

---

## Never

```yaml
restartPolicy: Never
```

Meaning:

```text
Container Fails
      ↓
Do Not Restart Container
      ↓
Job Controller May Create New Pod
```

---

## OnFailure

```yaml
restartPolicy: OnFailure
```

Meaning:

```text
Container Fails
      ↓
Restart Container
In Same Pod
```

---

## Interview Question

Can Jobs use:

```text
restartPolicy: Always
```

Answer:

```text
No

Jobs Only Support:

Never

OnFailure
```

---

# What Happens When A Job Fails?

Suppose:

```text
Job
      ↓
Runs Script
      ↓
Script Fails
```

Kubernetes checks:

```text
backoffLimit
```

---

Example:

```yaml
backoffLimit: 3
```

Possible flow:

```text
Attempt 1 ❌

Retry

Attempt 2 ❌

Retry

Attempt 3 ❌

Retry

Attempt 4 ❌

Job Failed
```

---

Final State:

```text
STATUS = Failed
```

---

# Default backoffLimit

If not specified:

```text
backoffLimit = 6
```

Example from lab:

```text
day31-hello
```

showed:

```text
Backoff Limit: 6
```

Meaning:

```text
Kubernetes Can Retry

Up To 6 Times

Before Marking The Job Failed
```

---

# 3. CronJob Concepts

CronJobs create Jobs automatically according to a schedule.

---

Relationship:

```text
CronJob
      ↓
Creates Jobs
      ↓
Jobs Create Pods
```

---

Architecture:

```text
CronJob
    ↓
Job
    ↓
Pod
```

---

# schedule

Defines:

```text
When The Job Runs
```

Example:

```yaml
schedule: "0 0 * * *"
```

Meaning:

```text
Every Day

At Midnight
```

---

# concurrencyPolicy

Controls:

```text
What Happens If
Another Scheduled Run Arrives
While A Previous Job Is Still Active
```

Values:

```text
Allow

Forbid

Replace
```

---

## Allow (Default)

```text
Old Job Running

New Schedule Arrives

Start New Job Anyway
```

---
## Forbid

```text
Old Job Running

New Schedule Arrives

Do Not Start New Job
```

Important:
```text
Missed Schedules Are Not
Automatically Guaranteed To Run Later
```

---

## Replace

```text
Old Job Running

New Schedule Arrives

Terminate Old Job

Start New Job
```

---

# successfulJobsHistoryLimit

Defines:

```text
How Many Successful Jobs
Kubernetes Keeps
```

Example:

```yaml
successfulJobsHistoryLimit: 2
```

Meaning:

```text
Keep Up To
2 Recent Successful Jobs
```

---

Practical Impact:

```text
Older Successful Jobs

May Be Deleted

Their Logs May No Longer Be Available
```

---

# failedJobsHistoryLimit

Defines:

```text
How Many Failed Jobs
Kubernetes Keeps
```

Example:

```yaml
failedJobsHistoryLimit: 1
```

Meaning:

```text
Keep Up To
1 Failed Job
```

---

# suspend

Defines:
```text
Should The CronJob
Create New Scheduled Jobs?
```

---
Example:

```yaml
suspend: true
`

Meaning:

```text
Do Not Start New Scheduled Jobs
```

---

Important:

```text
Already Running Jobs
Continue Running
```

---

To resume:

```yaml
suspend: false
```

---

# Timezone

Your lab showed:

```text
TIMEZONE = <none>
```

And logs displayed:

```text
UTC Time
```

---

Important:

```text
CronJob Scheduler Timezone

AND

Container Timezone

Are Separate Concepts
```

---

Rules:

```text
If spec.timeZone Is Not Defined
Kubernetes Uses The Controller Manager Timezone
```

---

Container Output:

```bash
date
```

may still show:

```text
UTC
```

even when scheduling uses another timezone.
---

Production Recommendation:

```text
Explicitly Configure

spec.timeZone

When Local Time Scheduling Matters
```

---

# 4. CronJob Schedule Format

Kubernetes CronJobs use Linux Cron syntax.

---

Format:
```text
* * * * *
│ │ │ │ │
│ │ │ │ └── Day Of Week (0-7)
│ │ │ └──── Month (1-12)
│ │ └────── Day Of Month (1-31)
│ └──────── Hour (0-23)
└────────── Minute (0-59)
```

---

Easy Memory Trick:

```text
Minute

Hour

Day Of Month

Month

Day Of Week
```

---

# Special Characters

## *

Means:

```text
Every
```

---

## ,
Means:

```text
Specific Values
```

---

## -

Means:

```text
Range
```

---

## /

Means:

```text
Every N Units
```

---

# Cron Schedule Reference

## Every Minute

```yaml
schedule: "* * * * *"
```

---
## Every 5 Minutes

```yaml
schedule: "*/5 * * * *"
```

---

## Every 15 Minutes

```yaml
schedule: "*/15 * * * *"
```

---

## Every Hour At Minute 0

```yaml
schedule: "0 * * * *"
```

---

## Daily At Midnight

```yaml
schedule: "0 0 * * *"
```

---

## Daily At 2 AM

```yaml
schedule: "0 2 * * *"
```

---

# Every Sunday At Midnight

```yaml
schedule: "0 0 * * 0"
```

---
## First Day Of Every Month At Midnight

```yaml
schedule: "0 0 1 * *"
```

---

## Daily At 9 AM And 6 PM

```yaml
schedule: "0 9,18 * * *"
```

---

## Every Hour From 9 AM Through 5 PM

```yaml
schedule: "* 9-17 * * *"
```

---

Important:
```text
* * * * *

Runs Every Minute

-------------------------------

0 * * * *

Runs Every Hour
At Minute 0
```

---

# 5. Creating A Job

Command:

```bash
kubectl create job day31-hello \
  --image=busybox:1.36 \
  -n dev \
  -- /bin/sh -c 'echo "Job started"; date; sleep 2; echo "Job completed successfully"'
```

Flow:

```text
Job
 ↓
Pod

Run Command
 ↓
Exit Successfully
```

---

# Wait For Completion

```bash
kubectl wait --for=condition=complete job/day31-hello \
  -n dev --timeout=120s
```

---

# Verify Job

```bash
kubectl get job day31-hello -n dev
```

or
```bash
kubectl get jobs -n dev
```

---

# Verify Pod

```bash
kubectl get pods -n dev \
  -l job-name=day31-hello
```

---

# View Logs

```bash
kubectl logs job/day31-hello -n dev
```

---

# Important Fields Seen In Describe Output

```text
Parallelism: 1

Completions: 1

Backoff Limit: 6
```

Meaning:

```text
Only One Pod Runs At A Time

Need One Successful Completion

Default Retry Limit Is 6
```

---

# 6. CronJob Practical Concepts

Verify CronJob:

```bash
kubectl get cronjob day31-clock -n dev
```

---

# Verify Ownership

```bash
kubectl get jobs -n dev \
  -o custom-columns='NAME:.metadata.name,OWNER:.metadata.ownerReferences[0].name'
```

Output example:

```text
OWNER

day31-clock
```

Meaning:

```text
CronJob Owns These Jobs
```

---

Relationship:

```text
day31-clock (CronJob)

      ↓

day31-clock-29877772 (Job)

      ↓

Pod
```

---

# Reading CronJob Logs

## List Current Jobs

```bash
kubectl get jobs -n dev
```

---

## Show CronJob Ownership

```bash
kubectl get jobs -n dev \
  -o custom-columns='NAME:.metadata.name,OWNER:.metadata.ownerReferences[0].name'
```

---

## List Pods Created By A Job

```bash
kubectl get pods -n dev \
  -l job-name=day31-clock-29877772
```

---

## Read Logs

```bash
kubectl logs job/day31-clock-29877772 -n dev
```

---
Important:

```text
Older CronJob Executions

May Have Been Cleaned Up

Always Use A Currently Existing Job Name
```

---

# Final Practical Checklist

## Jobs

```bash
kubectl get jobs -n dev

kubectl describe job day31-hello -n dev

kubectl logs job/day31-hello -n dev
```

---

## CronJobs

```bash
kubectl get cronjobs -n dev

kubectl describe cronjob day31-clock -n dev

kubectl get jobs -n dev \
  -o custom-columns='NAME:.metadata.name,OWNER:.metadata.ownerReferences[0].name'
```
---

## Inspect Job Pods

```bash
kubectl get pods -n dev \
  -l job-name=day31-hello

kubectl get pods -n dev \
  -l job-name=day31-failure
```

---

# Day 13 Golden Rules

```text
Deployment
      ↓
Maintain Desired Application Pods

------------------------------

Job
    ↓
Runs Until Completion

------------------------------

CronJob
     ↓
Runs Jobs On Schedule

------------------------------

CronJob
      ↓
Creates Jobs

Jobs
      
Manage Pods

------------------------------

completions
      ↓
Total Successes Required

------------------------------

parallelism
      ↓
How Many Pods Run Together
--------------------------------
backoffLimit
      ↓
Retry Limit Before Failure

------------------------------

activeDeadlineSeconds
      ↓
Maximum Job Runtime

------------------------------

restartPolicy
      ↓
Never / OnFailure

-------------------------------

Job Success
      ↓
STATUS = Complete

--------------------------------

Job Failure
      ↓
STATUS = Failed

--------------------------------

concurrencyPolicy=Forbid
      ↓
No Overlapping Active Jobs

--------------------------------

successfulJobsHistoryLimit
      ↓
Keep Last N Successful Jobs

--------------------------------

failedJobsHistoryLimit
      ↓
Keep Last N Failed Jobs

--------------------------------

suspend=true
      ↓
Stop Future Scheduled Jobs

--------------------------------

Cron Schedule
      ↓
Minute Hour Day Month Weekday

--------------------------------

CronJob
      ↓
Creates Jobs

Jobs
      ↓
Create Pods
```
````

