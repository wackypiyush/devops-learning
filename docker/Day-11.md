# Dockerfile & Image Building Notes

# 1. What is a Dockerfile?

A Dockerfile is a text file containing instructions that tell Docker:

> How to build an image.

Simply:

- Instructions for building an image
- File Type: Text File
- Executes: No
- Purpose: Define image creation steps

---

## Analogy

```text
Recipe      = Dockerfile
Cake Mold   = Image
Cake You Eat = Container
```

---

## Example Dockerfile

```dockerfile
FROM python:3.11

WORKDIR /app

COPY . .

CMD ["python", "app.py"]
```

Build an image:

```bash
docker build -t myapp:v1 .
```

---

## Dockerfile → Image → Container

```text
Dockerfile
      ↓
docker build
      ↓
Image
      ↓
docker run
      ↓
Container
```

---

## Image

A packaged application environment.

Contains:

- Application Code
- Dependencies
- Runtime
- Libraries
- Configuration

Properties:

```text
Executes? No
Purpose: Blueprint for Containers
```

---

## Container

A running instance of an image.

Properties:

```text
Executes? Yes
Purpose: Run the Application
```

---

## Why Do We Need a Dockerfile?

Without Dockerfiles:

- Developers manually create images
- Hard to reproduce builds
- Inconsistent deployments

Benefits:

- Repeatability
- Version Control
- Automation
- Consistency

Same Dockerfile → Same Image

---

# 2. Flask Application Example

## app.py

```python
from flask import Flask

app = Flask(__name__)

@app.route("/")
def home():
    return "Hello Docker"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
```

---

## Why host="0.0.0.0"?

Use:

```python
host="0.0.0.0"
```

Not:

```python
host="localhost"
```

Reason:

Flask must listen on all interfaces so Docker can forward traffic from outside the container.

---

## Dockerfile

```dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 5000

CMD ["python", "app.py"]
```

---

# 3. FROM

```dockerfile
FROM python:3.11-slim
```

Purpose:

Defines the base image.

Docker builds on top of an existing image.

Why use python:3.11-slim?

It already contains:

- Linux Filesystem
- Python Runtime
- Python Libraries

Without it we'd have to install Python manually.

Think of FROM as:

```text
Foundation of the House
```

---

# 4. WORKDIR

```dockerfile
WORKDIR /app
```

Creates and switches to:

```text
/app
```

Equivalent Linux commands:

```bash
mkdir /app
cd /app
```

After this instruction:

```text
Current Directory = /app
```

Why?

Keeps files organized.

Without WORKDIR:

```text
Files may be copied into /
```

which becomes messy.

---

# 5. COPY

Syntax:

```dockerfile
COPY <source> <destination>
```

Example:

```dockerfile
COPY requirements.txt .
```

Copies:

```text
Host:
requirements.txt

↓

Image:
/app/requirements.txt
```

Without WORKDIR:

```dockerfile
COPY requirements.txt /app/
```

---

## Why Copy requirements.txt First?

Dependencies change less often than application code.

Docker cache can be reused.

This speeds up image builds.

---

# 6. RUN

```dockerfile
RUN pip install --no-cache-dir -r requirements.txt
```

Purpose:

Runs commands during image creation.

Equivalent:

```bash
pip install -r requirements.txt
```

Result:

```text
Flask Installed
Inside Image
```

---

## When Does RUN Execute?

During:

```bash
docker build
```

Not during:

```bash
docker run
```

Flow:

```text
docker build
     ↓
RUN Executes
     ↓
Changes Become Part of Image
```

---

## Build Phase vs Runtime Phase

Build Phase:

```dockerfile
RUN pip install ...
```

Dependencies installed once.

Runtime Phase:

```dockerfile
CMD ["python","app.py"]
```

Application starts.

---

# 7. COPY Application Files

```dockerfile
COPY . .
```

Meaning:

Copy all project files from Host Machine to:

```text
/app
```

inside the image.

---

## Why After RUN?

Example:

```dockerfile
COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .
```

If only app.py changes:

```text
Dependency Layer → Cached
Application Layer → Rebuilt
```

Build becomes much faster.

---

# 8. EXPOSE

```dockerfile
EXPOSE 5000
```

Purpose:

Documents application port.

Means:

```text
Application listens on Port 5000
```

---

