#!/usr/bin/env bash
# emailreadvalidate.sh
# Interactive email reader/validator with single and batch modes.
# Drop into /C:/Users/... and run with Bash (WSL, Git Bash, Cygwin, etc.)

set -euo pipefail

# Basic (practical) email regex - not full RFC but covers common cases.
EMAIL_RE='^[A-Za-z0-9!#$%&'"'"'*+/=?^_`{|}~.-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'

trim() {
    # trim leading/trailing whitespace including CR
    local s="$*"
    s="${s#"${s%%[![:space:]]*}"}"
    s="${s%"${s##*[![:space:]]}"}"
    s="${s//$'\r'/}"
    printf '%s' "$s"
}

validate_email() {
    local email="$1"

    # quick syntactic check
    if [[ ! $email =~ $EMAIL_RE ]]; then
        printf '%s\n' "invalid" && return 1
    fi

    # reject leading/trailing dot or consecutive dots in local-part or domain
    local localpart domain
    localpart="${email%@*}"
    domain="${email#*@}"

    if [[ $localpart == .* || $localpart == *. || $domain == .* || $domain == *. ]]; then
        printf '%s\n' "invalid" && return 1
    fi
    if [[ $localpart == *..* || $domain == *..* ]]; then
        printf '%s\n' "invalid" && return 1
    fi

    # domain label checks (no label starts/ends with hyphen)
    IFS='.' read -r -a labels <<< "$domain"
    for lbl in "${labels[@]}"; do
        if [[ -z $lbl || $lbl == -* || $lbl == *- ]]; then
            printf '%s\n' "invalid" && return 1
        fi
    done

    printf '%s\n' "valid"
    return 0
}

check_dns_mx() {
    # returns 0 if MX or A record exists, 2 if no network tooling found, 1 if missing
    local domain="$1"
    if command -v dig >/dev/null 2>&1; then
        if dig +short MX "$domain" | grep -q .; then return 0; fi
        if dig +short A "$domain" | grep -q .; then return 0; fi
        return 1
    elif command -v host >/dev/null 2>&1; then
        if host -t MX "$domain" | grep -q 'mail is handled'; then return 0; fi
        if host -t A "$domain" | grep -q 'has address'; then return 0; fi
        return 1
    elif command -v nslookup >/dev/null 2>&1; then
        if nslookup -type=mx "$domain" 2>/dev/null | grep -q '^'; then
            # nslookup output is noisy; just try to see non-empty
            return 0
        fi
        return 1
    else
        return 2
    fi
}

read_one_and_validate() {
    while true; do
        printf '\nEnter email (or blank to cancel): '
        IFS= read -r raw_email
        raw_email="$(trim "$raw_email")"
        [[ -z $raw_email ]] && { printf 'Canceled.\n'; return; }

        if validate_email "$raw_email"; then
            printf 'Result: VALID\n'
            printf 'Local-part: %s\n' "${raw_email%@*}"
            printf 'Domain    : %s\n' "${raw_email#*@}"

            # DNS check (optional)
            check_dns_mx "${raw_email#*@}"
            case $? in
                0) printf 'DNS check: MX/A record found\n' ;;
                1) printf 'DNS check: No MX/A records found for domain\n' ;;
                2) printf 'DNS check: no DNS tool (dig/host/nslookup) available to verify\n' ;;
            esac

            return
        else
            printf 'Result: INVALID email syntax.\n'
            printf 'Options: [r]etry, [e]dit, [q]uit to menu: '
            IFS= read -r opt
            opt="${opt:-r}"
            case "${opt,,}" in
                r) continue ;;
                e) printf 'Please re-enter corrected email: '; IFS= read -r raw_email; raw_email="$(trim "$raw_email")"; if [[ -z $raw_email ]]; then printf 'Canceled.\n'; return; fi; if validate_email "$raw_email"; then printf 'Now VALID\n'; return; else printf 'Still INVALID\n'; continue; fi ;;
                q) return ;;
                *) printf 'Unknown option, retrying...\n'; continue ;;
            esac
        fi
    done
}

validate_file() {
    local file="$1"
    if [[ ! -f $file ]]; then
        printf 'File not found: %s\n' "$file"
        return 1
    fi
    local total=0 good=0 bad=0 blank=0
    while IFS= read -r line || [[ -n $line ]]; do
        total=$((total+1))
        line="$(trim "$line")"
        if [[ -z $line ]]; then
            blank=$((blank+1)); continue
        fi
        if validate_email "$line"; then
            printf 'OK  : %s\n' "$line"
            good=$((good+1))
        else
            printf 'BAD : %s\n' "$line"
            bad=$((bad+1))
        fi
    done < "$file"
    printf '\nSummary: total=%d good=%d bad=%d blank=%d\n' "$total" "$good" "$bad" "$blank"
}

main_menu() {
    while true; do
        cat <<'MENU'

Email Validator - choose an option:
    1) Validate single email (interactive)
    2) Validate emails from file (one per line)
    3) Exit

MENU
        printf 'Selection: '
        IFS= read -r choice
        case "$choice" in
            1) read_one_and_validate ;;
            2)
                printf 'Enter path to file: '
                IFS= read -r f
                f="$(trim "$f")"
                validate_file "$f"
                ;;
            3|q|quit) printf 'Goodbye.\n'; return 0 ;;
            *) printf 'Invalid choice. Try 1,2 or 3.\n' ;;
        esac
    done
}

# If an email argument is passed, validate it non-interactively
if [[ $# -gt 0 ]]; then
    input="$(trim "$*")"
    if validate_email "$input"; then
        printf 'VALID: %s\n' "$input"
        check_dns_mx "${input#*@}"
        case $? in 0) printf 'DNS: MX/A exists\n' ;; 1) printf 'DNS: no MX/A\n' ;; 2) printf 'DNS: no DNS tool\n' ;; esac
        exit 0
    else
        printf 'INVALID: %s\n' "$input"
        exit 2
    fi
fi

# Run interactive menu
main_menu