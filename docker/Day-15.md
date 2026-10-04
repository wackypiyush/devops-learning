
# Docker Storage — Volumes, Bind Mounts & tmpfs

Docker containers are **ephemeral by default**.

Any data written to a container's writable layer can disappear when the container is removed.

Docker provides different storage mechanisms to persist or share data:

```text
Docker Storage
│
├── Container Writable Layer
│      └── Temporary / tied to container
│
├── Named Volume
│      └── Docker-managed persistent storage
│
├── Bind Mount
│      └── Host filesystem ↔ Container
│
└── tmpfs Mount
       └── Temporary storage in memory
```

---

# 1. What is a Named Volume?

A **Docker volume** is a storage mechanism that allows data to persist independently of a container.

A **named volume** is a volume with a human-readable name chosen by the user.

Example:

```bash
docker volume create mydata
```

Here:

```text
mydata = volume name
```

Docker manages the volume's storage and lifecycle.

## Why Use Named Volumes?

### Persistence

Data survives:

* Container restarts
* Container removal
* Recreating a container

As long as the volume itself is not deleted.

### Reusability

The same volume can be mounted into different containers.

### Clarity

A meaningful name such as:

```text
mysql-data
app-data
jenkins-data
```

is easier to understand than an automatically generated anonymous volume name.

### Docker Management

Docker provides commands to:

```bash
docker volume ls
docker volume inspect
docker volume create
docker volume rm
docker volume prune
```

### Important

A named volume is **not automatically portable between Docker hosts**.

If you want to move a volume to another server, you generally need to back up/restore the data or use an appropriate volume driver/storage system.

---

# 2. Creating and Using a Named Volume

## Create a Volume

```bash
docker volume create mydata
```

Verify:

```bash
docker volume ls
```

---

## Run a Container Using the Volume

```bash
docker run -d \
  --name mycontainer \
  -v mydata:/app/data \
  nginx
```

Here:

```text
mydata       → Docker volume
/app/data    → mount point inside the container
```

The volume is mounted at:

```text
Container
└── /app/data
       ↑
       │
   mydata volume
```

---

## Inspect the Volume

```bash
docker volume inspect mydata
```

This displays information such as:

* Volume name
* Driver
* Mountpoint
* Labels
* Scope

For the default local volume driver on Linux, the mountpoint is commonly under:

```text
/var/lib/docker/volumes/
```

However, do **not** assume this path is universal. The actual location depends on the Docker environment and volume driver.

---

## List Volumes

```bash
docker volume ls
```

---

# 3. Sharing Data Between Containers

Multiple containers can use the same named volume.

### First Container — Write Data

```bash
docker run -it \
  --name writer \
  -v sharedvol:/data \
  busybox sh
```

Inside the container:

```bash
echo "Hello from writer" > /data/message.txt
```

Exit:

```bash
exit
```

---

### Second Container — Read Data

```bash
docker run -it \
  --name reader \
  -v sharedvol:/data \
  busybox sh
```

Inside the container:

```bash
cat /data/message.txt
```

Output:

```text
Hello from writer
```

The data exists in the volume, not in either container's writable layer.

This can be useful when multiple containers need access to shared:

* Application data
* Logs
* Configuration
* Uploaded files

However, applications sharing the same files must still handle concurrent access correctly.

---

# 4. Removing Volumes

## Remove a Specific Volume

```bash
docker volume rm mydata
```

Once the volume is deleted, the data stored in it is deleted as well.

---

## Remove Unused Volumes

```bash
docker volume prune
```

This removes unused local volumes.

Be careful:

```text
Volume prune
     ↓
Unused volumes deleted
     ↓
Data in those volumes is lost
```

Always check what you are deleting before running destructive cleanup commands.

---

# 5. Understanding `-v`

The `-v` / `--volume` option is used to mount storage into a container.

General syntax:

```bash
docker run -v <source>:<target> <image>
```

The meaning of `<source>` depends on what you provide.

### Named Volume

```bash
-v mydata:/app/data
```

Here:

```text
mydata = Docker volume
/app/data = container path
```

### Bind Mount

```bash
-v /home/piyush/appdata:/app/data
```

Here:

```text
/home/piyush/appdata = host path
/app/data             = container path
```

---

# 6. `--mount` — More Explicit Syntax

Docker also supports the `--mount` option.

For a named volume:

```bash
docker run -d \
  --name mycontainer \
  --mount type=volume,source=mydata,target=/app/data \
  nginx
```

For a bind mount:

```bash
docker run -d \
  --name webapp \
  --mount type=bind,source=/home/piyush/appdata,target=/usr/share/nginx/html \
  nginx
```

## `-v` vs `--mount`

Both can be used for container storage.

```text
-v
└── Shorter and convenient

--mount
└── More explicit and easier to read
```

