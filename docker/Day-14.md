# Docker Day 4 Notes
# Docker Networking Deep Dive

---

# 1. Docker Compose Build & Lifecycle

## Does `docker compose up --build` Use Docker Cache?

Yes.

```bash
docker compose up --build
```

is conceptually similar to:

```bash
docker build .
docker run ...
```

Therefore all Dockerfile layer caching rules still apply.

Example:

```dockerfile
COPY requirements.txt .

RUN pip install -r requirements.txt

COPY . .
```

If only `app.py` changes:

```text
COPY requirements.txt -> Cached
RUN pip install       -> Cached
COPY . .              -> Rebuilt
```

---

## Rebuild Without Cache

```bash
docker compose build --no-cache
```

---

# 2. Docker Compose vs Docker Commands

Containers created by Compose can be managed:

### Using Docker

```bash
docker stop mysql
docker start mysql
docker logs mysql
```

### Using Compose

```bash
docker compose stop mysql
docker compose start mysql
docker compose logs mysql
```

Both work.

However, Compose commands are preferred because they operate on services defined in the Compose file.

---

## Should Compose Containers Be Stopped Only With Compose?

Recommended:

```text
Yes
```

Mandatory:

```text
No
```

Docker commands work as well.

---

# 3. docker compose stop vs down vs down -v

## Stop

```bash
docker compose stop
```

Stops containers only.

Keeps:

- Containers
- Networks
- Volumes

---

## Down

```bash
docker compose down
```

Removes:

- Containers
- Compose Networks

Keeps:

- Volumes

Example:

```text
mysql-data volume remains
```

---

## Down with Volumes

```bash
docker compose down -v
```

Removes:

- Containers
- Networks
- Volumes

Data stored inside volumes is lost.

---

# 4. Docker Networking Fundamentals

## Why Do Containers Need Networking?

If an application has:

```text
Frontend
    |
Backend
    |
Database
```

then the containers must communicate.

Docker networking provides:

- Container-to-Container communication
- Host-to-Container communication
- Internet connectivity

---

## How Does A Container Receive Traffic?

Like a laptop, it needs:

```text
1. Network Interface
2. IP Address
3. Routing
```

---

## Real World Analogy

Home WiFi:

```text
Laptop -> 192.168.1.10

Phone  -> 192.168.1.20

TV     -> 192.168.1.30
```

All devices can communicate because they belong to the same network.

Docker works similarly:

```text
Container A -> 172.17.0.2

Container B -> 172.17.0.3
```

Same network:

```text
172.17.0.2 <----> 172.17.0.3
```

Communication possible.

---

# 5. What Is A Docker Network?

A Docker Network is:

```text
A Private Virtual Network For Containers
```

It allows containers to communicate with each other.

---

# 6. Docker Networking Stack

Every container gets:

```text
Network Namespace
        |
Network Interface (eth0)
        |
IP Address
        |
Connected To Docker Network
```

---

# 7. Default Docker Networks

When Docker is installed it automatically creates:

```text
bridge
host
none
```

Verify:

```bash
docker network ls
```

Example:

```text
NETWORK ID     NAME      DRIVER

abc123         bridge    bridge

xyz456         host      host

pqr789         none      null
```

---

# 8. Default Bridge Network

Docker automatically creates a bridge network.

Name:

```text
bridge
```

---

## Bridge Architecture

```text
Container A (172.17.0.2)
          |
       docker0
          |
Container B (172.17.0.3)
```

Docker creates a Linux bridge:

```text
docker0
```

which acts like a virtual switch.

---

# 9. Subnet

Inspect bridge:

```bash
docker network inspect bridge
```

You will see something like:

```text
172.17.0.0/16
```

Meaning Docker can assign IPs from:

```text
172.17.x.x
```

Examples:

```text
172.17.0.2

172.17.0.3

172.17.1.15
```

---

# 10. Gateway

Home Network:

```text
Laptop
    |
Router
    |
Internet
```

Router is the gateway.

Docker:

```text
Container
     |
docker0
     |
Host
```

docker0 acts as the gateway.

Usually:

```text
172.17.0.1
```

---

# 11. Inspect Bridge Network

```bash
docker network inspect bridge
```

Useful information:

- Subnet
- Gateway
- Connected Containers
- Container IP Addresses

---

# 12. Container IP

Every container gets an IP address.

Inspect:

```bash
docker inspect <container-name>
```

or

```bash
docker inspect -f '{{.NetworkSettings.IPAddress}}' <container-name>
```

Example:

```text
172.17.0.2
```

---

# 13. Why Not Use Container IPs?

Container IPs can change.

Example:

