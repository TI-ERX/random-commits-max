#!/usr/bin/env sh

_() {
  YEAR="2023"
  echo "GitHub Username: "
  read -r USERNAME
  echo "GitHub Access token: "
  read -r ACCESS_TOKEN

  [ -z "$USERNAME" ] && exit 1
  [ -z "$ACCESS_TOKEN" ] && exit 1
  [ ! -d $YEAR ] && mkdir $YEAR

  cd "${YEAR}" || exit
  git init
  git config core.autocrlf false  # Desativa a conversão automática de CRLF no Windows
  echo "**${YEAR}** - Gerado por https://github.com/TI-ERX/script-several-commits" \
    >README.md
  git add README.md

  # Gera commits aleatórios para todos os dias do ano
  for MONTH in {01..12}
  do
    for DAY in {01..31}
    do
      # Verifica se o dia é válido para o mês
      if [ "$MONTH-$DAY" != "02-30" ] && [ "$MONTH-$DAY" != "02-31" ] && [ "$MONTH-$DAY" != "04-31" ] && [ "$MONTH-$DAY" != "06-31" ] && [ "$MONTH-$DAY" != "09-31" ] && [ "$MONTH-$DAY" != "11-31" ]; then
        # Verifica se o dia é um sábado ou domingo (dias 6 e 0 no formato ISO, onde segunda é 1)
        if [ "$(date -d "${YEAR}-${MONTH}-${DAY}" +%u)" -ge 6 ]; then
          continue  # Pula para o próximo dia se for sábado ou domingo
        fi

        # Gera aleatoriamente o número de commits para cada dia (entre 1 e 20, ajuste conforme necessário)
        COMMITS_PER_DAY=$(shuf -i 1-50 -n 1)

        for ((i = 1; i <= COMMITS_PER_DAY; i++))
        do
          echo "Conteúdo para ${YEAR}-${MONTH}-${DAY}" > "day${DAY}_month${MONTH}_commit${i}.txt"
          git add "day${DAY}_month${MONTH}_commit${i}.txt"

          # Gera horas aleatórias entre 12:00 e 23:59
          RANDOM_HOUR=$((12 + RANDOM % 12))
          RANDOM_MINUTE=$((RANDOM % 60))
          GIT_AUTHOR_DATE="${YEAR}-${MONTH}-${DAY}T${RANDOM_HOUR}:${RANDOM_MINUTE}:00" \
            GIT_COMMITTER_DATE="${YEAR}-${MONTH}-${DAY}T${RANDOM_HOUR}:${RANDOM_MINUTE}:00" \
            git commit -m "Commit ${i} para ${YEAR}-${MONTH}-${DAY}"
        done
      fi
    done
  done

  git remote add origin "https://${ACCESS_TOKEN}@github.com/${USERNAME}/${YEAR}.git"
  git branch -M main
  git push -u origin main -f
  cd ..
  rm -rf "${YEAR}"

  echo
  echo "Pronto, agora verifique seu perfil: https://github.com/${USERNAME}"
} && _

unset -f _
