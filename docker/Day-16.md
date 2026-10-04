# Docker Security Mental Model

---

## 1. Docker Security Mental Model
Think about the Docker stack:

```
Host OS
   │
   ├── Docker Engine
   │       │
   │       ├── Container A
   │       ├── Container B
   │       └── Container C
   │
   └── Host resources
```

- The container is isolated from the host to a degree.
- But Docker containers still interact with:
  - Kernel
  - Filesystem
  - Network
  - Processes
  - CPU
  - Memory
  - Linux capabilities

**Key Point:**  
Container ≠ Virtual Machine.  
A VM provides a stronger isolation boundary because it has its own guest kernel.  
A container shares the host kernel.

---

## 2. Root Inside a Container
- By default, most Docker images run processes as **root (UID 0)** inside the container.
- This means the application inside the container has full privileges within the container’s namespace.
- Even though it’s “root inside the container,” it’s not the same as host root — but it can still be dangerous if combined with misconfigurations.

---

## 3. Why Is Root a Problem?
- **Privilege Escalation Risk**: Root inside the container can become root on the host if a container escape occurs.
- **Shared Volumes Risk**: Root inside the container can write files with root ownership on the host.
- **Best Practice**: Principle of least privilege — don’t give more rights than necessary.
- **Compliance**: Many organizations require non‑root containers.

👉 Example: Logs written to a bind mount may be owned by root, unreadable by normal users.

---

## 4. Run a Container as a Non‑Root User
### A. Use `-u` flag at runtime
```bash
docker run -it -u 1000:1000 -v ~/appdata:/data busybox sh
```

### B. Define a user in Dockerfile
```dockerfile
FROM nginx
RUN addgroup --system appgroup && adduser --system --ingroup appgroup appuser
USER appuser
```

### C. Use Docker Compose `user` directive
```yaml
services:
  web:
    image: nginx
    user: "1000:1000"
```

---

## 5. Problems Without Root
Running as non‑root is best practice, but some apps break:
- Legacy assumptions (write to `/var/log`, `/tmp`).
- File permissions issues.
- Runtime package installation attempts.
- Binding to ports <1024 requires root.

**Troubleshooting sequence:**
```
Permission denied
       ↓
Check container user
       ↓
Check UID/GID
       ↓
Check directory ownership
       ↓
Check filesystem permissions
       ↓
Fix ownership/permissions
```

---

## 6. Linux Capabilities
- Capabilities split root’s powers into smaller units.
- Examples:
  - `NET_ADMIN` → network interfaces, routing tables.
  - `NET_RAW` → raw sockets.
  - `SYS_ADMIN` → broad system tasks.
  - `CHOWN` → change file ownership.
  - `SETUID` / `SETGID` → change user/group IDs.

**Docker defaults:** Containers don’t run with full root privileges; they get a limited set of capabilities.

### Best Practices
- Drop unnecessary capabilities:
  ```bash
  docker run --cap-drop=NET_RAW --cap-drop=SYS_ADMIN myapp
  ```
- Add only what’s needed:
  ```bash
  docker run --cap-add=NET_ADMIN myvpn
  ```
- Use Kubernetes `securityContext.capabilities`.

---

## 7. Normal vs Privileged Containers
- **Normal container** → restricted set of capabilities.
- **Privileged container (`--privileged`)** → broad access to host resources, almost all capabilities.

```bash
docker run --rm --privileged alpine id
```

❌ Avoid `--privileged` unless absolutely required.

---

## 8. Read‑Only Root Filesystem
```bash
docker run --rm --read-only nginx
```
- Makes `/` immutable.
- Mount writable directories explicitly:
  ```bash
  docker run --rm --read-only \
    -v /home/piyush/appdata:/app/data \
    -v /tmp:/tmp \
    nginx
  ```

**Benefits:** Security, consistency, compliance.

---

## 9. Environment Variables Are Not Secrets
- Visible via `docker inspect` or `printenv`.
- May leak into logs or orchestration configs.
- Not suitable for sensitive data.

---

## 10. Secret Management
- Use secret managers:
  - AWS Secrets Manager
  - AWS Parameter Store
  - Kubernetes Secrets
  - HashiCorp Vault
  - CI/CD secret stores

👉 Best practice: Never bake secrets into images or ENV variables.

---

## 11. Image Security
- **Trusted sources** only.
- **Image signing** with Docker Content Trust.
- **Vulnerability scanning** (Trivy, Anchore, Clair).
- **Minimal base images** (alpine, distroless).
- **Regular updates**.
- **No secrets baked in**.
- **Least privilege** at runtime.

---

## 12. Dockerignore
- `.dockerignore` reduces build context, prevents accidental inclusion of files.
- Not a replacement for secret management.

---

## 13. Security Controls Complement Each Other
```
.dockerignore → reduce accidental inclusion
Secret manager → protect secrets
Image scanning → find vulnerabilities
Non-root → reduce process privileges
Capabilities → reduce kernel privileges
Read-only FS → reduce filesystem modification
```

---

## 14. Resource Limits
- Prevent containers from consuming excessive resources.

Examples:
```bash
docker run --rm --memory=128m nginx
docker run --rm --cpus=0.5 nginx
docker run --rm --pids-limit=100 nginx
```

---

## 15. Docker Security Layers
```
                 Docker Security
                       │
       ┌───────────────┼────────────────┐
       │               │                │
       ↓               ↓                ↓
   Identity       Capabilities       Filesystem
       │               │                │
       ↓               ↓                ↓
 Non-root          cap-drop          read-only
       │
       │
       ├───────────────┐
       ↓               ↓
   Secrets          Images
```

---

## 16. Common Interview Questions

**Q: Why shouldn’t you blindly use `latest` for production images?**  
A: `latest` makes deployments unpredictable. Always pin versions or digests for reproducibility.

**Q: Container Security vs VM Isolation?**  
A: Containers isolate processes with namespaces/cgroups but share the host kernel. VMs isolate at hardware level with separate kernels, stronger isolation but heavier.

**Q: What does `USER` do in a Dockerfile?**  
A: Sets the default user for container processes. Best practice: run as non‑root for least privilege. Can be overridden at runtime with `docker run -u`.

---
