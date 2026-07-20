#!/usr/bin/env sh

set -euo pipefail

ELASTIC_AUTH="${ELASTIC_USERNAME}:${ELASTIC_PASSWORD}"

echo "Waiting for Elasticsearch at ${ELASTIC_URL}..."
for i in $(seq 1 60); do
  if curl -sS --fail -u "${ELASTIC_AUTH}" \
    "${ELASTIC_URL}/_cluster/health?wait_for_status=green&timeout=1s" > /dev/null; then
    break
  fi
  sleep 5
done

echo "Register snapshot repository ${ELASTIC_SNAPSHOT_REPO}..."
curl -sS --fail -u "${ELASTIC_AUTH}" \
  -H 'Content-Type: application/json' \
  -X PUT "${ELASTIC_URL}/_snapshot/${ELASTIC_SNAPSHOT_REPO}" \
  -d "{
    \"type\": \"${ELASTIC_SNAPSHOT_STORE_TYPE}\",
    \"settings\": {
      \"${ELASTIC_SNAPSHOT_STORE_SETTING}\": \"${ELASTIC_SNAPSHOT_STORE}\",
      \"base_path\": \"${ELASTIC_SNAPSHOT_PREFIX}\",
      \"client\": \"default\"
    }
  }"

echo "Create/Update SLM policy daily..."
curl -sS --fail -u "${ELASTIC_AUTH}" \
  -H 'Content-Type: application/json' \
  -X PUT "${ELASTIC_URL}/_slm/policy/${ELASTIC_SNAPSHOT_REPO}" \
  -d "{
    \"schedule\": \"${ELASTIC_SNAPSHOT_SCHEDULE}\",
    \"name\": \"<snapshot-{now/d}>\",
    \"repository\": \"${ELASTIC_SNAPSHOT_REPO}\",
    \"config\": { \"indices\": [\"*\"], \"include_global_state\": true },
    \"retention\": {
      \"expire_after\": \"${ELASTIC_SNAPSHOT_EXPIRE_AFTER}\",
      \"min_count\": ${ELASTIC_SNAPSHOT_MIN_COUNT},
      \"max_count\": ${ELASTIC_SNAPSHOT_MAX_COUNT}
    }
  }"

echo "Done."
