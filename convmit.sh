#!/usr/bin/env bash

# This script is used to create commits using the conventional commits spec.
# Thanks to the Gum examples for some of their Code and Google for the err() fn.

set -euo pipefail

perr() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

if ! command_exists gum; then
  perr "Gum is not installed!"
  exit 1
fi

type=$(gum choose --header="Choose Type:" \
  "fix" \
  "feat" \
  "docs" \
  "style" \
  "refactor" \
  "test" \
  "chore" \
  "revert")

scope=$(gum input --placeholder "scope (optional)")
test -n "$scope" && scope="(${scope})"

summary=$(gum input --placeholder "Summary of the change")
if [[ $summary == "" ]]; then
  perr "No summary provided"
  exit 1
fi

is_breaking_change=$(gum choose --header="Is this a breaking change?" \
  --selected="no" \
  "yes" \
  "no")
if [[ $is_breaking_change == "yes" ]]; then
  breaking_change_char="!"
else
  breaking_change_char=""
fi

commit_message="${type}${scope}${breaking_change_char}: ${summary}"

if gum confirm "Commit changes with this message: ${commit_message}"; then
  echo "Committing:"

  git add .
  git commit -am "$commit_message"
else
  echo "Commit aborted!"
fi
