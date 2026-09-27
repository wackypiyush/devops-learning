# Git for DevOps --- Complete Notes & Practice Lab

> Practical Git notes based on the Git concepts studied and the
> `git-lab` practice session.

------------------------------------------------------------------------

# 1. Git Mental Model

Git tracks changes through three main areas:

``` text
Working Directory
       ↓ git add
Staging Area (Index)
       ↓ git commit
Repository
```

A useful mental model:

``` text
Working Directory → Staging Area → Commit
      git add           git commit
```

## Important Commands

``` bash
git status
git diff
git diff --staged
git log
git show
```

### `git status`

Shows:

-   Current branch
-   Modified files
-   Staged files
-   Untracked files
-   Whether the working tree is clean
-   Ahead/behind information for a tracked remote

Run it frequently before and after Git operations.

------------------------------------------------------------------------

# 2. `git diff`

Shows changes between the working directory and staging area.

``` bash
git diff
```

Use it to answer:

> What have I changed but not staged?

Example:

``` diff
 Hello DevOps
+Jenkins CI/CD
```

-   `-` = removed/old line
-   `+` = added/new line

## `git diff --staged`

Also:

``` bash
git diff --cached
```

Shows:

``` text
Staging Area
     ↓
Last Commit (HEAD)
```

Use it to answer:

> What exactly am I about to commit?

------------------------------------------------------------------------

# 3. First Git Practice: Create and Commit a File

Example practice flow:

``` bash
echo "Hello DevOps" > app.txt
git status
git add .
git status
git diff --staged
git diff
git commit -m "Initial Commit"
git status
```

Important observation:

Before `git add`:

``` text
app.txt = Untracked
```

After `git add`:

``` text
app.txt = Staged
```

After `git commit`:

``` text
Working tree = Clean
```

### Key lesson

`git add` does not create a commit.

It moves the current version of the file into the staging area.

`git commit` records the staged snapshot in the repository.

------------------------------------------------------------------------

# 4. Modifying a Tracked File

Example:

``` bash
echo "Jenkins CI/CD" >> app.txt
```

Then:

``` bash
git status
git diff
```

At this point:

``` text
Working Directory
      ↓
Modified
```

After:

``` bash
git add app.txt
```

the change becomes staged.

Verify:

``` bash
git diff
```

No output means there are no unstaged changes.

Then:

``` bash
git diff --staged
```

shows what will be committed.

Finally:

``` bash
git commit -m "Add Jenkins Info"
```

------------------------------------------------------------------------

# 5. Git Log and Commit History

## Full log

``` bash
git log
```

## Compact log

``` bash
git log --oneline
```

Example:

``` text
c424179 Add Jenkins Info
221445f Initial Commit
```

The short hash identifies the commit.

## Last N commits

``` bash
git log -5
git log --oneline -5
```

## Graph

``` bash
git log --oneline --graph --decorate --all
```

This is one of the most useful commands for understanding branch
history.

### What the options mean

``` text
--oneline     Short commit representation
--graph       ASCII branch/merge graph
--decorate    Show branch/tag/HEAD references
--all         Show all refs/branches
```

------------------------------------------------------------------------

# 6. `git show`

Shows detailed information about a commit.

``` bash
git show
```

Shows the current `HEAD` commit.

Specific commit:

``` bash
git show <commit-id>
```

Example:

``` bash
git show b455b75
```

It shows:

-   Commit hash
-   Author
-   Date
-   Commit message
-   Actual changes introduced by that commit

------------------------------------------------------------------------

# 7. Branches

A branch is a lightweight pointer to a commit.

It is not a complete copy of the repository.

## List branches

``` bash
git branch
```

Example:

``` text
  feature-login
* main
```

`*` means the current branch.

## Create a branch

``` bash
git branch feature-login
```

## Switch

``` bash
git switch feature-login
```

Older command:

``` bash
git checkout feature-login
```

## Create and switch

``` bash
git switch -c feature-api
```

Older:

``` bash
git checkout -b feature-api
```

## Rename current branch

``` bash
git branch -M main
```

## Delete branch

Safe:

