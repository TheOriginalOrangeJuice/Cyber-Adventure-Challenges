#!/usr/bin/env bash

# Concept 2: URL & Web Encoding (The Browser Buffet)
# Interactive quiz shell. Locks down Ctrl+C/Ctrl+Z/Ctrl+\ and ignores Ctrl+D.

IGNOREEOF=100000
set -o ignoreeof
trap 'printf ""' INT QUIT TSTP

reset=$'\033[0m'
primary=$'\033[38;5;51m'
accent=$'\033[38;5;214m'   # question text
code_color=$'\033[38;5;45m' # encoded blob
success=$'\033[38;5;82m'
warn=$'\033[38;5;203m'
muted=$'\033[2m'

intro_animation() {
  local frames=(
    "[ warming browser buffet ] >>>====> url"
    "[ warming browser buffet ] >>>====> html"
    "[ warming browser buffet ] >>>====> js\\x"
    "[ warming browser buffet ] >>>====> ready"
  )
  printf "%b" "${accent}"
  for _ in {1..8}; do
    for frame in "${frames[@]}"; do
      printf "\r%s" "$frame"
      sleep 0.08
    done
  done
  printf "\r%-42s\r%b\n" "[ warming browser buffet ] >>>====> served" "${reset}"
}

banner() {
  printf "%b" "${accent}"
  cat <<'EOF'
╔════════════════════════════════════╗
║   The Browser Buffet: URL Tastings  ║
╚════════════════════════════════════╝
EOF
  printf "%b" "${reset}"
  printf "%b\n" "${primary}Welcome! Decode each web-flavored bite to unlock the flag.${reset}"
  printf "%b\n\n" "${muted}Tip: CTRL+C/CTRL+D are disabled; close the session if you must leave.${reset}"
}

celebrate() {
  printf "%b\n" "${success}Nice work!${reset} $1"
  printf "%b%s%b\n\n" "${muted}" "$2" "${reset}"
}

incorrect() {
  printf "%b\n\n" "${warn}✗ Not quite.${reset} Check the reference sheet and try again."
}

ask() {
  local question="$1"
  local encoded="$2"
  local expected="$3"
  local why="$4"
  local input prompt_text
  while true; do
    prompt_text=$(printf '%b%s%b\nAnswer: ' " ${accent}${question}${reset} ${code_color}" "${encoded}" "${reset}")
    read -rp "$prompt_text" input
    if [[ $? -ne 0 ]]; then
      printf "%b\n" "${warn} Please provide an answer.${reset}"
      continue
    fi
    if [[ "$input" == "$expected" ]]; then
      celebrate "That's correct." "$why"
      break
    fi
    incorrect
  done
}

main() {
  [[ -t 1 ]] && clear
  intro_animation
  banner

  ask "2.1) Decode this:" "68%2074%2074%2070%2073%203a%202f%202f%2069%2070%206e%2073%2075%206d%206d%2069%2074%202e%2063%206f%206d%202f" \
      "https://ipnsummit.com/" \
      "URL encoding replaces unsafe characters with %HH so links survive browsers, proxies, and APIs without breaking."

  ask "2.2) Decode this:" "&#60;&#115;&#99;&#114;&#105;&#112;&#116;&#62;&#97;&#108;&#101;&#114;&#116;&#40;&#49;&#41;&#60;&#47;&#115;&#99;&#114;&#105;&#112;&#116;&#62;" \
      "<script>alert(1)</script>" \
      "HTML entities appear as &#number; or &name;; they stop browsers from executing injected tags by rendering them as literal text."

  ask "2.3) Decode this:" "\uD83D\uDE4C\uD83D\uDEA8\u0028\u0027\u0049\u0050\u004E\u0020\u0053\u0075\u006D\u006D\u0069\u0074\u0027\u0029\uD83D\uDEA8\uD83D\uDE4C" \
      "🙌🚨('IPN Summit')🚨🙌" \
      "URL Escape Characters use \\xHH or \\uHHHH sequences; they encode bytes so diverse symbols (emojis, foreign letters) can be safely used without breaking anything."

  local flag="IPN{Go_secure_your_web_apps_or_hack_them!}"
  printf "%b\n" "${primary}All tastings cleared!${reset}"
  printf "%b %s\n" "${success}Flag:${reset}" "$flag"
  printf "%b\n" "${muted}Close your session to leave, or stay to keep celebrating.${reset}"
  sleep 5m
}

main
