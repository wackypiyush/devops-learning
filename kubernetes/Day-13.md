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

```text*Every Day

At Midnight
```

---

* concurrencyPolicy

Controls:

```*ext
What*Happens If
Another Scheduled Run*Arrives
While A Previous*Job Is Still Active
```

Values:

*``text
Allow

Forbid

Replace
``*

---

## Allow (Default)

```text*Old Job Running

New Schedule Arri*es

Start New Job Anyway
```

---
*##*Forbid

```text
Old Job Running

*ew Schedule Arrives

Do*Not Start New Job
```

Important:
*```*ext
Missed Schedules Are Not
Autom*tically Guaranteed To Run Later
``*

---

## Replace

```text
Old Job*Running

New Schedule Arrives

Ter*inate Old Job

Start New Job
```

*--

# successfulJobsHistoryLimit

*efines:

```text
How*Many Successful Jobs
Kubernetes Ke*ps
```

Example:

```yaml
successf*lJobsHistoryLimit:*2
```

Meaning:

```text
Keep Up T*
* Recent Successful Jobs
```

---

*ractical Impact:

```text*Older Successful Jobs

May Be Dele*ed

Their Logs May No Longer Be Av*ilable
```

---

# failedJobsHisto*yLimit

Defines:

```text
How Many*Failed Jobs
Kubernetes Keeps
```

*xample:

```yaml
failedJobsHistory*imit: 1
```

Meaning:

```*ext
Keep Up To
1 Failed*Job
```

---

# suspend

Defines:
*```text
Should The CronJob
*reate New Scheduled Jobs?
```

---*
Example:

```yaml
suspend: true
`*`

Meaning:

```text
Do Not Start *ew Scheduled Jobs
```

---

Import*nt:

```text
Already Running Jobs
*Continue Running
```

---

To resu*e:

```yaml
suspend* false
```

---

#*Timezone

Your lab showed:

```tex**TIMEZONE = <none>
```

*nd logs*displayed:

```text
UTC*Time
```

---

Important*

```text
CronJob Scheduler Timezo*e

*ND

Container Timezone

Are Separa*e Concepts
```

---

Rules:

```te*t
If spec.timeZone Is Not Defined
*K*bernetes Uses The Controller Manag*r Timezone
```

---

Container Out*ut:

```bash
date
```

may still s*ow:

```text
UTC
```

even when*scheduling uses another timezone.
*---

Production Recommendation:

`*`text
Explicitly Configure

spec.t*meZone

When Local Time Scheduling*Matters
```

---

# 4. CronJob Sch*dule Format

Kubernetes CronJobs u*e Linux Cron syntax.

---

Format:*
```text
* * * * *
│ │ │ │ │
│ │ │*│ └── Day Of Week (0-7)
* │ │ └──── Month (1-12)
│ │ └─────* Day Of*Month (1-31)
│ └──────── Hour (0-2*)
└──────────*Minute (0-59)
```

---

Easy Memor* Trick:

```text
Minute

Hour

Day*Of Month

Month

Day Of Week
```

*--

# Special Characters

## *

Me*ns:

```text
Every
```

---

## ,
*Means:

```text
Specific Values
``*

---

## -

Means:

```text
Range*```

---

## /

Means:

```text
Ev*ry N Units
```

---

# Cron Schedu*e Reference

## Every Minute

```y*ml
schedule: "* * * * *"
```

---
*## Every 5 Minutes

```yaml
schedu*e: "*/5 * * * *"
```

---

## Ever* 15 Minutes

```yaml
schedule: "*/*5 * * * *"
```

---

## Every Hour*At Minute 0

```yaml
schedule: "0 * * * *"
```

---

## Daily At Midn*ght

```yaml
schedule: "0 0 * * *"*```

---

## Daily At 2 AM

```yam*
schedule: "0 2 * * *"
```

---

#* Every Sunday At Midnight

```*aml
schedule: "0 0 * * 0"
```

---*
## First Day Of Every Month At Mi*night

```yaml
schedule: "0 0 1 * *"
```

---

## Daily At 9 AM And 6*PM

```yaml
schedule: "0 9,18 * * *"
```

---

## Every Hour From 9 A* Through 5 PM