For learning and complex configurations, `--mount` is often easier to understand because the mount type is explicitly specified.

---

# 7. Bind Mount

A **bind mount** maps an existing file or directory from the host filesystem into a container.

Example:

```bash
docker run -d \
  --name webapp \
  -v /home/piyush/appdata:/usr/share/nginx/html \
  nginx
```

Here:

```text
Host
/home/piyush/appdata
        │
        │ Bind Mount
        ↓
Container
/usr/share/nginx/html
```

Changes made to the mounted files are visible from the other side.

---

# 8. Why Use Bind Mounts?

Bind mounts are especially useful during development.

Example:

```text
VS Code
   ↓
Host source code
   ↓
Bind Mount
   ↓
Container
```

You can edit source code on the host and immediately see the changes inside the container.

Common use cases:

* Local development
* Live code editing
* Testing
* Sharing configuration files
* Sharing scripts

---

# 9. Important Bind Mount Behavior — Mounts Obscure Existing Data

A bind mount does **not merge** the host directory with the existing directory inside the image.

Instead, the mounted directory **obscures** whatever was already present at the target path.

Example:

Suppose the image contains:

```text
/usr/share/nginx/html/
├── index.html
└── 404.html
```

Now run:

```bash
docker run \
  -v /home/piyush/appdata:/usr/share/nginx/html \
  nginx
```

If the host directory contains:

```text
/home/piyush/appdata/
└── mypage.html
```

Inside the container you will see:

```text
/usr/share/nginx/html/
└── mypage.html
```

The image's original files are still present in the underlying container filesystem, but they are **hidden by the mount** while the mount exists.

This is why you may sometimes see:

```text
"Why did the files that came with my image disappear?"
```

The files were not merged with the host directory. The mount is covering them.

---

# 10. Named Volume vs Bind Mount

| Feature              | Named Volume                                                              | Bind Mount                                       |
| -------------------- | ------------------------------------------------------------------------- | ------------------------------------------------ |
| Managed by           | Docker                                                                    | User/host filesystem                             |
| Source               | Docker volume                                                             | Host path                                        |
| Example              | `mydata:/data`                                                            | `/home/piyush/data:/data`                        |
| Portability          | More portable configuration, but data still needs migration between hosts | Host-path dependent                              |
| Best use             | Persistent application data                                               | Development/source code                          |
| Host path management | Docker manages it                                                         | User manages it                                  |
| Permissions          | Still affected by container user/UID/GID                                  | Directly affected by host filesystem permissions |
| Performance          | Depends on environment/driver                                             | Depends on host filesystem and environment       |
| Direct host access   | Not normally used directly                                                | Yes                                              |

### Simple Rule

```text
Application data
       ↓
Named Volume

Source code / development files
       ↓
Bind Mount
```

---

# 11. Named Volume Example — Database

A database is a common use case for a named volume.

Example:

```bash
docker volume create mysql-data
```

Then:

```bash
docker run -d \
  --name mysql \
  -v mysql-data:/var/lib/mysql \
  mysql
```

The database files are stored in:

```text
mysql-data
```

rather than being tied to the lifecycle of the MySQL container.

If the container is removed:

```bash
docker rm mysql
```

the volume remains:

```text
mysql-data
```

A new container can mount the same volume.

---

# 12. Container Removal vs Volume Removal

These are two different operations.

### Remove Container

```bash
docker rm mysql
```

This removes the container.

The named volume:

```text
mysql-data
```

normally remains.

### Remove Volume

```bash
docker volume rm mysql-data
```

This removes the volume and its stored data.

Therefore:

```text
docker rm mysql
       ↓
Container deleted
       ↓
Volume remains


docker volume rm mysql-data
       ↓
Volume deleted
       ↓
Persistent data deleted
```

---

# 13. Docker Compose — `down` vs `down -v`

Suppose `compose.yaml` contains:

```yaml
services:
  mysql:
    image: mysql
    volumes:
      - mysql-data:/var/lib/mysql

volumes:
  mysql-data:
```

## `docker compose down`

```bash
docker compose down
```

By default, this removes:

```text
Containers
Networks
```

The named volume declared in the Compose file remains.

Therefore:

```text
docker compose down
        ↓
Containers removed
Networks removed
Volume remains
Data remains
```

---

## `docker compose down -v`

```bash
docker compose down -v
```

The `-v` / `--volumes` option removes named volumes declared in the Compose file and anonymous volumes attached to containers.

Therefore:

```text
docker compose down -v
        ↓
Containers removed
Networks removed
Volumes removed
        ↓
Persistent data deleted
```

### Important

Use:

```bash
docker compose down -v
```

carefully when working with databases.

---

# 14. Permissions and UID/GID

Containers have users and groups identified by:

```text
UID = User ID
GID = Group ID
```

A common mistake is assuming:

```text
Container = separate permissions universe
```

This is not always true.

