# Docker Day 3 Notes
# Container Filesystem, Volumes, Networks & Docker Compose

---

# 1. Container Filesystem

## Does a Container Have Its Own Filesystem?

Yes.

Every container gets its own isolated filesystem.

Example:

```bash
docker run -it ubuntu bash
```

Inside the container:

```bash
ls /
```

You will see:

```text
bin
etc
usr
var
tmp
home
root
```

It looks like a complete Linux machine.

---

## Where Does the Container Filesystem Come From?

Remember:

```text
Dockerfile
     ↓
Image
     ↓
Container
```

The Image already contains a filesystem.

When Docker creates a container, it adds a writable layer on top of the image layers.

---

## Image Layers + Container Layer

```text
Container Writable Layer
------------------------
Application Layer
------------------------
Dependency Layer
------------------------
Base OS Layer
```

Example:

```dockerfile
FROM ubuntu

RUN apt install nginx

COPY app.py .
```

Layers:

```text
Layer 1 → Ubuntu
Layer 2 → Nginx
Layer 3 → Application Files
Layer 4 → Writable Container Layer
```

---

## Copy-On-Write (CoW)

Docker images are read-only.

When a container modifies a file:

```text
/app/config.txt
```

Docker:

1. Copies the file into the writable layer
2. Modifies the copied file
3. Leaves the original image untouched

Result:

```text
Image      → Original File
Container  → Modified Copy
```

---

## Ephemeral Storage

Container storage is:

```text
Ephemeral
```

Meaning:

```text
Temporary
```

Lifecycle:

```text
Container Created
      ↓
Data Written
      ↓
Container Deleted
      ↓
Data Lost
```

---

## What is Container Filesystem?

A container filesystem consists of:

```text
Read-only Image Layers
           +
Writable Container Layer
```

The writable layer exists only for that container and is deleted when the container is removed.

---

# 2. Docker Volumes

## Why Do We Need Volumes?

Container storage is temporary.

Example:

```text
MySQL Container
       ↓
Database Records Stored
       ↓
Container Deleted
       ↓
Database Lost
```

To solve this problem Docker provides Volumes.

---

## What is a Volume?

A Docker Volume is storage managed by Docker that exists independently of containers.

Think:

```text
Container = Temporary
Volume    = Persistent
```

---

## Architecture

Without Volume:

```text
Container
     |
Data
     |
Container Deleted
     |
Data Lost
```

With Volume:

```text
Container
     |
Volume
     |
Container Deleted
     |
Volume Still Exists
```

---

## Create Volume

```bash
docker volume create mydata
```

---

## List Volumes

```bash
docker volume ls
```

---

## Inspect Volume

```bash
docker volume inspect mydata
```

---

## Delete Volume

```bash
docker volume rm mydata
```

---

## Mount Volume Into Container

```bash
docker run -it \
-v mydata:/data \
ubuntu bash
```

Meaning:

```text
Volume mydata
      ↓
Mounted At
      ↓
/data inside container
```

---

## Volume Lifecycle

```text
Create Volume
      ↓
Mount Volume
      ↓
Write Data
      ↓
Delete Container
      ↓
Volume Remains
```

---

## Named Volumes

Create:

```bash
docker volume create mysql-data
```

Use:

```bash
docker run -d \
-v mysql-data:/var/lib/mysql \
mysql
```

Now database data survives container recreation.

This is how databases are typically deployed.

---

## Anonymous Volumes

Example:

```bash
docker run -v /data nginx
```

Docker creates a random volume name.

Example:

```text
6d8c3f9b...
```

Hard to manage.

Not recommended.

Use named volumes instead.

---

# 3. Bind Mount vs Volume

## Docker Volume

Docker manages storage.

```bash
-v myvolume:/data
```

Architecture:

```text
Docker
   |
Volume
   |
Container
```

---

## Bind Mount

Uses an actual folder from the host machine.

```bash
-v /home/piyush/data:/data
```

Architecture:

```text
Host Folder
      |
Container
```

---

## Why Are Bind Mounts Useful?

Development workflow:

```text
Edit Code On Laptop
        ↓
Container Immediately Sees Changes
```

No image rebuild required.

---

