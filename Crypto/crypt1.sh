#!/usr/bin/env bash

# Concept 3: Machine Talk (Numeric Representations)
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
    "[ syncing machine talk ] >>>====> bin"
    "[ syncing machine talk ] >>>====> hex"
    "[ syncing machine talk ] >>>====> oct"
    "[ syncing machine talk ] >>>====> ready"
  )
  printf "%b" "${accent}"
  for _ in {1..8}; do
    for frame in "${frames[@]}"; do
      printf "\r%s" "$frame"
      sleep 0.08
    done
  done
  printf "\r%-40s\r%b\n" "[ syncing machine talk ] >>>====> tuned" "${reset}"
}

banner() {
  printf "%b" "${accent}"
  cat <<'EOF'
╔══════════════════════════════════════╗
║   Machine Talk: Numeric Tastings     ║
╚══════════════════════════════════════╝
EOF
  printf "%b" "${reset}"
  printf "%b\n" "${primary}Welcome! Decode each numeric dialect to unlock the flag.${reset}"
  printf "%b\n\n" "${muted}Tip: CTRL+C/CTRL+D are disabled; close the session if you must leave.${reset}"
}

celebrate() {
  printf "%b\n" "${success}Nice work!${reset} $1"
  printf "%b\n\n" "${muted}$2${reset}"
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

  ask "1.1) Decode this:" "01010100 01101000 01100101 00100000 01001001 01010000 01001110 00100000 01010011 01110101 01101101 01101101 01101001 01110100 00100001" \
      "The IPN Summit!" \
      "Binary (base 2) is the \"Carbon\" for computers; used everywhere, you can find everything is just 0s and 1s!"

  ask "1.2) Decode this:" "52 65 61 64 61 62 6c 65 20 76 65 72 73 69 6f 6e 20 6f 66 20 42 69 6e 61 72 79" \
      "Readable version of Binary" \
      "Hex (base 16) uses 0-9 and A-F; each hex digit represents four binary digits (bits), making it more human-friendly."

  ask "1.3) Decode this:" "127 150 141 164 47 163 40 142 145 164 164 145 162 40 164 150 141 156 40 62 40 144 151 147 151 164 163 77\n" \
      "What's better than 2 digits?" \
      "Octal (base 8) uses digits 0–7; each octal digit represents three binary bits, which is why it's commonly used for Unix file permissions (like 755)."

  local flag="IPN{The_foundations_are_the_most_important!}"
  printf "%b\n" "${primary}All tastings cleared!${reset}"
  printf "%b %s\n" "${success}Flag:${reset}" "$flag"
  printf "%b\n" "${muted}Close your session to leave, or stay to keep celebrating.${reset}"
  sleep 5m
}

main
