# Workspace

Clone all repositories from the [Twilic](https://github.com/twilic) GitHub organization and generate a VS Code multi-root workspace file (`twilic.code-workspace`) in one step.

## Overview

Twilic development spans many repositories: the specification, language implementations, web framework integrations, CLI tools, benchmarks, and more. Running `setup-twilic-workspace.sh` in this repository lets you do the following in one step:

- List all repositories in the `twilic` organization
- Clone them into the current directory (or run `git pull` if already cloned)
- Generate `twilic.code-workspace`

Private repositories (including this `workspace` repository) are supported. Cloning uses authentication from the [GitHub CLI (`gh`)](https://cli.github.com/).

## Prerequisites

The following tools must be installed and available:

| Tool                          | Purpose                                         |
| ----------------------------- | ----------------------------------------------- |
| [git](https://git-scm.com/)   | Clone and update repositories                   |
| [gh](https://cli.github.com/) | List repositories and clone with authentication |

`gh` must be authenticated with a GitHub account that has access to private repositories in the `twilic` organization.

## Setup

### 1. Authenticate GitHub CLI

If you are not authenticated yet, log in with `gh` first:

```sh
gh auth login
```

You can verify your authentication status with:

```sh
gh auth status
```

### 2. Prepare a working directory

Create and move into the directory where you want to clone repositories. The script places each repository in **the current working directory** where it is executed.

```sh
mkdir -p ~/workspace/twilic
cd ~/workspace/twilic
```

### 3. Clone this repository

```sh
gh repo clone twilic/workspace .
```

If you have already cloned it, update to the latest version:

```sh
git pull
```

## Usage

Run the following from your working directory:

```sh
./setup-twilic-workspace.sh
```

When the script finishes, each repository will be present in the same directory and `twilic.code-workspace` will be generated.

### Open in VS Code

```sh
code twilic.code-workspace
```

You can also use **File > Open Workspace from File...** in VS Code and select `twilic.code-workspace`.

## What the script does

`setup-twilic-workspace.sh` performs the following steps:

1. Verifies that `git` and `gh` are installed and that `gh` is authenticated
2. Fetches repository names with `gh repo list twilic`
3. For each repository:
   - If already cloned (`./<repo>/.git` exists), updates it with `git pull`
   - Otherwise, clones it with `gh repo clone twilic/<repo>`
4. Generates `twilic.code-workspace` from successfully cloned or updated repositories

When finished, the script prints the number of repositories found, cloned, updated, and failed.

## Re-running the script

Running the script again in the same directory updates existing repositories and clones only newly added ones. `twilic.code-workspace` is regenerated from the current repository list.

## Environment variables

| Variable     | Default | Description                                                |
| ------------ | ------- | ---------------------------------------------------------- |
| `REPO_LIMIT` | `1000`  | Maximum number of repositories to fetch via `gh repo list` |

Example:

```sh
REPO_LIMIT=500 ./setup-twilic-workspace.sh
```

## Directory layout (after running)

After the script completes, the current directory will look roughly like this:

```text
.
├── setup-twilic-workspace.sh
├── README.md
├── twilic.code-workspace
├── twilic/              # Specification
├── website/             # Official website
├── cli/                 # CLI tool
└── ...                  # Other organization repositories
```

## Troubleshooting

### `gh is not authenticated`

Run `gh auth login`, then execute the script again.

### `cannot access organization 'twilic'`

Make sure your GitHub account is a member of the `twilic` organization or has the required access permissions.

### A specific repository fails to clone

This may be caused by insufficient permissions or a network issue. The script continues processing other repositories even if one fails. Inspect the problematic repository individually:

```sh
gh repo clone twilic/<repository-name>
```

### `./setup-twilic-workspace.sh: Permission denied`

Grant execute permission and run the script again:

```sh
chmod +x setup-twilic-workspace.sh
```
