#!/usr/bin/env bash

SAVE_FILE="savegame.txt"
board=("-" "-" "-" "-" "-" "-" "-" "-" "-")
current_player="X"

print_board() {
  echo "Aktualny stan planszy:"
  echo ""
  echo "  ${board[0]} | ${board[1]} | ${board[2]}"
  echo " ---+---+---"
  echo "  ${board[3]} | ${board[4]} | ${board[5]}"
  echo " ---+---+---"
  echo "  ${board[6]} | ${board[7]} | ${board[8]}"
  echo ""
}

check_winner() {
  local wins=(
    "0 1 2"
    "3 4 5"
    "6 7 8"
    "0 3 6"
    "1 4 7"
    "2 5 8"
    "0 4 8"
    "2 4 6"
  )
  for line in "${wins[@]}"; do
    set -- $line
    if [[ "${board[$1]}" != "-" ]] &&
       [[ "${board[$1]}" == "${board[$2]}" ]] &&
       [[ "${board[$2]}" == "${board[$3]}" ]]; then
      echo "${board[$1]}"
      return
    fi
  done
  echo ""
}

check_draw() {
  for (( i=0; i<9; i++ )); do
    if [[ "${board[$i]}" == "-" ]]; then
      return 1
    fi
  done
  return 0
}

save_game() {
  echo "$current_player" > "$SAVE_FILE"
  echo "${board[@]}" >> "$SAVE_FILE"
  echo "Gra została zapisana do pliku: $SAVE_FILE"
}

load_game() {
  if [[ ! -f "$SAVE_FILE" ]]; then
    echo "Brak zapisu gry w pliku '$SAVE_FILE'."
    return 1
  fi
  read -r saved_player < "$SAVE_FILE"
  current_player="$saved_player"
  read -r -a saved_board < <(tail -n +2 "$SAVE_FILE")
  board=("${saved_board[@]}")
  echo "Gra została wczytana z pliku: $SAVE_FILE"
  return 0
}

init_new_game() {
  board=("-" "-" "-" "-" "-" "-" "-" "-" "-")
  current_player="X"
}

game_loop() {
  while true; do
    print_board
    echo "Teraz ruch gracza: $current_player"
    read -p "Podaj numer pola (1-9) lub wpisz 'save': " move
    if [[ "$move" == "save" || "$move" == "z" ]]; then
      save_game
      read -p "Zapisano. Czy chcesz kontynuować? [t/N]: " ans
      if [[ "$ans" != "t" && "$ans" != "T" ]]; then
        echo "Zakończono."
        exit 0
      else
        continue
      fi
    fi
    if ! [[ "$move" =~ ^[1-9]$ ]]; then
      echo "Niepoprawny ruch! Wpisz cyfrę 1-9 lub 'save'."
      continue
    fi
    local idx=$((move - 1))
    if [[ "${board[$idx]}" != "-" ]]; then
      echo "Pole jest już zajęte. Spróbuj ponownie."
      continue
    fi
    board[$idx]="$current_player"
    local winner
    winner=$(check_winner)
    if [[ "$winner" == "X" || "$winner" == "O" ]]; then
      print_board
      echo "Wygrywa gracz: $winner!"
      break
    fi
    if check_draw; then
      print_board
      echo "Remis! Koniec gry."
      break
    fi
    if [[ "$current_player" == "X" ]]; then
      current_player="O"
    else
      current_player="X"
    fi
  done
}

main_menu() {
  echo "=============================================="
  echo "      KÓŁKO I KRZYŻYK w Bash - start"
  echo "=============================================="
  echo "1. Nowa gra"
  echo "2. Wczytaj grę"
  read -p "Wybierz opcję [1/2]: " choice
  case "$choice" in
    1)
      init_new_game
      ;;
    2)
      if ! load_game; then
        echo "Rozpoczynam nową grę..."
        init_new_game
      fi
      ;;
    *)
      echo "Nieprawidłowy wybór. Rozpoczynam nową grę..."
      init_new_game
      ;;
  esac
  game_loop
  echo "Koniec rozgrywki!"
}

main_menu
