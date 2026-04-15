---
name: release-prep
description: >
  Prepare a new release of this Terraform module. Use when the user says things like
  "prepare a release", "prep version X.Y.Z", "get ready to tag a release", or
  "what do I need to do for the next release". Handles all release artifacts:
  examples, compatibility table, README, release notes, versions.tf, and module metadata.
---

# Release Prep Skill — terraform-aviatrix-mc-spoke

This skill prepares all release artifacts for a new module version. Follow these steps in order.

---

## Step 1 — Confirm the target version

If the user hasn't specified the new version number, ask them before doing anything else. All subsequent steps depend on this. Example: "9.0.0"

---

## Step 2 — Determine the previous release tag

Run:
```bash
git tag | sort -V | tail -5
```

This gives you the last released tag (e.g. `v8.2.0`). Note: there may be a "prep" commit for a version that was never actually tagged — check `COMPATIBILITY.md` and compare with the tag list to determine the true last release. Use the last **tagged** version as the baseline for the changelog.

---

## Step 3 — Gather the changelog (changes since last tag)

Run:
```bash
git log <last-tag>..HEAD --oneline
```

Then for a more detailed diff of what actually changed in the module (ignore test fixtures, lock files, etc.):
```bash
git diff <last-tag>..HEAD -- variables.tf main.tf locals.tf output.tf versions.tf
```

From this, build a human-readable list of:
- New variables added (and which clouds they apply to)
- Variables removed or renamed (breaking changes)
- Bug fixes
- Provider/controller version bumps

---

## Step 4 — Decide if versions.tf needs updating

Only bump `versions.tf` if the new release requires a **higher minimum Aviatrix controller or provider version** due to new features or breaking changes. If the bump is purely additive with no new provider features, leave it alone.

The file to edit is `versions.tf`:
```hcl
terraform {
  required_providers {
    aviatrix = {
      source  = "aviatrixsystems/aviatrix"
      version = ">= X.Y.Z"   # ← only change if necessary
    }
  }
  required_version = ">= 1.2.0"
}
```

---

## Step 5 — Update all example files

Every `examples/*/main.tf` file contains a `version = "..."` line. Update all of them to the new version:

```bash
find examples -name main.tf | xargs grep -l 'version ='
```

Then do a find-and-replace for the old version string → new version string across all of them.

Verify with:
```bash
grep -r 'version =' examples/
```

---

## Step 6 — Update COMPATIBILITY.md

Add a new row at the **top** of the table (below the header) in `COMPATIBILITY.md`:

```
v<NEW_VERSION> | >= 1.3.0 | >= <CONTROLLER_VERSION> | >= <PROVIDER_VERSION>
```

The controller version follows the major version number pattern (e.g. module v9.0.0 → controller >= 9.0, module v8.2.x → controller >= 8.2).

---

## Step 7 — Update README.md

The README has a single-row compatibility table near the top:

```
Module version | Terraform version | Controller version | Terraform provider version
:--- | :--- | :--- | :---
v8.2.1 | >= 1.3.0 | >= 8.2 | >= 8.2.0
```

Replace that single data row with the new version. The README only shows the **current** version; older versions live in COMPATIBILITY.md.

---

## Step 8 — Update RELEASE_NOTES.md

Add a new section at the **very top** (below the `# terraform-aviatrix-mc-spoke release notes` heading). Follow the established style — heading is `## <VERSION>` with no `v` prefix, subsections use `###` for named features.

Template:
```markdown
## <VERSION>
### <Feature name>
<Description of what was added/changed and why. Call out which cloud(s) it applies to if not all.>

### <Bug fix or other change>
<Description.>
```

Do **not** include a "Version Alignment" or similar boilerplate section — just document the actual changes.

Use the changelog gathered in Step 3 as the source of truth. Group items logically — new features first, bug fixes after, breaking changes with a clear warning.

---

## Step 9 — Final verification

After all edits, confirm consistency by checking:

```bash
# Confirm example versions all match
grep -r 'version =' examples/

# Confirm COMPATIBILITY.md top row
head -6 COMPATIBILITY.md

# Confirm README.md compatibility row
grep -A1 'Terraform provider version' README.md | tail -1

# Confirm RELEASE_NOTES.md top section
head -20 RELEASE_NOTES.md
```

Report a summary of all files changed to the user, and remind them that the final step (not automated here) is to create and push the git tag:
```bash
git tag v<NEW_VERSION>
git push origin v<NEW_VERSION>
```