# Common Bind Mount Problem

## Scenario

Image contains:

```text
/app
 ├── app.py
 ├── requirements.txt
 └── config.py
```

created using:

```dockerfile
COPY . .
```

Container works correctly.

---

## Bind Mount Added

```yaml
services:
  app:
    volumes:
      - .:/app
```

Meaning:

```text
Current Folder
      ↓
Mounted On
      ↓
Container /app
```

---

## Problem

Host folder:

```text
empty-folder/
```

contains nothing.

Docker mount:

```bash
-v ./empty-folder:/app
```

Container now sees:

```text
/app
(empty)
```

Application fails:

```text
app.py missing
requirements.txt missing
```

---

## Why?

Bind mounts DO NOT merge content.

They completely overlay the target directory.

Before:

```text
/app
 ├── app.py
 ├── requirements.txt
 └── config.py
```

After:

```text
Host Folder
   (empty)
      ↓
Mounted On /app
```

Container sees:

```text
/app
(empty)
```

Image files still exist inside the image but are hidden by the bind mount.

---

## Golden Rule

```text
Host Folder Wins
```

Whatever exists on the host becomes visible.

Whatever existed in the image becomes hidden.

---

## Safe Usage Rule

Before using:

```yaml
volumes:
  - .:/app
```

Verify the host directory already contains:

```text
app.py
requirements.txt
templates/
static/
```

---

## Good Example

Host:

```text
flask/
├── app.py
├── requirements.txt
├── templates/
└── static/
```

Image:

```text
/app
├── app.py
├── requirements.txt
├── templates/
└── static/
```

Run:

```bash
docker run \
-v $(pwd):/app \
flask-app
```

OR

```yaml
services:
  flask:
    build: .
    volumes:
      - .:/app
```

Works perfectly because the host folder contains all required files.

---

## Memory Trick

```text
COPY
 ↓
Puts Files INTO Image

Bind Mount
 ↓
Puts Host Folder OVER Image
```

---

## Interview Question

### Why did files disappear after adding a bind mount?

Because bind mounts override the target directory inside the container. Docker does not merge contents. The mounted host directory hides files that already exist in the image.

---

# 4. Docker Networks

## Why Do We Need Networks?

Containers rarely run alone.

Example:

```text
Frontend Container
        ↓
Backend Container
        ↓
Database Container
```

Containers must communicate.

Docker Networks provide communication channels between containers.

Think:

```text
Docker Network = Virtual LAN
```

for containers.

---

## Network Drivers

Docker provides:

```text
Bridge
Host
None
Overlay
Macvlan
```

Interview focus:

```text
Bridge
Host
None
```

---

# 1. Bridge Network (Default)

Default Docker network.

List networks:

```bash
docker network ls
```

Every container joins bridge unless another network is specified.

---

## Architecture

```text
Container A
      |
Bridge Network
      |
Container B
```

Docker acts like a virtual switch.

---

## Inspect Bridge Network

```bash
docker network inspect bridge
```

Shows:

- Connected Containers
- Subnet
- Gateway
- Network Configuration

---

## Create Custom Bridge Network

```bash
docker network create my-network
```

Verify:

```bash
docker network ls
```

---

## Containers On Same Network

Container 1:

```bash
docker run -d \
--name web \
--network my-network \
nginx
```

Container 2:

```bash
docker run -it \
--network my-network \
ubuntu bash
```

Inside Container 2:

```bash
ping web
```

Docker automatically resolves container names.

---

## Why Use Custom Networks?

Benefits:

- Automatic DNS Resolution
- Better Isolation
- Easier Container Communication

Instead of:

```text
172.17.0.2
```

use:

```text
mysql
backend
web
```

---

# 2. Host Network

Container directly shares host networking.

```bash
docker run --network host nginx
```

---

## Normal Network

Requires:

```bash
-p 8080:80
```

```text
Host 8080
      ↓
Container 80
```

---

## Host Network

```text
Host Network
      |
Container
```

Container uses host ports directly.

No port mapping required.

---

## Advantages

```text
Better Performance
No NAT Translation
```

---

## Limitation

Port conflicts.

If host already uses:

```text
Port 80
```

container cannot start.

