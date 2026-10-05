# Docker Day 5 Notes
# Docker Image Optimization & Multi-Stage Builds

---

# 1. Docker Image Layers

## What is a Docker Image?

A Docker image is **not one big file**.

It is made up of multiple **read-only layers** stacked together.

Example:

```dockerfile
FROM ubuntu

RUN apt update

RUN apt install -y nginx

COPY app.py .
```

Docker creates layers roughly like:

```text
Layer 4 -> app.py copied
-------------------------
Layer 3 -> nginx installed
-------------------------
Layer 2 -> apt update
-------------------------
Layer 1 -> ubuntu base image
```

When a container starts, Docker adds a writable container layer on top:

```text
Container Writable Layer
------------------------
Image Layer 4
Image Layer 3
Image Layer 2
Image Layer 1
```

---

## Why Are Layers Important?

Layers provide:

```text
Caching
Layer Reuse
Faster Builds
Efficient Storage
```

Example:

If two images use:

```dockerfile
FROM python:3.11
```

Docker downloads that layer only once and reuses it.

---

## Layer Cache Rule

Docker builds from top to bottom.

```text
If a layer changes:
    ↓
That layer and all following layers rebuild.

Layers before it remain cached.
```

Example:

```dockerfile
COPY requirements.txt .

RUN pip install -r requirements.txt

COPY . .
```

Only `app.py` changes:

```text
COPY requirements.txt -> Cached

RUN pip install       -> Cached

COPY . .              -> Rebuilt
```

---

## Important Note

Not every Dockerfile instruction creates a filesystem layer.

Practically speaking, when learning Docker optimization, you can think of:

```dockerfile
RUN
COPY
ADD
```

as layer-producing instructions.

---

# 2. Check Image History

## List Images

```bash
docker images
```

or

```bash
docker image ls
```

---

## View Layer History

```bash
docker history myapp:latest
```

Example:

```text
IMAGE         CREATED BY

abcd1234      COPY . .

efgh5678      RUN pip install

ijkl9012      WORKDIR /app

mnop3456      FROM python:3.11
```

---

## Why Use docker history?

To understand:

```text
Which layers exist
Which command created them
How much space each layer uses
```

Useful for image optimization.

Example:

```bash
docker history myapp
```

Output:

```text
RUN pip install       250MB

RUN apt install vim    60MB

COPY . .               20MB
```

Immediately shows image bloat.

---

# 3. Inspect Images

## Basic Inspect

```bash
docker image inspect myapp
```

or

```bash
docker inspect myapp
```

---

## What Inspect Shows

Image metadata:

```text
Image ID
Size
Architecture
Operating System
Environment Variables
Working Directory
Exposed Ports
```

---

## Example

```bash
docker image inspect myapp
```

Output contains:

```json
{
  "Id": "sha256:abc123",
  "Size": 245000000,
  "Architecture": "amd64",
  "Os": "linux"
}
```

---

## Check Specific Fields

Image size:

```bash
docker inspect \
-f '{{.Size}}' myapp
```

Working directory:

```bash
docker inspect \
-f '{{.Config.WorkingDir}}' myapp
```

---

## History vs Inspect

### History

```bash
docker history myapp
```

Shows:

```text
Layers
Dockerfile commands
Layer sizes
```

---

### Inspect

```bash
docker inspect myapp
```

Shows:

```text
Metadata
Configuration
Environment Variables
Ports
Image Size
```

---

# 4. Why Image Size Matters

Image size is extremely important in production.

---

## Faster Pulls

Large image:

```text
2 GB
```

downloads slowly.

Small image:

```text
150 MB
```

downloads quickly.

---

## Faster Deployments

Kubernetes flow:

```text
Node
  |
Pull Image
  |
Start Pod
```

Smaller image:

```text
Faster startup
Faster deployments
```

---

## Less Storage

Example:

```text
100 servers
```

Image:

```text
2 GB
```

Storage:

```text
200 GB
```

Image:

```text
200 MB
```

Storage:

```text
20 GB
```

---

## Better Security

Large images often contain:

```text
Unused Packages
Unused Tools
Unused Libraries
```

More software means:

```text
More Vulnerabilities
```

---

## Faster CI/CD

Pipeline:

```text
Build
Push
Pull
Deploy
```

Every step becomes faster.

---

## Golden Rule

```text
Every MB in your image will be:

Built
Pushed
Stored
Pulled
Scanned
Deployed

Keep images as small as possible.
```

---

# 5. Check Current Image Sizes

## List Images

```bash
docker images
```

or

```bash
docker image ls
```

Example:

```text
REPOSITORY     TAG      SIZE

ubuntu         latest   77MB

nginx          latest   188MB

python         3.11     1.02GB

myapp          latest   245MB
```

---

## Inspect Image Size

```bash
docker image inspect myapp
```

Look for:

```json
"Size": 245000000
```

---

## Find Large Layers

```bash
docker history myapp
```

Shows layer sizes.

---

## Check Docker Disk Usage

```bash
docker system df
```

Example:

```text
TYPE            TOTAL   ACTIVE   SIZE

Images            10       6      4.5GB

Containers         4       2      500MB

Volumes            5              1.5GB

Build Cache                       2.1GB
```

---

## Detailed Disk Usage

```bash
docker system df -v
```

Shows:

```text
Images
Containers
Volumes
Shared layers
Unique layers
Build cache
```

---

# 6. Build a Deliberately Bad Image

## Bad Dockerfile

```dockerfile
FROM python:3.11

WORKDIR /app

COPY . .

RUN apt update

RUN apt install -y vim

RUN apt install -y curl

RUN apt install -y wget

RUN pip install -r requirements.txt

CMD ["python", "app.py"]
```

---

## Problems

### Large Base Image

```dockerfile
FROM python:3.11
```

is much larger than:

```dockerfile
FROM python:3.11-slim
```

---

### Multiple RUN Instructions

```dockerfile
RUN apt install vim

RUN apt install curl

RUN apt install wget
```

creates unnecessary layers.

---

### Unnecessary Packages

Examples:

```text
vim
curl
wget
```

Usually not needed inside production containers.

---

### Poor Cache Usage

```dockerfile
COPY . .

RUN pip install -r requirements.txt
```

If any file changes:

```text
app.py
README.md
config.py
```

Docker must rerun:

```text
pip install
```

again.

---

## Build Image

```bash
docker build -t bad-app .
```

Check size:

```bash
docker image ls
```

Analyze:

```bash
docker history bad-app
```

Inspect:

```bash
docker image inspect bad-app
```

---

# 7. Docker Build Cache

Docker stores previously built layers and reuses them.

This is called:

```text
Build Cache
```

---

## Good Cache Pattern

```dockerfile
COPY requirements.txt .

RUN pip install -r requirements.txt

COPY . .
```

First build:

```text
Layer 1 -> requirements.txt

Layer 2 -> pip install

Layer 3 -> source code
```

---

Only `app.py` changes:

```text
Layer 1 -> Cached

Layer 2 -> Cached

Layer 3 -> Rebuilt
```

Fast build.

---

## Cache Rule

```text
Docker checks layers from top to bottom.

As soon as a layer changes,
all subsequent layers rebuild.
```

---

# 8. Why Dockerfile Ordering Matters

Docker builds sequentially.

Order directly affects build speed.

---

## Things That Change Rarely

Place near the top:

```text
Base Image

requirements.txt

package.json

pom.xml
```

---

## Things That Change Frequently

Place near the bottom:

```text
Application Source Code
```

---

## Golden Rule

```text
Things That Change Rarely
        ↓
Keep At Top

Things That Change Frequently
        ↓
Keep At Bottom
```

---

# 9. Improved Dockerfile

```dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .

RUN pip install \
    --no-cache-dir \
    -r requirements.txt

COPY . .

CMD ["python", "app.py"]
```

---

## Improvements

### Smaller Base Image

```dockerfile
python:3.11-slim
```

instead of:

```dockerfile
python:3.11
```

---

### Better Layer Cache

