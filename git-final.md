# Git for DevOps - Last Minute Revision

# Git Flow

Working Dir
 ↓ git add
Staging Area
 ↓ git commit
Local Repo
 ↓ git push
Remote Repo

Staging Area:
Snapshot of what will be included in the next commit.

---

# Most Important Commands

git status
→ Current branch, modified, staged, untracked, ahead/behind

git diff
→ Working Dir vs Staging Area
→ What changed but is NOT staged?

git diff --staged
→ Staging Area vs HEAD
→ What will be committed?

git show
→ Last commit details
→ Commit hash, author, date, message, changes

git log -5
→ Last 5 commits

git log --oneline --graph --decorate --all
→ Best Git history visualization

---

# Branches

Branch = Lightweight pointer to a commit.

HEAD = Where you're currently working.

Create & switch:

git switch -c feature-api

Delete merged branch:

git branch -d feature

Force delete:

git branch -D feature

---

# Merge

Fast Forward Merge
→ No merge commit created.

Three-Way Merge

          C --- D
         /       \
A --- B           M
         \       /
          E --- F

M = Merge Commit

Complete Merge Conflict:

git add <file>
git commit

Abort:

git merge --abort

---

# Stash

Purpose:
Temporarily save unfinished work.

git stash

git stash list

Newest:
stash@{0}

Older:
stash@{1}
stash@{2}

Inspect:

git stash show
git stash show -p

apply
→ Restore + Keep stash

pop
→ Restore + Remove stash

Delete:

git stash drop stash@{0}

---

# Reset vs Revert

Reset
→ Local mistakes
→ Rewrites history

Revert
→ Shared commits
→ Creates undo commit

Golden Rule:

Shared Commit
↓
Revert

Local Commit
↓
Reset

---

# Reset Types

soft
→ Commit removed
→ Staging kept

mixed
→ Commit removed
→ Staging removed
→ Working dir kept

hard
→ Commit removed
→ Files reset

Memory Trick:

soft  = staged kept
mixed = unstaged kept
hard  = files reset

---

# Remote

Check Remotes:

git remote -v

origin
→ Default remote name

main
→ Local branch

origin/main
→ Remote-tracking branch

---

# Push

git push -u origin main

-u
→ Upstream tracking

After first push:

git push
git pull

---

# Fetch vs Pull

git fetch
→ Download only
→ No merge
→ No working dir changes

git pull
→ Fetch + Merge

---

# Safe Remote Investigation

git fetch origin

git log HEAD..origin/main --oneline
→ Remote-only commits

git log origin/main..HEAD --oneline
→ Local-only commits

git diff HEAD origin/main
→ File-level differences

git remote show origin
→ URLs, tracking, branch status

---

# Authentication Issue

git remote -v

ssh -T git@github.com

git remote show origin

ssh-add -l

---

# Rebase

Purpose:
Keep feature branch updated with main.

git rebase main

Benefits:

✅ Linear history
✅ Cleaner PR

Merge
→ Preserves history

Rebase
→ Rewrites history

---

# Rebase Conflict

git status

# fix file

git add <file>

git rebase --continue

Abort:

git rebase --abort

Skip:

git rebase --skip

---

# Detached HEAD

HEAD points directly to a commit.

Enter:

git switch --detach <commit>

Save work:

git switch -c temp-branch

Exit:

git switch main

---

# Force Push

git push --force
→ Blind overwrite

git push --force-with-lease
→ Safer

---

# non-fast-forward

Usually means:

Remote has commits
You don't have them

Investigate:

git fetch

git log HEAD..origin/main --oneline

git diff HEAD origin/main

---

# Branch Not Found

Check:

git branch

git branch -r

Was branch pushed?

Correct branch name?

Correct Jenkins branch config?

---

# Git Troubleshooting Flow

git status

git log --oneline --graph --decorate --all

git diff

git diff --staged

git show

git fetch origin

git log HEAD..origin/main --oneline

git diff HEAD origin/main

Understand
↓
Investigate
↓
Compare
↓
Modify
↓
Verify

---

# Answer

Whenever I face a Git issue, I first determine the local repository state using git status, git diff, git diff --staged, and git log --oneline --graph --decorate --all. This helps me understand the current branch, staged changes, commit history, and branch relationships.
If the issue may involve remote repositories, I use git fetch origin first rather than immediately pulling. Then I investigate remote changes using git log HEAD..origin/main --oneline and git diff HEAD origin/main.
For merge or rebase problems, I inspect conflicts using git status, resolve them manually, stage the fixes, and complete the operation using either git commit for merges or git rebase --continue for rebases.
For shared branches, I avoid rewriting history and prefer git revert over git reset. Before any risky operation, I make sure I fully understand the repository state and history.
My overall approach is:
Understand
↓
Investigate
↓
Compare
↓
Modify
↓
Verify
