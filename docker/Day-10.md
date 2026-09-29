# Docker Complete Notes

---

# 1. Problem Docker Solves

## The "Works on My Machine" Problem

Before Docker, developers used to develop applications on their local machines and then deploy them to QA or Production environments.

Example:

Development Environment:

- Ubuntu 22.04
- Python 3.11
- PostgreSQL 15

Production Environment:

- CentOS
- Python 3.8
- PostgreSQL 12

The application works perfectly on the developer's machine but fails in production due to:

- Package not found
- Dependency mismatch
- Wrong library versions
- Different configurations

This led to the famous statement:

> "It works on my machine."

---

## Traditional Solution

Teams maintained detailed installation guides:

- Install Java 17
- Install Maven 3.8
- Configure PATH
- Install PostgreSQL
- Set environment variables

Even then, people missed steps and deployments failed.

---

## Docker Solution

Docker packages everything required by an application:

- Application Code
- Dependencies
- Libraries
- Runtime
- Configuration

Into a single unit called a:

**Container**

Now developers ship containers instead of only source code.

### Build Once, Run Anywhere

If it works on:

- Laptop

It should work on:

- QA
- Production
- AWS
- Azure
- GCP

Because the environment travels with the application.

---

## Interview Question

### What Problem Does Docker Solve?

Docker solves the "works on my machine" problem by packaging applications together with all dependencies and configurations into containers, ensuring consistent behavior across development, testing, and production environments.

---

# 2. Virtual Machines vs Containers

## Virtual Machine Architecture

```text
Physical Server
      |
Hypervisor
      |
------------------------
| VM1 | VM2 | VM3 |
------------------------
      |
Each VM Contains:
- Guest OS
- Libraries
- Application
```

Each VM has its own complete operating system.

---

## Container Architecture

```text
Physical Server
      |
Host OS
      |
Docker Engine
      |
--------------------------
| C1 | C2 | C3 | C4 |
--------------------------
      |
Application
Dependencies
Libraries
```

Containers share the host OS kernel.

No separate OS exists inside every container.

---

## Comparison

| Feature | VM | Container |
|----------|----------|----------|
| OS Included | Yes | No |
| Startup Time | Minutes | Seconds |
| Size | GBs | MBs |
| Performance | More Overhead | Near Native |
| Resource Usage | High | Low |
| Portability | Medium | High |
| Density per Server | Low | High |

---

## Memory Usage Example

Server RAM:

```text
16 GB
```

VMs:

```text
4 GB per VM
```

Maximum:

```text
4 VMs
```

Containers:

```text
500 MB per container
```

Possible:

```text
30+ Containers
```

---

## Use VMs When

- Different operating systems required
- Strong isolation needed
- Complete OS separation required

Example:

```text
Windows VM
Linux VM
```

---

## Use Containers When

- Microservices
- CI/CD
- Cloud-native applications
- Fast deployments
- Scalability

---

## Interview Question

### Container vs VM

A VM virtualizes hardware and includes a complete guest operating system.

A container virtualizes the operating system, shares the host kernel, and contains only the application and dependencies, making it lightweight and resource-efficient.

---

## Memory Trick

### VM

```text
Virtualizes Hardware
Contains Full OS
Heavy
```

### Container

```text
Virtualizes OS
Shares Host Kernel
Lightweight
```

---

# 3. Understanding Container OS and Kernel

## Linux Container Architecture

```text
Laptop
   |
Linux OS
   |
Linux Kernel
   |
Docker Engine
   |
Containers
```

All containers share the same Linux kernel.

---

## Important Rule

A Linux container requires a Linux kernel because it depends on:

- Linux system calls
- Linux kernel features
- Linux filesystem behavior

---

## Docker on Windows

Most Docker containers are Linux containers.

Windows has:

```text
Windows Kernel
```

Docker Desktop solves this using:

```text
Windows
   |
WSL2
   |
Linux Kernel
   |
Docker Engine
   |
Containers
```

WSL2 provides a real Linux kernel inside Windows.

---

## Docker on macOS

macOS uses:

```text
XNU Kernel
```

Docker Desktop starts a lightweight Linux VM so Linux containers can run.

```text
macOS
   |
Linux VM
   |
Docker
   |
Containers
```

---

## Important Limitation

Docker does NOT:

- Convert Windows apps to Linux
- Convert macOS apps to Windows
- Remove OS-specific dependencies

Example:

```text
Xcode
Apple Frameworks
```

Require macOS.

---

## Interview Question

### Can a Docker container built on macOS run on Windows?

Usually yes, because most Docker images are Linux images.

