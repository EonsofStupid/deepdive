#!/usr/bin/env bash
# SessionStart hook — prime forked BRANCH sessions with their identity + close contract.
# Branch-scoped: does nothing unless CLYFFY_BRANCH_ID is set (the spawn scripts export it).
# Normal sessions are untouched.
set -euo pipefail

[ -z "${CLYFFY_BRANCH_ID:-}" ] && exit 0
HOME_DIR="${DEEPDIVE_HOME:-$HOME/.deepdive}"

# stdout from a SessionStart hook is injected as context for the session.
cat <<EOF
<deepdive-branch-context>
This session IS branch '${CLYFFY_BRANCH_ID}' (parent session: ${CLYFFY_BRANCH_PARENT:-unknown}) under the
DeepDive branch-fold discipline. THE CLOSE CONTRACT: this branch cannot close until (a) the running
decision notes are extended with the USER'S OWN reasoning captured in their words, and (b) the build-plan
notes for this decision are written. Work THIS branch's sub-topic only; fold back to the parent when
closed. Capture dir: ${HOME_DIR}/branches/${CLYFFY_BRANCH_ID}/
If DEEPDIVE_SIGNAL_CMD is set, emit lifecycle signals per transition (queue to ${HOME_DIR}/signal.queue
when the sink is busy).
</deepdive-branch-context>
EOF
exit 0
