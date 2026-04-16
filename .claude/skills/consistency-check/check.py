#!/usr/bin/env python3
"""
Consistency checker for terraform-aviatrix-mc-spoke.
Checks variable coverage and description alignment between variables.tf and README.md.
Run from the repo root.
"""

import re
import sys

VARIABLES_FILE = "variables.tf"
README_FILE = "README.md"
EXAMPLES_GLOB = "examples/*/main.tf"
COMPATIBILITY_FILE = "COMPATIBILITY.md"

errors = []
warnings = []


def parse_variables(path):
    """Return dict of {var_name: description} from a variables.tf file."""
    text = open(path).read()
    variables = {}
    for match in re.finditer(
        r'variable\s+"(\w+)"\s*\{[^}]*?description\s*=\s*"([^"]*)"',
        text,
        re.DOTALL,
    ):
        name, desc = match.group(1), match.group(2).strip()
        variables[name] = desc
    return variables


def parse_readme_variables(path):
    """
    Return dict of {var_name: description} from the optional variables table in README.md.
    Handles both plain names and markdown links: [name](url)
    Also handles rows with a leading pipe: | name | ... | ... | ... |
    """
    text = open(path).read()
    readme_vars = {}
    for line in text.splitlines():
        # Strip leading pipe and whitespace (mc-spoke uses | key | ... | format)
        stripped = line.lstrip("| \t")
        # Match table rows: name | icons | default | description
        m = re.match(r"^\[?(\w+)\]?(?:\([^)]*\))?\s*\|(.+)", stripped)
        if not m:
            continue
        name = m.group(1)
        if name in readme_vars:
            # Only record the first occurrence (avoids sub-table rows shadowing top-level vars)
            continue
        rest = m.group(2)
        parts = [p.strip() for p in rest.split("|")]
        if len(parts) >= 3:
            desc = parts[2].strip()
            if desc:
                readme_vars[name] = desc
    return readme_vars


def check_variable_coverage(tf_vars, readme_vars):
    """Every variable in variables.tf should appear in README.md."""
    # Required variables (cloud, name, region, account) live in a separate table
    # and don't appear in the optional table — skip them.
    # Required variables live in the required table, not the optional table — skip them.
    # cidr and transit_gw are documented in the required table even though they have defaults.
    always_required = {"cloud", "name", "region", "cidr", "account", "transit_gw"}
    # Variables intentionally omitted from README (e.g. hidden backward-compat flags)
    intentionally_undocumented = set()
    for name in sorted(tf_vars):
        if name in always_required or name in intentionally_undocumented:
            continue
        if name not in readme_vars:
            errors.append(f"MISSING from README : variable '{name}'")


def check_descriptions(tf_vars, readme_vars):
    """Flag variables where the README description diverges significantly from variables.tf."""
    for name, tf_desc in tf_vars.items():
        if name not in readme_vars:
            continue
        readme_desc = readme_vars[name]
        # Normalise whitespace and case for comparison
        tf_norm = re.sub(r"\s+", " ", tf_desc).lower().rstrip(".")
        rm_norm = re.sub(r"\s+", " ", readme_desc).lower().rstrip(".")
        if tf_norm and rm_norm and tf_norm != rm_norm:
            warnings.append(
                f"DESCRIPTION MISMATCH for '{name}':\n"
                f"  variables.tf : {tf_desc}\n"
                f"  README.md    : {readme_desc}"
            )


def check_example_versions():
    """All examples should reference the same module version."""
    import glob

    versions = {}
    for path in sorted(glob.glob(EXAMPLES_GLOB)):
        text = open(path).read()
        m = re.search(r'version\s*=\s*"([^"]+)"', text)
        if m:
            versions[path] = m.group(1)

    unique = set(versions.values())
    if len(unique) > 1:
        errors.append(f"INCONSISTENT example versions: {versions}")
    elif versions:
        print(f"  Examples version   : {next(iter(unique))} ({len(versions)} files)")


def check_readme_vs_compatibility():
    """The version in README.md should match the top row of COMPATIBILITY.md."""
    readme = open(README_FILE).read()
    compat = open(COMPATIBILITY_FILE).read()

    rm = re.search(r"(v\d+\.\d+\.\d+)\s*\|", readme)
    cm = re.search(r"(v\d+\.\d+\.\d+)\s*\|", compat)

    if rm and cm:
        rv, cv = rm.group(1), cm.group(1)
        print(f"  README version     : {rv}")
        print(f"  COMPATIBILITY top  : {cv}")
        if rv != cv:
            errors.append(
                f"VERSION MISMATCH: README.md shows {rv} but COMPATIBILITY.md top row is {cv}"
            )


def main():
    print("\n=== terraform-aviatrix-mc-spoke consistency check ===\n")

    tf_vars = parse_variables(VARIABLES_FILE)
    readme_vars = parse_readme_variables(README_FILE)

    print(f"  variables.tf vars  : {len(tf_vars)}")
    print(f"  README table vars  : {len(readme_vars)}")

    check_variable_coverage(tf_vars, readme_vars)
    check_descriptions(tf_vars, readme_vars)
    check_example_versions()
    check_readme_vs_compatibility()

    print()
    if warnings:
        print("WARNINGS:")
        for w in warnings:
            print(f"  ⚠  {w}")
        print()

    if errors:
        print("ERRORS:")
        for e in errors:
            print(f"  ✗  {e}")
        print(f"\n{len(errors)} error(s) found. Please fix before pushing.\n")
        sys.exit(1)
    else:
        print(f"✓  All checks passed ({len(warnings)} warning(s)).\n")


if __name__ == "__main__":
    main()
