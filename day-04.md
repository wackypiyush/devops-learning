# Networking Basic Terms & Troubleshooting Notes

## 1. Networking basic terms

### i) IP address

Internet Protocol Address, a unique address of a device on a network.

```
ip addr
hostname -I
```

One IP can have many ports.
An IP address can support up to 65535 TCP ports and 65535 UDP ports.

**Types of IP addresses:**

- Private IP: used inside homes, offices, data centers.
- Public IP: Visible on the internet. `curl ifconfig.me`

Router uses NAT to translate private addresses into a public address.

### ii) MAC address

Unique hardware address of a network card. Like a device's fingerprint.
MAC address is assigned to a network interface and is usually fixed,
but can be spoofed/changed in software.

```
ip link
```

### iii) Difference between IP and MAC

| IP                    | MAC                        |
| --------------------- | -------------------------- |
| Logical address       | Physical address           |
| Can change            | Usually fixed              |
| Used across networks  | Used inside local network  |
| Example: 192.168.1.10 | Example: 00:1A:2B:3C:4D:5E |

### iv) port

Identifies a specific service running on a system.

```
ss -tulpn   # check listening ports
netstat -tulpn
```

### v) protocol

Set of communication rules.

**TCP**
Reliable communication.
Example: Web applications, Databases, SSH

**UDP**
Fast communication.
Example: DNS, Streaming, VoIP

### vi) client / server

client: requesting the service.
server: providing the service to the client

**Flow**

```
Client ---------> Server
       Request

Client <--------- Server
       Response
```

Example:

```
curl https://google.com
```

Your machine = Client
Google = Server

### vii) DNS

Domain name system. DNS converts names into IP addresses.

Without DNS:

```
http://142.250.xxx.xxx
```

With DNS:

```
http://google.com
```

```
cat /etc/resolv.conf   # Check DNS servers
nslookup google.com    # Lookup DNS
dig google.com         # OR
```

### viii) router

Connects different networks.

```
Laptop
|
WiFi Router
|
Internet
```

**Responsibilities:**

- Forwards packets
- Connects LAN to Internet
- Performs NAT

```
ip route   # Linux route table
```

ex. default via 192.168.1.1, router IP 192.168.1.1

### ix) gateway

The path used to reach other networks.
When your PC wants to visit Google:

```
PC -> Gateway -> Internet
```

```
ip route   # check gateway
```

default via 192.168.1.1, That is your default gateway.

### x) subnet

Divides a network into smaller networks

```
192.168.1.0/24
```

Means:

- Network: 192.168.1.0
- Hosts: 192.168.1.1 - 192.168.1.254
- Broadcast: 192.168.1.255

```
ip addr
```

Output: 192.168.1.100/24
Meaning:

- IP = 192.168.1.100
- Subnet = /24

### xi) REAL WORLD EXAMPLE

```
http://jenkins.company.com:8080
```

**Flow:**

```
Browser
   |
DNS lookup
   |
IP Found
   |
Gateway
   |
Router
   |
Jenkins Server
   |
Response
```

**Breakdown:**

| Item                | Value                 |
| ------------------- | --------------------- |
| jenkins.company.com | DNS Name              |
| 192.168.100.50      | IP Address            |
| 8080                | Port                  |
| HTTP                | Protocol              |
| Browser             | Client                |
| Jenkins             | Server                |
| 192.168.100.1       | Gateway               |
| Router              | Routes traffic        |
| 192.168.100.0/24    | Subnet                |
| MAC Address         | Network card identity |

### xii) Commands

```
ip addr     OR   ip a      # Check IP
ip route         # Check gateway/routes
ip link          # Check MAC
ss -tulpn        # Check ports
ping google.com  # Connectivity
nslookup google.com
dig google.com
curl URL
traceroute google.com
```

## 2. IMPORTANT interview-friendly sentence

IP tells "where" the device is, MAC tells "who" the device is, Port tells "which service" to use, DNS translates names to IPs, Router forwards traffic, Gateway connects to external networks, Protocol defines communication rules, and Subnet groups devices into smaller networks.

Router = Device that forwards packets.
Gateway = IP address of the router that my machine sends traffic to.

## 3. More on IP

