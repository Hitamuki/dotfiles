#!/bin/bash

# ==========================================================
# Claude Code ステータスライン
#
# 標準入力で渡されるセッション情報のJSONを整形し、日本語のキーと値で表示する。
# home/.claude/settings.json の statusLine から呼び出される。
#
# 表示例:
#   モデル: Fable 5 │ 思考量: 超高 │ 拡張思考: 有効 │ 高速モード: 無効
#   ディレクトリ: dotfiles │ ブランチ: main（変更あり）│ 変更行数: +210/-64 │ 経過時間: 15分5秒
#   コンテキスト: 31%（62.3k/200k）│ 入力: 62.3k │ 出力: 1.2k │ コスト: $0.42
#   レート上限 │ 5時間: 24%（リセット 15:30）│ 7日間: 41%（リセット 03/12 09:00）
#
# 4行目はレート上限を取得できるプラン（Claude.ai Pro / Max）で、
# かつ最初のAPI応答があった後にのみ表示される。
#
# 仕様: https://code.claude.com/docs/en/statusline
#
# set -e は使わない。個々の取得に失敗しても行全体が消えないようにするため。
# ==========================================================

set -u

# Homebrew 配下のコマンド（jq）を確実に解決できるようPATHを補う
PATH="/opt/homebrew/bin:/usr/local/bin:/home/linuxbrew/.linuxbrew/bin:$HOME/.linuxbrew/bin:$PATH"

# 色（ラベルは淡色、値は色付き）
RESET=$'\033[0m'
DIM=$'\033[2m'
CYAN=$'\033[36m'
BLUE=$'\033[34m'
MAGENTA=$'\033[35m'
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
RED=$'\033[31m'

SEP="${DIM} │ ${RESET}"

INPUT=$(cat)

# JSONの解析に jq が必要。無い場合は導入を促すだけにして異常終了はしない
if ! command -v jq > /dev/null 2>&1; then
  printf '%s\n' "${YELLOW}ステータスライン: jq が必要です（brew install jq）${RESET}"
  exit 0
fi

# 必要な値をまとめて1回のjq呼び出しで取り出す。
# 空になり得るフィールドがあるためタブ区切りは使えない（read がタブを連結してしまい列がずれる）。
# jq の @sh でシェル代入文として安全にクォートさせ、eval で読み込む。
ASSIGNMENTS=$(printf '%s' "$INPUT" | jq -r '
  def n(f): if (f | type) == "number" then f else null end;

  # トークン数を 1.2k / 3.4M の形に丸める
  def tok:
    if . == null then ""
    elif . >= 1000000 then (((. / 100000) | floor) / 10 | tostring) + "M"
    elif . >= 1000 then (((. / 100) | floor) / 10 | tostring) + "k"
    else (. | floor | tostring) end;

  [
    @sh "SL_MODEL=\(.model.display_name // "不明")",
    @sh "SL_EFFORT=\(.effort.level // "")",

    # 真偽値は 有効/無効 を判定できるよう true / false / 空 の3値で渡す
    @sh "SL_THINKING=\(if (.thinking.enabled | type) == "boolean" then (.thinking.enabled | tostring) else "" end)",
    @sh "SL_FAST=\(if (.fast_mode | type) == "boolean" then (.fast_mode | tostring) else "" end)",
    @sh "SL_STYLE=\(.output_style.name // "")",
    @sh "SL_DIR=\(.workspace.current_dir // .cwd // "")",

    # コンテキスト使用率。未確定のことがあるため、その場合はトークン数から算出する
    @sh "SL_CTX_PCT=\(
      if n(.context_window.used_percentage) != null then
        (.context_window.used_percentage | floor | tostring)
      elif (n(.context_window.context_window_size) != null
            and .context_window.context_window_size > 0
            and n(.context_window.total_input_tokens) != null) then
        (.context_window.total_input_tokens * 100 / .context_window.context_window_size | floor | tostring)
      else "" end
    )",
    @sh "SL_CTX_USED=\(n(.context_window.total_input_tokens) | tok)",
    @sh "SL_CTX_MAX=\(n(.context_window.context_window_size) | tok)",

    # 入力はキャッシュの読み書きを含む合計、出力は直近の応答分（仕様どおり）
    @sh "SL_IN=\(n(.context_window.total_input_tokens) | tok)",
    @sh "SL_OUT=\(n(.context_window.total_output_tokens) | tok)",

    @sh "SL_LINES_ADD=\(n(.cost.total_lines_added) // 0 | floor | tostring)",
    @sh "SL_LINES_DEL=\(n(.cost.total_lines_removed) // 0 | floor | tostring)",
    @sh "SL_COST=\(n(.cost.total_cost_usd) // 0 | tostring)",
    @sh "SL_DURATION_MS=\(n(.cost.total_duration_ms) // 0 | floor | tostring)",

    # レート上限。ウィンドウごとに独立して欠落し得る
    @sh "SL_R5_PCT=\(if n(.rate_limits.five_hour.used_percentage) != null
                     then (.rate_limits.five_hour.used_percentage | floor | tostring) else "" end)",
    @sh "SL_R5_RESET=\(n(.rate_limits.five_hour.resets_at) // "" | tostring)",
    @sh "SL_R7_PCT=\(if n(.rate_limits.seven_day.used_percentage) != null
                     then (.rate_limits.seven_day.used_percentage | floor | tostring) else "" end)",
    @sh "SL_R7_RESET=\(n(.rate_limits.seven_day.resets_at) // "" | tostring)"
  ] | join("\n")
