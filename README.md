# Workspace

Clone all repositories from the [Twilic](https://github.com/twilic) GitHub organization and generate a VS Code multi-root workspace file (`twilic.code-workspace`) in one step.

This repository provides a [Dev Container](https://containers.dev/) for a reproducible development environment with language toolchains used across the Twilic organization.

## Included tools

The Dev Container installs the following runtimes and build tools:

| Tool        | Version | Used by                                                 |
| ----------- | ------- | ------------------------------------------------------- |
| Node.js     | 24      | `twilic-js`, `cli`, `@twilic/*`, `website`, `benchmark` |
| pnpm        | latest  | Node.js packages                                        |
| Python      | 3.12    | `twilic-python`                                         |
| Rust        | stable  | `twilic-rust`, conformance fixtures                     |
| Zig         | 0.15.2  | `twilic-zig`                                            |
| Go          | 1.22    | `twilic-go`                                             |
| Java (JDK)  | 21      | `twilic-java`, `twilic-kotlin`, `twilic-scala`          |
| Ruby        | 3.3     | `twilic-ruby`                                           |
| .NET SDK    | 8.0     | `twilic-csharp`                                         |
| PHP         | 8.3     | `twilic-php`                                            |
| GCC / Clang | latest  | `twilic-c`, `twilic-cpp`                                |
| Elixir      | distro  | `twilic-elixir`                                         |
| Lua         | 5.4     | `twilic-lua`                                            |
| R           | distro  | `twilic-r`                                              |
| git / gh    | latest  | repository setup                                        |

VS Code extensions for EditorConfig, Rust, Python, Go, Java, Ruby, Zig, ESLint, Terraform, and Markdownlint are preinstalled.

## Overview

Twilic development spans many repositories: the specification, language implementations, web framework integrations, CLI tools, benchmarks, and more. Opening this repository in a Dev Container and running `scripts/setup-twilic-workspace.sh` lets you do the following in one step:

- List all repositories in the `twilic` organization
- Clone them next to this repository (or run `git pull` if already cloned)
- Generate `twilic.code-workspace`

Private repositories (including this `workspace` repository) are supported. Cloning uses authentication from `gh`.

## Prerequisites

| Tool                                                                       | Purpose                                           |
| -------------------------------------------------------------------------- | ------------------------------------------------- |
| [Docker](https://www.docker.com/)                                          | Run the Dev Container                             |
| [VS Code](https://code.visualstudio.com/) or [Cursor](https://cursor.com/) | Editor with Dev Containers support                |
| Dev Containers extension                                                   | **Dev Containers** (VS Code) or built-in (Cursor) |
| [gh](https://cli.github.com/) on the host                                  | Authenticate before opening the container         |

`gh` must be authenticated on the host with a GitHub account that has access to private repositories in the `twilic` organization. The Dev Container reuses your host `~/.config/gh` credentials.

## Quick start

### 1. Authenticate GitHub CLI on the host

```sh
gh auth login
gh auth status
```

### 2. Clone this repository

Clone into a directory whose parent will hold the other organization repositories:

```sh
mkdir -p ~/workspace/twilic
gh repo clone twilic/workspace ~/workspace/twilic/workspace
```

After setup, repositories are laid out like this on the host:

```text
~/workspace/twilic/
├── workspace/           # this repository
├── twilic/              # specification
├── twilic-js/
└── ...
```

### 3. Open in a Dev Container

Open `~/workspace/twilic/workspace` in VS Code or Cursor, then choose **Reopen in Container**.

### 4. Run the setup script

Inside the container:

```sh
./scripts/setup-twilic-workspace.sh
```

When the script finishes, open the generated workspace file:

```sh
code twilic.code-workspace
```

You can also use **File > Open Workspace from File...** and select `twilic.code-workspace`.

## Repository layout

```text
twilic/workspace
├── .devcontainer/
│   ├── devcontainer.json
│   ├── Dockerfile
│   └── docker-compose.yml
├── scripts/
│   └── setup-twilic-workspace.sh
├── twilic.code-workspace    # generated (gitignored)
├── README.md
└── LICENSE
```

Organization repositories are cloned as siblings of this repository (one directory above `workspace/` on the host).

## What the script does

`scripts/setup-twilic-workspace.sh` performs the following steps:

1. Verifies that `git` and `gh` are installed and that `gh` is authenticated
2. Fetches repository names with `gh repo list twilic`
3. For each repository:
   - If already cloned (`<repos-dir>/<repo>/.git` exists), updates it with `git pull`
   - Otherwise, clones it with `gh repo clone twilic/<repo>`
4. Generates `twilic.code-workspace` with sorted folders and `@twilic/*` display names for the CLI and framework integration repositories

When finished, the script prints the number of repositories found, cloned, updated, and failed.

## Re-running the script

Running the script again updates existing repositories and clones only newly added ones. `twilic.code-workspace` is regenerated from the current repository list.

## Environment variables

| Variable                | Default (Dev Container) | Description                                                |
| ----------------------- | ----------------------- | ---------------------------------------------------------- |
| `TWILIC_REPOS_DIR`      | `/workspaces`           | Directory to clone organization repositories into          |
| `TWILIC_WORKSPACE_ROOT` | `/workspaces/workspace` | Directory where `twilic.code-workspace` is written         |
| `REPO_LIMIT`            | `1000`                  | Maximum number of repositories to fetch via `gh repo list` |

In the Dev Container, repositories are cloned to `/workspaces` (siblings of `/workspaces/workspace`). When running locally without these variables, both default to the repository root.

Example:

```sh
REPO_LIMIT=500 ./scripts/setup-twilic-workspace.sh
```

## Local usage (without Dev Container)

You can run the setup script on the host if `git` and `gh` are installed:

```sh
gh auth login
./scripts/setup-twilic-workspace.sh
```

By default, repositories are cloned into this repository's root directory. To match the Dev Container layout on the host:

```sh
export TWILIC_REPOS_DIR="$(cd .. && pwd)"
export TWILIC_WORKSPACE_ROOT="$(pwd)"
./scripts/setup-twilic-workspace.sh
```

## Troubleshooting

### `gh is not authenticated`

Run `gh auth login` on the host, then rebuild or reopen the Dev Container so credentials are available inside the container.

### `cannot access organization 'twilic'`

Make sure your GitHub account is a member of the `twilic` organization or has the required access permissions.

### Dev Container fails to start

Confirm Docker is running and the Dev Containers extension is installed. Rebuild the container with **Dev Containers: Rebuild Container**.

### A specific repository fails to clone

This may be caused by insufficient permissions or a network issue. The script continues processing other repositories even if one fails. Inspect the problematic repository individually:

```sh
gh repo clone twilic/<repository-name>
```

### `./scripts/setup-twilic-workspace.sh: Permission denied`

Grant execute permission and run the script again:

```sh
chmod +x scripts/setup-twilic-workspace.sh
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