### i) Multiple interfaces / IPs

A machine can have multiple network interfaces, and each interface can have one or more IP addresses.
A machine can have:

```
Laptop
├── WiFi Interface
├── Ethernet Interface
├── VPN Interface
└── Loopback Interface
```

Each can have its own IP.
One machine = many interfaces = many IPs.

to check interfaces: `ip link`

### ii) lo (LoopBack Interface)

Almost every Linux machine has: `lo`
It means, the machine talks to itself.
To check it: `ip addr show lo`
Why? Applications often communicate internally.

**Traffic Path:**

```
Application
    ↓
 Loopback (lo)
    ↓
Application
```

### iii) 127.0.0.1

This is localhost, the machine itself.

`ping 127.0.0.1` and `curl localhost:8080`
Both target the local machine

localhost = 127.0.0.1

checking `cat /etc/hosts` gives usually

```
127.0.0.1 localhost
```

`curl localhost` and `curl 127.0.0.1`
are equivalent

### iv) eth0

eth = Ethernet

```
eth0
eth1
eth2
```

means:

- Ethernet interface 0
- Ethernet interface 1
- Ethernet interface 2

### v) Modern interface naming

Modern Linux distributions often use names like:

```
ens33
enp0s3
eno1
wlan0
wlp2s0
```

examples:

- enp0s3 = ethernet
- wlp2s0 = wifi

**Common interface names:**

- Ethernet: eth0, enp0s3, ens160
- WiFi: wlan0, wlp2s0

### vi) hostname -I

Shows All assigned IP addresses like 192.168.1.100 172.17.0.1 but not interface details

### vii) One Interface Can Also Have Multiple IPs

Example:

```
eth0
  inet 192.168.1.100/24
  inet 192.168.1.101/24
```

This is called IP aliasing.

Common for:

- Multiple websites
- Load balancers
- Virtual IPs
- High availability setups

### viii) inet vs inet6

- inet = IPV4
- inet6 = IPV6

## 4. Types of IP addresses

### i) IPV4

- 32 bits long
- Written as 4 decimal numbers separated by dots
- Each number ranges from 0 to 255
- max limit = 2^32 =~ 4.3 billion

Binary representation: 192.168.1.10

```
11000000.10101000.00000001.00001010
```

An IP address consists of: Network Part + Host Part
example: 192.168.1.10/24

- Network = 192.168.1.0
- Host    = 10 (Host portion = last 8 bits)
- subnet = /24

`ip -4 addr` : show only ipv4 addr

### ii) IPV6

- 128 bits long
- Written in hexadecimal
- Uses colons (:)
- Limit = 2^128 addresses

`ip -6 addr` : show only ipv6 addr

### iii) IPv4 vs IPv6

| Feature    | IPv4           | IPv6         |
| ---------- | -------------- | ------------ |
| Length     | 32 bits        | 128 bits     |
| Format     | Dotted decimal | Hexadecimal  |
| Example    | 192.168.1.10   | 2001:db8::1  |
| Count      | ~4.3 billion   | Huge (2^128) |
| NAT Needed | Often          | Usually No   |
| Separator  | .              | :            |

### iv) Private IP ranges

Private IPs are used inside:

- Homes
- Offices
- Data Centers
- Cloud VPCs

These IPs are not routable on the Internet.

**i.) 10.0.0.0/8**

- range: 10.0.0.0 to 10.255.255.255
- Subnet mask: 255.0.0.0

Very common in:

- AWS VPCs
- Azure VNets
- Large enterprises

**ii.) 172.16.0.0/12**

- range: 172.16.0.0 to 172.31.255.255
- subnet mask: 255.240.0.0

Common in:

- Corporate networks
- Docker environments

**iii.) 192.168.0.0/16**

- range: 192.168.0.0 to 192.168.255.255
- subnet mask: 255.255.0.0

Most home routers use: 192.168.1.x or 192.168.0.x

| Range          | Size                |
| -------------- | ------------------- |
| 10.0.0.0/8     | Very Large          |
| 172.16.0.0/12  | Medium              |
| 192.168.0.0/16 | Small/Home Networks |

## 5. Ports