```bash
docker rm mysql
```

Create again:

```bash
docker run ...
```

Old IP:

```text
172.17.0.2
```

New IP:

```text
172.17.0.5
```

Applications break.

Preferred:

```text
Use Container Names
```

---

# 14. Network Namespace

Docker wants containers to behave like independent machines.

Therefore Docker creates a separate networking environment for every container.

This environment is called:

```text
Network Namespace
```

---

## Simple Definition

A Network Namespace is:

```text
A Container's Private Networking World
```

It contains:

- IP Address
- Network Interfaces
- Routes
- Hostname

---

## Example

Container A:

```text
Network Namespace A

IP = 172.17.0.2

Interface = eth0
```

Container B:

```text
Network Namespace B

IP = 172.17.0.3

Interface = eth0
```

Both have:

```text
eth0
```

No conflict because they are different namespaces.

---

## Easy Analogy

```text
House = Namespace

House Address = IP Address
```

The address belongs to the house.

Similarly:

```text
IP Address belongs to Namespace
```

---

# 15. Custom Bridge Network

## Why Create One?

Benefits:

✅ Better Isolation

✅ Automatic DNS Resolution

✅ Easier Troubleshooting

✅ Used In Real Applications

---

## Create Network

```bash
docker network create my-network
```

---

## Inspect Network

```bash
docker network inspect my-network
```

Docker creates a separate subnet.

Usually:

```text
172.18.x.x
```

---

## Run Container 1

```bash
docker run -d \
--name web \
--network my-network \
nginx
```

---

## Run Container 2

```bash
docker run -it \
--name client \
--network my-network \
ubuntu bash
```

---

## Test Communication

Inside client:

```bash
ping web
```

Docker DNS resolves:

```text
web
    |
172.18.0.2
```

---

## Golden Rule

```text
Never Depend On Container IPs.

Use Container Names.
```

---

# 16. Connect Existing Container To Network

Create container:

```bash
docker run -d --name nginx nginx
```

Attach:

```bash
docker network connect my-network nginx
```

Now nginx belongs to:

```text
bridge
  +
my-network
```

simultaneously.

---

## Disconnect

```bash
docker network disconnect my-network nginx
```

---

## Remove Network

```bash
docker network rm my-network
```

Network must not have active containers connected.

---

# 17. Container-to-Container Communication

Containers communicate when connected to the same network.

Example:

```text
Backend
     |
Docker Network
     |
MySQL
```

---

# 18. Docker Compose Networking

Compose automatically creates a network.

Example:

```yaml
services:

  backend:

  mysql:
```

Compose creates:

```text
project_default
```

network automatically.

All services join this network.

---

# 19. Verify Communication

Enter container:

```bash
docker exec -it backend bash
```

Check:

```bash
ping mysql
```

or

```bash
telnet mysql 3306
```

or

```bash
curl http://frontend
```

---

# 20. Common Networking Problems

### Different Networks

```text
backend -> network1

mysql -> network2
```

Cannot communicate.

---

### Wrong Container Name

Application:

```text
DB_HOST=database
```

Real container:

```text
mysql
```

DNS resolution fails.

---

### Service Not Listening

Network is fine.

Application is not.

Example:

```text
MySQL stopped
```

Result:

```text
Connection Refused
```

---

# 21. Docker Networking Troubleshooting Flow

## Step 1

```bash
docker network ls
```

---

## Step 2

```bash
docker network inspect app-network
```

Verify containers are attached.

---

## Step 3

```bash
ping mysql
```

Verify DNS resolution.

---

## Step 4

```bash
telnet mysql 3306
```

or

```bash
curl backend:5000
```

Verify connectivity.

---

# 22. The Localhost Trap

Most common networking mistake.

---

## What Developers Think

```text
Backend
    |
localhost
    |
MySQL
```

❌ Wrong

---

## What localhost Actually Means

```text
localhost = me

127.0.0.1 = myself
```

---

## Example

Backend container:

```text
DB_HOST=localhost
```

Backend tries:

```text
localhost:3306
```

Meaning:

```text
Backend Container itself
```

Not:

```text
MySQL Container
```

---

## Result

```text
Connection Refused
```

---

## Correct Configuration

```text
DB_HOST=mysql
```

or

```text
DB_HOST=postgres
```

Use container name.

---

# 23. Flask Localhost Trap

Wrong:

```python
app.run(host="localhost", port=5000)
```

Flask listens only inside the container.

Browser cannot reach it.

---

Correct:

```python
app.run(host="0.0.0.0", port=5000)
```

Meaning:

```text
Listen On All Interfaces
```

Docker can now forward traffic.

---