``` bash
git branch -d feature-login
```

Force:

``` bash
git branch -D feature-login
```

## Remote branches

``` bash
git branch -r
```

## Local + remote branches

``` bash
git branch -a
```

------------------------------------------------------------------------

# 8. Branch Pointer and HEAD

Suppose:

``` text
A --- B --- C
          ↑
         main
```

If a new branch is created:

``` text
A --- B --- C
          ↑
        main
        feature
```

Both branches initially point to the same commit.

After committing on `feature`:

``` text
A --- B --- C --- D
          ↑       ↑
         main   feature
```

Only the feature branch moved.

## HEAD

Normally:

``` text
HEAD
 ↓
main
 ↓
commit
```

HEAD represents where you are currently working.

------------------------------------------------------------------------

# 9. Branch Practice: Feature Login

The practice session created:

``` bash
git branch feature-login
git switch feature-login
```

Then:

``` bash
echo "login feature" > login.txt
git add login.txt
git commit -m "Add login feature"
```

History became:

``` text
* 50deada (HEAD -> feature-login) Add login feature
* c424179 (main) Add Jenkins Info
* 221445f Initial Commit
```

Switching back to main:

``` bash
git switch main
```

showed that `login.txt` was not present on `main`.

### Important lesson

A commit made on one branch does not automatically appear on another
branch.

------------------------------------------------------------------------

# 10. Merge

Merge brings changes from one branch into another.

## Correct workflow

If you want to merge `feature-login` into `main`:

``` bash
git switch main
git merge feature-login
```

The branch receiving the changes must be checked out.

## Fast-forward merge

If `main` has not moved since the feature branch was created:

``` text
A --- B --- C
          \
           D
```

Git can simply move the main pointer:

``` text
A --- B --- C --- D
                  ↑
               main
                  ↑
               feature
```

No merge commit is required.

Practice result:

``` text
* 50deada (HEAD -> main, feature-login) Add login feature
* c424179 Add Jenkins Info
* 221445f Initial Commit
```

Both branches pointed to the same commit after the fast-forward.

------------------------------------------------------------------------

# 11. Three-Way Merge

A three-way merge occurs when both branches have new commits after they
diverge.

Example:

``` text
          C --- D  feature
         /
A --- B
         \
          E --- F  main
```

Merging feature into main can create:

``` text
          C --- D
         /       \
A --- B           M
         \       /
          E --- F
```

`M` is a merge commit.

A merge commit normally has two parents.

------------------------------------------------------------------------

# 12. Merge Conflict

A conflict can happen when two branches modify the same part of a file
in incompatible ways.

Practice setup:

On `feature-api`:

``` text
version 1
API enabled
```

On `main`:

``` text
version 1
Production mode
```

Then:

``` bash
git switch main
git merge feature-api
```

Git reported:

``` text
CONFLICT (content): Merge conflict in config.txt
Automatic merge failed
```

The file contained conflict markers:

``` text
version 1
<<<<<<< HEAD
Production mode
=======
API enabled
>>>>>>> feature-api
```

## Meaning

``` text
<<<<<<< HEAD
Current branch's version
=======
Incoming branch's version
>>>>>>> feature-api
```

Resolve the file manually.

Then:

``` bash
git add config.txt
git status
git commit
```

The commit completes the merge.

## Important

After resolving:

``` bash
git add <file>
```

does not itself finish the merge.

You still need:

``` bash
git commit
```

------------------------------------------------------------------------

# 13. Abort a Merge

If you do not want to resolve the conflict:

``` bash
git merge --abort
```

This attempts to return the repository to the state before the merge
started.

------------------------------------------------------------------------

# 14. Investigating Branch History

Use:

``` bash
git log --oneline --graph --decorate --all
```

Example:

``` text
*   d2d439b (HEAD -> main) Merge branch 'feature-api'
|\
| * fe9d2eb (feature-api) Enable API
* | 4261c97 Enable production mode
|/
* c1442dc Add config
```

This graph clearly shows that `main` and `feature-api` had diverged and
were later merged.

------------------------------------------------------------------------

# 15. Stash

