#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC_DIR="$ROOT_DIR/src"
DOCUMENTS_DIR="$ROOT_DIR/building/documents"
HASHES_DIR="$ROOT_DIR/building/hashes"

export TYPST_FONT_PATHS="$ROOT_DIR/fonts"

usage() {
  cat <<'USAGE'
Usage: building/build.sh

Builds every Typst Summary (src/**/main.typ) and Note (src/**/notes/*.typ) into
building/documents/. Only documents without a saved hash, with changed source
files, or with a missing PDF output are compiled.
USAGE
}

die() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

document_slug() {
  local relative_dir="$1"
  local slug=""
  local part
  local clean_part

  IFS='/' read -r -a parts <<< "$relative_dir"
  for part in "${parts[@]}"; do
    clean_part="$(printf '%s' "$part" | sed -E 's/[^[:alnum:].-]+//g')"
    [[ -z "$clean_part" ]] && continue

    if [[ -z "$slug" ]]; then
      slug="$clean_part"
    else
      slug="${slug}_${clean_part}"
    fi
  done

  [[ -n "$slug" ]] || die "could not derive an output name for $relative_dir"
  printf '%s\n' "$slug"
}

document_hash() {
  local document_dir="$1"
  local source_typ="$2"
  local relative_source="${source_typ#"$document_dir"/}"

  (
    cd "$document_dir"
    find . -path './notes' -prune -o -type f ! -name '*.pdf' -print0 \
      | sort -z \
      | xargs -0 sha256sum

    if [[ "$relative_source" == notes/* ]]; then
      sha256sum "$relative_source"
    fi
  ) | sha256sum | awk '{print $1}'
}

build_document() {
  local source_typ="$1"
  local pdf_path="$2"
  local hash_path="$3"
  local current_hash="$4"
  local label="$5"
  local reason="$6"
  local tmp_pdf="${pdf_path%.pdf}.tmp.${BASHPID}.pdf"

  printf 'Building %s (%s)\n' "$label" "$reason"
  rm -f "$tmp_pdf"

  if typst c --root "$ROOT_DIR" "$source_typ" "$tmp_pdf"; then
    mv "$tmp_pdf" "$pdf_path"
    printf '%s\n' "$current_hash" > "$hash_path"
    printf 'Built %s -> %s\n' "$label" "${pdf_path#"$ROOT_DIR"/}"
    return 0
  fi

  rm -f "$tmp_pdf"
  printf 'Failed %s\n' "$label" >&2
  return 1
}

main() {
  if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage
    exit 0
  fi

  command -v typst >/dev/null 2>&1 || die "typst is not available in PATH"
  [[ -d "$SRC_DIR" ]] || die "source directory not found: $SRC_DIR"
  [[ -d "$TYPST_FONT_PATHS" ]] || die "font directory not found: $TYPST_FONT_PATHS"

  mkdir -p "$DOCUMENTS_DIR" "$HASHES_DIR"

  local source_files=()
  mapfile -d '' source_files < <(
    find "$SRC_DIR" -path '*/.*' -prune -o -type f \
      \( -name 'main.typ' -o -path '*/notes/*.typ' \) -print0 \
      | sort -z
  )

  if ((${#source_files[@]} == 0)); then
    printf 'No Typst documents found under %s\n' "${SRC_DIR#"$ROOT_DIR"/}"
    exit 0
  fi

  local pids=()
  local labels=()
  local source_typ
  local document_dir
  local relative_dir
  local relative_source
  local slug
  local pdf_path
  local hash_path
  local current_hash
  local saved_hash
  local reason

  for source_typ in "${source_files[@]}"; do
    if [[ "$source_typ" == */notes/* ]]; then
      document_dir="${source_typ%%/notes/*}"
    else
      document_dir="$(dirname "$source_typ")"
    fi

    relative_dir="${document_dir#"$SRC_DIR"/}"
    relative_source="${source_typ#"$document_dir"/}"

    if [[ "$relative_source" == "main.typ" ]]; then
      slug="$(document_slug "$relative_dir")"
    else
      slug="$(document_slug "$relative_dir/${relative_source%.typ}")"
    fi

    pdf_path="$DOCUMENTS_DIR/${slug}.pdf"
    hash_path="$HASHES_DIR/${slug}.sha256"
    current_hash="$(document_hash "$document_dir" "$source_typ")"
    saved_hash=""
    reason=""

    if [[ -f "$hash_path" ]]; then
      saved_hash="$(awk 'NR == 1 { print $1; exit }' "$hash_path")"
    fi

    if [[ -z "$saved_hash" ]]; then
      reason="no saved hash"
    elif [[ "$current_hash" != "$saved_hash" ]]; then
      reason="hash mismatch"
    elif [[ ! -f "$pdf_path" ]]; then
      reason="missing PDF"
    else
      printf 'Up to date %s\n' "$slug"
      continue
    fi

    build_document "$source_typ" "$pdf_path" "$hash_path" "$current_hash" "$slug" "$reason" &
    pids+=("$!")
    labels+=("$slug")
  done

  if ((${#pids[@]} == 0)); then
    printf 'All documents are up to date.\n'
    exit 0
  fi

  local failures=0
  local i
  for i in "${!pids[@]}"; do
    if ! wait "${pids[$i]}"; then
      printf 'Build job failed: %s\n' "${labels[$i]}" >&2
      failures=$((failures + 1))
    fi
  done

  if ((failures > 0)); then
    die "$failures document build(s) failed"
  fi

  printf 'Finished %s document build(s).\n' "${#pids[@]}"
}

main "$@"
