#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# Nikki's Great Music Festivals — Newsletter Monkey Test
#
# Tests the full subscribe → send flow end-to-end against a live deployment.
# Auth uses real Supabase JWT (signs in as admin, uses access_token).
#
# Usage:
#   bash scripts/test-newsletter.sh
#
# Required env vars (set in scripts/.test-env):
#   SITE_URL        - e.g. https://nikkisgreatmusicfestivals.vercel.app
#   ADMIN_EMAIL     - your Supabase admin login email
#   ADMIN_PASSWORD  - your Supabase admin password
#   EMAIL_1         - first test email address
#   EMAIL_2         - second test email address
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load scripts/.test-env
if [[ -f "$SCRIPT_DIR/.test-env" ]]; then source "$SCRIPT_DIR/.test-env"; fi
# Load project .env for Supabase URL + anon key
if [[ -f "$SCRIPT_DIR/../.env" ]]; then source "$SCRIPT_DIR/../.env"; fi

SITE_URL="${SITE_URL:-}"
ADMIN_EMAIL="${ADMIN_EMAIL:-}"
ADMIN_PASSWORD="${ADMIN_PASSWORD:-}"
EMAIL_1="${EMAIL_1:-}"
EMAIL_2="${EMAIL_2:-}"
SUPABASE_URL="${VITE_SUPABASE_URL:-}"
SUPABASE_ANON_KEY="${VITE_SUPABASE_KEY:-}"

# ── Colours ───────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'; BOLD='\033[1m'
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
[[ -z "$SITE_URL"       ]] && { fail "SITE_URL not set";       MISSING=1; }
[[ -z "$ADMIN_EMAIL"    ]] && { fail "ADMIN_EMAIL not set";    MISSING=1; }
[[ -z "$ADMIN_PASSWORD" ]] && { fail "ADMIN_PASSWORD not set"; MISSING=1; }
[[ -z "$EMAIL_1"        ]] && { fail "EMAIL_1 not set";        MISSING=1; }
[[ -z "$EMAIL_2"        ]] && { fail "EMAIL_2 not set";        MISSING=1; }
[[ -z "$SUPABASE_URL"   ]] && { fail "VITE_SUPABASE_URL not set (check .env)"; MISSING=1; }
[[ -z "$SUPABASE_ANON_KEY" ]] && { fail "VITE_SUPABASE_KEY not set (check .env)"; MISSING=1; }

if [[ "$MISSING" == "1" ]]; then
  echo ""
  echo -e "${YELLOW}Set missing vars in scripts/.test-env:${NC}"
  cat <<'EXAMPLE'
  SITE_URL=https://nikkisgreatmusicfestivals.vercel.app
  ADMIN_EMAIL=nikki@example.com
  ADMIN_PASSWORD=your-supabase-admin-password
  EMAIL_1=you@example.com
  EMAIL_2=you+test@example.com
EXAMPLE
  exit 1
fi

echo -e "  Target: ${BOLD}$SITE_URL${NC}"
echo -e "  Emails: ${BOLD}$EMAIL_1${NC} and ${BOLD}$EMAIL_2${NC}"
echo ""

# ── Helpers ───────────────────────────────────────────────────────────────────

api_post() {
  local path="$1" body="$2" extra_header="${3:-}"
  curl -sS -X POST "${SITE_URL}${path}" \
    -H "Content-Type: application/json" \
    ${extra_header:+-H "$extra_header"} \
    -d "$body" -w "\n%{http_code}" --max-time 20
}

supabase_post() {
  local table="$1" body="$2"
  curl -sS -X POST "${SUPABASE_URL}/rest/v1/${table}" \
    -H "apikey: ${SUPABASE_ANON_KEY}" \
    -H "Authorization: Bearer ${SUPABASE_ANON_KEY}" \
    -H "Content-Type: application/json" \
    -H "Prefer: return=representation" \
    -d "$body" -w "\n%{http_code}" --max-time 20
}

supabase_get() {
  curl -sS "${SUPABASE_URL}/rest/v1/${1}" \
    -H "apikey: ${SUPABASE_ANON_KEY}" \
    -H "Authorization: Bearer ${SUPABASE_ANON_KEY}" \
    --max-time 20
}

# ── Step 1: Sign in as admin → get JWT ───────────────────────────────────────

echo -e "${BOLD}Step 1 — Admin sign-in (get JWT)${NC}"

auth_resp=$(curl -sS -X POST "${SUPABASE_URL}/auth/v1/token?grant_type=password" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"${ADMIN_EMAIL}\",\"password\":\"${ADMIN_PASSWORD}\"}" \
  --max-time 20)

JWT=$(echo "$auth_resp" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('access_token',''))" 2>/dev/null || echo "")

if [[ -z "$JWT" ]]; then
  fail "Sign-in failed — check ADMIN_EMAIL and ADMIN_PASSWORD"
  echo "  Response: $auth_resp"
  exit 1
fi
ok "Signed in as $ADMIN_EMAIL"
echo ""

# ── Step 2: Subscribe both emails ────────────────────────────────────────────

echo -e "${BOLD}Step 2 — Subscribe${NC}"

for email in "$EMAIL_1" "$EMAIL_2"; do
  name="Test $(echo "$email" | cut -d@ -f1)"
  response=$(api_post "/api/newsletter/subscribe" \
    "{\"email\":\"${email}\",\"name\":\"${name}\",\"lists\":[\"newsletter\"]}" || true)
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

