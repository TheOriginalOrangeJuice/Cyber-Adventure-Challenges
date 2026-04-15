# Cyber Adventure Challenges

A series of OverTheWire-Inspired Challenges for Linux, Windows, Hacking (Red Team), and Cryptography. These are begginern challenges that can be given to anyone with a reference guide to help them develop foundational skills needed for the Cyber Security Field. 

The OTW Docker-TCP-Switchboard is used to allow any # of users connect to the machines and have their own instance. Each Theme has a Pre-Made CTFd Backup that can be imported for easy spin-up. 

Themes have a startup script that makes it easy to bring the infrastrucute up (outside of CTFd):

```bash
cd "<theme folder>"
./labctl.sh up
```

That local script builds the theme images, starts the theme support stack, generates the switchboard config, and starts the switchboard container.

## Theme generator

The repo also includes a maintainer tool in [theme-generator/](theme-generator/) for creating a brand-new theme from one existing baseline.

The generator is meant to reduce the manual work of making a third theme by rewriting the repeated theme-specific pieces across the challenge content, such as:

- theme names and event branding
- flag prefixes
- usernames and user-prefix naming
- support stack network names and service names
- website directory/domain references
- Windows evidence directory names and mount paths

Read [theme-generator/README.md](theme-generator/README.md) for step-by-step usage.

## Theme structure

## Editing an existing theme 

To make a new theme, the following are the palces that you'll want to edit and check for any artificats of previous themes. 

- `Crypto/Dockerfile` and the `crypt*.sh` scripts:
  This is where the crypto usernames, passwords, shells, and challenge flow live.
- `Linux/*/Dockerfile` plus any helper files in those folders:
  This is where Linux usernames, flags, file names, seeded artifacts, and challenge-specific logic live.
- `Windows/*/Dockerfile`, `profile*.ps1`, and `scripts/`:
  This is where PowerShell behavior, usernames, flags, evidence locations, and scheduled-task style logic live.
- `Hack/Box 1/docker-compose.yml`:
  This defines the support containers and internal challenge networks used by the hacking boxes.
- `Hack/Box3/`:
  This usually contains the cloned website content, wordlists, nginx config, and the web-enumeration challenge text.
- CTFd backup zip or `CTFd/` content:
  This is where scoreboard-facing challenge names, descriptions, hints, files, and category presentation are managed.

## Creating a new theme

If you want a third theme that is not based on IPN or RowdyCon, the simplest path is:

1. Copy one existing theme folder and rename it.
2. Update the challenge content inside that copied folder.
3. Update the small set of bootstrapping files that still carry theme-specific names and paths.

Look at the theme generator README for more information. 