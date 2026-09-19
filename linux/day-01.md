Hi, these are my first day notes of Linux
So, today I did these things:
1. Checked WSL is installed, in Powershell ran, wsl --status
2. Then opened Ubuntu, used these commands
	;pwd, means present working directory. it shows the absolute path of the dir in which you are currently in
	;whoami, shows the name of the user like ubuntu or piyush whoever is currently signed in.
	;uname -a, prints detailed information about the system's hardware, operating system, and software kernel
	;cat /etc/os-release, shows the full info of the system. Outputs details like NAME, VERSION, ID, and PRETTY_NAME
3. Understood the dir representations. Like where to use / and where not. If it is used before fir name than it means its a root dir because / means root dir. And if it is not used and directly starts with dir name than it is a relative path and in which dir you are that path starts from there automatically. If this / is used afterwards, its same as not using it as it just shows the end of the path.
4. mkdir creates the dir. mkdir -p also creates the parent dir of it is not pesent.
5. tree: it shows the dir strucuture
6. sudo apt update    sudo apt install <name>
7. git was already installed. checked it with git --version
	;than set the global values:
		; git config --global user.name ""
		; git config --global user.email ""
	;TO check the global values, git config --global --list
	; created the repo via UI
	;Tried cloning it but it was showing that this dir already exists. So, I know that same name of dir can't exist so, I'll just puch the whole changes no need to clone it
8. Linux Fundamentals
	; ls, ls -a, ls -l: it lists the files/dir in the folder, a means hidden files, and l means more detailed
	; cd, cd .., cd ~, cd -: all means chaging the dir. cd .. takes you to the parent dir. cd ~ takes you to the user's home dir which is /home/user_name. cd - takes you to the previous working dir.
9. Absolute path and relative path. absolute path means starts with root. relative path means starts from where you are currently.
10. Creating file and dir
	;mkdir
	;touch: it create the file
	;cp: copy 
	;mv: moves or renames
	;rm: remove    rm -rf: removes iteratively a non-empty dir
	;rmdir: removes an empty dir
11. Reading Files
	; cat: shows you all the content in the screen
	; head: shows first 10 lines     head -n 5: shows first 5 lines	
	; tail: shows last 10 lines
	; less: it shows you in pagination, so that long files like logs does not consume too much memory while viewing. To exit, press q
12. Redirections
	; > : writes in the file the output of the command. If the file already have something than it overwrites it.
	; >> : appends the output of the command to the file
13. Finding things
	; find: helps to look for files, dir inside a dir. you can tell it to look for a absolute file or a pattern like just excel files. find /tmp -name "*.log"
	; grep: it looks for the pattern inside the file. it is used to look for words in the files. grep -i is the case-insensitive version of it
14. File info
	; file :  it outputs the filename followed by a human-readable description of its classification (such as Bourne-Again shell script, ASCII text, or ELF 64-bit LSB executable)
	; wc: means word count shows (word, lines, bytes) and if you want separately than use flags, wc -w, wc -l, wc -c
	; du: shows the storage of a particular file/dir. du -h file.txt
	; df: shows the file system disk storage. df -h
; -h means human readable
15. Linux File System
	; / : root dir. everything strts from here
	; /home: dir is where the normal users dir is created.
	; /root: root user home dir
	; /tmp: temporary files
	; /usr: user-space programs/data
	; /opt: optional/additional softwares
	; /proc: process/lernel info
	; /etc: Configurations
	; /bin: stands for "binary" and contains the essential user command binaries required for the system to boot and function properly
	; /dev:  Linux represents hardware devices (like disks, keyboards, and terminals) as special files inside the /dev folder.
16. Linux Processes
	; ps: static/snapshot of info of currently running processes in this terminal session.
	; ps aux: shows the static info in more detailed manner for all the terminal sessions across all users.
	; top: shows the real time info of the running processes. exit with q
; shows PID (Process Identification number), %CPU, %Mem etc.
17. Basic System Info
	; hostname
	; uptime
	; free -h : shows memoey/ram usage
	; df -h: shows system storage 
	; uname -a
18. Linux is an open-source Operating System that manages hardware and software resources. It is used widely for cloud computing, servers, devops due to its stability, flexibilty, and security.
19. Shell is a command line interpreter that is a medium between the user and the Linux OS. It accepts the commands from the user, interprets them, and passes them to the kernel for execution.
20. Bash means Bourne Again Shell. It is one type of the shell, the default ones for Linux systems.
21. PID (Process ID) is a unique identifier assigned by the OS to every running process. It helps the system and users identify, monitor, manage, and terminate specific processes.
22. PPID is Parent Process ID. It identifies the process that started the current process. 
23. Issue Faced while pushing to Github:
What happened

You initially had your Git remote configured with HTTPS:

https://github.com/wackypiyush/devops-learning.git

When you ran:

git push -u origin main

GitHub asked for:

Username for 'https://github.com':
Password for 'https://wackypiyush@github.com':

You entered your GitHub credentials, but GitHub rejected the password:

remote: Invalid username or token.
Password authentication is not supported for Git operations.
Why?

GitHub doesn't allow normal account passwords for Git operations over HTTPS anymore.

For HTTPS, you would need a Personal Access Token (PAT) instead of your GitHub password.

We chose a different approach: SSH authentication.

What we did
1. Generated an SSH key
ssh-keygen -t ed25519 -C "wacky.piyush@gmail.com"

This created:

~/.ssh/id_ed25519

→ private key — keep this secret

and:

~/.ssh/id_ed25519.pub

→ public key — this can be added to GitHub.

2. Started the SSH agent
eval "$(ssh-agent -s)"

Then loaded the private key:

ssh-add ~/.ssh/id_ed25519

Git responded:

Identity added: /home/piyush/.ssh/id_ed25519

So the SSH agent now knows about your key.

3. Added the public key to GitHub

You add the contents of:

cat ~/.ssh/id_ed25519.pub

to:

GitHub → Settings → SSH and GPG keys → New SSH key

GitHub then associates that public key with your account.

4. Tested authentication

We ran:

ssh -T git@github.com

and got:

Hi wackypiyush! You've successfully authenticated,
but GitHub does not provide shell access.

This is success. ✅

It means:

Your computer
    ↓
SSH private key
    ↓
GitHub
    ↓
"Yes, this is wackypiyush"
5. Change Git from HTTPS → SSH

Instead of:

https://github.com/wackypiyush/devops-learning.git

the SSH remote is:

git@github.com:wackypiyush/devops-learning.git

You change it with:

git remote set-url origin git@github.com:wackypiyush/devops-learning.git

Then:

git push -u origin main

Git uses your SSH key instead of asking for your GitHub password.

The key concept to remember

HTTPS:

Git → GitHub
     ↓
Username + Personal Access Token

SSH:

Git → SSH → GitHub
       ↓
   SSH key pair