`git stash` temporarily saves uncommitted changes and gives you a clean
working directory.

Useful scenario:

``` text
You are working on feature A
↓
Urgent bug needs investigation
↓
You don't want to commit unfinished work
↓
Stash it
↓
Work on the urgent task
```

## Save changes

``` bash
git stash
```

## List stashes

``` bash
git stash list
```

Example:

``` text
stash@{0}
stash@{1}
```

## Inspect

``` bash
git stash show
```

Detailed:

``` bash
git stash show -p
```

Specific stash:

``` bash
git stash show -p stash@{1}
```

## Apply

``` bash
git stash apply
```

Applies the stash but keeps it in the stash list.

Specific:

``` bash
git stash apply stash@{1}
```

## Pop

``` bash
git stash pop
```

Applies the stash and normally removes it if the application succeeds.

## Delete

``` bash
git stash drop
```

Specific:

``` bash
git stash drop stash@{0}
```

Delete all:

``` bash
git stash clear
```

------------------------------------------------------------------------

# 16. Important Stash Practice Lesson

The practice session demonstrated an important situation.

After:

``` bash
git stash
git stash apply
```

the changes were restored into the working directory.

The stash still existed.

Then running:

``` bash
git stash pop
```

again failed because the same changes were already present in the
working directory.

Git reported:

``` text
Your local changes to the following files would be overwritten by merge
```

### Lesson

`apply`:

``` text
Restore changes
+
Keep stash
```

`pop`:

``` text
Restore changes
+
Remove stash if successful
```

Do not repeatedly apply/pop the same stash while its changes are already
present.

------------------------------------------------------------------------

# 17. Multiple Stashes

Practice:

``` bash
echo "feature A" >> app.txt
git stash

echo "Feature B" >> app.txt
git stash
```

Then:

``` bash
git stash list
```

gave:

``` text
stash@{0}
stash@{1}
```

Important:

``` text
stash@{0} = newest stash
stash@{1} = older stash
```

Inspect individually:

``` bash
git stash show -p stash@{0}
git stash show -p stash@{1}
```

This is useful when multiple pieces of work are temporarily stored.

------------------------------------------------------------------------

# 18. Reset

`git reset` moves the current branch/HEAD to another point.

It can affect:

-   Repository/commit history
-   Staging area
-   Working directory

------------------------------------------------------------------------

# 19. `git reset --soft`

``` bash
git reset --soft HEAD~1
```

Moves HEAD back one commit.

The changes remain staged.

Mental model:

``` text
Commit      ← moved back
Staging     ← changes remain
Working Dir ← changes remain
```

Use case:

> I made a commit but want to edit/recreate that commit while keeping
> the changes staged.

Practice confirmed:

``` bash
git reset --soft HEAD~1
git status
```

showed the changes as staged.

------------------------------------------------------------------------

# 20. `git reset` / Mixed Reset

Default reset mode is mixed:

``` bash
git reset HEAD~1
```

The commit is removed from the current branch history, but the file
changes remain in the working directory and become unstaged.

Mental model:

``` text
Commit      ← moved back
Staging     ← cleared for those changes
Working Dir ← changes remain
```

Practice output:

``` text
Unstaged changes after reset:
M app.txt
```

------------------------------------------------------------------------

# 21. `git reset --hard`

``` bash
git reset --hard HEAD~1
```

Moves HEAD back and resets staging + working directory to that commit.

Mental model:

``` text
Commit      ← moved back
Staging     ← reset
Working Dir ← reset
```

### WARNING

Uncommitted changes can be discarded.

Use carefully.

Practice:

``` bash
git commit -m "Commit to Destroy"
git reset --hard HEAD~1
```

The commit disappeared from the normal branch history and the working
tree returned to the previous commit state.

------------------------------------------------------------------------

# 22. Reset Memory Trick

``` text
--soft  = Keep changes staged
--mixed = Keep changes unstaged
--hard  = Reset files too
```

Or:

``` text
soft  → commit removed, staging kept
mixed → commit removed, staging removed
hard  → commit removed, files reset
```

------------------------------------------------------------------------

# 24. Reset vs Revert