' 2>/dev/null)

# jq が失敗した場合（想定外のJSON等）は何も表示しない
if [ -z "$ASSIGNMENTS" ]; then
  exit 0
fi

eval "$ASSIGNMENTS"

# 算術・比較に使う値は非数値を弾いておく（想定外の入力で行全体が壊れないようにする）
case "$SL_CTX_PCT" in *[!0-9]*) SL_CTX_PCT="" ;; esac
case "$SL_R5_PCT" in *[!0-9]*) SL_R5_PCT="" ;; esac
case "$SL_R7_PCT" in *[!0-9]*) SL_R7_PCT="" ;; esac
case "$SL_R5_RESET" in *[!0-9]*) SL_R5_RESET="" ;; esac
case "$SL_R7_RESET" in *[!0-9]*) SL_R7_RESET="" ;; esac
case "$SL_LINES_ADD" in ''|*[!0-9]*) SL_LINES_ADD=0 ;; esac
case "$SL_LINES_DEL" in ''|*[!0-9]*) SL_LINES_DEL=0 ;; esac
case "$SL_DURATION_MS" in ''|*[!0-9]*) SL_DURATION_MS=0 ;; esac

# --------------------
# 共通のヘルパー
# --------------------
# 使用率に応じた色（70%以上で黄、90%以上で赤）
usage_color() {
  if [ "$1" -ge 90 ]; then
    printf '%s' "$RED"
  elif [ "$1" -ge 70 ]; then
    printf '%s' "$YELLOW"
  else
    printf '%s' "$GREEN"
  fi
}

# Unix時刻を日時に整形する（BSD date は -r、GNU date は -d @ を使う）
format_epoch() {
  date -r "$1" "+$2" 2>/dev/null || date -d "@$1" "+$2" 2>/dev/null || printf ''
}

# --------------------
# 1行目: モデルと動作モード
# --------------------
LINE1="${DIM}モデル: ${RESET}${CYAN}${SL_MODEL}${RESET}"

# 思考量（モデルが推論の強度指定に対応している場合のみ渡ってくる）
case "$SL_EFFORT" in
  low)    EFFORT_JA="低" ;;
  medium) EFFORT_JA="中" ;;
  high)   EFFORT_JA="高" ;;
  xhigh)  EFFORT_JA="超高" ;;
  max)    EFFORT_JA="最大" ;;
  *)      EFFORT_JA="" ;;
esac
[ -n "$EFFORT_JA" ] && LINE1="${LINE1}${SEP}${DIM}思考量: ${RESET}${EFFORT_JA}"

# 拡張思考
case "$SL_THINKING" in
  true)  LINE1="${LINE1}${SEP}${DIM}拡張思考: ${RESET}${GREEN}有効${RESET}" ;;
  false) LINE1="${LINE1}${SEP}${DIM}拡張思考: 無効${RESET}" ;;
esac

# 高速モード
case "$SL_FAST" in
  true)  LINE1="${LINE1}${SEP}${DIM}高速モード: ${RESET}${GREEN}有効${RESET}" ;;
  false) LINE1="${LINE1}${SEP}${DIM}高速モード: 無効${RESET}" ;;
esac

# 出力スタイル（既定以外のときだけ表示する）
case "$SL_STYLE" in
  default | "") STYLE_JA="" ;;
  Explanatory)  STYLE_JA="解説" ;;
  Learning)     STYLE_JA="学習" ;;
  *)            STYLE_JA="$SL_STYLE" ;;
esac
[ -n "$STYLE_JA" ] && LINE1="${LINE1}${SEP}${DIM}出力スタイル: ${RESET}${STYLE_JA}"

# --------------------
# 2行目: 作業場所と作業量
# --------------------
if [ -n "$SL_DIR" ]; then
  DIR_NAME=$(basename "$SL_DIR")
else
  DIR_NAME="不明"
fi
LINE2="${DIM}ディレクトリ: ${RESET}${BLUE}${DIR_NAME}${RESET}"

