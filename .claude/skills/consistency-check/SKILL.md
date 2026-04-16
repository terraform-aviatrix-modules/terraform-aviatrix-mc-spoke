---
name: consistency-check
description: >
  Run pre-push consistency and quality checks on the module. Use when the user says
  things like "run a consistency check", "check everything before I push", "validate
  the module", "lint check", or "is everything in order". Checks variable coverage in
  the README, description alignment, Terraform formatting, version consistency across
  files, and more.
---

# Consistency Check Skill — terraform-aviatrix-mc-spoke

Run all checks below in order. Report a clear pass/fail summary at the end. Fix any
errors automatically where safe to do so; flag warnings for the user to decide.

---

## Check 1 — Terraform formatting

```bash
terraform fmt -check -recursive .
```

If this exits non-zero, run `terraform fmt -recursive .` to auto-fix, then report
which files were changed. Formatting errors are always safe to auto-fix.

---

## Check 2 — Variable coverage and description alignment

Run the helper script from the repo root:

```bash
python3 .claude/skills/consistency-check/check.py
```

This checks:
- Every variable in `variables.tf` is present in the optional variables table in `README.md`
- Descriptions in the README don't diverge from `variables.tf` (warnings only — README
  descriptions are often intentionally shorter or rephrased for clarity)
- All `examples/*/main.tf` files reference the same module version
- The version in `README.md` matches the top row of `COMPATIBILITY.md`

If variables are missing from the README, add them to the correct alphabetical position
in the optional variables table. Use the existing row format:

```
variable_name | <cloud icon(s)> | default_value | Description from variables.tf.
```

For cloud-specific variables, only show the relevant cloud icon(s). The Azure icon path is:
`https://github.com/terraform-aviatrix-modules/terraform-aviatrix-mc-spoke/blob/main/img/azure.png?raw=true`

---

## Check 3 — No stray debug or placeholder values

Search for things that should never be committed:

```bash
grep -rn "TODO\|FIXME\|HACK\|XXX\|debug\s*=\s*true" --include="*.tf" .
grep -rn 'version\s*=\s*"0\.0\.0"' --include="*.tf" examples/
```

Flag any hits for the user to review.

---

## Check 4 — Release notes header matches target version

Check that the top `##` section in `RELEASE_NOTES.md` matches the version shown in
`README.md` and `COMPATIBILITY.md`:

```bash
head -5 RELEASE_NOTES.md
grep -m1 'v[0-9]' README.md
head -6 COMPATIBILITY.md
```

All three should agree on the same version. If not, flag it — do not auto-fix, as this
may indicate the release prep skill wasn't run yet.

---

## Check 5 — versions.tf provider constraint is consistent

Verify that the minimum provider version in `versions.tf` is >= the provider version
in the top row of `COMPATIBILITY.md`:

```bash
grep version versions.tf
head -6 COMPATIBILITY.md
```

These should align. If `COMPATIBILITY.md` says `>= 9.0.0` but `versions.tf` still
constrains to `>= 8.2.0`, flag it as an error.

---

## Reporting

After all checks, print a summary:

```
=== Consistency Check Summary ===
✓ Terraform formatting
✓ Variable coverage (N variables, all accounted for)
⚠ Description mismatches (list them — user to decide)
✓ Example versions consistent (9.0.0)
✓ Version alignment (README / COMPATIBILITY / RELEASE_NOTES all agree)
✓ No stray debug values
✓ versions.tf constraint aligned

Result: PASS / FAIL
```

If anything auto-fixed, list the changed files explicitly so the user knows to review them.