Docker Desktop provides a Linux environment on both macOS and Windows.

However, applications dependent on macOS-specific frameworks cannot run on Windows.

---

# 4. Docker Architecture

```text
Docker Client (CLI)
          |
          v
Docker Engine
          |
--------------------
|                  |
v                  v
Image          Container
```

---

## Docker Client / CLI

The user-facing component.

Example:

```bash
docker run nginx
```

The CLI sends commands to Docker Engine.

---

## Docker Engine

Also called:

```text
Docker Daemon
```

Process:

```text
dockerd
```

Responsibilities:

- Pull Images
- Create Containers
- Run Containers
- Manage Networking
- Manage Storage

---

## Docker Image

A read-only blueprint used to create containers.

Contains:

- OS libraries
- Application code
- Dependencies
- Runtime
- Configuration

Image = Blueprint

---

## Docker Container

A running instance of an image.

Container = Running Application

---

## Execution Flow

```text
docker run nginx

CLI
 ↓
Engine
 ↓
Image
 ↓
Container
```

---

## Interview Answer

Docker Architecture consists of:

- Docker Client (CLI)
- Docker Engine
- Docker Images
- Docker Containers

The client sends commands to the engine, which manages images and creates containers.

---

# 5. Docker Installation

## Windows Installation

Install:

```text
Docker Desktop
```

It automatically configures:

- WSL2
- Virtualization
- Hyper-V (if required)

---

## Verify Installation

```bash
docker --version
```

Shows Docker CLI version.

---

```bash
docker info
```

Shows Docker Engine information.

---

```bash
docker version
```

Shows:

- Client Version
- Server Version

---

## Verify WSL2

```bash
wsl --status
```

List Linux distributions:

```bash
wsl -l -v
```

Open Linux terminal:

```bash
wsl
```

---

## Docker + WSL2

Docker Desktop → Settings → Resources → WSL Integration

Enable your Linux distribution.

---

## Docker on Linux

Install:

```bash
sudo apt update
sudo apt install docker.io
```

Start service:

```bash
sudo systemctl start docker
```

---

## VS Code Integration

Install:

- Docker Extension (Microsoft)

Provides management for:

- Images
- Containers
- Networks
- Volumes

---

# 6. Image vs Container

## Relationship

```text
Image -> Container

Blueprint -> Running Thing

Class -> Object

Recipe -> Cake
```

---

## Image

Read-only template.

Stored on disk.

View:

```bash
docker images
```

---

## Container

Running instance of an image.

View:

```bash
docker ps
```

---

## Difference

| Feature | Image | Container |
|----------|----------|----------|
| State | Static | Dynamic |
| Read/Write | Read-only | Writable Layer |
| Executes | No | Yes |
| Created By | Build/Pull | Run |
| Multiple Instances | N/A | Yes |

---

# 7. Running Containers

## First Container

```bash
docker run hello-world
```

Execution Flow:

1. Check image locally
2. Download image
3. Create container
4. Start container
5. Print message
6. Exit

---

## Interactive Mode

```bash
docker run -it ubuntu
```

Options:

```text
-i = Interactive
-t = Terminal
```

Exit:

```bash
exit
```

---

## Foreground Mode

```bash
docker run nginx
```

Terminal remains attached.

Stop:

```text
CTRL + C
```

---

## Detached Mode

```bash
docker run -d nginx
```

Runs in background.

---

## Give Container a Name

```bash
docker run -d --name my-nginx nginx
```

---

## Useful Commands

```bash
docker ps
docker ps -a
docker stop
docker start
docker restart
docker rm
```

---

# 8. Container Lifecycle

```text
Image
 ↓
Created
 ↓
Running
 ↓
Paused
 ↓
Running
 ↓
Exited
 ↓
Restarted
 ↓
Removed
```

---

## Commands

Create:

```bash
docker create nginx
```

Run:

```bash
docker run nginx
```

Pause:

```bash
docker pause container
```

Resume:

```bash
docker unpause container
```

Stop:

```bash
docker stop container
```

Delete:

```bash
docker rm container
```

---

# 9. Docker Ports

Applications listen on ports.

Example:

```text
HTTP -> 80
HTTPS -> 443
MySQL -> 3306
```

---

## Port Mapping

```bash
docker run -d -p 8080:80 nginx
```

Format:

```text
HOST_PORT : CONTAINER_PORT
```

Example:

```text
Browser
   |
localhost:8080
   |
Host 8080
   |
Container 80
   |
Nginx
```

---

## Multiple Ports

```bash
docker run -d \
-p 8080:80 \
-p 8443:443 nginx
```

---

## Check Mappings

```bash
docker port container
```

