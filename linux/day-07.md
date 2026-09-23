## 1. grep
Global Regular Expression Print
-i : ignore case
-c : count matches (gives numeric value only)
-n : show line numbers (Displays line numbers where matches occur)
-v : invert match (shows lines that do not match)
-E : Extended Regular Expression

without -E: grep "apple\|banana" file.txt
with -E: grep -E "apple|banana" file.txt
grep -E "[0-9]+" file.txt

## 2. cat > file << EOF
This is called a Here Document (Heredoc).
Used to create a file directly from the terminal or inside shell scripts.
Example:
cat > hello.txt << EOF
Hello World
Linux Training
EOF

Breakdown in this case:
cat : Reads text from standard input.
> hello.txt : Redirects output to file. 
<< EOF : Read input until the word EOF is encountered. (It is just a marker. You can use any word.)

## 3. cut
cut is used to extract specific columns, fields, or characters from each line of a file or command output.
syntax: cut OPTION [FILE]

-c   Character position
-f   Field number
-d   Delimiter

cut -c1-3 names.txt : give each lines 1 to 3 characters from starting
cut -c2,4,6 names.txt : (2nd, 4th, and 6th characters)
cut -d ":" -f2 emp.txt : rows with ':' separator of columns, taking 2nd column
cut -d ":" -f1,3 emp.txt : 1st and 3rd column
cut -d ":" -f1-2 emp.txt : range of columns 1st to 2nd
cut -d ":" -f2- : from 2nd column onwards


Without -d, cut assumes TAB delimiter.

cut works best with a consistent delimiter. Otherwise, use awk
cut fails with spaces: Multiple spaces are treated as multiple delimiters.

## 4. sort

By default, sorting is ascending alphabetical order.
default sort is lexicographical (dictionary order). So, does not sort numbers.

-r : reverse order
-n : number sorting
-u : unique values
-f : Ignore case ( Treats uppercase and lowercase as the same.)
-k : Sort by Specific Field
-t : Delimiter-Based Sorting with -k
-c : checks if file is sorted (No output means sorted.)

sort -k2 employees.txt : sorting according to 2nd field
sort -t ":" -k2 data.txt : sorting according to 2nd field with delimiter ':'

## 5. tr
tr stands for translate.

It is used to:
Replace characters
Convert lowercase ↔ uppercase
Delete characters
Compress repeated characters

Unlike grep, cut, or sort, tr works on characters, not lines or fields.
tr replaces characters, not strings. Need sed for that

-d → Delete
-s → Squeeze
-c → Complement (everything except specified set)

Synatx: tr [OPTION] SET1 [SET2]

lowercase to uppercase:
echo "linux" | tr 'a-z' 'A-Z' 
OR
echo "linux" | tr '[:lower:]' '[:upper:]'

uppercase to lowercase:
echo "LINUX DEVOPS" | tr 'A-Z' 'a-z'
OR
cat app.log | tr '[:upper:]' '[:lower:]'

Replace Characters:
echo "10:30:45" | tr ':' '-'

Delete Characters:
echo "hello123" | tr -d '0-9'

Remove Spaces:
echo "Linux DevOps" | tr -d ' '

Remove Newline:
cat file.txt | tr -d '\n'

Delete all alphabets:
echo "abc123xyz" | tr -d 'a-z'

Squeeze Repeated Characters (-s):
echo "Linux      DevOps" | tr -s ' '
Result: Linux DevOps

echo "aaaaabbbbcc" | tr -s 'a-z'
Result: abc

Remove Duplicate Blank Lines:
tr -s '\n'

Extract digits only:
echo "Order123Amount456" | tr -cd '0-9'

Extract Alphabets Only:
echo "abc123xyz" | tr -cd 'a-zA-Z'

Command	Result
tr -d '0-9'		Removes numbers
tr -cd '0-9'	Keeps only numbers

## 6. awk
"grep finds lines, cut extracts columns, awk can do both plus calculations, filtering, formatting, and reporting."

Syntax: awk 'pattern { action }' file

Variable	Meaning
$0		Entire line
$1		First field
$2		Second field
$3		Third field
NF		Number of fields
NR		Record (line) number
-F		Delimiter

Default delimiter = whitespace.
Unlike cut, awk handles multiple spaces well.

Print Entire Line:
awk '{print}' emp.txt
OR
awk '{print $0}' emp.txt

Print first column:
awk '{print $1}' emp.txt

Print multiple columns:
awk '{print $1,$3}' emp.txt

Print Line Numbers also:
awk '{print NR,$0}' emp.txt

Print Number of fields for each line:
awk '{print NF}' emp.txt

Print last column:
awk '{print $3}'
OR
awk '{print $NF}'

Search Like grep:
awk '/Rahul/' emp.txt.  equivalent to grep Rahul emp.txt

Conditional Filtering:
awk '$2 > 40000' salary.txt

Average:
awk '{sum += $1} END {print sum/NR}'

BEGIN and END Blocks:
awk '
BEGIN {print "Report Started"}
{print $1}
END {print "Report Finished"}
' file.txt

Delimiter Handling:
awk -F ":" '{print $1}' /etc/passwd

Count Lines:
awk 'END {print NR}' file.txt
OR
wc -l file.txt

free -m | awk 'NR==2 {print $3}'

df -h | awk '$5+0 > 80' : Finds filesystems above 80%.

awk '$3=="DevOps"' emp.txt

## 7. sed
sed = Stream Editor

It is used to:
Find and replace text
Edit files non-interactively
Delete lines
Insert lines
Print specific lines
Automate configuration changes

Think of it as:
grep finds, awk analyzes, sed modifies.

Syntax: sed 'command' file

^$ : means empty line.
^# : Comments
s → Substitute
g → Global
d → Delete
p → Print
i → Insert before
a → Append after
c → Change line
-i → Edit file in place

Replace Text (s): sed 's/old/new/' file
echo "Linux is good" | sed 's/Linux/Ubuntu/'
means replace first occurrence of Linux with Ubuntu.

echo "Linux Linux Linux" | sed 's/Linux/Ubuntu/g'
Here g means replace all occurences

sed 's/dev/prod/' file
Changes output only.

sed -i 's/dev/prod/' file
Changes the actual file.

Delete Lines (d):
sed '2d' file.txt
2nd line deleted

Delete Multiple Lines:
sed '2,4d' file.txt
Deletes lines 2 through 4.

Delete Empty Lines:
sed '/^$/d' file.txt

Print Specific Lines (-n and p):
sed -n '3p' file.txt

Print range of lines:
sed -n '2,4p' file.txt

Insert Line before:
sed '/Docker/i Kubernetes' file.txt
Kubernetes will be placed vefore Docker line

Append line after:
sed '/Docker/a Jenkins' file.txt

Change Entire Line (c):
sed '/Docker/c Container Platform' file.txt

Show all lines with numbers:
sed = file.txt
OR
nl file.txt

Using Regex:
sed 's/[Ee][Rr][Rr][Oo][Rr]/FAILED/g'

Replace digits:
echo "Build123" | sed 's/[0-9]/X/g'

Delete comments:
sed '/^#/d' config.txt

Extract Error lines:
sed -n '/ERROR/p' app.log
OR
grep ERROR app.log
