1. Linux users and groups:
whoami: tells the currently logged in username
who: tells the currently logged in username, from where it is logged in, when its logged in.
	piyush pts/1 2026-09-19 time
        Username  terminal/1 date time
pts stands for pseudo-terminal slave.
if other terminal exists than /2, /3...
id: shows the userId, groupID, groups I belong to
	uid=1000(piyush) gid=1000(piyush) groups=..............
Linux doesn't internally identify users only by their names. It gives every user a numerical ID.
A Linux user can belong to one or more groups.
groups: shows the group name you are into

Linux stores info about users and groups in these dirs:
/etc/passwd → USER database
/etc/group  → GROUP database

cat /etc/passwd each line means a user:
username:password:UID:GID:GECOS:home_directory:login_shell
password: shown x. as before passwd were stroed here only but in modern systems passwd hashes are stored in  /etc/shadow
GECOS field: It can contain information such as: Full name, Office information, Phone number
login shell: It means when you log in as piyush, Linux uses Bash as your command-line shell.


Root is the superuser on Linux. It has uid 0
Why are there 20+ users?" Because Linux creates many system/service accounts.
These aren't necessarily people. They're often used by services/processes so that those services don't have to run as root.
For example: www-data        is commonly used by web servers.
/usr/sbin/nologin      That's important. It means this account isn't intended for interactive login.

cat /etc/group gives this
group_name:password:GID:members
example: sudo:x:27:piyush

There are primary and secondary/supplementary groups.
Primary groups are Exactly 1 per user. Secondary can be multiple
Primary groups are automatically created with the same name as the username upon user creation.
Automatically owns any new file or directory the user creates.

2. Linux Permissions
file_type owner group others

r = 4
w = 2
x = 1

Therefore:

7 = rwx
6 = rw-
5 = r-x
4 = r--

755 = rwxr-xr-x 
700 = rwx------
644 = rw-r--r-- 
600 = rw-------

3. Pipes & Redirection
Standard output — stdout=Normal successful output
Standard error — stderr=Error/warning messages

Linux represents:
0 → stdin   → input
1 → stdout  → normal output
2 → stderr  → error output


If you want stdout and stderr to both not come on terminal than
ls /valid-folder /invalid-folder > output.txt 2> errors.txt

&  When placed at the end of a command means Run this command in the background.
2>&1 means Send stderr (2) to wherever stdout (1) is currently going

>       output goes INTO a file
>>      output goes INTO a file (append)
<       input comes FROM a file example: sort < files.txt
|       output goes INTO another command
2>      ERROR output goes INTO a file 
2>>     ERROR output goes INTO a file (append)

4. Text Processing Commands
grep
tail
head
wc
sort: sorts lines of text
uniq: removes adjacent duplicate lines. adjacent means one after other.
cut: is used to extract specific parts/columns from each line.

sort -r fruits.txt (Reverse Sort)
Normal sort just sorts text/strings not numericals. For numerical use this sort -n numbers.txt

uniq is mostly used with sort as 
sort fruits.txt | uniq
because duplicates become adjacent and than uniq can remove them
sort fruits.txt | uniq -c     c means count the occurences

cut -d: -f2 fruits.txt
d means delimiter type f means which field to show

cut -d: -f7 /etc/passwd | sort | uniq -c

5. Linux Processes
ps: process status, static info of processes in current terminal session
ps aux: static process status for all users.
top: live process status. q means quit, P means sort by CPU, M means sort by memory, k means kill a process
pgrep:  Use pgrep process name for just getting all PIDs related to that process
kill: kill PID, sends signal to the process, Please terminate gracefully.
killall: killall process_name. kill all the PIDs for that process_name. 

ps -f gives more data
pgrep -a nginx (PID+Process name)
kill -9 PID: stop immeiately


6. Services & systemd

systemctl is the command used to interact with systemd, Linux's service and system manager.
Check service status: systemctl status ssh
Start a service: sudo systemctl start nginx
Stop a service: sudo systemctl stop nginx
Restart a service: sudo systemctl restart nginx
Useful after changing configuration.

Reload a service
sudo systemctl reload nginx
Reload means: "Re-read your configuration without completely restarting the service." Whether a service supports reload depends on the service.

Starting a service does not necessarily mean it will automatically start after reboot.
Enable: sudo systemctl enable nginx
Means: Configure Nginx to start automatically during boot.

sudo systemctl enable --now nginx
Meaning: Enable it for boot and start it now.

Check whether a service is enabled
systemctl is-enabled nginx
Possible output: enabled or disabled

Check whether a service is running
systemctl is-active nginx
Possible output: active or inactive

List services
systemctl list-units --type=service
This shows currently loaded service units.

You can also see failed services:
systemctl --failed
This is very useful during troubleshooting.

journalctl — Read system/service logs
Now suppose: systemctl status nginx
shows: Active: failed
The next question is: WHY did it fail?
That's where journalctl comes in. It displays logs collected by systemd's journal.

Logs for a specific servoce: journalctl -u nginx
-u means unit.

Logs from the current boot
journalctl -b
-b = current boot.
This is useful when: "The server rebooted and something isn't working."

Follow Logs live: Ctrl + C to exit
journalctl -u nginx -f
-f = follow.
It behaves somewhat like: tail -f logfile


journalctl -u nginx -n 50
means: Show the last 50 log entries for nginx.


journalctl -u nginx --since "1 hour ago" Or today


7. Environment Varibales

env: shows the environment variables available to your current shell/process environment.

printenv: Specifically designed to print environment variables.
You can also ask for one variable: printenv HOME

echo $PATH: one of the most important Linux env variables
PATH tells Linux: "When I type a command, which directories should I search for that executable?"
Linux needs to find the executable of the command
like for ls command it needs to look for /usr/bin/ls
You can look the executable path of a command via: which <command>

Why does PATH use :?
Your PATH looks like: /usr/local/bin:/usr/bin:/bin
The : separates directories.
So conceptually:
PATH
 │
 ├── /usr/local/bin
 ├── /usr/bin
 └── /bin

When you run: git
Linux searches these directories to find git.

echo $HOME: HOME tells Linux, This is the current user's home directory.
cd ~ = cd $HOME = cd

echo $USER: gives current username
whoami = ehco $USER

The $ means: "Give me the value of this variable."

Creating your own varibale:
export DEVOPS=1
It does not save it permanently for other terminal sessions also

if you simple do: DEVOPS=1
then you are simply creating a shell variable.

Export will work for your bash, child bash, scripts etc. but only for this terminal in which you have created.

8. Service 
Process = a running program
Service = a program managed to provide some functionality, usually in the background
On a system using systemd, services are managed as systemd units.

A service often runs one or more processes.
