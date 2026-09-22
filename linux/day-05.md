# DevOps Troubleshooting Quick Revision

## 0. MASTER FLOW

When something is not working:

```text
DNS
 ↓
Reachability
 ↓
Routing
 ↓
Port
 ↓
Service
 ↓
Application
 ↓
Firewall / Security
 ↓
Logs
```

Quick sequence:

```bash
getent hosts HOST
ping -c 4 HOST
ip route get IP
nc -vz HOST PORT
ss -lntp
curl -v URL
firewall check
logs
```

Remember:

```text
getent → ping → route → nc → ss → curl → firewall → logs
```

---

# 1. "What IP does this machine have?"

### Use

```bash
ip addr
```

or:

```bash
hostname -I
```

### Need interface information?

```bash
ip link
```

### Need IPv4 only?

```bash
ip -4 addr
```

### Need IPv6?

```bash
ip -6 addr
```

### Think

```text
IP = Where is this machine?
Interface = Which network connection?
```

---

# 2. "Is the network interface UP?"

```bash
ip link
```

Look for:

```text
state UP
```

For a specific interface:

```bash
ip link show eth0
```

---

# 3. "Is localhost working?"

```bash
ping -c 4 127.0.0.1
```

or:

```bash
curl http://localhost:8080
```

Check loopback:

```bash
ip addr show lo
```

Remember:

```text
localhost = 127.0.0.1
lo = loopback interface
```

---

# 4. "Can this machine resolve the hostname?"

First:

```bash
getent hosts google.com
```

If needed:

```bash
nslookup google.com
```

For detailed DNS:

```bash
dig google.com
```

Quick answer:

```bash
dig +short google.com
```

Specific DNS server:

```bash
dig @8.8.8.8 google.com
```

Check configured DNS:

```bash
cat /etc/resolv.conf
```

### Think

```text
Hostname → DNS → IP
```

If DNS fails, don't jump directly to application troubleshooting.

---

# 5. "Can I reach the server?"

```bash
ping -c 4 HOST
```

Example:

```bash
ping -c 4 10.0.1.20
```

### IMPORTANT

Ping tests:

```text
Host reachability / ICMP
```

It does NOT prove:

```text
HTTP works
HTTPS works
SSH works
Jenkins works
Database works
```

A server can:

```text
PING FAIL
HTTPS WORK
```

because ICMP may be blocked.

---

# 6. "What route will Linux use?"

```bash
ip route
```

Find default gateway:

```bash
ip route | grep default
```

Check route to a specific destination:

```bash
ip route get 8.8.8.8
```

or:

```bash
ip route get 10.10.20.30
```

### Think

```text
Destination → Which interface? → Which gateway?
```

---

# 7. "Where is the network path breaking?"

```bash
traceroute HOST
```

Alternative:

```bash
tracepath HOST
```

Useful when:

```text
Connection is slow
Connection times out
You suspect a network path problem
```

Remember:

```text
* * *
```

doesn't automatically mean failure. A router may simply not respond to traceroute.

---

# 8. "Is the TCP port reachable?"

Use:

```bash
nc -vz HOST PORT
```

Example:

```bash
nc -vz google.com 443
```

Jenkins:

```bash
nc -vz jenkins.company.com 8080
```

### Think

```text
ping = Can I reach the host?

nc = Can I establish TCP connection to this port?
```

---

# 9. "Is something listening on this server?"

```bash
ss -lntp
```

All TCP/UDP listening:

```bash
ss -tulpn
```

Specific port:

```bash
ss -lntp | grep 8080
```

Example:

```text
LISTEN ... :8080
```

means something is listening on port 8080.

---

# 10. "Which process owns this port?"

```bash
sudo lsof -i :8080
```

Example:

```text
java    1234
```

Means:

```text
Java process
PID = 1234
Port = 8080
```

Then:

```bash
ps -p 1234 -f
```

to inspect the process.

---

# 11. "Is the service running?"

For systemd services:

```bash
systemctl status SERVICE
```

Examples:

```bash
systemctl status ssh
systemctl status nginx
```

Start:

```bash
sudo systemctl start SERVICE
```

Stop:

```bash
sudo systemctl stop SERVICE
```

Restart:

```bash
sudo systemctl restart SERVICE
```

Enable at boot:

```bash
sudo systemctl enable SERVICE
```

Check failed services:

```bash
systemctl --failed
```

---

