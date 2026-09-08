# Contributing to MiTV Vietnam Toolkit

Thank you for contributing to the **MiTV Vietnam Toolkit**! We welcome bug reports, application suggestions, script optimizations, and documentation improvements.

---

## Code of Conduct

All contributors and maintainers are expected to maintain a professional, respectful, and collaborative environment.

---

## Development Workflow

1. **Fork the repository** on GitHub.
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/<your-username>/mitv-vn-setup.git
   cd mitv-vn-setup
   ```
3. **Create a feature branch**:
   ```bash
   git checkout -b feat/add-app-xyz
   ```

---

## Guidelines for Adding Applications (`apps.json`)

When proposing a new application to `apps.json`:
- The app **must** be designed for **Android TV / Leanback UI** (navigable via D-pad remote control).
- Apps targeting mobile phones (requiring touchscreens or screen rotation tools) will **not** be accepted.
- Prefer official open-source GitHub releases (`type: "github_release"`).
- Provide accurate `package` names and category designations.

Schema example:
```json
{
  "id": "app_id",
  "name": "Application Name",
  "package": "com.example.tv",
  "category": "video | iptv | music | tools",
  "type": "github_release | direct_url | aptoide_query",
  "description": "Short explanation of the app"
}
```

---

## Script Standards

- **PowerShell (`setup.ps1`)**:
  - Compatible with Windows PowerShell 5.1 and PowerShell Core 7+.
  - Adhere to PSScriptAnalyzer best practices.
  - Maintain `$ErrorActionPreference = "Stop"` for fatal blocks and explicit error trapping.
- **POSIX Shell (`setup.sh`)**:
  - Must pass `shellcheck` without errors.
  - Compatible with bash 3.2+ (macOS default), Dash, and BusyBox/Termux.

---

## Submitting Pull Requests

1. Test changes on a physical Xiaomi / Redmi TV or an Android TV emulator.
2. Ensure commit messages follow Conventional Commits (`feat:`, `fix:`, `docs:`, `chore:`).
3. Open a Pull Request referencing related issues.