# ── Step 3: Verify in Supabase ────────────────────────────────────────────────

echo -e "${BOLD}Step 3 — Verify in database${NC}"
for email in "$EMAIL_1" "$EMAIL_2"; do
  encoded=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$email'))" 2>/dev/null || echo "$email")
  result=$(supabase_get "newsletter_subscribers?email=eq.${encoded}&select=email,status")
  if echo "$result" | grep -q "\"$email\""; then
    ok "Confirmed in DB: $email"
  else
    warn "Could not verify $email in DB: $result"
  fi
done
echo ""

# ── Step 4: Create test newsletter draft ─────────────────────────────────────

echo -e "${BOLD}Step 4 — Create test newsletter draft${NC}"

TIMESTAMP=$(date '+%Y-%m-%d %H:%M')
NL_SUBJECT="🐒 Monkey Test Newsletter — $TIMESTAMP"
body="{\"title\":\"[MONKEY TEST] ${TIMESTAMP}\",\"subject\":\"${NL_SUBJECT}\",\"blocks\":[{\"type\":\"intro\",\"title\":\"Monkey Test 🐒\",\"body\":\"End-to-end test of the newsletter system. If you see this, it works!\"}],\"status\":\"draft\"}"

response=$(supabase_post "newsletters" "$body" || true)
http_code=$(echo "$response" | tail -1)
resp_body=$(echo "$response" | head -1)

NEWSLETTER_ID=""
if [[ "$http_code" == "201" ]]; then
  NEWSLETTER_ID=$(echo "$resp_body" | python3 -c "import sys,json; d=json.load(sys.stdin); r=d[0] if isinstance(d,list) else d; print(r['id'])" 2>/dev/null || echo "")
fi

if [[ -z "$NEWSLETTER_ID" ]]; then
  fail "Failed to create newsletter (HTTP $http_code): $resp_body"
  echo ""
  echo -e "${YELLOW}Hint — run this SQL in Supabase if you get 403:${NC}"
  echo "  ALTER TABLE newsletters ENABLE ROW LEVEL SECURITY;"
  echo "  CREATE POLICY \"Anon manages newsletters\" ON newsletters FOR ALL USING (true) WITH CHECK (true);"
  exit 1
fi
ok "Created draft: $NEWSLETTER_ID"
echo ""

# ── Step 5: Send newsletter (JWT auth) ───────────────────────────────────────

echo -e "${BOLD}Step 5 — Send newsletter${NC}"
info "Using Supabase JWT for auth"

response=$(api_post "/api/newsletter/send" \
  "{\"newsletter_id\":\"${NEWSLETTER_ID}\"}" \
  "Authorization: Bearer ${JWT}" || true)
http_code=$(echo "$response" | tail -1)
resp_body=$(echo "$response" | head -1)

if [[ "$http_code" == "200" ]]; then
  sent=$(echo "$resp_body" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('sent','?'))" 2>/dev/null || echo "?")
  ok "Newsletter sent! Delivery count: ${BOLD}${sent}${NC}"
  [[ "$sent" == "0" ]] && warn "sent=0 — check MAILGUN_API_KEY is set in Vercel env vars"
elif [[ "$http_code" == "401" ]]; then
  fail "Unauthorized (401) — JWT rejected. Is SUPABASE_SERVICE_ROLE_KEY set in Vercel?"
  exit 1
elif [[ "$http_code" == "500" ]]; then
  fail "Server error (500): $resp_body"
  warn "Check Vercel function logs"
  exit 1
else
  fail "Unexpected (HTTP $http_code): $resp_body"
  exit 1
fi
echo ""

# ── Done ─────────────────────────────────────────────────────────────────────

echo -e "${BOLD}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}${BOLD}  All steps passed!${NC}"
echo ""
echo -e "  Check your inboxes:"
echo -e "    • ${BOLD}$EMAIL_1${NC}"
echo -e "    • ${BOLD}$EMAIL_2${NC}"
echo ""
echo -e "  To clean up test data:"
echo -e "    ${CYAN}bash scripts/test-newsletter.sh --cleanup $NEWSLETTER_ID${NC}"
echo -e "${BOLD}═══════════════════════════════════════════════════════${NC}"
echo ""

# ── Optional cleanup ──────────────────────────────────────────────────────────

if [[ "${1:-}" == "--cleanup" ]]; then
  CLEANUP_ID="${2:-$NEWSLETTER_ID}"
  echo -e "${BOLD}Cleanup${NC}"
  curl -sS -X DELETE "${SUPABASE_URL}/rest/v1/newsletters?id=eq.${CLEANUP_ID}" \
    -H "apikey: ${SUPABASE_ANON_KEY}" -H "Authorization: Bearer ${SUPABASE_ANON_KEY}" \
    -o /dev/null -w "  newsletter HTTP %{http_code}\n" --max-time 10
  for email in "$EMAIL_1" "$EMAIL_2"; do
    encoded=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$email'))" 2>/dev/null || echo "$email")
    curl -sS -X DELETE "${SUPABASE_URL}/rest/v1/newsletter_subscribers?email=eq.${encoded}" \
      -H "apikey: ${SUPABASE_ANON_KEY}" -H "Authorization: Bearer ${SUPABASE_ANON_KEY}" \
      -o /dev/null -w "  subscriber $email HTTP %{http_code}\n" --max-time 10
  done
  ok "Test data cleaned up"
fi
