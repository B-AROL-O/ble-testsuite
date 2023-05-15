#!/bin/bash
# ============================================================================================
# Test triggering a workflow by posting to GitHub REST API
#
# References:
# * https://docs.github.com/en/actions/learn-github-actions/understanding-github-actions
# * https://docs.github.com/en/rest/repos/repos?apiVersion=2022-11-28#create-a-repository-dispatch-event
# * https://www.enekoalonso.com/articles/issue-7
#
# HOW TO USE:
# * Open <https://github.com/settings/personal-access-tokens/new>
#   to generate a Personal Access Token
#   * Token name: `GM_TOK_DISPATCH_BLETS`
#   * Expiration: 30 days
#   * Description: `Repository gmacario/ble-testsuite dispatch`
#   * Resource owner: `gmacario`
#   * Repository access: Only select repositories
#     * `gmacario/ble-testsuite`
#   * Permissions:
#     * Repository permissions:
#       * Actions: Access: Read and write
#       * ...
#       * Contents: Access: Read and write
#       * ...
#       * Workflows: Access: Read and write
# * Review summary in section "Overview", then click "Generate token"
# * Copy the token and paste it to MY_TOKEN just below
# * Run the script and verify results 
# ============================================================================================

set -e
set -x

# MY_TOKEN=github_pat_xxxx
MY_TOKEN=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
OWNER="gmacario"
REPO="ble-testsuite"
WORKFLOW_ID="test-webhook.yml"
PAYLOAD="${PWD}/docs/sample_webhooks/2023-05-11-120942-webhook-site.json"

# Create a workflow dispatch event
# https://docs.github.com/en/rest/actions/workflows?apiVersion=2022-11-28#create-a-workflow-dispatch-event
# POST /repos/{owner}/{repo}/actions/workflows/{workflow_id}/dispatches
curl -L \
  -X POST \
  -H "Authorization: Bearer ${MY_TOKEN}" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/${OWNER}/${REPO}/actions/workflows/${WORKFLOW_ID}/dispatches \
  -d '{"ref":"feat/bitbucket-webhook","inputs":{"unit":false, "integration":false, "payload":false}'

# -d '{"ref":"main","inputs":{"unit":false, "integration":{}}}'
  # "unit":false,"integration":true

# # Create a repository dispatch event
# # ENDPOINT_URL="https://api.github.com/repos/${OWNER}/${REPO}/dispatches"
# cat ${PAYLOAD} | curl -L \
#   -X POST \
#   -H "Accept: application/vnd.github+json" \
#   -H "Authorization: Bearer ${MY_TOKEN}"\
#   -H "X-GitHub-Api-Version: 2022-11-28" \
#   https://api.github.com/repos/${OWNER}/${REPO}/dispatches \
#   -d '{"event_type":"on-demand-test","client_payload":{"unit":false,"integration":true}}'

# TODO

# EOF