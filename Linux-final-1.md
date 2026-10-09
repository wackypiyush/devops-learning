# Linux for DevOps - Ultimate Interview Revision Sheet

---

# 1. Linux Troubleshooting Order (MOST IMPORTANT)

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
Firewall
 ↓
Logs
```

Commands:

```bash
getent hosts HOST
ping -c 4 HOST
ip route get IP
nc -vz HOST PORT
ss -lntp
curl -v URL
firewall check
journalctl
```

Remember:

```text
getent → ping → route → nc → ss → curl → firewall → logs
```

---

# 2. Server Health Commands

CPU:

```bash
top
ps aux --sort=-%cpu | head
```

Memory:

```bash
free -h
ps aux --sort=-%mem | head
```

Disk:

```bash
df -h
du -sh /*
```

Processes:

```bash
ps aux
top
pgrep nginx
```

---

# 3. Process vs Service

```text
Process = Running Program

Service = Background functionality managed by systemd

One service can run one or more processes
```

Examples:

```text
nginx = Service
nginx worker = Process
```

---

# 4. systemd / Services

Status:

```bash
systemctl status nginx
```

Start:

```bash
systemctl start nginx
```

Stop:

```bash
systemctl stop nginx
```

Restart:

```bash
systemctl restart nginx
```

Reload Config:

```bash
systemctl reload nginx
```

Enable at Boot:

```bash
systemctl enable nginx
```

Enable and Start:

```bash
systemctl enable --now nginx
```

Failed Services:

```bash
systemctl --failed
```

List Services:

```bash
systemctl list-units --type=service
```

---

# 5. Logs

Live Application Log:

```bash
tail -f app.log
```

Live Service Log:

```bash
journalctl -u nginx -f
```

Last 50 Lines:

```bash
journalctl -u nginx -n 50
```

Current Boot:

```bash
journalctl -b
```

Remember:

```text
tail -f = follow file log

journalctl -f = follow service log
```

---

# 6. Users, Groups & Ownership

User Database:

```text
/etc/passwd
```

Group Database:

```text
/etc/group
```

Passwd Structure:

```text
username:x:UID:GID:GECOS:HOME:SHELL
```

Root User:

```text
UID = 0
```

Current User:

```bash
whoami
id
groups
```

Change Owner:

```bash
sudo chown user file.txt
```

Change Owner and Group:

```bash
sudo chown user:group file.txt
```

Example:

```bash
sudo chown jenkins:jenkins app.log
```

Change Group Only:

```bash
sudo chgrp developers app.log
```

Check Ownership:

```bash
ls -l
```

---

# 7. Permissions

```text
r = 4
w = 2
x = 1
```

Important:

```text
755 = rwxr-xr-x
700 = rwx------
644 = rw-r--r--
600 = rw-------
777 = rwxrwxrwx
```

Change Permissions:

```bash
chmod 755 script.sh
chmod +x script.sh
chmod u+x script.sh
```

File Checks:

```bash
-f file exists
-d directory exists
-e path exists
-z string empty
-n string not empty
```

Numeric Comparisons:

```bash
-eq equal
-ne not equal
-gt greater than
-lt less than
-ge greater/equal
-le less/equal
```

---

# 8. Redirection

```text
0 = stdin
1 = stdout
2 = stderr
```

stdout:

```bash
> output.txt
```

Append:

```bash
>> output.txt
```

stderr:

```bash
2> error.txt
```

Both stdout and stderr:

```bash
> output.txt 2>&1
```

Discard Output:

```bash
> /dev/null 2>&1
```

---

# 9. Bash Scripting

Run Scripts:

```bash
./script.sh
bash script.sh
```

Shebang:

```bash
#!/bin/bash
```

Arguments:

```text
$0 = script name
$1 = first argument
$2 = second argument
$# = argument count
```

Exit Code:

```bash
echo $?
```

```text
0 = success
non-zero = failure
```

Debug:

```bash
bash -x script.sh
```

Stop on Error:

```bash
set -e
```

Command Substitution:

```bash
current_user=$(whoami)
```

Functions:

```bash
my_func() {
    echo "Hello"
}
```

---

# 10. Jenkins Script Fails

Always Check:

```text
PATH
Environment Variables
Permissions
Working Directory
User
Exit Codes
Logs
```

Common Reason:

```text
Works manually
Fails in Jenkins
```

Because:

```text
Different user
Different PATH
Different environment
Missing permissions
Missing credentials
```

Useful:

```bash
whoami
pwd
echo $PATH
env
echo $?
```

---

# 11. Environment Variables

Show All:

```bash
env
printenv
```

Important Variables:

```bash
echo $PATH
echo $HOME
echo $USER
```

PATH Example:

```text
/usr/local/bin:/usr/bin:/bin
```

Find Executable:

```bash
which git
which kubectl
```

Shell Variable:

```bash
DEVOPS=1
```

Environment Variable:

```bash
export DEVOPS=1
```

---

# 12. Networking Foundations

Remember:

```text
IP       = Where?
MAC      = Who?
Port     = Which Service?
DNS      = Name → IP
Router   = Forwards Packets
Gateway  = Router IP
Subnet   = Group of Hosts
```

---

# 13. Networking Commands

IPs:

```bash
ip addr
hostname -I
```

Interfaces / MAC:

```bash
ip link
```

Routes:

```bash
ip route
ip route get IP
```

Loopback:

```bash
ip addr show lo
```

Remember:

```text
localhost = 127.0.0.1
```

---

# 14. Common Ports

```text
22    SSH
53    DNS
80    HTTP
443   HTTPS
3306  MySQL
5432  PostgreSQL
6443  Kubernetes API
8080  Jenkins/Tomcat
```

---

# 15. DNS

Check Resolution:

```bash
getent hosts google.com
```

Quick Lookup:

```bash
nslookup google.com
```

Detailed Lookup:

```bash
dig google.com
```

Script Friendly:

```bash
dig +short google.com
```

DNS Configuration:

```bash
cat /etc/resolv.conf
```

---

# 16. Connectivity

Host Reachability:

```bash
ping google.com
```

Port Reachability:

```bash
nc -vz google.com 443
```

Remember:

```text
Ping Success
≠
HTTP Success
```

Ping Uses:

```text
ICMP
```

NOT:

```text
TCP
UDP
```

---

# 17. Ports

Listening Ports:

```bash
ss -tulpn
```

TCP Listening:

```bash
ss -lntp
```

Specific Port:

```bash
ss -lntp | grep 8080
```

Who Owns Port:

```bash
sudo lsof -i :8080
```

---

# 18. HTTP Troubleshooting

Headers Only:

```bash
curl -I URL
```

Verbose:

```bash
curl -v URL
```

Follow Redirects:

```bash
curl -L URL
```

Status Code Only:

```bash
curl -o /dev/null -s -w "%{http_code}\n" URL
```

---

# 19. HTTP Status Codes

```text
200 Success

301 Redirect
302 Temporary Redirect

401 Unauthorized
403 Forbidden
404 Not Found

500 Internal Server Error
502 Bad Gateway
503 Service Unavailable
```

---

# 20. Connection Refused vs Timeout

Connection Refused:

```text
Host reached
Port reached
Nothing listening
Service crashed
Wrong port
```

Connection Timeout:

```text
No response

Firewall
Security Group
Routing issue
Network ACL
Wrong IP
```

---

# 21. Package Management

Ubuntu / Debian:

Update Package List:

```bash
sudo apt update
```

Upgrade Packages:

```bash
sudo apt upgrade
```

Install Package:

```bash
sudo apt install nginx
```

Remove Package:

```bash
sudo apt remove nginx
```

Search Package:

```bash
apt search nginx
```

RHEL / CentOS:

```bash
yum install nginx
dnf install nginx
```

Check Package Installed:

```bash
dpkg -l
rpm -qa
```

---

# 22. Archives & Compression

Create Archive:

```bash
tar -cvf app.tar app/
```

Extract Archive:

```bash
tar -xvf app.tar
```

Create Compressed Archive:

```bash
tar -czvf app.tar.gz app/
```

Extract Compressed Archive:

```bash
tar -xzvf app.tar.gz
```

Compress:

```bash
gzip file.log
```

Decompress:

```bash
gunzip file.log.gz
```

Zip:

```bash
zip -r archive.zip project/
```

Unzip:

```bash
unzip archive.zip
```

Remember:

```text
c = create
x = extract
v = verbose
f = file
z = gzip
```

---

# 23. Cron Jobs

Edit Crontab:

```bash
crontab -e
```

List Cron Jobs:

```bash
crontab -l
```

Remove Cron Jobs:

```bash
crontab -r
```

Format:

```text
* * * * * command
│ │ │ │ │
│ │ │ │ └─ Day of Week
│ │ │ └── Month
│ │ └──── Day of Month
│ └────── Hour
└──────── Minute
```

Examples:

Run Every Minute:

```text
* * * * * /home/piyush/script.sh
```

Run Daily at 2 AM:

```text
0 2 * * * /home/piyush/backup.sh
```

Run Every Sunday at 3 AM:

```text
0 3 * * 0 /home/piyush/cleanup.sh
```

Interview Answer:

```text
Cron is used to schedule repetitive tasks such as backups, cleanup jobs, report generation, health checks and automation scripts.
```

---

# 24. Text Processing

### grep

```bash
grep -i
grep -v
grep -c
grep -n
grep -E
```

### cut

```bash
cut -d ":" -f2
cut -d ":" -f2-
cut -c1-3
```

### sort

```bash
sort -n
sort -u
sort -t ":" -k2
```

### tr

```bash
tr -d
tr -s
tr -cd
```

### awk

```bash
awk '{print $1}'
awk '{print $NF}'
awk '{print NR,$0}'
awk -F ":" '{print $1}'
awk '$2 > 40000'
df -h | awk '$5+0 > 80'
```

### sed

```bash
sed -i 's/dev/prod/g'
sed '/^#/d'
sed '/^$/d'
sed '5d'
```

Remember:

```text
grep = Find
cut  = Extract
tr   = Translate/Delete
awk  = Analyze/Report
sed  = Modify/Edit
```

---

# 25. 30-Second DevOps Interview Answer

Q: How would you troubleshoot an application that is not reachable?

Answer:

```text
First I would verify DNS resolution using getent hosts.

Then I would verify host reachability using ping and inspect routing using ip route get.

Next I would test TCP connectivity using nc -vz.

If I have access to the server, I would check whether the service is listening using ss and verify service status using systemctl.

Then I would test the application using curl -v and analyze the HTTP response.

If connectivity still fails, I would investigate firewall, security groups and network ACLs.

Finally I would inspect system and application logs using journalctl and application logs.
```

---

# 26. ONLY 20 COMMANDS TO MEMORIZE

```bash
ip addr
ip route
getent hosts
ping -c 4
nc -vz
ss -lntp
lsof -i
curl -I
curl -v
ps aux
top
free -h
df -h
systemctl status
journalctl -u
tail -f
find
grep
awk
sed
```

---

# GOLDEN INTERVIEW FLOW

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
SYSTEMCTL
 ↓
CURL
 ↓
FIREWALL
 ↓
LOGS
```