# 12. "Is the application actually responding?"

For HTTP:

```bash
curl http://HOST:PORT
```

Headers:

```bash
curl -I http://HOST:PORT
```

Detailed troubleshooting:

```bash
curl -v http://HOST:PORT
```

Follow redirects:

```bash
curl -L URL
```

Only HTTP status:

```bash
curl -o /dev/null -s -w "%{http_code}\n" URL
```

---

# 13. "What does the HTTP status mean?"

```text
200 → Success

301 → Permanent redirect
302 → Temporary redirect

401 → Authentication required
403 → Access denied
404 → Resource not found

500 → Application/server error
502 → Bad gateway
503 → Service unavailable
```

Quick interpretation:

```text
DNS error
    ↓
Cannot find server

Connection refused
    ↓
Reached host, but nothing accepted the connection
    ↓
Check service/listening port

Connection timeout
    ↓
Traffic isn't getting a response
    ↓
Check firewall/security/routing

HTTP 500
    ↓
Network probably worked
    ↓
Investigate application

HTTP 502
    ↓
Gateway/proxy cannot reach upstream

HTTP 503
    ↓
Service unavailable/overloaded/maintenance
```

---

# 14. "Why is Jenkins not opening?"

Suppose:

```text
http://jenkins.company.com:8080
```

### Step 1 — DNS

```bash
getent hosts jenkins.company.com
```

If it fails:

```text
DNS problem
```

### Step 2 — Host reachability

```bash
ping -c 4 jenkins.company.com
```

If it fails:

```text
Could be ICMP blocked
```

Don't conclude Jenkins is down.

### Step 3 — Route

```bash
ip route get <JENKINS_IP>
```

Check:

```text
gateway
interface
source IP
route
```

### Step 4 — Port

```bash
nc -vz jenkins.company.com 8080
```

### Step 5 — On Jenkins server

```bash
ss -lntp | grep 8080
```

### Step 6 — Check Jenkins/service

```bash
systemctl status jenkins
```

### Step 7 — HTTP

```bash
curl -v http://jenkins.company.com:8080
```

### Step 8 — Logs

```bash
journalctl -u jenkins
```

---

# 15. "Website is down"

Start:

```bash
getent hosts example.com
```

Then:

```bash
ping -c 4 example.com
```

Then:

```bash
nc -vz example.com 443
```

Then:

```bash
curl -v https://example.com
```

If server access exists:

```bash
ss -lntp | grep 443
```

Then check:

```text
nginx/apache/application
firewall
security rules
logs
```

---

# 16. "Port is refused"

Example:

```bash
nc -vz server 8080
```

Result:

```text
Connection refused
```

Think:

```text
Host reachable
        ↓
TCP reached destination
        ↓
Nothing accepted connection
```

Check:

```bash
ss -lntp | grep 8080
```

Then:

```bash
systemctl status SERVICE
```

Then application logs.

Common causes:

```text
Service stopped
Wrong port
Application crashed
Service listening on another interface/port
```

---

# 17. "Port is timing out"

Example:

```bash
nc -vz server 8080
```

Result:

```text
Connection timed out
```

Think:

```text
No response
```

Investigate:

```text
Firewall
Security Group
Network ACL
Routing
Network path
Wrong IP
```

Then:

```bash
ip route get IP
traceroute HOST
```

and check firewall/security rules.

---

# 18. "Ping works but application doesn't"

Example:

```text
ping server
SUCCESS

curl https://server
FAIL
```

Do NOT blame DNS immediately.

Check:

```bash
nc -vz server 443
```

If port fails:

```text
Firewall
Security Group
Service not listening
Wrong port
```

If port works:

```bash
curl -v https://server
```

Then investigate:

```text
TLS
HTTP status
reverse proxy
application
authentication
```

---

# 19. "DNS works but application doesn't"

Example:

```bash
getent hosts app.company.com
```

SUCCESS.

But:

```bash
curl https://app.company.com
```

FAILS.

Next:

```bash
nc -vz app.company.com 443
```

Then:

```bash
curl -v https://app.company.com
```

Think:

```text
DNS is NOT the problem.
Move to TCP/port/application.
```

---

# 20. "localhost works but server IP doesn't"

Example:

```bash
curl http://localhost:8080
```

works.

But:

```bash
curl http://192.168.1.50:8080
```

fails.

Think:

```text
Application may only be bound to localhost.
```