---

# 3. None Network

```bash
docker run --network none ubuntu
```

Container gets:

```text
No Network Access
```

Useful for:

- Security
- Offline Processing
- Isolated Workloads

---

## Network Commands

Inspect container IP:

```bash
docker inspect my-container
```

or

```bash
docker inspect -f '{{.NetworkSettings.IPAddress}}' my-container
```

---

Connect existing container:

```bash
docker network connect my-network my-container
```

---

Disconnect:

```bash
docker network disconnect my-network my-container
```

---

Delete network:

```bash
docker network rm my-network
```

---

## Bridge vs Host vs None

| Feature | Bridge | Host | None |
|----------|---------|---------|---------|
| Default Network | Yes | No | No |
| Container Isolation | Yes | No | Full |
| Port Mapping Needed | Yes | No | N/A |
| Container Communication | Yes | Limited | No |
| Typical Use | Most Apps | High Performance | Secure Isolation |

---

## What is a Docker Network?

A Docker Network is a virtual networking layer that enables communication between containers, the host machine, and external systems.

---

# 5. Docker Compose

## What is Docker Compose?

Docker Compose allows you to define and run multi-container applications using a single YAML file.

---

## Without Compose

```bash
docker run flask
docker run mysql
docker run redis
```

---

## With Compose

```text
compose.yaml
      ↓
docker compose up
      ↓
-----------------------
| Flask | MySQL | Redis |
-----------------------
```

---

## Install Docker Compose

Modern Docker Desktop already includes Compose.

Verify:

```bash
docker compose version
```

---

## Important Commands

Start:

```bash
docker compose up
```

Background:

```bash
docker compose up -d
```

Logs:

```bash
docker compose logs
```

Single Service Logs:

```bash
docker compose logs flask-app
```

Live Logs:

```bash
docker compose logs -f
```

Stop Application:

```bash
docker compose down
```

Stops:

- Containers
- Networks

created by Compose.

---

## Rebuild After Changes

```bash
docker compose up --build
```

Equivalent:

```text
Rebuild Images
+
Start Containers
```

---

## Compose Automatically Creates

```text
Network
```

All services join the same network.

Docker DNS resolves service names automatically.

---

## Dockerfile vs Docker Compose

Dockerfile:

```text
Build One Image
```

Compose:

```text
Run Entire Application Stack
```

---

# 6. compose.yaml

## What is a Compose File?

A Compose file is a YAML file that defines:

- Services
- Networks
- Volumes
- Environment Variables
- Port Mappings

File:

```text
compose.yaml
```

Older name:

```text
docker-compose.yml
```

---

## Basic Structure

```yaml
services:
  nginx:
    image: nginx
```

---

# Important Compose Keywords

## 1. services

Defines containers.

```yaml
services:
  flask-app:
```

Rule:

```text
One Service = One Container
```

---

## 2. build

Build image using Dockerfile.

```yaml
build: .
```

Equivalent:

```bash
docker build .
```

Custom Dockerfile:

```yaml
build:
  context: .
  dockerfile: Dockerfile.dev
```

---

## 3. image

Use existing image.

```yaml
image: nginx
```

Equivalent:

```bash
docker pull nginx
```

---

## 4. container_name

```yaml
container_name: flask-container
```

Assign fixed name.

---

## 5. ports

```yaml
ports:
  - "5000:5000"
```

Equivalent:

```bash
docker run -p 5000:5000
```

---

## 6. environment

```yaml
environment:
  APP_ENV: production
  DB_HOST: mysql
```

Equivalent:

```bash
docker run -e APP_ENV=production
```

---

## 7. env_file

```yaml
env_file:
  - .env
```

Example:

```text
APP_ENV=production
DB_HOST=mysql
DB_PORT=3306
```

---

## 8. volumes

```yaml
volumes:
  - mydata:/data
```

Persistent storage.

---

## 9. depends_on

```yaml
depends_on:
  - mysql
```

Meaning:

```text
Start mysql first
Then flask-app
```

Important:

```text
Does NOT mean MySQL is ready.
```

Container may still be initializing.

Possible error:

```text
Connection Refused
```

---

## 10. restart

Restart policy.

