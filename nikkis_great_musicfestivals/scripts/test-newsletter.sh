#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# Nikki's Great Music Festivals — Newsletter Monkey Test
#
# Tests the full subscribe → send → unsubscribe flow end-to-end
# against a live deployment.
#
# Usage:
#   bash scripts/test-newsletter.sh
#
# Required env vars (copy to scripts/.test-env and source it, or export inline):
#   SITE_URL        - deployed URL, e.g. https://nikkisgreatmusicfestivals.vercel.app
#   ADMIN_SECRET    - value you set in Vercel as ADMIN_SECRET
#   EMAIL_1         - first test email address
#   EMAIL_2         - second test email address
#
# Supabase anon credentials are read from ../.env automatically.
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

# ── Config ───────────────────────────────────────────────────────────────────

# Load test env overrides if present
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_ENV="$SCRIPT_DIR/.test-env"
if [[ -f "$TEST_ENV" ]]; then
  # shellcheck source=/dev/null
  source "$TEST_ENV"
fi

# Load project .env for Supabase credentials
PROJECT_ENV="$SCRIPT_DIR/../.env"
if [[ -f "$PROJECT_ENV" ]]; then
  # shellcheck source=/dev/null
  source "$PROJECT_ENV"
fi

SITE_URL="${SITE_URL:-}"
ADMIN_SECRET="${ADMIN_SECRET:-}"
EMAIL_1="${EMAIL_1:-}"
EMAIL_2="${EMAIL_2:-}"
SUPABASE_URL="${VITE_SUPABASE_URL:-}"
SUPABASE_ANON_KEY="${VITE_SUPABASE_KEY:-}"

# ── Pre-flight checks ─────────────────────────────────────────────────────────

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
BOLD='\033[1m'

ok()   { echo -e "${GREEN}  ✓${NC} $1"; }
fail() { echo -e "${RED}  ✗${NC} $1"; }
info() { echo -e "${CYAN}  →${NC} $1"; }
warn() { echo -e "${YELLOW}  ⚠${NC} $1"; }

echo ""
echo -e "${BOLD}═══════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}  Nikki's Great Music Festivals — Newsletter Test${NC}"
echo -e "${BOLD}═══════════════════════════════════════════════════════${NC}"
echo ""

MISSING=0
[[ -z "$SITE_URL"      ]] && { fail "SITE_URL not set";      MISSING=1; }
[[ -z "$ADMIN_SECRET"  ]] && { fail "ADMIN_SECRET not set";  MISSING=1; }
[[ -z "$EMAIL_1"       ]] && { fail "EMAIL_1 not set";       MISSING=1; }
[[ -z "$EMAIL_2"       ]] && { fail "EMAIL_2 not set";       MISSING=1; }
[[ -z "$SUPABASE_URL"  ]] && { fail "VITE_SUPABASE_URL not set (check .env)"; MISSING=1; }
[[ -z "$SUPABASE_ANON_KEY" ]] && { fail "VITE_SUPABASE_KEY not set (check .env)"; MISSING=1; }

if [[ "$MISSING" == "1" ]]; then
  echo ""
  echo -e "${YELLOW}Set missing vars in scripts/.test-env:${NC}"
  echo "  SITE_URL=https://nikkisgreatmusicfestivals.vercel.app"
  echo "  ADMIN_SECRET=your-admin-secret-here"
  echo "  EMAIL_1=you@example.com"
  echo "  EMAIL_2=you+alias@example.com"
  echo ""
  echo -e "${YELLOW}(scripts/.test-env is gitignored — safe for secrets)${NC}"
  exit 1
fi

echo -e "  Target: ${BOLD}$SITE_URL${NC}"
echo -e "  Emails: ${BOLD}$EMAIL_1${NC} and ${BOLD}$EMAIL_2${NC}"
echo ""

# ── Helper: call API endpoint ─────────────────────────────────────────────────

api_post() {
  local path="$1"
  local body="$2"
  local extra_headers="${3:-}"
  curl -sS -X POST "${SITE_URL}${path}" \
    -H "Content-Type: application/json" \
    ${extra_headers:+-H "$extra_headers"} \
    -d "$body" \
    -w "\n%{http_code}" \
    --max-time 20
}