# ブランチ（未コミットの変更がある場合のみ注記する）
if [ -n "$SL_DIR" ] && [ -d "$SL_DIR" ]; then
  BRANCH=$(git -C "$SL_DIR" --no-optional-locks symbolic-ref --quiet --short HEAD 2>/dev/null)

  # 切り離しHEADのときはコミットハッシュを表示する
  if [ -z "$BRANCH" ]; then
    COMMIT=$(git -C "$SL_DIR" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
    [ -n "$COMMIT" ] && BRANCH="切り離し@${COMMIT}"
  fi

  if [ -n "$BRANCH" ]; then
    BRANCH_PART="${DIM}ブランチ: ${RESET}${MAGENTA}${BRANCH}${RESET}"

    # 未追跡ファイルは除外する（成果物やキャッシュで常に「変更あり」になるのを避ける）
    if [ -n "$(git -C "$SL_DIR" --no-optional-locks status --porcelain --untracked-files=no 2>/dev/null | head -n 1)" ]; then
      BRANCH_PART="${BRANCH_PART}${YELLOW}（変更あり）${RESET}"
    fi
    LINE2="${LINE2}${SEP}${BRANCH_PART}"
  fi
fi

# 変更行数
if [ "$SL_LINES_ADD" -eq 0 ] && [ "$SL_LINES_DEL" -eq 0 ]; then
  LINE2="${LINE2}${SEP}${DIM}変更行数: なし${RESET}"
else
  LINE2="${LINE2}${SEP}${DIM}変更行数: ${RESET}${GREEN}+${SL_LINES_ADD}${RESET}${DIM}/${RESET}${RED}-${SL_LINES_DEL}${RESET}"
fi

# 経過時間
format_duration() {
  local total=$(( $1 / 1000 ))
  local hours=$(( total / 3600 ))
  local minutes=$(( (total % 3600) / 60 ))
  local seconds=$(( total % 60 ))

  if [ "$hours" -gt 0 ]; then
    printf '%d時間%d分' "$hours" "$minutes"
  elif [ "$minutes" -gt 0 ]; then
    printf '%d分%d秒' "$minutes" "$seconds"
  else
    printf '%d秒' "$seconds"
  fi
}
LINE2="${LINE2}${SEP}${DIM}経過時間: ${RESET}$(format_duration "$SL_DURATION_MS")"

# --------------------
# 3行目: トークンとコスト
# --------------------
if [ -n "$SL_CTX_PCT" ]; then
  CTX_COLOR=$(usage_color "$SL_CTX_PCT")
  CTX_VALUE="${CTX_COLOR}${SL_CTX_PCT}%${RESET}"

  # 使用量/上限も併記する（どちらか取れないときは使用率のみ）
  if [ -n "$SL_CTX_USED" ] && [ -n "$SL_CTX_MAX" ]; then
    CTX_VALUE="${CTX_VALUE}${DIM}（${SL_CTX_USED}/${SL_CTX_MAX}）${RESET}"
  fi
  LINE3="${DIM}コンテキスト: ${RESET}${CTX_VALUE}"
else
  LINE3="${DIM}コンテキスト: 集計前${RESET}"
fi

# 入力・出力トークン（入力はキャッシュの読み書きを含むため、コンテキスト使用量と一致する）
[ -n "$SL_IN" ] && LINE3="${LINE3}${SEP}${DIM}入力: ${RESET}${SL_IN}"
[ -n "$SL_OUT" ] && LINE3="${LINE3}${SEP}${DIM}出力: ${RESET}${SL_OUT}"

# コスト（1セント未満は2桁だと 0.00 になってしまうため桁を増やす）
COST_TEXT=$(printf '%.2f' "$SL_COST" 2>/dev/null) || COST_TEXT="$SL_COST"
if [ "$COST_TEXT" = "0.00" ] && [ "$SL_COST" != "0" ]; then
  COST_TEXT=$(printf '%.4f' "$SL_COST" 2>/dev/null) || COST_TEXT="$SL_COST"
fi
LINE3="${LINE3}${SEP}${DIM}コスト: ${RESET}${YELLOW}\$${COST_TEXT}${RESET}"

# --------------------
# 4行目: レート上限（取得できるプランのみ）
# --------------------
LINE4=""
build_rate_part() {
  local label=$1 pct=$2 epoch=$3 reset_fmt=$4
  local color reset_at part

  [ -z "$pct" ] && return

  color=$(usage_color "$pct")
  part="${DIM}${label}: ${RESET}${color}${pct}%${RESET}"

  if [ -n "$epoch" ]; then
    reset_at=$(format_epoch "$epoch" "$reset_fmt")
    [ -n "$reset_at" ] && part="${part}${DIM}（リセット ${reset_at}）${RESET}"
  fi

  printf '%s' "$part"
}

RATE_5H=$(build_rate_part "5時間" "$SL_R5_PCT" "$SL_R5_RESET" "%H:%M")
RATE_7D=$(build_rate_part "7日間" "$SL_R7_PCT" "$SL_R7_RESET" "%m/%d %H:%M")

if [ -n "$RATE_5H" ] || [ -n "$RATE_7D" ]; then
  LINE4="${DIM}レート上限${RESET}"
  [ -n "$RATE_5H" ] && LINE4="${LINE4}${SEP}${RATE_5H}"
  [ -n "$RATE_7D" ] && LINE4="${LINE4}${SEP}${RATE_7D}"
fi

# --------------------
# 出力
# --------------------
printf '%s\n%s\n%s\n' "$LINE1" "$LINE2" "$LINE3"
[ -n "$LINE4" ] && printf '%s\n' "$LINE4"

exit 0