## Reset

``` bash
git reset
```

Moves the current branch backward.

Can rewrite local branch history.

Useful for local/private mistakes.

## Revert

``` bash
git revert <commit>
```

Creates a new commit that reverses an earlier commit.

History is preserved.

Example practice:

``` bash
echo "Bad production config" >> app.txt
git add app.txt
git commit -m "Bad prod config"

git revert eb062e4
```

History became:

``` text
Revert "Bad prod config"
Bad prod config
...
```

The bad change was removed from the current file contents while the
original commit remained in history.

### Practical rule

For commits already shared on a team/shared branch:

``` text
Prefer git revert
```

For local/private mistakes:

``` text
git reset can be appropriate
```

------------------------------------------------------------------------

# 25. Diff Investigation

Important commands:

``` bash
git diff
git diff --staged
git diff <commit1> <commit2>
git diff main feature-login
git diff --name-only
```

## Questions answered

  Command                   Question
  ------------------------- -----------------------------------
  `git diff`                What changed but is not staged?
  `git diff --staged`       What will be committed?
  `git diff A B`            What differs between two commits?
  `git diff main feature`   How do two branches differ?
  `git diff --name-only`    Which files differ?

------------------------------------------------------------------------

# 26. History Investigation

Useful commands:

``` bash
git log --oneline
git log -10
git log --author="Piyush"
git log --grep="Jenkins"
git log app.txt
git log --stat
```

A practical investigation sequence:

``` bash
git log --oneline -10
git show <commit-id>
git diff <old-commit> <new-commit>
```

Think:

``` text
git log  → When / which commit?
git show → What did that commit do?
git diff → What changed between two states?
```

------------------------------------------------------------------------

# 27. Remote Repository

A remote is another Git repository, commonly hosted on
GitHub/GitLab/Bitbucket.

Check remotes:

``` bash
git remote -v
```

Example:

``` text
origin  https://github.com/user/project.git (fetch)
origin  https://github.com/user/project.git (push)
```

`origin` is just the conventional default name for the remote.

It is not a special Git keyword.

------------------------------------------------------------------------

# 28. HTTPS Authentication Problem from Practice

The practice session initially used:

``` bash
git remote add origin https://github.com/wackypiyush/git-devops-lab.git
git push -u origin main
```

GitHub rejected password authentication:

``` text
remote: Invalid username or token.
Password authentication is not supported for Git operations.
```

The problem was not the repository itself.

The authentication method was the issue.

The SSH test:

``` bash
ssh -T git@github.com
```

returned:

``` text
Hi wackypiyush! You've successfully authenticated, but GitHub does not provide shell access.
```

This confirmed that SSH authentication was working.

The remote was changed to SSH:

``` bash
git remote set-url origin git@github.com:wackypiyush/git-devops-lab.git
```

Then:

``` bash
git push -u origin main
```

worked.

### Practical DevOps lesson

When HTTPS authentication fails:

1.  Check the remote:

    ``` bash
    git remote -v
    ```

2.  Test SSH:

    ``` bash
    ssh -T git@github.com
    ```

3.  If SSH is configured, use an SSH remote:

    ``` bash
    git remote set-url origin git@github.com:<user>/<repo>.git
    ```

4.  Push:

    ``` bash
    git push -u origin main
    ```

------------------------------------------------------------------------

# 29. `git push -u`

First push:

``` bash
git push -u origin main
```

`-u` establishes the upstream/tracking relationship.

After that, on the same branch, you can normally use:

``` bash
git push
```

and:

``` bash
git pull
```

Git knows the upstream branch.

Example:

``` text
main
  ↓ tracking
origin/main
```

------------------------------------------------------------------------

# 30. Local Branch vs Remote Tracking Branch vs Remote Repository

This distinction is extremely important for DevOps.

``` text
Local machine                GitHub

main
  │
  │ tracks
  ↓
origin/main
  │
  │ represents the last fetched remote state
  ↓
Actual remote repository
```

More precisely:

``` text
main
= local branch

origin/main
= remote-tracking reference

GitHub main
= actual remote branch
```