```yaml
restart: always
```

### Options

#### no

```text
Container crashes
      ↓
Docker does nothing
```

#### always

```text
Container crashes
      ↓
Docker restarts it
```

Also starts after Docker daemon reboot.

#### on-failure

Restart only when exit code is non-zero.

Example:

```text
Exit Code 1 → Restart
Exit Code 0 → No Restart
```

#### unless-stopped

Automatically restarts unless you explicitly stopped it.

Docker remembers manual stop.

---

### Restart Policy Comparison

| Policy | Crash | Reboot | Manual Stop |
|----------|----------|----------|----------|
| no | No Restart | No Restart | Stopped |
| always | Restart | Restart | Starts Again |
| on-failure | Restart On Error | Depends | Stopped |
| unless-stopped | Restart | Restart | Remains Stopped |

---

## 11. command

Overrides Dockerfile CMD.

```yaml
command: python test.py
```

Compose command wins.

---

## 12. Compose Network

Compose automatically creates a network.

All services can communicate using:

```text
Service Names
```

Example:

```text
DB_HOST=mysql
```

---

# Flask + MySQL Example

```yaml
services:

  flask-app:
    build: .

    ports:
      - "5000:5000"

    environment:
      DB_HOST: mysql
      DB_USER: root
      DB_PASSWORD: admin123

    depends_on:
      - mysql

  mysql:
    image: mysql:8

    environment:
      MYSQL_ROOT_PASSWORD: admin123

    volumes:
      - mysql-data:/var/lib/mysql

volumes:
  mysql-data:
```

---

# 7. Common Compose Scenarios

## Smallest Compose File

```yaml
services:
  nginx:
    image: nginx
```

Creates:

- One Container
- One Network

Problem:

```text
Browser cannot access nginx
```

No ports published.

---

## Image Only

```yaml
services:
  nginx:
    image: nginx
```

Pull existing image.

No build.

---

## Build Only

```yaml
services:
  app:
    build: .
```

Build image from Dockerfile and run it.

---

## Custom Dockerfile

```yaml
build:
  context: .
  dockerfile: Dockerfile.dev
```

Useful for:

- Development
- Testing
- Production

---

## Multiple Ports

```yaml
ports:
  - "8080:80"
  - "8443:443"
```

---

## Service Without Ports

```yaml
services:
  mysql:
    image: mysql
```

Other containers can access it.

Host machine cannot.

---

## Two Services

```yaml
services:

  backend:
    build: .

  mysql:
    image: mysql
```

Backend connects to:

```text
mysql
```

using service name.

---

## Volume Example

```yaml
services:

  mysql:
    image: mysql

    volumes:
      - mysql-data:/var/lib/mysql

volumes:
  mysql-data:
```

---

## Bind Mount Example

```yaml
services:

  app:
    build: .

    volumes:
      - .:/app
```

Used mainly for development.

---

## Container Name Conflict

```yaml
container_name: flask-container
```

Error:

```text
Container name already in use
```

---

## YAML Indentation Error

Wrong:

```yaml
services:
app:
image: nginx
```

Error:

```text
YAML Parsing Error
```

YAML is indentation-sensitive.

---

# 8. Docker Compose Troubleshooting Flow

## Step 1 - Validate Configuration

```bash
docker compose config
```

---

## Step 2 - Start Application

```bash
docker compose up
```

---

## Step 3 - Check Containers

```bash
docker compose ps
```

---

## Step 4 - Check Logs

```bash
docker compose logs
```

---

## Step 5 - Enter Container

```bash
docker compose exec app bash
```

---

## Step 6 - Verify Service Connectivity

```bash
ping mysql
```

or

```bash
curl backend:5000
```

---

# Docker Compose Memory Flow

```text
Compose File
      ↓
Services
      ↓
Network
      ↓
Volumes
      ↓
Containers
      ↓
Application
```

# Day 3 Golden Rules

```text
Container Filesystem = Temporary

Volume = Persistent Storage

Host Folder Wins In Bind Mounts

Bridge = Default Network

Compose = Run Multiple Containers

One Service = One Container

depends_on ≠ Service Ready

Dockerfile Builds Images
Compose Runs Applications
```