# 24. EXPOSE vs -p

## EXPOSE

Dockerfile:

```dockerfile
EXPOSE 5000
```

Meaning:

```text
Application uses Port 5000
```

Documentation only.

---

## What EXPOSE Does NOT Do

- Publish port
- Open firewall
- Allow browser access

---

## Port Publishing (-p)

```bash
docker run -p 5000:5000 flask-app
```

Meaning:

```text
Host Port 5000
       |
Container Port 5000
```

---

## Browser Access

```text
Browser
   |
localhost:5000
   |
Host Port 5000
   |
Container Port 5000
```

---

# 25. Does Container-to-Container Communication Need -p?

No.

Containers communicate through Docker networks.

Example:

```text
Backend
     |
mysql:3306
     |
MySQL
```

No port publishing needed.

---

## When Do We Need -p?

Only when something outside Docker needs access.

Examples:

- Browser
- Postman
- Host Machine
- External Server

---

# 26. Accessing Applications

## Browser -> Flask Container

```text
http://localhost:5000
```

or

```text
http://<host-ip>:5000
```

Host IP means:

```text
Laptop / VM IP
```

NOT container IP.

---

## Backend -> MySQL

```text
DB_HOST=mysql
DB_PORT=3306
```

Connection:

```text
mysql:3306
```

---

## Backend -> Flask

```text
http://flask:5000
```

Docker DNS resolves:

```text
flask
  |
Container IP
```

---

## Browser -> Backend

```text
http://localhost:8080
```

Requires:

```bash
-p 8080:8080
```

---

## Easy Rule

Outside Docker:

```text
localhost:<published-port>
```

Needs:

```bash
-p
```

---

Inside Docker:

```text
container-name:container-port
```

Examples:

```text
mysql:3306

redis:6379

backend:8080

flask:5000
```

---

# 27. Docker DNS

Instead of:

```text
DB_HOST=172.18.0.2
```

Use:

```text
DB_HOST=mysql
```

Docker automatically converts:

```text
mysql
      |
172.18.0.2
```

This is Docker DNS.

---

## Definition

Docker DNS is an internal DNS service that converts:

```text
Container Name
      |
IP Address
```

for containers on the same Docker network.

---

## Verify DNS

Inside container:

```bash
ping mysql
```

or

```bash
getent hosts mysql
```

---

## Important

Docker DNS works for containers connected to the same Docker network.

---

# 28. Host Network

Normal Docker:

```text
Host
   |
Docker Network
   |
Container
```

Container gets its own IP.

Example:

```text
172.17.0.2
```

---

## Host Network Mode

```bash
docker run --network host nginx
```

Docker says:

```text
Use Host Network Directly
```

---

Architecture:

```text
Host
  |
Nginx Container
```

No:

- Separate Container IP
- Docker Bridge
- NAT
- Port Mapping

---

## Example

Host:

```text
192.168.1.10
```

Nginx:

```text
Port 80
```

Run:

```bash
docker run --network host nginx
```

Access:

```text
http://localhost
```

or

```text
http://192.168.1.10
```

---

## Advantages

```text
Better Performance

No NAT Translation
```

---

## Disadvantages

Port conflicts.

Example:

```text
Apache already using Port 80
```

Nginx cannot start.

---

# 29. None Network

Run:

```bash
docker run --network none ubuntu
```

Docker creates:

- Filesystem
- Processes

But:

```text
No Network
```

---

## Characteristics

No:

- Internet Access
- Container Communication
- Host Communication

---

## Test

```bash
ping google.com
```

Result:

```text
Network Unreachable
```

---

## What Exists?

Only:

```text
Loopback Interface (lo)
```

Check:

```bash
ip addr
```

---

# 30. When To Use None Network?

## Security

Example:

```text
Secret Processing

Report Generation

File Decryption
```

---

## Offline Jobs

Example:

```text
Image Resize

PDF Conversion

Log Analysis
```

No network required.

---

# 31. Bridge vs Host vs None

## Bridge (Default)

```text
Container
     |
Own IP
     |
Docker Network
```

Used for most applications.

---

## Host

```text
Container
     |
Host Network
```

Maximum performance.

No port mapping.

---

## None

```text
Container

No Network
```

Maximum isolation.

---

# Golden Rules

```text
Use Custom Bridge Networks For Real Applications.

Never Depend On Container IPs.

Use Container Names.

localhost Means "Myself".

Container-to-Container Communication Does NOT Need -p.

Browser-to-Container Access Needs -p.

EXPOSE = Documentation

-p = Actual Access

Bridge = Most Applications

Host = Maximum Performance

None = Maximum Isolation
```
