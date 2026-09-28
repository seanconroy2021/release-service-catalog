#!/usr/bin/env bash
# Fails if a release-service-utils image digest added by this PR's diff
# is older than MAX_AGE_DAYS.

set -euo pipefail

fail=0
max_age_days=7
max_age_seconds=$(( max_age_days * 86400 ))
now=$(date +%s)

echo "Checking that new release-service-utils image references are no older than ${max_age_days} days"

# pull_request gives us a bare branch name, merge_group gives a full "refs/heads/..." ref
BASE_REF="${RAW_BASE_REF#refs/heads/}"

# checkout only fetches HEAD's history, so the base branch isn't available locally yet
git fetch --quiet origin "${BASE_REF}"

changed_yaml_files=$(git diff --name-only "origin/${BASE_REF}...HEAD" -- '*.yaml')

is_fresh() {
  ref="$1"

  # These refs are multi-arch manifest lists, so skopeo needs to be told which
  # platform to resolve to before it can hand back a single image's metadata
  if ! created=$(skopeo inspect --override-os linux --override-arch amd64 "docker://${ref}" 2>&1 | jq -r '.Created'); then
    echo "ERROR: failed to inspect ${ref}"
    echo "  ${created}"
    grep -rl "${ref}" ${changed_yaml_files} 2>/dev/null | sed 's/^/  /'
    return 1
  fi

  created_ts=$(date -d "${created}" +%s)
  age_days=$(( (now - created_ts) / 86400 ))

  if (( now - created_ts > max_age_seconds )); then
    echo "ERROR: ${ref} is ${age_days} days old (max ${max_age_days}), built ${created}"
    grep -rl "${ref}" ${changed_yaml_files} 2>/dev/null | sed 's/^/  /'
    return 1
  fi

  echo "OK: ${ref} is ${age_days} days old"
  return 0
}

# Only digests this diff actually adds, not ones already present in a file the PR happens to touch.
# --unified=0 strips the surrounding context lines so we're only looking at real +/- changes;
# the extra "grep -v '^+++'" drops the "+++ b/file" diff header, which also starts with a "+".
# sort -u so the same new digest pasted into several task YAMLs only gets checked once.
digests=$(
  git diff --unified=0 "origin/${BASE_REF}...HEAD" -- '*.yaml' \
    | grep -E '^\+' | grep -v '^\+\+\+' \
    | grep -oP "quay\.io/konflux-ci/release-service-utils@sha256:[a-f0-9]+" \
    | sort -u || true
)

if [[ -z "${digests}" ]]; then
  echo "No new image references introduced by this diff"
  exit 0
fi

for ref in ${digests}; do
  if ! is_fresh "${ref}"; then
    fail=1
  fi
done

exit ${fail}
