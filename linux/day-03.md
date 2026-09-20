1. Shebang
#!/bin/bash
is called a shebang (or hashbang). It tells the system which interpreter should be used to execute the script.

2. Execute a script
./variables.sh
OR
bash variables.sh

3. $ variable expansion
echo "$name"
$name means: Expand the value stored in the variable name

4. Important Bash rule
Do:
name="Piyush"
Not:
name = "Piyush"
There cannot be spaces around = when assigning a variable.

5. $(command) means: Execute the command and substitute its output here.
current_user=$(whoami)
echo "User: $current_user"

6. Script arguments:
$0 → script name
$1 → first argument
$2 → second argument
$# → number of arguments
example:
./arguments.sh hello world
$0 = ./arguments.sh
$1 = hello
$2 = world
$# = 2

7. Conditions:
if [ -f "$1" ]; then
	echo "File exists" 
else 
	echo "File does not exist"
fi

8.Learn these:

-f    file exists
-d    directory exists
-e    path exists
-z    string is empty
-n    string is not empty

Also understand numeric comparisons:

-eq    equal
-ne    not equal
-gt    greater than
-lt    less than
-ge    greater/equal
-le    less/equal

9. exit codes:
echo $?
contains the exit status of the most recently executed command.

The basic convention is:
0       → success
non-zero → failure

10. Loops
for server in server1 server2 server3 
do 
	echo "Checking $server" 
done

for number in 1 2 3 4 5 
do 
	echo "Number: $number" 
done

11. Functions

show_info() { 
	echo "Hostname: $(hostname)" 
	echo "User: $(whoami)" 
	echo "Uptime: $(uptime -p)" 
} 

show_info

show_info() {
    ...
}
defines a function.

Then: show_info
calls it.

12. Error Handling
set -e
It exists the script when any error happens.
When its not in the script, then if the error happens but next commands still executes.
example:
#!/bin/bash 
set -e 
echo "Starting" 
ls /does-not-exist 
echo "This should not execute"

Result:
Starting
ls: cannot access '/does-not-exist': No such file or directory

without set -e
Result:
Starting
ls: cannot access '/does-not-exist': No such file or directory
This should not execute

13. Also, if you want to explicitly exit successfully:
exit 0

14. Rule to remember
For now, prefer:
"$variable"
when using variables in conditions/commands, unless you specifically know why unquoted expansion is appropriate.

15. Used awk and tr this time for an exercise but not yet clearly know about them.

16. bash -x runs a Bash script in debug/trace mode.
It prints each command after Bash has expanded variables and substitutions, just before executing it.
example:
#!/bin/bash

name="Piyush"
echo "Hello $name"


bash -x test.sh
Result:
+ name=Piyush
+ echo 'Hello Piyush'
Hello Piyush

17. Works manually, fails in Jenkins

This is the most important one.

You'd investigate the environment in which the script is running.

Thing	Question
PATH	Can Jenkins find the commands?
Environment variables	Are required variables available?
Permissions	Does the Jenkins user have permission?
Working directory	Is the script looking for files in the correct location?
User	Who is actually running the script?
Exit codes	Which command is returning non-zero?
Logs	What exactly failed?