```dockerfile
COPY requirements.txt .
```

before:

```dockerfile
COPY . .
```

keeps dependency layer cached.

---

### No Pip Cache

```dockerfile
--no-cache-dir
```

prevents pip package cache from being stored inside the image.

Smaller image.

---

### Cleaner Image

Fewer unnecessary packages.

---

## Why Copy requirements.txt First?

Dependencies change less frequently than application code.

Docker can reuse:

```text
pip install layer
```

across builds.

---

# 10. Slim Base Images

## Standard Python Image

```dockerfile
FROM python:3.11
```

Typically contains:

```text
Python
Additional OS packages
Utilities
Extra libraries
Documentation
```

Larger image size.

---

## Slim Image

```dockerfile
FROM python:3.11-slim
```

Contains:

```text
Python Runtime
Minimal Debian Packages
Essential Runtime Libraries
```

Much smaller.

---

## How To Know If Slim Works?

### Rule 1

Application only runs Python code:

```text
Flask
FastAPI
Django
Simple APIs
```

Usually slim works perfectly.

---

### Rule 2

Common libraries:

```python
flask
requests
pandas
```

Usually work fine.

---

### Rule 3

Dependencies requiring compilation

Examples:

```text
numpy
scipy
opencv
psycopg2
```

may require:

```text
gcc
build-essential
libpq-dev
```

during build.

---

## Golden Rule

```text
Start With Slim

If Build Fails
      ↓
Install Only The Missing Packages
```

---

# 11. pip --no-cache-dir

## Normal pip Install

```bash
pip install flask
```

Pip:

```text
1. Downloads package
2. Installs package
3. Stores downloaded copy in cache
```

Example cache location:

```text
/root/.cache/pip
```

---

## Why Pip Cache Exists

Later:

```bash
pip install flask
```

can reuse downloaded files.

Faster installation.

---

## Why Cache Is Usually Useless In Images

Docker image is built once.

Runtime containers rarely run:

```bash
pip install
```

again.

Cache becomes:

```text
Dead Weight
```

inside the image.

---

## Without no-cache-dir

Image contains:

```text
Application Packages
+
Pip Cache Files
```

---

## With no-cache-dir

```dockerfile
RUN pip install \
    --no-cache-dir \
    -r requirements.txt
```

Image contains:

```text
Application Packages
```

only.

---

## Production Rule

Always prefer:

```dockerfile
RUN pip install \
    --no-cache-dir \
    -r requirements.txt
```

unless there is a specific reason not to.

---

# 12. Recommended Dockerfile Pattern

```text
1. Base Image

2. Copy Dependency Files

3. Install Dependencies

4. Copy Application Code

5. Start Application
```

Example:

```dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .

RUN pip install \
    --no-cache-dir \
    -r requirements.txt

COPY . .

CMD ["python", "app.py"]
```

---

# 13. Understanding Images, Containers & Build Cache

## Image

An image is:

```text
Read Only
Portable
Reusable
```

It contains whatever was copied during the build.

Example:

```dockerfile
COPY . .
```

Image contains:

```text
app.py

requirements.txt

config.yaml

templates/

static/
```

---

## What Is Inside An Image?

```text
Application
Dependencies
Configuration
OS Files
```

---

## What Gets Pushed To Docker Hub?

Docker pushes:

```text
Final Image Layers
```

containing:

```text
Source Files (copied into image)

Installed Dependencies

Configuration Files

Application Artifacts
```

---

## What Does NOT Get Pushed?

```text
Dockerfile
.git
Build Cache
Containers
Volumes
Logs
Running State
```

unless explicitly copied into the image.

---

## Image Size

After build:

```text
Image Size = Fixed
```

until a new image is built.

Containers do not modify image size.

---

# 14. Build Cache Is Separate

Many people think build cache is inside the image.

It is not.

Docker stores build cache separately.

Think:

```text
Docker Host

├── Images
├── Containers
├── Volumes
└── Build Cache
```

---

## View Cache Usage

```bash
docker system df
```

---

## Remove Cache

```bash
docker builder prune
```

---