A port is a logical communication endpoint used to identify a specific service on a machine. While an IP address identifies the host, the port identifies the application running on that host.

IP Address = Building Address
Port = Apartment Number

A machine can have:

- One IP
- Multiple IPs
- Thousands of ports

we need ports so that linux should know where the traffic should go. if ports are not there, each service would have same IP, so ports solves it.

Ports are 16-bit numbers: 0 - 65535

| Port | Service        |
| ---- | -------------- |
| 22   | SSH            |
| 21   | FTP            |
| 25   | SMTP           |
| 53   | DNS            |
| 80   | HTTP           |
| 443  | HTTPS          |
| 3306 | MySQL          |
| 5432 | PostgreSQL     |
| 6443 | Kubernetes     |
| 8080 | Jenkins/Tomcat |

- Well-Known Ports (0-1023)
- Registered Ports (1024-49151) by applications
- Ephemeral/Dynamic Ports (49152-65535). Temporary ports used by clients.

**Source Port vs Destination Port**
Open google: https://google.com
then:

- Source IP     : 192.168.1.100
- Source Port   : 52341
- Destination IP   : 142.x.x.x
- Destination Port : 443

```
ss -tulpn OR netstat -tulpn   # check listening ports
ss -tulpn | grep 8080         # check specific port
```

**Meaning of listening:**

```
tcp LISTEN 0 128 *:22
```

SSH service is waiting for incoming connections on port 22.

**Check which process uses a port:**

```
sudo lsof -i :8080
```

output: java 1234 root
meaning: Java process PID 1234 is using port 8080.

- Open port: `22/tcp open ssh`
- Closed port: `22/tcp closed.` No application is listening

**Command:**
`ss` means Socket Statistics

