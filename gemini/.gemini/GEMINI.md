## Gemini Added Memories

- My name is Simon.
- I am using a Macbook Air 15'' with an M2 processor. If I don't specify my OS or hardware, assume I'm using this MacBook.
- I am studying computer science at the TUBAF University in Freiberg, Saxony, Germany.
- I am a native German speaker, if possible respond in German when I ask questions in German.

## Agent Guidelines & Workflow

### General Project Structure
- **Root Directory:** My coding projects are located in `~/CapyCode`. New projects should be created there.
- **Task Tracking:** I use a `TO-DO.md` file in the root of my projects to track features, bugs, and tasks. Always read and update this file.

### Development Workflow
1.  **Git First:** always check `git status` before starting work to ensure a clean state.
2.  **Branching:**
    - New Features: `feat/<short-description>`
    - Bug Fixes: `fix/<short-description>`
    - Refactoring: `refactor/<short-description>`
3.  **Implementation:** Implement the requested changes autonomously.
4.  **Feedback Loop (CRITICAL):**
    - **NEVER** commit or push without my explicit approval.
    - After implementing changes, ask me for feedback/verification.
    - Only proceed to commit/merge after I confirm the changes work as intended.
5.  **Finalization:**
    - Update `TO-DO.md` (mark tasks as done).
    - Commit using **Conventional Commits** (e.g., `feat: add login button`, `fix: resolve crash on startup`).
    - Push the branch.
    - Create a Pull Request using `gh pr create` (GitHub CLI).
    - Merge the PR and delete the branch (if requested).

### Tools
- Use `gh` (GitHub CLI) for PRs and issues.

## Commit Conventions
I follow the **Conventional Commits 1.0.0** specification:

- **Structure:**

  ```text
  <type>[optional scope]: <description>
  [optional body]
  [optional footer(s)]
  ```

- **Types:**
  - `feat`: New feature (triggers MINOR release)
  - `fix`: Bug fix (triggers PATCH release)
  - `docs`, `style`, `refactor`, `perf`, `test`, `chore`: No semantic version bump.
- **Breaking Changes:**
  - Indicate a MAJOR release by adding `!` after type/scope (e.g., `feat!: drop support for Node 12`) OR
  - Add `BREAKING CHANGE: <description>` in the footer.
- **Rules:** English, imperative description ("add" not "added"), no trailing period in header.