## Important

Build cache is:

```text
Machine Specific
```

When somebody pulls your image:

```text
They Get:
    Image Layers

They Do Not Get:
    Build Cache
    Containers
    Volumes
```

---

## Docker Lifecycle

```text
Project Files
      |
      v
Dockerfile
      |
      v
docker build
      |
      +--> Build Cache
      |
      v
Image (Read Only)
      |
      v
docker run
      |
      v
Container (Read/Write)
```

---

# 15. Multi-Stage Builds

Multi-stage builds are one of the most important image optimization techniques.

---

## Problem

Java application needs:

```text
JDK
Maven
Dependencies
Source Code
```

to build.

But only needs:

```text
JRE
Application JAR
```

to run.

---

## Build Stage

```dockerfile
FROM maven:3.9-eclipse-temurin-17 AS builder

WORKDIR /app

COPY . .

RUN mvn package
```

Produces:

```text
target/app.jar
```

---

## Runtime Stage

```dockerfile
FROM eclipse-temurin:17-jre

WORKDIR /app

COPY --from=builder \
target/app.jar \
app.jar

CMD ["java", "-jar", "app.jar"]
```

---

## Result

### Builder Stage

Contains:

```text
Maven
JDK
Source Code
Dependencies
Build Tools
```

---

### Runtime Stage

Contains:

```text
JRE
Application JAR
```

---

### Final Image

```text
JRE
Application JAR
```

No:

```text
Maven
Build Tools
Source Code
```

Much smaller image.

---

## Understanding COPY --from

```dockerfile
COPY --from=builder target/app.jar app.jar
```

Meaning:

```text
Copy File From Builder Stage
Into Current Stage
```

---

## Naming Stages

```dockerfile
FROM maven:3.9 AS builder
```

Stage name:

```text
builder
```

Later referenced using:

```dockerfile
COPY --from=builder
```

---

## Benefits

```text
Smaller Images

Better Security

Faster Pulls

Faster Deployments

Cleaner Runtime Images
```

---

## Golden Rule

```text
Build With Heavy Tools

Run With Lightweight Image

Copy Only What Is Needed To Run
```

---

# 16. Single Stage vs Multi-Stage

## Single Stage

Final image contains:

```text
Maven
JDK
Dependencies
Source Code
Application
```

### Pros

```text
Simple

Easy To Understand
```

### Cons

```text
Large Image

More Vulnerabilities

Slow Pull

Slow Deploy
```

---

## Multi-Stage

Final image contains:

```text
Runtime

Application
```

### Pros

```text
Smaller Images

Better Security

Faster Deployments

Production Standard
```

### Cons

```text
More Complex

Harder To Debug Sometimes
```

---

# 17. Multi-Stage Limitations

```text
More Complex Dockerfiles

Harder Debugging

Incorrect COPY Can Break Runtime

Not Always Worth It For Tiny Applications
```

---

# 18. Image Inspection Toolkit

## List Images

```bash
docker image ls
```

---

## Layer History

```bash
docker history myapp
```

Best tool for finding large layers.

---

## Image Metadata

```bash
docker image inspect myapp
```

---

## Disk Usage

```bash
docker system df
```

---

## Detailed Disk Usage

```bash
docker system df -v
```

---

# 19. Image Optimization Checklist

Before shipping an image:

✅ Use Slim Base Images

✅ Optimize Dockerfile Ordering

✅ Use Build Cache Effectively

✅ Use `pip --no-cache-dir`

✅ Avoid Unnecessary Packages

✅ Use `.dockerignore`

✅ Use Multi-Stage Builds Where Appropriate

✅ Check:

```bash
docker image ls
docker history myapp
docker system df
```

before pushing.

---

# Interview Question

## Does Multi-Stage Build Reduce Image Size Or Container Size?

Answer:

```text
Image Size
```

Multi-stage builds optimize the final image.

Containers are created from images.

Smaller images lead to:

```text
Faster Pulls

Faster Deployments

Lower Storage Usage

More Efficient Containers
```

but the optimization is applied primarily to the image itself.