Check:

```bash
ss -lntp | grep 8080
```

Look for:

```text
127.0.0.1:8080
```

vs:

```text
0.0.0.0:8080
```

Concept:

```text
127.0.0.1
    ↓
Only local machine

0.0.0.0
    ↓
Listening on all IPv4 interfaces
```

Then investigate firewall/security rules.

---

# 21. "Which process is consuming resources?"

### CPU/processes

```bash
ps aux
```

Interactive:

```bash
top
```

### Memory

```bash
free -h
```

### Disk

```bash
df -h
```

### Disk usage of directory

```bash
du -sh DIRECTORY
```

Think:

```text
CPU high?
Memory high?
Disk full?
Process consuming resources?
```

---

# 22. "Disk is full"

Start:

```bash
df -h
```

Find large directories:

```bash
du -sh /*
```

Then investigate specific directories:

```bash
du -sh /var/*
```

Common places:

```text
/var/log
/tmp
application logs
Docker data
build artifacts
old files
```

---

# 23. "Memory is high"

```bash
free -h
```

Then:

```bash
ps aux --sort=-%mem | head
```

Find processes consuming memory.

Then investigate:

```text
Application
Java heap
Memory leak
Too many processes
Container memory
```

---

# 24. "CPU is high"

```bash
top
```

or:

```bash
ps aux --sort=-%cpu | head
```

Find the process.

Then:

```bash
ps -p PID -f
```

Investigate what that process is doing.

---

# 25. "A Linux service suddenly stopped"

```bash
systemctl status SERVICE
```

Then:

```bash
journalctl -u SERVICE -n 50
```

For current boot:

```bash
journalctl -u SERVICE -b
```

Follow live logs:

```bash
journalctl -u SERVICE -f
```

Then check:

```bash
ps
ss
resources
configuration
permissions
```

---

# 26. "Command works manually but fails in Jenkins"

Check these first:

```text
PATH
Environment variables
Working directory
User
Permissions
Credentials
Network access
Exit code
```

Compare:

```bash
whoami
pwd
echo "$PATH"
env
```

Debug Bash:

```bash
bash -x script.sh
```

Check exit code:

```bash
echo $?
```

Remember:

```text
exit 0     → success
non-zero   → failure
```

This is especially important because Jenkins uses command exit status to determine build-step success/failure.

---

# 27. "A script says FAILED"

Don't immediately modify the script.

Run:

```bash
bash -x script.sh
```

Then identify:

```text
Which command failed?
Why did it fail?
What exit code did it return?
```

Run that command manually.

Example:

```bash
curl ...
echo $?
```

---

# 28. "I don't know where the problem is"

Use the MASTER FLOW:

```text
1. DNS
   getent hosts HOST

2. Reachability
   ping -c 4 HOST

3. Routing
   ip route get IP

4. Port
   nc -vz HOST PORT

5. Service
   ss -lntp
   systemctl status SERVICE

6. Application
   curl -v URL

7. Security
   firewall / Security Group / NACL

8. Logs
   journalctl / application logs
```

---

# 29. The 30-second interview answer

If interviewer asks:

> "How would you troubleshoot an application that is not reachable?"

Answer:

```text
First I would check whether DNS resolves the hostname.

Then I would verify basic host reachability and inspect the route to the destination.

Next I would check whether the required TCP port is reachable using nc.

If I have access to the server, I would verify that the service is actually listening using ss and check its systemd status if applicable.

Then I would test the application itself using curl -v and inspect the HTTP response.

If connectivity is failing, I would investigate firewall, security group, network ACL and routing rules.

Finally, I would check system and application logs to identify the root cause.
```

---

# 30. Most important commands to actually memorize

Don't memorize 50 commands.

Memorize these:

```bash
ip addr
ip route
ip route get IP
ip link

getent hosts HOST
nslookup HOST
dig HOST

ping -c 4 HOST

ss -lntp
ss -tulpn

nc -vz HOST PORT

curl -I URL
curl -v URL

traceroute HOST

ps aux
top
free -h
df -h

systemctl status SERVICE
journalctl -u SERVICE -n 50

bash -x script.sh
echo $?
```

And this sequence:

```text
DNS
 ↓
PING
 ↓
ROUTE
 ↓
NC
 ↓
SS
 ↓
CURL
 ↓
FIREWALL
 ↓
LOGS
```

That sequence is more important than memorizing individual commands.