`origin/main` is not the actual GitHub branch itself.

It is your local Git reference representing the last known state of the
remote branch.

------------------------------------------------------------------------

# 31. `git fetch`

``` bash
git fetch origin
```

Downloads new remote information/objects and updates remote-tracking
references.

It does not automatically merge the changes into your current local
branch.

Think:

> Download and show me what's new, but don't change my working branch
> yet.

------------------------------------------------------------------------

# 32. `git pull`

``` bash
git pull
```

Generally performs:

``` bash
git fetch
git merge
```

for the configured upstream.

Think:

> Get the remote changes and integrate them into my current branch.

------------------------------------------------------------------------

# 33. Safe Remote Investigation

Instead of immediately pulling:

``` bash
git fetch origin
git log HEAD..origin/main --oneline
git diff HEAD origin/main
git show <commit-id>
```

This lets you inspect remote changes before integrating them.

------------------------------------------------------------------------

# 34. Find Remote-Only Commits

``` bash
git fetch origin
git log HEAD..origin/main --oneline
```

Meaning:

> Show commits that exist on `origin/main` but not on my current HEAD.

Practice result:

``` text
b455b75 Change from another dev
```

This showed that another clone had pushed a commit that the original
local repository did not yet have.

------------------------------------------------------------------------

# 35. Find Local-Only Commits

``` bash
git log origin/main..HEAD --oneline
```

Meaning:

> Show commits that exist locally but not on the remote-tracking branch.

Useful before pushing.

------------------------------------------------------------------------

# 36. Compare Local and Remote

``` bash
git diff HEAD origin/main
```

Shows file-level differences.

Also:

``` bash
git diff main origin/main
```

when you specifically want to compare those two references.

------------------------------------------------------------------------

# 37. `git remote show`

``` bash
git remote show origin
```

Provides more information about the remote and tracking relationships.

Useful for understanding:

-   Fetch/push URLs
-   Tracked branches
-   Upstream relationships
-   Branch status

------------------------------------------------------------------------

# 38. Clone

A second working copy was created during practice:

``` bash
cd ~
git clone https://github.com/wackypiyush/git-devops-lab git-other
```

This created:

``` text
~/git-other
```

The second clone represented another developer/workstation.

It made a change:

``` bash
echo "Change form another developer" >> app.txt
git add app.txt
git commit -m "Change from another dev"
```

Then the SSH remote was configured:

``` bash
git remote set-url origin git@github.com:wackypiyush/git-devops-lab.git
```

and:

``` bash
git push
```

was successful.

------------------------------------------------------------------------

# 39. Simulating Two Developers

This was one of the most useful parts of the practice session.

``` text
git-lab
   │
   │
GitHub
   │
   │
git-other
```

`git-other` pushed a change.

Back in `git-lab`:

``` bash
git fetch origin
```

Then:

``` bash
git log HEAD..origin/main --oneline
```

showed the remote-only commit.

Then:

``` bash
git diff HEAD origin/main
```

showed the actual file change.

Finally:

``` bash
git pull
```

updated local `main`.

The output showed:

``` text
Fast-forward
```

because there was no conflicting local commit at that point.

### DevOps lesson

This is the practical difference between:

``` text
fetch → inspect → integrate
```

and:

``` text
pull → fetch + integrate
```

------------------------------------------------------------------------

# 40. Rebase

Rebase replays your commits on top of another base.

Example:

``` bash
git switch feature-monitoring
git rebase main
```

Before:

``` text
A --- B --- C  main
       \
        D      feature
```

After:

``` text
A --- B --- C --- D'
                  ↑
               feature
```

The feature commit gets a new commit ID because its parent/base changed.

------------------------------------------------------------------------

# 41. Why Rebase Changes Commit IDs

A Git commit includes information about its parent commit.

When rebase changes the parent:

``` text
D
```

becomes a new commit:

``` text
D'
```

Therefore the commit hash changes.

This is why rebase rewrites history.

------------------------------------------------------------------------

# 42. Rebase Practice

The practice created:

``` bash
git switch -c feature-monitoring
```

Then:

``` bash
echo "prometheus" >> monitoring.txt
git add monitoring.txt
git commit -m "Add prometheus config"
```

Meanwhile `main` received:

``` bash
echo "Grafana" >> app.txt
git add app.txt
git commit -m "Add Grafana Config"
```

Then:

``` bash
git switch feature-monitoring
git rebase main
```

After rebase:

``` text
26f79ba (feature-monitoring) Add prometheus config
b3a600f (main) Add Grafana Config
b455b75 (origin/main) Change from another dev
...
```

The feature commit got a new hash.

------------------------------------------------------------------------

# 43. Rebase Conflict

Practice created the same file on both branches:

On `main`:

``` text
PORT=8080
```

On `feature-monitoring`:

``` text
PORT=9090
```

Then:

``` bash
git rebase main
```

Git reported:

``` text
CONFLICT (add/add): Merge conflict in application.conf
```

Git showed:

``` text
interactive rebase in progress
```

## Resolve

Open the file:

``` bash
nano application.conf
```

Choose the desired final content and remove conflict markers.

Then:

``` bash
git add application.conf
git rebase --continue
```

After successful resolution:

``` text
Successfully rebased and updated refs/heads/feature-monitoring.
```

------------------------------------------------------------------------

# 44. Rebase Conflict Commands

During a rebase conflict:

``` bash
git status
```

Resolve files.

Then:

``` bash
git add <file>
git rebase --continue
```

Abort:

``` bash
git rebase --abort
```

Skip current commit:

``` bash
git rebase --skip
```

### Important

During rebase, use:

``` bash
git rebase --continue
```

not:

``` bash
git commit
```

Git manages the commit creation as part of the rebase process.

------------------------------------------------------------------------

# 45. Rebase and Shared Branches

Rebase rewrites commit history.

Therefore avoid rebasing commits that other developers are already
depending on, especially shared branches.

Typical feature workflow:

``` bash
git switch main
git pull origin main

git switch feature-login
git rebase main
```

If the rebased feature branch had already been pushed, updating the
remote may require:

``` bash
git push --force-with-lease
```

`--force-with-lease` is safer than plain `--force` because Git checks
that the remote branch has not unexpectedly moved.

------------------------------------------------------------------------

# 46. Merge vs Rebase

## Merge

``` text
A --- B --- C -------- M
       \             /
        D --- E ----
```

Advantages:

-   Preserves branch topology
-   Does not rewrite existing commits
-   Good for integrating shared work

## Rebase

``` text
A --- B --- C --- D' --- E'
```

Advantages:

-   Linear history
-   Useful for keeping a feature branch up to date
-   Avoids an extra merge commit in many workflows

Key difference:

``` text
merge  → combines histories
rebase → rewrites/replays commits onto a new base
```

------------------------------------------------------------------------

# 47. Detached HEAD

Normally:

``` text
HEAD
 ↓
main
 ↓
commit
```

Detached HEAD:

``` text
HEAD
 ↓
commit
```

Practice:

``` bash
git switch --detach b3a600f
```

Git reported:

``` text
HEAD detached at b3a600f
```

This is useful for:

-   Inspecting an old commit
-   Testing historical code
-   Debugging an old version
-   Comparing behavior

## Return to a branch

``` bash
git switch main
```

------------------------------------------------------------------------

# 48. Commit While Detached

A detached HEAD can still have commits.

But the new commit is not automatically attached to a normal branch.

If you want to preserve the work:

``` bash
git switch -c experimental-work
```

This creates a branch at the current commit.

------------------------------------------------------------------------

# 49. `git log` Graph Practice

A very useful command:

``` bash
git log --oneline --graph --decorate --all
```

The practice session repeatedly used this to understand:

-   Current branch
-   Merge commits
-   Feature branches
-   Remote-tracking branches
-   Rebased commits
-   HEAD location

Example:

``` text
* e1858bf (HEAD -> feature-monitoring) Add prometheus config
* 7ec9a10 (main) Config application port
* b3a600f Add Grafana Config
* b455b75 (origin/main) Change from another dev
* d944364 Revert "Bad prod config"
* eb062e4 Bad prod config
*   d2d439b Merge branch 'feature-api'
|\
| * fe9d2eb (feature-api) Enable API
* | 4261c97 Enable production mode
|/
* c1442dc Add config
* 50deada (feature-login) Add login feature
* c424179 Add Jenkins Info
* 221445f Initial Commit
```

This is an excellent command to run when Git history becomes confusing.

------------------------------------------------------------------------

# 50. Common Git Troubleshooting Pattern

When something unexpected happens:

## Step 1 --- Check status

``` bash
git status
```

## Step 2 --- Understand history

``` bash
git log --oneline --graph --decorate --all
```

## Step 3 --- Inspect changes

``` bash
git diff
git diff --staged
```

## Step 4 --- Inspect a commit

``` bash
git show <commit>
```

## Step 5 --- Check remote

``` bash
git remote -v
git fetch origin
```

## Step 6 --- Compare remote

``` bash
git log HEAD..origin/main --oneline
git log origin/main..HEAD --oneline
git diff HEAD origin/main
```

This sequence is highly useful in DevOps troubleshooting.

------------------------------------------------------------------------

# 51. Important Git Commands Cheat Sheet

## Repository / Status

``` bash
git status
git init
git clone <url>
```

## Changes

``` bash
git diff
git diff --staged
git add <file>
git add .
git restore <file>
git restore --staged <file>
```

## Commits

``` bash
git commit -m "message"
git log
git log --oneline
git log --oneline --graph --decorate --all
git show <commit>
```

## Branches

``` bash
git branch
git branch <name>
git switch <name>
git switch -c <name>
git branch -m <new-name>
git branch -d <name>
git branch -D <name>
git branch -r
git branch -a
```

## Merge

``` bash
git switch main
git merge feature
git merge --abort
```

## Stash

``` bash
git stash
git stash list
git stash show
git stash show -p
git stash apply
git stash apply stash@{1}
git stash pop
git stash drop
git stash clear
```

## Reset / Revert

``` bash
git reset --soft HEAD~1
git reset HEAD~1
git reset --hard HEAD~1

git revert <commit>
```

## Remote

``` bash
git remote -v
git remote show origin
git fetch origin
git pull
git push
git push -u origin main
```

## Remote Investigation

``` bash
git branch -r
git log HEAD..origin/main --oneline
git log origin/main..HEAD --oneline
git diff HEAD origin/main
git show <remote-commit>
```

## Rebase

``` bash
git rebase main
git rebase --continue
git rebase --abort
git rebase --skip
git push --force-with-lease
```

## Detached HEAD

``` bash
git switch --detach <commit>
git switch main
git switch -c <new-branch>
```

------------------------------------------------------------------------

# 52. Git Investigation Cheat Sheet

When asked:

### "What changed?"

``` bash
git diff
```

### "What am I about to commit?"

``` bash
git diff --staged
```

### "What commits happened?"

``` bash
git log --oneline
```

### "What exactly did this commit change?"

``` bash
git show <commit>
```

### "What branches exist?"

``` bash
git branch -a
```

### "What changed on the remote?"

``` bash
git fetch origin
git log HEAD..origin/main --oneline
git diff HEAD origin/main
```

### "My branch is behind"

``` bash
git fetch origin
git log HEAD..origin/main --oneline
git pull
```

### "I accidentally committed something locally"

Depending on the situation:

``` bash
git reset --soft HEAD~1
```

or:

``` bash
git reset HEAD~1
```

### "I committed something that is already shared"

Usually:

``` bash
git revert <commit>
```

### "I need to temporarily save unfinished work"

``` bash
git stash
```

### "I have a merge conflict"

``` bash
git status
# edit conflict
git add <file>
git commit
```

### "I have a rebase conflict"

``` bash
git status
# edit conflict
git add <file>
git rebase --continue
```

------------------------------------------------------------------------

# 53. Git Concepts to Remember for DevOps Interviews

## Branch

> A lightweight pointer to a commit.

## HEAD

> The current location/branch reference being worked on.

## Origin

> The conventional default name for a remote repository.

## `origin/main`

