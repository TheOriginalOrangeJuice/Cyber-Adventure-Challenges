#!/usr/bin/env bash

# Prevent users from escaping with common key combos.
IGNOREEOF=100000
set -o ignoreeof
trap 'printf ""' INT QUIT TSTP

# Colors
reset=$'\033[0m'
primary=$'\033[38;5;51m'
accent=$'\033[38;5;214m'   # question text
code_color=$'\033[38;5;45m' # encoded blob
success=$'\033[38;5;82m'
warn=$'\033[38;5;203m'
muted=$'\033[2m'

intro_animation() {
  local frames=(
    "[ plating base samplers ] >>>====> b64"
    "[ plating base samplers ] >>>====> b58"
    "[ plating base samplers ] >>>====> b32"
    "[ plating base samplers ] >>>====> ready"
  )
  printf "%b" "${accent}"
  for _ in {1..8}; do
    for frame in "${frames[@]}"; do
      printf "\r%s" "$frame"
      sleep 0.08
    done
  done
  printf "\r%-40s\r%b\n" "[ plating base samplers ] >>>====> served" "${reset}"
}


banner() {
  printf "${accent}"
  cat <<'EOF'
╔══════════════════════════════════╗
║ The Cyber Kitchen: Base Tasting  ║
╚══════════════════════════════════╝
EOF
  printf "${reset}"
  printf "${primary}Welcome! Decode each challenge to unlock the final flag.${reset}\n"
  printf "${muted}Tip: CTRL+C and CTRL+D are disabled; close the session if you must leave.${reset}\n\n"
}

celebrate() {
  printf "${success}Nice work!${reset} $1\n"
  printf "${muted}$2${reset}\n\n"
}

incorrect() {
  printf "${warn}✗ Not quite.${reset} Check the reference sheet and try again.\n\n"
}

ask() {
  local question="$1"
  local encoded="$2"
  local expected="$3"
  local why="$4"
  local input
  while true; do
    local prompt_text
    prompt_text=$(printf '%b' " ${accent}${question}${reset} ${code_color}${encoded}${reset}\nAnswer: ")
    read -rp "$prompt_text" input
    if [[ $? -ne 0 ]]; then
      printf "${warn} Please provide an answer.${reset}\n"
      continue
    fi
    if [[ "$input" == "$expected" ]]; then
      celebrate "That's correct!" "$why"
      break
    fi
    incorrect
  done
}

main() {
  [[ -t 1 ]] && clear
  intro_animation
  banner

ask "2.1) Decode this:" "V2VsY29tZSB0byB0aGUgQ3J5cHRvZ3JhcGh5IExhbmUh" "Welcome to the Cryptography Lane!" "Base64 encodes binary into text using A–Z, a–z, 0–9, +, and /."
ask "2.2) Decode this:" "46avPqp375Fe5k5xfYuC2gYchJzHWfkYMeTq2sD6acYdLsphbYm21YocZcJVJVZ2Qy" "This is the most commonly used encoding in Cyber" "Base58 removes look-alike characters such as 0, O, l, and I to reduce human error."
ask "2.3) Decode this:" "IFXGIIDUNBSXSJ3SMUQG2YLOPEQHMYLSNFQW45DTEBXWMIDJOQQHI33P" "And they're many variants of it too" "Base32 uses only uppercase letters A–Z and digits 2–7, making it easy to type and read."


  local flag="IPN{Cyber_is_so_based}"
  printf "${primary}All courses cleared!${reset}\n"
  printf "${success}Flag:${reset} %s\n" "$flag"
  printf "\n${muted}Close your session to leave, or stay to keep celebrating.${reset}\n"
  sleep 5m
}

main