## Common Misconception

```dockerfile
EXPOSE 5000
```

does NOT mean:

```text
Application Accessible from Browser
```

❌ Wrong

---

Need:

```bash
docker run -p 5000:5000 myapp
```

---

Memory Trick:

```text
EXPOSE = Inform Docker
-p     = Publish Port
```

---

# 9. CMD

```dockerfile
CMD ["python", "app.py"]
```

Purpose:

Default command executed when container starts.

Equivalent:

```bash
python app.py
```

---

Execution:

```bash
docker run flask-app
```

Docker runs:

```bash
python app.py
```

inside container.

---

Without CMD:

```text
Container Starts
      ↓
No Main Process
      ↓
Container Exits
```

Remember:

> A container lives as long as its main process lives.

---

# 10. Build Image

Build:

```bash
docker build -t flask-app:v1 .
```

Docker executes:

```text
FROM
 ↓
WORKDIR
 ↓
COPY requirements.txt
 ↓
RUN pip install
 ↓
COPY application files
 ↓
EXPOSE
 ↓
CMD
```

Result:

```text
Image Created
```

---

# 11. Run Container

```bash
docker run -d \
-p 5000:5000 \
--name flask-container \
flask-app:v1
```

Flow:

```text
Image
 ↓
Create Container
 ↓
Run CMD
 ↓
python app.py
 ↓
Flask Starts
 ↓
Listening on 5000
```

Access:

```text
http://localhost:5000
```

---

# Dockerfile Instruction Memory Trick

```text
FROM     → Start From
WORKDIR  → Change Directory
COPY     → Copy Files
RUN      → Execute During Build
EXPOSE   → Document Port
CMD      → Execute On Container Start
```

---

# 12. docker build

Used to create an image from a Dockerfile.

Syntax:

```bash
docker build -t <image-name>:<tag> <path>
```

Example:

```bash
docker build -t flask-app:v1 .
```

Meaning:

```text
flask-app → Image Name
v1        → Version Tag
.         → Current Directory
```

---

## Different Dockerfile Name

```bash
docker build -f Dockerfile.dev -t flask-app:v1 .
```

```text
-f = Use this Dockerfile
```

---

## Without Tag

```bash
docker build .
```

Image gets:

```text
<none>
```

as name/tag.

Not recommended.

Always use tags.

---

# 13. Docker Build Cache

Docker caches layers.

Example:

```dockerfile
COPY requirements.txt .

RUN pip install -r requirements.txt

COPY . .
```

---

## First Build

```bash
docker build -t flask-app:v1 .
```

Docker:

```text
Copies requirements
Installs dependencies
Copies source code
```

---

## Second Build

Only app.py changed.

```bash
docker build -t flask-app:v1 .
```

Docker reuses cache:

```text
COPY requirements.txt → Cached
RUN pip install       → Cached
COPY . .              → Rebuilt
```

Faster build.

---

## Disable Cache

```bash
docker build --no-cache -t flask-app:v1 .
```

Docker rebuilds everything.

---

# 14. .dockerignore

Purpose:

```text
Don't send these files to Docker Build Process
```

Example:

```text
.git
.venv
__pycache__
*.log
tests/
```

These files never*enter the build context.

Benefits*

- Smaller Build Context
- Faster*Builds
- Smaller Images
- Avoid Se*ret Leakage

---

# 15. Build Cont*xt

Command:

```bash
docker build*.
```

Docker first packages files from current directory.

This package is called:

```text
Build Context
```

Flow:

```text
Project Folder
      ↓
Build Context
      ↓
Docker Engine
      ↓
Docker Image
```

`.dockerignore` reduces the build context.

---

# 16. ENV

Syntax:

```dockerfile
ENV KEY=value
```

Example:

```dockerfile
ENV APP_ENV=production
```

Every container automatically gets:

```text
APP_ENV=production
```

---

## Multiple Variables

```dockerfile
ENV APP_ENV=production
ENV DB_HOST=mysql
ENV DB_PORT=3306
```

or

```dockerfile
ENV APP_ENV=production \
    DB_HOST=mysql \
    DB_PORT=3306
```

---

## Verify Variables

All variables:

```bash
printenv
```

Specific variable:

```bash
echo $APP_ENV
```

---

## Runtime Override

Dockerfile:

```dockerfile
ENV APP_ENV=production
```