> A remote-tracking reference representing the last fetched state of the
> remote `main` branch.

## Fetch

> Downloads remote updates and updates remote-tracking references
> without integrating them into the current branch.

## Pull

> Fetches remote changes and integrates them into the current branch.

## Merge

> Combines histories of branches.

## Rebase

> Replays commits on top of another base and rewrites commit history.

## Stash

> Temporarily stores uncommitted changes.

## Reset

> Moves the current branch/HEAD and can modify staging and working-tree
> state depending on the mode.

## Revert

> Creates a new commit that reverses an earlier commit.

## Fast-forward

> Moves a branch pointer forward without creating a merge commit when
> there is no divergent history.

------------------------------------------------------------------------

# 54. Most Important DevOps Git Workflow

A realistic feature workflow:

``` bash
# Update local main
git switch main
git fetch origin
git pull origin main

# Create feature
git switch -c feature-monitoring

# Work
vim monitoring.txt

# Inspect
git status
git diff

# Stage
git add monitoring.txt

# Verify staged content
git diff --staged

# Commit
git commit -m "Add monitoring configuration"

# Update feature with latest main
git switch main
git pull origin main

git switch feature-monitoring
git rebase main

# Resolve conflicts if necessary
git status
# edit files
git add <file>
git rebase --continue

# Push feature
git push -u origin feature-monitoring
```

Depending on the team's workflow, the feature may then be merged through
a Pull Request.

------------------------------------------------------------------------

# 56. Final Git Mental Model

Keep this model in your head:

``` text
                    REMOTE REPOSITORY
                          │
                       fetch
                          ↓
                    origin/main
                          │
                    merge / rebase
                          ↓
                        main
                          │
                     create branch
                          ↓
                   feature branch
                          │
                        commit
                          ↓
                     local history
```

For individual file changes:

``` text
Working Directory
       │
       │ git add
       ↓
Staging Area
       │
       │ git commit
       ↓
Repository / History
```

For investigation:

``` text
git status
     ↓
git diff
     ↓
git log
     ↓
git show
     ↓
git fetch
     ↓
git diff / git log against origin/main
```

For collaboration:

``` text
clone
  ↓
branch
  ↓
work
  ↓
add
  ↓
commit
  ↓
fetch/rebase
  ↓
push
  ↓
Pull Request / merge
```

------------------------------------------------------------------------

# 57. One-Page Command Memory List

``` bash
# State
git status

# Changes
git diff
git diff --staged

# Stage
git add <file>
git add .

# Commit
git commit -m "message"

# History
git log --oneline
git log --oneline --graph --decorate --all
git show <commit>

# Branch
git branch
git switch <branch>
git switch -c <branch>

# Merge
git switch main
git merge <branch>

# Stash
git stash
git stash list
git stash apply
git stash pop
git stash drop

# Undo
git reset --soft HEAD~1
git reset HEAD~1
git reset --hard HEAD~1
git revert <commit>

# Remote
git remote -v
git fetch origin
git pull
git push
git push -u origin main

# Remote investigation
git log HEAD..origin/main --oneline
git log origin/main..HEAD --oneline
git diff HEAD origin/main

# Rebase
git rebase main
git rebase --continue
git rebase --abort

# Detached HEAD
git switch --detach <commit>
git switch main
```

------------------------------------------------------------------------

# 58. Golden Rules

``` text
1. Check git status frequently.

2. Review git diff before staging.

3. Review git diff --staged before committing.

4. Keep commits small and meaningful.

5. Use one feature/fix per branch.

6. Know which branch you are currently on before merge/rebase.

7. Fetch before investigating remote changes.

8. Understand main vs origin/main.

9. Prefer revert for already-shared history.

10. Be careful with reset --hard.

11. Do not blindly use git push --force.

12. Prefer git push --force-with-lease after a necessary rebase.

13. Resolve merge conflicts manually and inspect the result.

14. During rebase, use git rebase --continue after resolving conflicts.

15. When Git behaves unexpectedly:
    git status
    ↓
    git log --oneline --graph --decorate --all
    ↓
    git diff
    ↓
    git show
```