When using bind mounts, the underlying host filesystem permissions still matter.

---

## Example

Suppose the host directory is:

```text
/home/piyush/mount-test
```

and is owned by:

```text
UID 1000
GID 1000
```

If a process inside the container runs as another UID and tries to write to the directory, it may receive:

```text
Permission denied
```

The important thing is the **numeric UID/GID and filesystem permissions**, not simply the username.

---

# 15. Check UID/GID

On the host:

```bash
id
```

Example:

```text
uid=1000(piyush) gid=1000(piyush)
```

Check numeric ownership:

```bash
ls -ln ~/mount-test
```

Inside a container:

```bash
docker exec <container> id
```

Example:

```text
uid=1000 gid=1000
```

---

# 16. Troubleshooting Permission Problems

If a container cannot read or write to a mounted directory:

### Step 1 — Check the mount

```bash
docker inspect <container>
```

Look under:

```text
Mounts
```

---

### Step 2 — Check the container user

```bash
docker exec <container> id
```

---

### Step 3 — Check host ownership

```bash
ls -ln <host-directory>
```

---

### Step 4 — Check permissions

```bash
ls -ld <host-directory>
```

---

### Step 5 — Check whether the mount is read-only

Look for:

```text
ro
```

or:

```text
RW: false
```

in the mount configuration.

---

# 17. Running a Container With a Specific UID/GID

You can specify the user for a container process using:

```bash
-u
```

Example:

```bash
docker run --rm \
  -u $(id -u):$(id -g) \
  -v ~/mount-test:/data \
  alpine \
  sh -c "id && touch /data/test.txt"
```

Here:

```bash
$(id -u)
```

returns the current user's UID.

And:

```bash
$(id -g)
```

returns the current user's GID.

For example:

```text
1000:1000
```

This can help when working with bind mounts and development environments.

---

# 18. Fixing Ownership

For a named volume, you can adjust ownership from a temporary container.

Example:

```bash
docker run --rm \
  -v mydata:/app/data \
  alpine \
  chown -R 1000:1000 /app/data
```

This changes the ownership of files inside the volume to:

```text
UID 1000
GID 1000
```

Whether this is the correct solution depends on which user your application actually runs as.

---

# 19. Dockerfile `USER`

You can specify which user a container process should run as.

Example:

```dockerfile
FROM alpine

RUN addgroup -g 1000 appgroup && \
    adduser -D -u 1000 -G appgroup appuser

USER 1000:1000
```

Now subsequent container processes run as that user by default.

Using a non-root user is generally preferable when the application does not require root privileges.

---

# 20. Read-Only Mounts

By default, volume and bind mounts are read-write.

You can make a mount read-only by adding:

```text
:ro
```

Example:

```bash
docker run -d \
  --name webapp \
  -v /home/piyush/appdata:/usr/share/nginx/html:ro \
  nginx
```

Now the container can read the files but cannot modify them through that mount.

---

## Why Use Read-Only Mounts?

### Security

Prevents the container from modifying mounted files.

### Protection

Useful for configuration files or static content.

### Isolation

Useful when a container only needs to consume data.

Example:

```text
Host configuration
       ↓
Read-only mount
       ↓
Container
       ↓
Can read
Cannot modify
```

---

# 21. tmpfs Mount

A **tmpfs mount** is temporary storage backed primarily by memory rather than persistent disk storage.

Example:

```bash
docker run -d \
  --name cachetest \
  --tmpfs /app/cache:rw,size=64m \
  nginx
```

Here:

```text
/app/cache → tmpfs mount
rw          → read/write
size=64m    → maximum tmpfs size
```

---

# 22. tmpfs Is Ephemeral

Data stored in a tmpfs mount does not persist after the container is stopped/removed.

Example:

```bash
docker run -it \
  --name cachetest \
  --tmpfs /app/cache:rw,size=64m \
  alpine sh
```

Inside:

```bash
echo "temporary data" > /app/cache/test.txt
```

Exit:

```bash
exit
```

After the container is stopped, the tmpfs contents are gone.

If the container is started again with a newly created tmpfs mount:

```text
Previous tmpfs data
       ↓
     Gone
```

---

# 23. Why Use tmpfs?

Useful for data that should be temporary.

Examples:

* Cache
* Temporary files
* Scratch space
* Short-lived session data
* Some sensitive temporary data

### Advantages

```text
Fast
 ↓
Memory-backed
 ↓
No normal persistent storage lifecycle
 ↓
Data disappears with the mount
```

---

# 24. Important tmpfs Considerations

### 1. No Persistence

Data disappears when the tmpfs mount is removed.

### 2. Uses Memory

tmpfs consumes memory and its usage counts toward the container's memory limit when applicable.

### 3. Size Matters

You can specify a limit:

```bash
--tmpfs /app/cache:size=64m
```

### 4. Linux