- `-t`  = TCP sockets
- `-u`  = UDP sockets
- `-l`  = Listening sockets only
- `-n`  = Show numbers (don't resolve names)
- `-p`  = Show process/PID using the socket

`ss -tulpn`: Shows

- TCP listening ports
- UDP listening ports
- PID/process name

## 6. Client and Server

Client and Server are roles, not machines.
The same machine can be a client in one interaction and a server in another

Jenkins example:

```
Developer
    |
    v
Jenkins
    |
    +--> GitLab
    |
    +--> SonarQube
    |
    +--> Nexus
    |
    +--> Docker Registry
```

Jenkins as server provides:

- Web UI
- Build API
- Job execution
- port : 8080 users connect to it

Jenkins as Client, connects to and request services:

- GitLab
- Nexus
- Docker Registry
- AWS
- Kubernetes

## 7. DNS

DNS translates:

```
google.com
      ↓
142.250.183.110
```

Background after `curl google.com`

```
1. Ask DNS server:
   "What is google.com?"

2. DNS replies:
   "142.250.xxx.xxx"

3. Connect to that IP
```

Linux stores DNS servers in: `cat /etc/resolv.conf`

### i) getent hosts google.com

Output: `142.250.183.110 google.com`

if this command fails, can't resolve a hostname: Application will likely fail too.

### ii) nslookup google.com

Output:

```
Server:  8.8.8.8

Name:    google.com
Address: 142.250.183.110
```

```
nslookup 8.8.8.8
```

Output: dns.google

### iii) dig google.com

```
QUESTION SECTION:
google.com

ANSWER SECTION:
google.com 300 IN A 142.250.183.110
```

Meaning:

- A record = IPv4 address
- TTL      = 300 seconds

```
dig +short google.com
```

Output: 142.250.183.110
Cleaner and easier to use in scripts.

Query IPV6 records: `dig AAAA google.com`

### iv) Query a Specific DNS Server

```
dig @8.8.8.8 google.com
OR
dig @1.1.1.1 google.com
```

Useful when comparing DNS responses.

### v) getent vs nslookup vs dig

| Command      | Uses System Resolver | DNS Only | Most Common DevOps Use             |
| ------------ | -------------------- | -------- | ---------------------------------- |
| getent hosts | ✅                   | ❌       | Verify real application resolution |
| nslookup     | ❌                   | ✅       | Quick DNS checks                   |
| dig          | ❌                   | ✅       | Detailed DNS troubleshooting       |

### vi) Example Troubleshooting Scenario

```
curl jenkins.company.com
FAILS
```

Step 1: `getent hosts jenkins.company.com`
if no result: Name resolution issue.

Step 2: `nslookup jenkins.company.com`
Check whether DNS server responds.

Step 3: `dig jenkins.company.com`

## 8. Ping

ping is the quickest way to check whether another host is reachable over the network.

```
ping google.com
```

```
Your Machine
      |
      | ICMP Echo Request
      v
Target Host
      |
      | ICMP Echo Reply
      v
Your Machine
```

ping uses the ICMP (Internet Control Message Protocol) protocol.
ICMP is NOT TCP.
ICMP is NOT UDP.

It is a separate network protocol used for:

- Connectivity testing
- Error reporting
- Diagnostics

if ping works: Host reachable and responding to ICMP.
it does not prove:

- SSH works
- HTTPS works
- Jenkins works
- Database works

**Mistake:**

```
Ping works
=
Application works
```

Ping may work but HTTPS fails
Possible reasons:

- Port 443 closed
- Firewall blocking TCP 443
- Nginx not running
- Load balancer issue

Ping Fails, Website Works
Very common on cloud platforms. ICMP blocked
Many companies intentionally block ping.

Host Reachability vs Port Reachability
Host reachability is checked by: `ping`
Port reachability is checked by: `nc -vz host 443` OR `telnet host 443`

Send only 4 packets:

```
ping -c 4 google.com
```

Continuous ping

```
ping google.com
```

Exit by Ctrl +C

ping uses ICMP Echo Requests and Echo Replies to test basic network connectivity. A successful ping indicates that the host is reachable and responding to ICMP traffic. However, it does not guarantee that application services such as HTTP, HTTPS, SSH, Jenkins, or databases are accessible. A host may respond to ping while a required TCP port is blocked by a firewall or the service is not running. Conversely, some servers block ICMP and do not respond to ping, while their application ports remain fully accessible. Therefore, ping tests host reachability, whereas tools like nc, telnet, curl, and ss are used to verify service and port availability.

## 9. Curl

It acts as an HTTP client and is commonly used to:

- Test APIs
- Test websites
- Verify server responses
- Check HTTP status codes
- Debug networking issues

Basic Request: `curl https://google.com`

**Flow:**

```
curl (Client)
      |
      | HTTP Request
      v
Web Server
      |
      | HTTP Response
      v
curl
```

View Headers only:

```
curl -I https://google.com
```

(Note: It's uppercase I, not lowercase l.)

Result:

```
HTTP/2 200
content-type: text/html
server: gws
date: Mon, 21 Sep 2026
```

**common status codes:**

| Code | Meaning                                                                 |
| ---- | ----------------------------------------------------------------------- |
| 200  | Request successful                                                      |
| 301  | Moved permanently example: http://example.com ↓ https://example.com    |
| 302  | Temporary redirect (common with login systems)                          |
| 401  | unauthorized (without credentials.)                                     |
| 403  | Forbidden (You are authenticated or identified, but access is denied.)  |
| 404  | Not Found (Page/resource doesn't exist.)                                |
| 500  | Internal Server Error (Server-side application issue.)                  |
| 502  | Bad gateway (Application is unavailable.)                               |
| 503  | Service Unavailable (Common during: Maintenance, Deployments, Overload) |

Check only status code:

```
curl -o /dev/null -s -w "%{http_code}\n" https://google.com
```

- `-o /dev/null` : discards body
- `-s` : Silent mode
- `-w` : Print custom output.

Follow redirect: `curl -L http://google.com`

Show Full Request/Response Details: `curl -v https://google.com`
Useful for troubleshooting.
Shows:

- DNS lookup
- TCP connection
- TLS handshake
- HTTP request
- HTTP response

## 10. Putting It All Together: IP + Port + TCP + Connection

```
curl -v https://google.com
```

Behind the scenes:

```
1. DNS resolves google.com
       ↓
   142.250.x.x

2. TCP connection established
       ↓
   142.250.x.x:443

3. HTTPS request sent
       ↓

4. HTTP response received
```

curl -v can be used to check for:

- DNS
- TCP
- TLS
- Port 443
- HTTPS
- Application response (status code)

**nc -vz (Netcat)**
One of the best tools for checking TCP port connectivity.

```
nc -vz google.com 443
```

checks: Can I establish a TCP connection?
It does not check:

- HTTP
- HTTPS
- API response
- Application health

**Scenario:**
Suppose Jenkins is down: `http://jenkins.company.com:8080`

Step 1: `ping jenkins.company.com`, checks host reachable

Step 2: `nc -vz jenkins.company.com 8080`, connection refused
means TCP port not available
Maybe:

- Jenkins stopped
- Firewall blocking
- Wrong port

Step 3: On jenkins server
`ss -lntp | grep 8080`, Checks whether Jenkins is listening.

Step 4: if TCP works
`curl -v http://jenkins.company.com:8080`

## 11. Routing

If I want to send traffic to another IP, where should I send it next?
`ip route` : checks routing table

```
ip route get <ip>
```

Shows:

- chosen route
- chosen interface
- source IP
- gateway
- Destination: The network you want to reach.
- Interface: The network card used to send traffic. like etho, wlan0, docker0
- Gateway: The next-hop router to which traffic should be sent.

```
192.168.1.0/24 dev eth0
```

Meaning:
To reach 192.168.1.x
use interface eth0 directly.
No gateway needed because the destination is on the same network.

**Default route:**
"If no specific route matches, send traffic to 192.168.1.1 using eth0."

```
0.0.0.0/0 via 192.168.1.1 dev eth0
OR
default via 192.168.1.1 dev eth0
```

This is 192.168.1.1 default gateway.
When Linux doesn't know where to send packets, it sends them to the gateway.

**Why default route is needed?**
You need Google and Google is not in your local subnet. So your machine cannot directly reach it.
"I don't know where Google is.
I'll send traffic to my gateway."

## 12. traceroute

traceroute shows the path packets take from your machine to a destination.

Suppose curl is slow, you want to know

- Where is the delay?
- My machine?
- My router?
- ISP?
- Internet?
- Google?

Use: `traceroute google.com`
Output:

```
1   192.168.1.1      1 ms
2   10.10.10.1       5 ms
3   172.16.100.1    10 ms
4   72.x.x.x        15 ms
5   142.250.x.x     20 ms
```

Each line is called a hop.
Every forwarding step = one hop.
Asterisk means: No response received for that hop. It does NOT always mean failure. Many routers intentionally block traceroute responses.

Traceroute uses the TTL (Time To Live) field in IP packets.
Alternative: `tracepath google.com`

## 13. Think layer by layer

Jenkins cannot connect to an application server.

1. is the machine reachable?
2. Does DNS resolve?
3. is the route correct?
4. Is the port reachable?
5. Is the service listening?
6. Is the application healthy?
7. Are firewall/security rules blocking it?

```
1. ping app-server
2. getent hosts app-server
3. ip route, ip route get 10.10.20.30
4. nc -vz app-server 443
5. ss -lntp
6. curl -v http://app-server:8080
7. iptables -L -n OR firewall-cmd --list-all OR ufw status
```

if port check is time out
suspect:
❌ Timeout

Immediately suspect:

- Firewall
- Security Group
- Network ACL
- Routing issues can also cause a timeout.

**Troubleshooting pyramid:**

1. DNS
2. Reachability
3. Routing
4. Port
5. Service
6. Application
7. Firewall/Security

## 14. Linux Networking Command Cheat Sheet

### General / Interfaces

| What are you checking? | Command           | When to use                                  |
| ---------------------- | ----------------- | -------------------------------------------- |
| All interfaces + IPs   | ip addr / ip a    | First command for networking troubleshooting |
| Only IP addresses      | hostname -I       | Quickly see machine IPs                      |
| Network interfaces     | ip link           | Check interface names and status             |
| Loopback interface     | ip addr show lo   | Verify localhost configuration               |
| Specific interface     | ip addr show eth0 | View one NIC's details                       |
| IPv4 only              | ip -4 addr        | Focus on IPv4                                |
| IPv6 only              | ip -6 addr        | Focus on IPv6                                |

### DNS

| What are you checking?                  | Command                 | When to use                           |
| --------------------------------------- | ----------------------- | ------------------------------------- |
| Actual hostname resolution used by apps | getent hosts google.com | Best DNS check for Linux applications |
| Quick DNS lookup                        | nslookup google.com     | Basic DNS troubleshooting             |
| Detailed DNS info                       | dig google.com          | Deep DNS troubleshooting              |
| Just the DNS answer                     | dig +short google.com   | Scripts and quick checks              |
| Specific DNS server                     | dig @8.8.8.8 google.com | Compare DNS responses                 |
| Configured DNS servers                  | cat /etc/resolv.conf    | Check what DNS server Linux uses      |

### Connectivity

| What are you checking? | Command        | When to use              |
| ---------------------- | -------------- | ------------------------ |
| Host reachability      | ping host      | Is machine reachable?    |
| Send 4 packets only    | ping -c 4 host | Quick connectivity test  |
| Continuous monitoring  | ping host      | Watch connection quality |

### Routing

| What are you checking?     | Command                 | When to use                 |
| -------------------------- | ----------------------- | --------------------------- |
| Routing table              | ip route                | See all routes              |
| Default gateway            | ip route\| grep default | Find gateway quickly        |
| Route to destination       | ip route get 8.8.8.8    | Check path Linux will take  |
| Specific destination route | ip route get<ip></ip>   | Troubleshoot routing issues |

### Path Analysis

| What are you checking? | Command         | When to use                            |
| ---------------------- | --------------- | -------------------------------------- |
| Network path/hops      | traceroute host | Find where packets are delayed/dropped |
| Alternative traceroute | tracepath host  | Usually works without root             |

### Port Reachability

| What are you checking? | Command         | When to use                        |
| ---------------------- | --------------- | ---------------------------------- |
| TCP port reachable?    | nc -vz host 443 | Most common port connectivity test |
| Old alternative        | telnet host 443 | Same purpose as nc                 |

### Open / Listening Ports

| What are you checking? | Command              | When to use                   |
| ---------------------- | -------------------- | ----------------------------- |
| Everything listening   | ss -tulpn            | Most useful overall           |
| TCP + process names    | ss -lntp             | Which process owns TCP ports? |
| Listening ports only   | ss -tuln             | Quick port list               |
| TCP listening only     | ss -lnt              | Check web/database services   |
| Specific port          | ss -lntp\| grep 8080 | Check one service             |

### Process Using Port

| What are you checking? | Command            | When to use                   |
| ---------------------- | ------------------ | ----------------------------- |
| Who owns port 8080?    | sudo lsof -i :8080 | Port conflict troubleshooting |
| Who owns port 443?     | sudo lsof -i :443  | SSL/web troubleshooting       |

### HTTP / HTTPS

| What are you checking?     | Command                                      | When to use                            |
| -------------------------- | -------------------------------------------- | -------------------------------------- |
| Basic webpage/API response | curl https://host                            | Fetch content                          |
| Headers only               | curl -I https://host                         | Check HTTP status                      |
| Verbose connection details | curl -v https://host                         | DNS + TCP + TLS + HTTP troubleshooting |
| Follow redirects           | curl -L https://host                         | Websites with redirects                |
| Only HTTP status code      | curl -o /dev/null -s -w "%{http_code}\n" URL | Monitoring scripts                     |

### Firewall

| What are you checking? | Command                 | When to use                |
| ---------------------- | ----------------------- | -------------------------- |
| iptables rules         | iptables -L -n          | Traditional Linux firewall |
| UFW rules              | ufw status              | Ubuntu firewall            |
| firewalld rules        | firewall-cmd --list-all | RHEL/CentOS/Rocky          |

### My Favorite DevOps Troubleshooting Sequence

| Layer              | Command                    |
| ------------------ | -------------------------- |
| DNS                | getent hosts hostname      |
| Reachability       | ping hostname              |
| Routing            | ip route get<ip></ip>      |
| Port Reachability  | nc -vz hostname 443        |
| Service Listening  | ss -lntp                   |
| Application Health | curl -v https://host       |
| Security Rules     | iptables -L -n / SG / NACL |

Remember:
`getent → ping → ip route get → nc → ss → curl → firewall`

