## 1. `case` Statement
- The `case` statement is used for branching logic based on a variable’s value.
- Syntax:
  ```bash
  case $variable in
      pattern1)
          commands
          ;;
      pattern2)
          commands
          ;;
      *)
          default commands
          ;;
  esac
```

- Example:
read -p "Enter choice: " choice
case $choice in
    1) echo "Server Health";;
    2) echo "Network Check";;
    3) echo "Service Check";;
    *) echo "Invalid choice";;
esac

## 2. `read` Command
- Used to take input from the user.
- Syntax:
read -p "Prompt message: " variable

- Examples:
read -p "Enter hostname: " host
echo "You entered: $host"

## 3. Condition with /dev/null
- command > /dev/null 2>&1
- Explanation:
	- > /dev/null → Redirects standard output (stdout) to /dev/null, a special file that discards all data (like a "black hole").
	- 2>&1 → Redirects standard error (stderr) (file descriptor 2) to the same place as stdout (file descriptor 1).
	- Together: Both stdout and stderr are discarded.
- Purpose: Run a command silently, only checking its exit status.