Run:

```bash
docker run -e APP_ENV=dev myapp
```

Result:

```text
APP_ENV=dev
```

Priority:

```text
docker run -e
      ↓
Dockerfile ENV
```

Runtime value wins.

---

## ENV Used by Other Instructions

```dockerfile
ENV APP_HOME=/app

WORKDIR $APP_HOME

COPY . $APP_HOME
```

Equivalent:

```text
WORKDIR /app
```

---

# 17. ARG vs ENV

## ARG

Build-time variable.

```dockerfile
ARG VERSION=1.0
```

Used during:

```bash
docker build
```

Not available inside running containers.

---

## ENV

Runtime variable.

```dockerfile
ENV APP_ENV=prod
```

Available inside containers and applications.

---

Memory Trick:

```text
ARG → Build Time
ENV → Run Time
```

---

# 18. CMD vs ENTRYPOINT

Containers need a process.

Without a process:

```text
Container Starts
      ↓
No Process
      ↓
Container Exits
```

---

## CMD

Default command.

```dockerfile
CMD ["python","app.py"]
```

Can be overridden:

```bash
docker run image bash
```

CMD gets replaced.

---

## ENTRYPOINT

Main executable.

```dockerfile
ENTRYPOINT ["echo"]
```

Run:

```bash
docker run image hello
```

Executes:

```bash
echo hello
```

ENTRYPOINT remains fixed.

Arguments change.

---

## Together

```dockerfile
ENTRYPOINT ["echo"]
CMD ["Hello Docker"]
```

Run:

```bash
docker run demo
```

Executes:

```bash
echo Hello Docker
```

---

Override:

```bash
docker run demo Piyush
```

Executes:

```bash
echo Piyush
```

ENTRYPOINT remains fixed.

CMD becomes default argument.

---

## Override ENTRYPOINT

```bash
docker run --entrypoint bash image
```

Useful for debugging.

---

## CMD vs ENTRYPOINT

```text
CMD
 ↓
Default Command
Can Be Replaced

ENTRYPOINT
 ↓
Main Executable
Arguments Appended
```

---

## Best Practice

```dockerfile
ENTRYPOINT ["python"]
CMD ["app.py"]
```

Result:

```bash
python app.py
```

---

# 19. Dockerfile Troubleshooting Flow

```text
Dockerfile
    ↓
Build
    ↓
Image
    ↓
Container
    ↓
Application
```

Identify which layer is failing.

---

## Step 1

Verify Dockerfile exists:

```bash
ls
ls -l Dockerfile
```

---

## Step 2

Validate syntax:

```bash
docker build -t myapp:v1 .
```

---

## Step 3

Check build logs.

Example:

```text
[1/6] FROM
[2/6] WORKDIR
[3/6] COPY
[4/6] RUN pip install
❌ Failed Here
```

---

## Step 4

Verify COPY source files exist.

```bash
ls
```

---

## Step 5

Check .dockerignore

Make sure required files aren't ignored.

---

## Step 6

Verify dependencies.

```bash
cat requirements.txt
```

Check:

- Wrong package names
- Wrong versions

---

## Step 7

Verify image exists.

```bash
docker images
```

---

## Step 8

Inspect image.

```bash
docker image inspect myapp:v1
```

---

## Step 9

Run container.

```bash
docker run myapp:v1
```

---

## Step 10

Check logs.

```bash
docker logs <container-id>
```

---

## Step 11

Verify CMD / ENTRYPOINT.

```bash
docker inspect <container-id>
```

---

## Step 12

Enter container.

```bash
docker exec -it <container> bash
```

or

```bash
docker run -it myapp:v1 bash
```

---

## Step 13

Verify filesystem.

```bash
ls -R
```

---

## Step 14

Verify environment variables.

```bash
printenv
```

---

## Step 15

Verify ports.

```bash
docker ps
```

```bash
curl localhost:5000
```

---

## Step 16

Verify application process.

```bash
ps -ef
```

---

## Step 17

Verify listening ports.

```bash
ss -tulpn
```

---

## Dockerfile Troubleshooting Memory Flow

```text
Dockerfile
    ↓
Build
    ↓
Image
    ↓
Container
    ↓
Logs
    ↓
Filesystem
    ↓
ENV
    ↓
Ports
    ↓
Process
*
