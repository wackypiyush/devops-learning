# Docker for DevOps – Last Minute Interview Revision

---

# 1. Why Docker?

Problem:

```text
Works on My Machine


Application fails in production due to:

Package not found
Dependency mismatch
Wrong library versions
Different configurations

Docker packages:

Application Code
Dependencies
Libraries
Runtime
Configuration
Environment Variables

Result:

Build Once
Run Anywhere

2. VM vs Container

Use VM when:

Need Windows + Linux on same host
Need strong isolation
Need complete OS separation

Use Containers when:

Microservices
CI/CD
Cloud-native apps
Fast deployments
Scalability

Memory Trick:

VM
=
Virtualizes Hardware

Container
=
Virtualizes Operating System

3. Linux Container Architecture
Laptop
 ↓
Linux OS
 ↓
Linux Kernel
 ↓
Docker Engine
 ↓
Containers


Important:

Containers share Host Kernel


Windows:

WSL2 provides a real Linux Kernel
used by Docker Desktop


macOS:

Docker Desktop starts a lightweight Linux VM

4. Docker Architecture

Docker Client (CLI)

User-facing component


Docker Engine / Docker Daemon

Responsibilities:

Pull Images
Create Containers
Run Containers
Manage Networking
Manage Storage

Flow:

CLI
 ↓
Engine
 ↓
Image
 ↓
Container

5. Image vs Container
Image
=
Blueprint
=
Recipe
=
Class

Container
=
Running Instance
=
Cake
=
Object

6. Container Lifecycle
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


Remember:

docker create
=
Create only

docker run
=
docker create
+
docker start

docker stop
=
Container Exited

7. Core Docker Commands

Installation:

docker --version
docker info
docker version


Linux:

sudo apt update
sudo apt install docker.io
sudo systemctl start docker


Containers:

docker run -it ubuntu

docker ps
docker ps -a

docker stop container
docker start container
docker restart container
docker rm container


Logs:

docker logs container
docker logs -f container
docker logs --tail 50 container


Ports:

docker port container

8. Container Verification Commands
docker ps

docker logs container

curl localhost:8080

docker exec -it container bash

ps -ef

ss -tulpn

9. Docker Container Troubleshooting Flow
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


Useful Inspect Filters:

Container State:

docker inspect -f '{{.State.Status}}' container


Container IP:

docker inspect -f '{{.NetworkSettings.IPAddress}}' container


Image Used:

docker inspect -f '{{.Config.Image}}' container

10. Dockerfile Fundamentals

Without Dockerfiles:

Manual image creation
Hard to reproduce
Inconsistent deployments

Benefits:

Repeatability
Version Control
Automation
Consistency
Same Dockerfile
=
Same Image

Dockerfile Memory Trick
FROM      → Start From
WORKDIR   → Change Directory
COPY      → Copy Files
RUN       → Execute During Build
EXPOSE    → Document Port
CMD       → Execute On Container Start

Important Facts

Without FROM we'd manually install:

OS Libraries
Python
Dependencies
Filesystem

python:3.11-slim contains:

Linux Filesystem
Python Runtime
Python Libraries
pip
Build-Time vs Runtime
ARG = Build Time

ENV = Runtime

RUN = Build Time

CMD = Runtime

CMD vs ENTRYPOINT
CMD
=
Default Command
Can Be Replaced

ENTRYPOINT
=
Main Executable
Arguments Appended


Override ENTRYPOINT:

docker run --entrypoint bash image

Build Commands
docker build -t myapp:v1 .

docker build -f Dockerfile.dev -t myapp:v1 .

docker build --no-cache -t myapp:v1 .

Build Context
Files sent to Docker Engine
during docker build


.dockerignore reduces build context size.

Flask in Containers

Use:

host="0.0.0.0"


Not:

host="localhost"


Reason:

Docker can forward traffic
from outside container

WORKDIR
WORKDIR /app


Benefits:

Organized files
Avoids using /

Equivalent:

mkdir /app
cd /app

EXPOSE
EXPOSE 5000


Means:

Application listens on port 5000


Important:

EXPOSE = Documentation

-p = Actual Access

Container Rule
A container lives as long as
its main process lives.

11. Dockerfile Troubleshooting Flow
Dockerfile
 ↓
Build
 ↓
Image
 ↓
Container
 ↓
Application


Steps:

ls
ls -l Dockerfile

docker build -t myapp:v1 .

cat requirements.txt

docker images

docker image inspect myapp:v1

docker run myapp:v1

docker logs <container>

docker exec -it <container> bash

printenv

curl localhost:5000

ps -ef

ss -tulpn

12. Docker Networking
Docker Network = Virtual LAN


Network Types:

Bridge
Host
None
Overlay
Macvlan


Most important:

Bridge
Host
None

Host Network

Advantages:

No NAT
No Port Mapping
Better Performance


Disadvantage:

Port Conflict

Custom Networks Benefits
Automatic DNS Resolution
Better Isolation
Easier Container Communication

Create Network:

docker network create my-network


Inspect:

docker network inspect bridge

docker network inspect my-network


Attach Existing Container:

docker network connect my-network my-container


Delete:

docker network rm my-network


List Networks:

docker network ls

docker0
Linux bridge created by Docker

Acts like:
- Virtual Switch
- Gateway


Default subnet:

172.17.0.0/16


Default gateway:

172.17.0.1

Network Namespace
Container's private networking world


Contains:

IP Address
Interface
Routes
Hostname

Each container has its own:

eth0


No conflict due to separate namespaces.

Docker DNS

Never depend on:

Container IP


Use:

Container Name


Verify DNS:

getent hosts mysql

ping mysql


Verify Connectivity:

telnet mysql 3306

curl http://frontend

Localhost Trap

Wrong:

DB_HOST=localhost


Correct:

DB_HOST=mysql


Remember:

localhost = myself

Easy Rule

Outside Docker:

localhost:<published-port>

Needs:
-p


Inside Docker:

container-name:container-port


Example:

mysql:3306
redis:6379
backend:8080
flask:5000

13. Docker Compose

Modern:

compose.yaml


Old:

docker-compose.yml


Compose:

Run Multi-Container Applications
using one YAML file


Defines:

Services
Networks
Volumes
Environment Variables
Port Mappings
Common Commands
docker compose up

docker compose up -d

docker compose up --build

docker compose logs

docker compose down

Compose Down
docker compose down


Removes:

Containers
Networks

Keeps:

Volumes
Restart Policies
Policy	Crash	Reboot	Manual Stopno	No Restart	No Restart	Stopped
always	Restart	Restart	Starts Again
on-failure	Restart On Error	Depends	Stopped
unless-stopped	Restart	Restart	Remains Stopped
Smallest Compose File
services:
  nginx:
    image: nginx


Creates:

One Container
One Network
Important
YAML is indentation-sensitive

14. Docker Storage
Docker Storage
│
├── Writable Layer
├── Named Volume
├── Bind Mount
└── tmpfs

Storage Selection Guide
Jenkins Data
→ Named Volume

Database Data
→ Named Volume

Development Code
→ Bind Mount

Temporary Cache
→ tmpfs

Temporary Container Data
→ Writable Layer

Named Volume
Docker-managed persistent storage


Commands:

docker volume create mydata

docker volume ls

docker volume inspect mydata

docker volume rm mydata


Mount:

docker run -v mydata:/data ubuntu bash

Bind Mount
Host Directory ↔ Container Directory


Development Workflow:

Edit Code
 ↓
Container Sees Changes
 ↓
No Rebuild Required


Golden Rule:

HOST FOLDER WINS

tmpfs
Temporary Memory-backed Storage


Example:

docker run \
--tmpfs /app/cache:size=64m \
nginx


Use Cases:

Cache
Temp Files
Scratch Space
Sensitive Temporary Data

Important:

Data disappears
when container/mount disappears

Writable Layer vs tmpfs
Feature	Writable Layer	tmpfsStorage	Disk	RAM
Persistence	Until container removal	Lost immediately
Speed	Slower	Faster
Use Case	Runtime writes	Temporary cache
15. Permissions

Important:

Container ≠ Separate Permission Universe


Bind mounts use:

Host Filesystem Permissions

Useful Commands

Host:

id

ls -ln <dir>

ls -ld <dir>


Container:

docker exec <container> id

Permission Denied Troubleshooting
Permission Denied
      ↓
Check Container User
      ↓
Check UID/GID
      ↓
Check Directory Ownership
      ↓
Check Filesystem Permissions
      ↓
Fix Ownership/Permissions

Run With Matching UID/GID
docker run \
-u $(id -u):$(id -g)

USER
USER 1000:1000


Runs processes as:

UID 1000
GID 1000


instead of root.

Read-Only Mount
-v /data:/app/data:ro


Benefits:

Security
Protection
Isolation
16. Docker Security

Containers interact with:

Kernel
Filesystem
Network
Processes
CPU
Memory
Linux Capabilities

Important:

VM → Own Kernel

Container → Shares Host Kernel

Root Inside Container

Default:

UID 0


Risks:

Privilege Escalation
Root-owned Host Files
Excess Permissions
Non-Root Options

Runtime:

docker run -u 1000:1000


Dockerfile:

USER appuser


Compose:

user: "1000:1000"

Linux Capabilities

Examples:

NET_ADMIN

NET_RAW

CHOWN

SETUID

SETGID


Docker default:

Limited Capabilities
(not full root powers)

Containers

Normal:

Restricted


Privileged:

--privileged


Gives:

Broad Host Access
Almost All Capabilities


Avoid whenever possible.

Read-Only Root Filesystem
docker run --read-only nginx


Benefits:

Security
Consistency
Compliance
Secrets

Do NOT store secrets in:

ENV variables


Use:

AWS Secrets Manager
AWS Parameter Store
HashiCorp Vault
Kubernetes Secrets
CI/CD Secret Stores
Image Security
Trusted Images
Signed Images
Vulnerability Scanning
Minimal Images
Updated Images
No Secrets
Least Privilege

Scanning Tools:

Trivy ⭐
Anchore
Clair
Resource Limits
docker run --memory=128m nginx

docker run --cpus=0.5 nginx

docker run --pids-limit=100 nginx

Secure Container Checklist
Non-root user
Minimal capabilities
Read-only filesystem
Secret manager
Trusted image
Vulnerability scan
Resource limits
17. Image Optimization

Docker Image:

Multiple Read-Only Layers


Benefits:

Caching
Layer Reuse
Faster Builds
Efficient Storage
Build Cache
Previously built layers
reused in future builds

pip Cache
pip install --no-cache-dir


Prevents storing:

Downloaded Pip Cache


inside image.

Image Inspection

History:

docker history myapp


Shows:

Layers
Commands
Layer Sizes

Inspect:

docker image inspect myapp


Shows:

Metadata
Size
Env
Ports
Working Directory
Image Size Matters

Reasons:

Faster Pulls
Faster Deployments
Less Storage
Better Security
Faster CI/CD
Image Size Commands
docker image ls

docker images

docker system df

docker system df -v

Build Cache Storage

Stored on:

Docker Host


Not inside image.

Cleanup:

docker builder prune

Optimization Rules
Start With Slim

If Build Fails
 ↓
Install Only Missing Packages


Recommended Pattern:

1. Base Image

2. Copy Dependency Files

3. Install Dependencies

4. Copy Application Code

5. Start Application

What Gets Pushed?

✅ Image Layers

Contains:

Source Code
Dependencies
Config
Artifacts
What Does NOT Get Pushed?
Dockerfile
.git
Build Cache
Containers
Volumes
Logs
Runtime State
Multi-Stage Builds

Golden Rule:

Build With Heavy Tools

Run With Lightweight Image

Copy Only What Is Needed To Run


Benefits:

Smaller Images
Better Security
Faster Pulls
Faster Deployments

Limitations:

More Complex
Harder Debugging
COPY Mistakes
Overkill For Tiny Apps