---

## EXPOSE vs -p

EXPOSE:

```dockerfile
EXPOSE 80
```

Documentation only.

Publish:

```bash
-p 8080:80
```

Actually exposes the port.

---

# 10. Linux Commands for Container Verification

Check running containers:

```bash
docker ps
```

Logs:

```bash
docker logs container
```

Host listening ports:

```bash
ss -tulpn
```

Test application:

```bash
curl localhost:8080
```

Enter container:

```bash
docker exec -it container bash
```

Processes:

```bash
ps -ef
```

Listening ports:

```bash
ss -tulpn
```

---

# 11. Container Logs

View logs:

```bash
docker logs container
```

Follow logs:

```bash
docker logs -f container
```

Last 50 lines:

```bash
docker logs --tail 50 container
```

Follow + Tail:

```bash
docker logs -f --tail 20 container
```

Timestamps:

```bash
docker logs -t container
```

---

## Logs vs Exec

Logs:

```bash
docker logs container
```

Read application output.

Exec:

```bash
docker exec -it container bash
```

Enter container.

---

# 12. Docker Inspect

Shows everything Docker knows about an object.

```bash
docker inspect container
```

Provides:

- IP Address
- Image Used
- Ports
- Volumes
- Networks
- Environment Variables
- State

---

## Useful Filters

Container State:

```bash
docker inspect -f '{{.State.Status}}' container
```

IP Address:

```bash
docker inspect -f '{{.NetworkSettings.IPAddress}}' container
```

Image:

```bash
docker inspect -f '{{.Config.Image}}' container
```

---

# 13. Environment Variables

Used to configure containers without changing code.

Run:

```bash
docker run -e APP_ENV=prod nginx
```

Multiple variables:

```bash
docker run \
-e APP_ENV=prod \
-e DB_HOST=mysql \
-e DB_PORT=3306 nginx
```

---

## View Variables

Inside container:

```bash
printenv
```

or

```bash
env
```

---

## Using .env Files

Create:

```text
APP_ENV=prod
DB_HOST=mysql
DB_PORT=3306
```

Run:

```bash
docker run --env-file .env nginx
```

---

## ARG vs ENV

ARG:

```dockerfile
ARG VERSION=1.0
```

Build Time.

ENV:

```dockerfile
ENV APP_ENV=dev
```

Runtime.

---

# 14. Container Filesystem

Every container has its own filesystem.

```text
/bin
/etc
/usr
/var
/tmp
```

---

## Filesystem Layers

```text
Writable Layer
--------------
Image Layer 3
Image Layer 2
Image Layer 1
```

Images are read-only.

Containers add a writable layer.

---

## Copy-On-Write (CoW)

If a container modifies a file:

1. Docker copies file
2. Modification happens in writable layer
3. Original image remains unchanged

---

## Ephemeral Storage

Container storage is temporary.

Deleting the container removes its writable layer.

---

# 15. Docker Images

List:

```bash
docker images
```

Pull:

```bash
docker pull nginx
```

Specific Version:

```bash
docker pull nginx:1.25
```

Search:

```bash
docker search nginx
```

Inspect:

```bash
docker image inspect nginx
```

History:

```bash
docker history nginx
```

Delete:

```bash
docker rmi nginx
```

Tag:

```bash
docker tag nginx nginx:v1
```

Save:

```bash
docker save -o nginx.tar nginx
```

Load:

```bash
docker load -i nginx.tar
```

Build:

```bash
docker build -t myapp:v1 .
```

---

# 16. Docker Container Troubleshooting (9-Step Checklist)

## Step 1

Is container running?

```bash
docker ps
```

---

## Step 2

Does container exist?

```bash
docker ps -a
```

---

## Step 3

Check status

```bash
docker inspect -f '{{.State.Status}}' container
```

---

## Step 4

Check logs

```bash
docker logs container
```

---

## Step 5

Verify image

```bash
docker inspect -f '{{.Config.Image}}' container
```

---

## Step 6

Check port mappings

```bash
docker port container
```

---

## Step 7

Test connectivity

```bash
curl localhost:<port>
```

---

## Step 8

Enter container

```bash
docker exec -it container bash
```

---

## Step 9

Verify internals

```bash
ps -ef
ss -tulpn
env
```

---

## Troubleshooting Flow

```text
docker ps
      ↓
docker ps -a
      ↓
docker inspect
      ↓
docker logs
      ↓
Verify Image
      ↓
Verify Ports
      ↓
curl Test
      ↓
docker exec
      ↓
Check Process + Port + ENV
```

This checklist solves the majority of Docker container issues encountered in development and production environments.