```yaml
schedule: "* 9-17 * * *"
```

---

Important:
*```text
* * * * *

Runs Every Minu*e

-------------------------------*

0 * * * *

Runs Every Hour
At Mi*ute 0
```

---

# 5. Creating A Jo*

Command:

```bash
kubectl create*job day31-hello \
  --image=busybo*:1.36 \
  -n dev \
  -- /bin/sh -c*'echo "Job started"; date; sleep *; echo "Job completed successfully*'
```

Flow:

```text
Job
 ↓
Pod
 *
Run Command
 ↓
Exit*Successfully
```

---

# Wait For *ompletion

```bash
kubectl wait --*or=condition=complete job/day31-he*lo \
  -n dev --timeout=120s
```

*--

# Verify Job

```bash
kubectl *et job day31-hello -n dev
```

or
*```bash
kubectl get jobs -n dev
``*

---

# Verify Pod

```bash
kubec*l get pods -n dev \
  -l job-name=*ay31-hello
```

---

# View Logs

*``bash
kubectl logs job/day31-hell* -n dev
```

---

# Important Fiel*s Seen In Describe Output

```text*Parallelism: 1

Completions: 1

Ba*koff Limit: 6
```

Meaning:

```te*t
Only One Pod Runs At A Time

Nee* One Successful Completion

Defaul* Retry Limit Is 6
```

---

# 6. C*onJob Practical Concepts

Verify C*onJob:

```bash
kubectl get cronjo* day31-clock -n dev
```

---

# Ve*ify Ownership

```bash
kubectl get*jobs -n dev \
  -o custom-columns=*NAME:.metadata.name,OWNER:.metadat*.ownerReferences[0].name'
```

Out*ut example:

```text
OWNER

day31-*lock
```

Meaning:

```text
CronJo* Owns These Jobs
```

---

Relatio*ship:

```text
day31-clock (CronJo*)

      ↓

day31-clock-29877772 (*ob)

      ↓

Pod
```

---

# Read*ng CronJob Logs

## List Current J*bs

```bash
kubectl get jobs -n de*
```

---

## Show CronJob Ownersh*p

```bash
kubectl get jobs -n dev*\
  -o custom-columns='NAME:.metad*ta.name,OWNER:.metadata.ownerRefer*nces[0].name'
```

---

## List Po*s Created By A Job

```bash
kubect* get pods -n dev \
  -l job-name=d*y31-clock-29877772
```

---

## Re*d Logs

```bash
kubectl logs job/d*y31-clock-29877772 -n dev
```

---*
Important:

```text
Older CronJob*Executions

May Have Been Cleaned *p

Always Use A Currently Existing*Job Name
```

---

# Final Practic*l Checklist

## Jobs

```bash
kube*tl get jobs -n dev

kubectl descri*e job day31-hello -n dev

kubectl *ogs job/day31-hello -n dev
```

--*

## CronJobs

```bash
kubectl get*cronjobs -n dev

kubectl describe *ronjob day31-clock -n dev

kubectl*get jobs -n dev \
  -o custom-colu*ns='NAME:.metadata.name,OWNER:.met*data.ownerReferences[0].name'
```
*---

## Inspect Job Pods

```bash
*ubectl get pods -n dev \
  -l job-*ame=day31-hello

kubectl get pods *n dev \
  -l job-name=day31-failur*
```

---

# Day 13 Golden Rules

*``text
Deployment
      ↓
Maintain* Desired Application Pods

-------*------------------------

Job
    * ↓
Runs Until Completion

--------*-----------------------

CronJob
 *    ↓
Runs Jobs On Schedule

-----*--------------------------

CronJo*
      ↓
Creates Jobs

Jobs
      *
Manage Pods

--------------------*-----------

completions
      ↓
T*tal Successes Required

----------*---------------------

parallelism*      ↓
How Many Pods Run Together*
--------------------------------
*backoffLimit
      ↓
Retry Limit B*fore Failure

--------------------*-----------

activeDeadlineSeconds*      ↓
Maximum Job Runtime

-----*--------------------------

restar*Policy
      ↓
Never / OnFailure

*-------------------------------

J*b Success
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
````*
