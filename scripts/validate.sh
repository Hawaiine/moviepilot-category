#!/usr/bin/env bash
# validate.sh — MoviePilot 配置校验脚本（增强版）
# 校验范围：category.yaml + rules/*.json + words/*.txt
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
ERRORS=0
WARNINGS=0

# ─── 颜色 ───
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
info()  { echo -e "${GREEN}✅ $1${NC}"; }
warn()  { echo -e "${YELLOW}⚠️  $1${NC}"; WARNINGS=$((WARNINGS + 1)); }
fail()  { echo -e "${RED}❌ $1${NC}"; ERRORS=$((ERRORS + 1)); }

# ─── 合法的 MP 分类字段（来源：wiki.movie-pilot.org/advanced）───
VALID_FIELDS="genre_ids|original_language|production_countries|origin_country|release_year"
VALID_PREFIXED_FIELDS="!origin_country|!original_language|!production_countries"

echo "╔══════════════════════════════════════╗"
echo "║   MoviePilot 配置校验（增强版）      ║"
echo "╚══════════════════════════════════════╝"
echo ""

# ─── 1. category.yaml 校验 ───
YAML_FILE="${1:-$REPO_DIR/config/category.yaml}"
echo "── category.yaml ──"

if [[ ! -f "$YAML_FILE" ]]; then
  fail "文件不存在: $YAML_FILE"
  exit 1
fi
info "文件存在: $YAML_FILE"

python3 - "$YAML_FILE" << 'PYEOF'
import yaml, sys, re

VALID_FIELDS = {'genre_ids', 'original_language', 'production_countries', 'origin_country', 'release_year'}
VALID_PREFIXED = {'!origin_country', '!original_language', '!production_countries'}
ALL_VALID = VALID_FIELDS | VALID_PREFIXED

file = sys.argv[1]
with open(file) as f:
    data = yaml.safe_load(f)

errors = 0
warnings = 0

# 1. 根节点
if not isinstance(data, dict):
    print("❌ 根节点必须是 dict"); sys.exit(1)

# 2. 一级分类
for section in ['movie', 'tv']:
    if section not in data:
        print(f"❌ 缺少一级分类: {section}"); sys.exit(1)
    if not isinstance(data[section], dict):
        print(f"❌ {section} 必须是 dict"); sys.exit(1)
    if len(data[section]) == 0:
        print(f"⚠️  {section} 下无二级分类")

# 3. 每条规则的字段合法性 + 死分类检测
for section in ['movie', 'tv']:
    items = list(data[section].items())
    # 兜底检测
    last_key, last_val = items[-1]
    if last_val is not None:
        print(f"⚠️  {section} 最后一项 \"{last_key}\" 非空，建议保留空值兜底分类")
        warnings += 1
    else:
        print(f"✅ {section} 兜底分类正确: {last_key}")

    for name, rule in items:
        if rule is None:
            continue
        if not isinstance(rule, dict):
            print(f"❌ [{section}] {name}: 值必须是 dict 或 null"); errors += 1; continue
        for field in rule:
            if field not in ALL_VALID:
                print(f"❌ [{section}] {name}: 未知字段 \"{field}\"（合法字段: {sorted(ALL_VALID)}）"); errors += 1

print(f"✅ YAML 语法正确，字段合法性检查通过")
print(f"✅ 一级分类: {sorted(data.keys())}")
for s in ['movie', 'tv']:
    print(f"✅ {s} 二级分类数: {len(data[s])} ({list(data[s].keys())})")

if errors > 0:
    sys.exit(1)
PYEOF

echo ""

# ─── 2. rules/*.json 校验 ───
echo "── rules/ ──"
RULES_DIR="$REPO_DIR/rules"
if [[ -d "$RULES_DIR" ]]; then
  for f in "$RULES_DIR"/*.json; do
    [[ -f "$f" ]] || continue
    if python3 -c "import json; json.load(open('$f'))" 2>/dev/null; then
      info "JSON 语法正确: $(basename "$f")"
    else
      fail "JSON 语法错误: $(basename "$f")"
    fi
  done
else
  warn "rules/ 目录不存在"
fi
echo ""

# ─── 3. words/*.txt 校验 ───
echo "── words/ ──"
WORDS_DIR="$REPO_DIR/words"
if [[ -d "$WORDS_DIR" ]]; then
  for f in "$WORDS_DIR"/*.txt; do
    [[ -f "$f" ]] || continue
    lines=$(grep -cv '^\s*$' "$f" 2>/dev/null || echo 0)
    if [[ "$lines" -gt 0 ]]; then
      info "识别词文件: $(basename "$f") ($lines 行)"
    else
      warn "识别词文件为空: $(basename "$f")"
    fi
  done
else
  warn "words/ 目录不存在"
fi
echo ""

# ── 结构完整性 ──
echo "── 结构完整性 ──"
for req in config/category.yaml docs/reference.md scripts/validate.sh VERSION; do
  if [[ -f "$REPO_DIR/$req" ]]; then
    info "$req 存在"
  else
    fail "$req 缺失"
  fi
done
echo ""

# ─── 总结 ───
echo "╔══════════════════════════════════════╗"
if [[ $ERRORS -eq 0 ]]; then
  echo "║   🎉 校验完成 ($WARNINGS 个警告)        ║"
else
  echo "║   ❌ 发现 $ERRORS 个错误 ($WARNINGS 个警告)  ║"
fi
echo "╚══════════════════════════════════════╝"

exit $ERRORS