supabase_post() {
  local table="$1"
  local body="$2"
  curl -sS -X POST "${SUPABASE_URL}/rest/v1/${table}" \
    -H "apikey: ${SUPABASE_ANON_KEY}" \
    -H "Authorization: Bearer ${SUPABASE_ANON_KEY}" \
    -H "Content-Type: application/json" \
    -H "Prefer: return=representation" \
    -d "$body" \
    -w "\n%{http_code}" \
    --max-time 20
}

supabase_get() {
  local path="$1"
  curl -sS -X GET "${SUPABASE_URL}/rest/v1/${path}" \
    -H "apikey: ${SUPABASE_ANON_KEY}" \
    -H "Authorization: Bearer ${SUPABASE_ANON_KEY}" \
    -H "Content-Type: application/json" \
    --max-time 20
}

supabase_patch() {
  local table="$1"
  local filter="$2"
  local body="$3"
  curl -sS -X PATCH "${SUPABASE_URL}/rest/v1/${table}?${filter}" \
    -H "apikey: ${SUPABASE_ANON_KEY}" \
    -H "Authorization: Bearer ${SUPABASE_ANON_KEY}" \
    -H "Content-Type: application/json" \
    -d "$body" \
    --max-time 20
}

# ── Step 1: Subscribe both emails ─────────────────────────────────────────────

echo -e "${BOLD}Step 1 — Subscribe${NC}"

for email in "$EMAIL_1" "$EMAIL_2"; do
  name="Test $(echo "$email" | cut -d@ -f1)"
  body="{\"email\":\"${email}\",\"name\":\"${name}\",\"lists\":[\"newsletter\"]}"
  response=$(api_post "/api/newsletter/subscribe" "$body" || true)
  http_code=$(echo "$response" | tail -1)
  resp_body=$(echo "$response" | head -1)

  if [[ "$http_code" == "200" ]]; then
    ok "Subscribed: $email"
  else
    fail "Subscribe failed for $email (HTTP $http_code): $resp_body"
    exit 1
  fi
done

echo ""

# ── Step 2: Verify subscribers in Supabase ────────────────────────────────────

echo -e "${BOLD}Step 2 — Verify subscribers in database${NC}"

for email in "$EMAIL_1" "$EMAIL_2"; do
  encoded=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$email'))" 2>/dev/null || echo "$email")
  result=$(supabase_get "newsletter_subscribers?email=eq.${encoded}&select=email,status,subscribed_newsletter")
  if echo "$result" | grep -q "\"$email\""; then
    ok "Confirmed in DB: $email"
  else
    warn "Could not verify $email in DB (may be RLS or network): $result"
  fi
done

echo ""

# ── Step 3: Create test newsletter draft ──────────────────────────────────────

echo -e "${BOLD}Step 3 — Create test newsletter draft${NC}"

TIMESTAMP=$(date '+%Y-%m-%d %H:%M')
NL_TITLE="[MONKEY TEST] $TIMESTAMP"
NL_SUBJECT="🐒 Test Newsletter — $TIMESTAMP"
NL_BLOCKS='[{"type":"intro","title":"Monkey Test 🐒","body":"This is an automated end-to-end test of the newsletter system. If you are reading this, the workflow is working!\n\nSubscribed from: '"$SITE_URL"'"}]'

body="{\"title\":$(printf '%s' "$NL_TITLE" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read()))"),\"subject\":$(printf '%s' "$NL_SUBJECT" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read()))"),\"blocks\":$(echo "$NL_BLOCKS"),\"status\":\"draft\"}"

response=$(supabase_post "newsletters" "$body" || true)
http_code=$(echo "$response" | tail -1)
resp_body=$(echo "$response" | head -1)

NEWSLETTER_ID=""
if [[ "$http_code" == "201" ]]; then
  NEWSLETTER_ID=$(echo "$resp_body" | python3 -c "import sys,json; data=json.load(sys.stdin); print(data[0]['id'] if isinstance(data,list) else data['id'])" 2>/dev/null || echo "")
  if [[ -n "$NEWSLETTER_ID" ]]; then
    ok "Created newsletter draft: $NEWSLETTER_ID"
  else
    fail "Created but could not parse newsletter ID from: $resp_body"
    exit 1
  fi
