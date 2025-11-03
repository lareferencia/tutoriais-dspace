#!/usr/bin/env bash

set -x
set -e

# Defina as variáveis conforme sua instância
# Defina las variables según su instancia
[ -z "$URL_BASE" ] && URL_BASE="http://localhost:8080"
[ -z "$INDEX_NAME" ] && INDEX_NAME="statistics"
[ -z "$EXPORT_DIR" ] && EXPORT_DIR="$PWD/tmp"
[ -z "$PAGINATION_ROWS" ] && PAGINATION_ROWS="10000"

export_statistics_i() {
  local i="$1"
  local start="$2"
  local rows="$3"

  mkdir -p "$EXPORT_DIR"

  curl \
    -L "${URL_BASE}/solr/statistics/select" \
    --data-urlencode "q=*:*" \
    --data-urlencode "rows=${rows}" \
    --data-urlencode "wt=csv" \
    --data-urlencode "indent=true" \
    --data-urlencode "start=${start}" \
    -o "${EXPORT_DIR}/${INDEX_NAME}_export_$((i + 1)).csv"
}

get_num_found() {
  curl \
    -s \
    -L "${URL_BASE}/solr/statistics/select" \
    --data-urlencode "q=*:*" \
    --data-urlencode "rows=0" \
    --data-urlencode "indent=true" \
    --data-urlencode "wt=json" | \
    grep -o '"numFound":[0-9]\+,' | \
    grep -o '[0-9]\+'
}

export_statistics() {
  local i=0
  local limit="$(get_num_found)"
  local rows="${PAGINATION_ROWS}"
  local start
  local end

  while [ 1 ]; do
    start=$((i * rows))
    end=$((start + rows))

    if [ "$end" -gt "$limit" ]; then
      end=$((limit))
      rows=$((end - start))
      export_statistics_i "$i" "$start" "$rows"
      break
    fi

    export_statistics_i "$i" "$start" "$rows"

    i=$((i + 1))
  done
}

export_statistics
