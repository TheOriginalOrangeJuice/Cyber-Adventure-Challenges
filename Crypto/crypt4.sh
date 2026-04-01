#!/usr/bin/env bash

# Concept 4: The Keyed Ciphers (Polyalphabetic)
# Interactive quiz shell. Locks down Ctrl+C/Ctrl+Z/Ctrl+\ and ignores Ctrl+D.

IGNOREEOF=100000
set -o ignoreeof
trap 'printf ""' INT QUIT TSTP

reset=$'\033[0m'
primary=$'\033[38;5;51m'
accent=$'\033[38;5;214m'   # question text
code_color=$'\033[38;5;45m' # encoded blob
hint_color=$'\033[38;5;208m'
success=$'\033[38;5;82m'
warn=$'\033[38;5;203m'
muted=$'\033[2m'

intro_animation() {
  local frames=(
    "[ priming cipher wheels ] >>>====> vig"
    "[ priming cipher wheels ] >>>====> gron"
    "[ priming cipher wheels ] >>>====> rot"
    "[ priming cipher wheels ] >>>====> ready"
  )
  printf "%b" "${accent}"
  for _ in {1..8}; do
    for frame in "${frames[@]}"; do
      printf "\r%s" "$frame"
      sleep 0.08
    done
  done
  printf "\r%-42s\r%b\n" "[ priming cipher wheels ] >>>====> spun up" "${reset}"
}

banner() {
  printf "%b" "${accent}"
  cat <<'EOF'
╔═════════════════════════════════════════╗
║   The Keyed Ciphers: Polyalpha Tastings ║
╚═════════════════════════════════════════╝
EOF
  printf "%b" "${reset}"
  printf "%b\n" "${primary}Welcome! Decode each keyed bite to unlock the flag.${reset}"
  printf "%b\n\n" "${muted}Tip: CTRL+C/CTRL+D are locked; close the session if you must leave.${reset}"
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
  local plain_hint="$3"
  local hint="$4"
  local expected="$5"
  local why="$6"
  local input prompt_text
  while true; do
    prompt_text=$(printf '%b%s%b\n%bCiphertext:%b %s\n%bPlaintext (partial):%b %s\n%bKey Hint:%b %s\nAnswer: ' \
      "${accent}" "${question}" "${reset}" \
      "${code_color}" "${reset}" "${encoded}" \
      "${primary}" "${reset}" "${plain_hint}" \
      "${hint_color}" "${reset}" "${hint}")
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

# IPN
  ask "4.1) What is the plaintext based on the following information" \
      "Ptem xf pdj et uqsr utfaptmh vv ium Rljte Edets" \
      "Here is ho" \
      "What is the name of the Summit?" \
      "Here is how we hide messages in the Cyber World" \
      "In Vigenère, we used the following formula: Plain = (Cipher - Key) mod Length_of_CharacterSET. So Plain = P (15) - I (8) mod 26 = H (7)"
# 2018 
  ask "4.2) What is the plaintext based on the following information" \
      "Nowqpg nivh ja c mvav fpz Erzxvohzcpig Cnbtasja!" \
      "Loving ma" \
      "What year was the Houston Ismaili Center announced. " \
      "Loving math is a must for Cryptography Analysis!" \
      "With Gronsfeld, take the digit from the key toand shift down for each letter. N (14) - 2 (1st value in Key) = L (12)."

  ask "4.3) What is the decoded message?" \
      "Qvq lbh yrnea fbzrguvat arj nobhg Pelcgbtencul?" \
      "Did you lea" \
      "No Key for this one!" \
      "Did you learn something new about Cryptography?" \
      "This cipher (Ceasar) shifts the alphabet by a specific number of places. The challenge below is shifted by 13 places (often called ROT13)."

  local flag="IPN{K3y3d_C1ph3rs_4r3_Fun!}"
  printf "%b\n" "${primary}All tastings cleared!${reset}"
  printf "%b %s\n" "${success}Flag:${reset}" "$flag"
  printf "%b\n" "${muted}Close your session to leave, or stay to keep celebrating.${reset}"
  sleep 5m
}

main