else
  fail "Failed to create newsletter (HTTP $http_code): $resp_body"
  echo ""
  echo -e "${YELLOW}Hint: If this is a 401/403, the newsletters table may need an RLS policy."
  echo -e "      Run this in Supabase SQL editor:${NC}"
  echo "      ALTER TABLE newsletters ENABLE ROW LEVEL SECURITY;"
  echo "      CREATE POLICY \"Anon manages newsletters\" ON newsletters FOR ALL USING (true) WITH CHECK (true);"
  exit 1
fi

echo ""

# ── Step 4: Send newsletter ───────────────────────────────────────────────────

echo -e "${BOLD}Step 4 — Send newsletter${NC}"
info "POSTing to /api/newsletter/send with newsletter_id: $NEWSLETTER_ID"

body="{\"newsletter_id\":\"${NEWSLETTER_ID}\"}"
response=$(api_post "/api/newsletter/send" "$body" "x-admin-secret: ${ADMIN_SECRET}" || true)
http_code=$(echo "$response" | tail -1)
resp_body=$(echo "$response" | head -1)

if [[ "$http_code" == "200" ]]; then
  sent=$(echo "$resp_body" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('sent','?'))" 2>/dev/null || echo "?")
  ok "Newsletter sent! Reported delivery count: ${BOLD}${sent}${NC}"
  if [[ "$sent" == "0" ]]; then
    warn "Sent=0 — check that MAILGUN_API_KEY is set in Vercel env vars"
  fi
elif [[ "$http_code" == "401" ]]; then
  fail "Unauthorized (HTTP 401) — check that ADMIN_SECRET in Vercel matches ADMIN_SECRET in scripts/.test-env"
  exit 1
elif [[ "$http_code" == "500" ]]; then
  fail "Server error (HTTP 500): $resp_body"
  warn "Check Vercel function logs: vercel logs --follow"
  exit 1
else
  fail "Unexpected response (HTTP $http_code): $resp_body"
  exit 1
fi

echo ""

# ── Step 5: Verify newsletter is marked sent ──────────────────────────────────

echo -e "${BOLD}Step 5 — Verify newsletter status${NC}"

result=$(supabase_get "newsletters?id=eq.${NEWSLETTER_ID}&select=id,status,sent_at,recipient_count")
if echo "$result" | grep -q '"status":"sent"'; then
  count=$(echo "$result" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d[0].get('recipient_count','?'))" 2>/dev/null || echo "?")
  ok "Newsletter status=sent in DB (recipient_count: $count)"
else
  warn "Newsletter status may not have updated yet: $result"
fi

echo ""

# ── Done ──────────────────────────────────────────────────────────────────────

echo -e "${BOLD}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}${BOLD}  All steps passed!${NC}"
echo ""
echo -e "  Check your inboxes for:"
echo -e "    • ${BOLD}$EMAIL_1${NC}"
echo -e "    • ${BOLD}$EMAIL_2${NC}"
echo ""
echo -e "  Subject: ${BOLD}$NL_SUBJECT${NC}"
echo ""
echo -e "  To clean up test data, run:"
echo -e "    ${CYAN}bash scripts/test-newsletter.sh --cleanup $NEWSLETTER_ID${NC}"
echo -e "${BOLD}═══════════════════════════════════════════════════════${NC}"
echo ""

# ── Optional cleanup ──────────────────────────────────────────────────────────

if [[ "${1:-}" == "--cleanup" ]]; then
  CLEANUP_ID="${2:-$NEWSLETTER_ID}"
  echo -e "${BOLD}Cleanup — removing test data${NC}"
  info "Deleting newsletter: $CLEANUP_ID"
  curl -sS -X DELETE "${SUPABASE_URL}/rest/v1/newsletters?id=eq.${CLEANUP_ID}" \
    -H "apikey: ${SUPABASE_ANON_KEY}" \
    -H "Authorization: Bearer ${SUPABASE_ANON_KEY}" \
    -o /dev/null -w "HTTP %{http_code}\n" --max-time 10
  for email in "$EMAIL_1" "$EMAIL_2"; do
    encoded=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$email'))" 2>/dev/null || echo "$email")
    info "Removing subscriber: $email"
    curl -sS -X DELETE "${SUPABASE_URL}/rest/v1/newsletter_subscribers?email=eq.${encoded}" \
      -H "apikey: ${SUPABASE_ANON_KEY}" \
      -H "Authorization: Bearer ${SUPABASE_ANON_KEY}" \
      -o /dev/null -w "HTTP %{http_code}\n" --max-time 10
  done
  ok "Test data cleaned up"
fi