Docker's tmpfs mount functionality is a Linux-specific feature.

### 5. Don't Say "Never Touches Disk"

tmpfs is memory-backed, but on systems where memory can be swapped, data may potentially reach swap storage.

Therefore, do not treat tmpfs as an absolute guarantee that sensitive data can never reach disk.

---

# 25. Named Volume vs Bind Mount vs tmpfs

| Feature                    | Named Volume           | Bind Mount      | tmpfs                     |
| -------------------------- | ---------------------- | --------------- | ------------------------- |
| Persistent                 | Yes                    | Yes             | No                        |
| Managed by Docker          | Yes                    | No              | Yes                       |
| Stored in                  | Docker-managed storage | Host filesystem | Memory                    |
| Host path required         | No                     | Yes             | No                        |
| Survives container removal | Yes                    | Yes             | No                        |
| Good for databases         | Yes                    | Possible        | No                        |
| Good for development code  | Usually no             | Yes             | No                        |
| Good for temporary cache   | Possible               | Possible        | Yes                       |
| Direct host file access    | Not normally           | Yes             | No                        |
| Shared between containers  | Yes                    | Yes             | No                        |
| Data lifecycle             | Explicitly managed     | Host filesystem | Container/mount lifecycle |

---

# 26. Docker Storage Architecture

A simplified view:

```text
                     Docker Container
                            │
             ┌──────────────┼──────────────┐
             │              │              │
             ↓              ↓              ↓
       Writable Layer   Named Volume   Bind Mount
             │              │              │
             │              │              │
             ↓              ↓              ↓
         Temporary      Docker-managed    Host FS
             │
             ↓
     Removed with container
```

And:

```text
tmpfs
  │
  ↓
Memory-backed temporary storage
  │
  ↓
Removed when mount/container lifecycle ends
```

---

# 27. What Happens to Data?

## Container Writable Layer

```text
Container created
       ↓
Data written
       ↓
Container removed
       ↓
Data lost
```

---

## Named Volume

```text
Container
    ↓
Named Volume
    ↓
Container removed
    ↓
Volume remains
    ↓
Data remains
```

---

## Bind Mount

```text
Container
    ↓
Host Directory
    ↓
Container removed
    ↓
Host files remain
```

---

## tmpfs

```text
Container
    ↓
tmpfs
    ↓
Memory
    ↓
Mount/container removed
    ↓
Data lost
```

---

# 28. Practical Decision Guide

Use a **named volume** when:

```text
I need persistent application data
```

Examples:

```text
MySQL data
PostgreSQL data
Jenkins data
Application uploads
Persistent application state
```

---

Use a **bind mount** when:

```text
I need direct access to host files
```

Examples:

```text
Source code
Development configuration
Local scripts
Development files
```

---

Use **tmpfs** when:

```text
I need temporary memory-backed storage
```

Examples:

```text
Cache
Temporary files
Scratch data
Ephemeral application state
```

---

# 29. Important Commands to Remember

## Volumes

```bash
docker volume create mydata
docker volume ls
docker volume inspect mydata
docker volume rm mydata
docker volume prune
```

## Container + Volume

```bash
docker run -d \
  --name app \
  -v mydata:/app/data \
  nginx
```

## Bind Mount

```bash
docker run -d \
  --name app \
  -v ~/appdata:/app/data \
  nginx
```

## Read-Only Mount

```bash
docker run -d \
  -v ~/appdata:/app/data:ro \
  nginx
```

## tmpfs

```bash
docker run -d \
  --tmpfs /app/cache:size=64m \
  nginx
```

## Inspect Container Mounts

```bash
docker inspect <container>
```

## Check Container User

```bash
docker exec <container> id
```

## Check Host UID/GID

```bash
id
```

## Check Numeric Ownership

```bash
ls -ln <directory>
```

## Docker Compose

```bash
docker compose down
```

Keeps declared named volumes.

```bash
docker compose down -v
```

Removes declared named volumes and their data.

---

# 30. The Most Important Concepts

Remember these four rules:

```text
1. Named Volume
   → Persistent Docker-managed storage

2. Bind Mount
   → Host filesystem ↔ Container

3. tmpfs
   → Temporary memory-backed storage

4. Container Writable Layer
   → Temporary storage tied to the container
```

### Simple Mental Model

```text
                    Docker Storage
                          │
          ┌───────────────┼────────────────┐
          │               │                │
          ↓               ↓                ↓
     Named Volume    Bind Mount         tmpfs
          │               │                │
          ↓               ↓                ↓
     Persistent       Host files       Temporary
     app data         / source code     memory data
```

### Golden Rule

```text
Need persistent application data?
→ Named Volume

Need to edit/access host files directly?
→ Bind Mount

Need temporary memory-backed data?
→ tmpfs

Need temporary container-specific data?
→ Container writable layer
```


