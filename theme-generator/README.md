# Theme Generator

This folder contains the maintainer workflow for creating a brand-new theme from an existing baseline theme.

The goal is to get from a small config file to a ready-to-review theme folder without manually editing every Dockerfile, script, username, website path, or support-stack network name.

This tool is for theme creation, not for running a theme. To run an existing theme, use that theme folder's `labctl.sh`.

## Current scope

`generate_theme.py` currently does the following:

1. Copies an existing base theme folder to a new output folder.
2. Applies theme-aware text and path replacements for:
   - event names
   - flag prefixes
   - usernames and user prefixes
   - hack network names
   - switchboard-facing service names
   - Windows evidence directory names and mount paths
   - website directory names and domains
3. Rewrites the generated theme's `labctl.sh` so it no longer depends on IPN/RCC detection and instead uses the generated theme values directly.
4. Replaces the Hack Box 2 seeded usernames from a provided people list.
5. Replaces the Linux Box 3 pipeline-owner username.
6. Replaces the Windows Box 2 protocol user references.
7. Optionally clones a website into the generated theme's `Hack/Box3/` web folder using `wget`.
8. Audits the generated theme for leftover baseline branding, usernames, service names, path names, and other preset markers.
9. Validates the generated theme by checking `labctl.sh` syntax, rendering switchboard config/service output, and running `docker compose config` for the support stack when Docker and `Docker-TCP-Switchboard` are available.
10. Rewrites binary files conservatively when they contain embedded UTF-8 marker strings and the replacement can be done safely without expanding the byte length.

## Before you run it

You need:

- one baseline theme folder such as `IPN Theme/` or `RowdyCon Theme/`
- Python 3
- `wget` if you want website cloning enabled
- Docker plus `Docker-TCP-Switchboard/` nearby if you want the validation step to fully render `labctl.sh` output

The most common layout is:

```text
Cyber-Adventure-Challenges/
├── Docker-TCP-Switchboard/
├── IPN Theme/
├── RowdyCon Theme/
└── theme-generator/
```

## Config shape

Start from [config.example.json](./config.example.json).

The required values are intentionally small:

- base theme path
- output folder
- display name
- slug
- short code
- flag prefix
- event name
- website domain
- website clone URL
- a small people list

Most of the bootstrapping values are derived automatically from those fields.

Optional theme fields that are useful when you want tighter control:

- `short_display_name`
- `website_public_url`
- `website_service_name`
- `support_project`
- `hack_box1_network`
- `hack_box3_network`
- `evidence_dir_name`
- `evidence_mount_path`
- `crypto_user_prefix`
- `linux_user_prefix`
- `windows_user_prefix`
- `windows_underscored_prefix`
- `hack_user_prefix`
- `hack_underscored_prefix`
- `profile_dir`
- `hack_service_name`
- `notes_dir_name`
- `linux_users_filename`
- `extra_replacements`

## How to use it

1. Copy [config.example.json](./config.example.json) to a new config file.
2. Point `base_theme_dir` at the baseline theme you want to copy.
3. Set `output_dir` to the new theme folder you want created.
4. Fill in the new theme values under `theme`.
5. Fill in the generated usernames under `people`.
6. Run the generator.
7. Review the output theme and then make any theme-specific manual improvements you still want.

Example:

```bash
cp theme-generator/config.example.json /tmp/acme-theme.json
python3 theme-generator/generate_theme.py --config /tmp/acme-theme.json
```

## Website cloning

If `theme.website_clone_url` is set, the generator will try to mirror that site into:

```text
Hack/Box3/<website_dir_name>/<website_domain>/
```

Current implementation notes:

- It uses `wget`, so `wget` must be installed if website cloning is enabled.
- If you do not want to clone the website during a run, pass `--skip-website-clone`.
- The cloned site is a starting point, not a guarantee that every page will work perfectly offline.

## Command reference

```bash
python3 theme-generator/generate_theme.py \
  --config theme-generator/config.example.json \
  --skip-website-clone
```

If `Docker-TCP-Switchboard` is not next to the config, base theme, or output folder, set `SWITCHBOARD_DIR` before running the generator so the validation step can render the switchboard config and service files:

```bash
SWITCHBOARD_DIR=/path/to/Docker-TCP-Switchboard \
python3 theme-generator/generate_theme.py --config theme-generator/config.example.json
```

Available flags:

- `--force`
  Overwrite the output directory if it already exists.
- `--skip-website-clone`
  Skip the `wget` mirror step for the Box 3 website.
- `--skip-audit`
  Skip the leftover-content audit.
- `--skip-validation`
  Skip the generated `labctl.sh` and compose validation checks.

## Validation and review

By default the generator now does two checks after it writes the theme:

1. Audit the generated files and paths for leftover baseline markers from the source theme.
2. Validate `labctl.sh` and the support compose stack when the local machine has the needed prerequisites.

You can skip either phase if you only want a fast copy/rewrite pass:

```bash
python3 theme-generator/generate_theme.py \
  --config theme-generator/config.example.json \
  --skip-audit \
  --skip-validation
```

## Binary files

The generator now attempts a conservative binary rewrite pass in addition to text replacement.

- `.zip` archives are handled as structured containers, so entry names and text-like entry contents are rewritten instead of being treated as opaque blobs.
- If a non-archive binary file contains an embedded UTF-8 marker string and the replacement is the same length, it is replaced directly.
- If the replacement is shorter, it is written with null padding to keep the byte length stable.
- If the replacement would be longer than the original embedded marker, the generator leaves it unchanged and the audit step will still catch it if the old marker remains.
- To reduce false positives in random binary data, the raw binary scan only targets longer legacy markers instead of very short codes like `IPN` or `RCC`.

That means binary replacement is now supported on a best-effort basis, but it is intentionally conservative so the generator does not silently corrupt compiled assets or archives.

## What to review after generation

The generator should get a new theme very close, but you should still review:

- `README.md` inside the generated theme
- the cloned website content under `Hack/Box3/`
- challenge mission text and solution notes
- any binary assets or archives if you know they intentionally embed branded strings
- the CTFd backup or `CTFd/` content if you want scoreboard branding to match the new theme

## Planned follow-up work

- Move more challenge files from replacement-based generation to structured templates.
- Add a small regression fixture suite so generator changes can be checked without copying a full theme.
- Make website post-processing more robust for frameworks that need asset rewriting.
