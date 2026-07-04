#!/usr/bin/env bash
# sync-upstream.sh — 同步 MoviePilot 官方 category.yaml
# 拉取 jxxghp/MoviePilot main 分支的默认配置，与本地 diff
# 如有变更则自动创建 Issue，附带 unified diff
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
VERSION_FILE="$REPO_DIR/VERSION"
LOCAL_YAML="$REPO_DIR/config/category.yaml"
UPSTREAM_YAML="$REPO_DIR/.upstream-category.yaml"
UPSTREAM_URL="https://raw.githubusercontent.com/jxxghp/MoviePilot/main/config/category.yaml"

echo "🔍 同步上游配置..."
echo "   源: $UPSTREAM_URL"

# ─── 1. 拉取上游配置 ───
HTTP_CODE=$(curl -sf -o "$UPSTREAM_YAML" -w "%{http_code}" "$UPSTREAM_URL" || echo "000")
if [[ "$HTTP_CODE" != "200" ]]; then
  echo "⚠️  拉取上游配置失败 (HTTP $HTTP_CODE)，跳过"
  rm -f "$UPSTREAM_YAML"
  exit 0
fi
echo "✅ 已拉取上游配置"

# ─── 2. 对比差异 ───
if [[ ! -f "$LOCAL_YAML" ]]; then
  echo "❌ 本地配置不存在: $LOCAL_YAML"
  rm -f "$UPSTREAM_YAML"
  exit 1
fi

# 忽略注释行和空行做对比（实际配置内容对比）
DIFF=$(diff -u \
  <(grep -vE '^\s*(#|$)' "$LOCAL_YAML" | sort) \
  <(grep -vE '^\s*(#|$)' "$UPSTREAM_YAML" | sort) \
  2>/dev/null || true)

if [[ -z "$DIFF" ]]; then
  echo "✅ 与上游配置一致（忽略注释/空行后）"
  rm -f "$UPSTREAM_YAML"
  exit 0
fi

echo "🔄 发现配置差异"
echo "$DIFF"

# ─── 3. 检查 GH_TOKEN ───
if [[ -z "${GH_TOKEN:-}" ]]; then
  echo "⚠️  GH_TOKEN 未设置，仅提示差异但不创建 Issue"
  echo "   请手动对比: $LOCAL_YAML vs $UPSTREAM_URL"
  rm -f "$UPSTREAM_YAML"
  exit 1
fi

# ─── 4. 获取上游最新版本号 ───
LATEST_TAG=""
API_URL="https://api.github.com/repos/jxxghp/MoviePilot/releases/latest"
if LATEST_TAG=$(curl -sf "$API_URL" | grep '"tag_name"' | head -1 | sed -E 's/.*"([^"]+)".*/\1/'); then
  echo "🌐 上游最新版本: $LATEST_TAG"
  # 更新本地 VERSION 文件
  if [[ -n "$LATEST_TAG" ]]; then
    echo "$LATEST_TAG" > "$VERSION_FILE"
    echo "   已更新本地 VERSION: $LATEST_TAG"
  fi
fi

# ─── 5. 创建 Issue ───
REPO="$(cd "$REPO_DIR" && git remote get-url origin 2>/dev/null | sed -E 's/.*github.com[:/]([^/]+\/[^.]+).*/\1/' || echo "")"
if [[ -z "$REPO" ]]; then
  echo "⚠️  无法获取仓库地址，跳过创建 Issue"
  rm -f "$UPSTREAM_YAML"
  exit 1
fi

# 检查是否已有未关闭的同类 Issue
EXISTING=$(gh issue list --repo "$REPO" --label "upstream-sync" --state open --json number --jq 'length' 2>/dev/null || echo "0")
if [[ "$EXISTING" -gt 0 ]]; then
  echo "ℹ️  已有 $EXISTING 个未关闭的 upstream-sync Issue，跳过创建"
  rm -f "$UPSTREAM_YAML"
  exit 0
fi

# 生成可读的 diff（只显示实际配置行）
READABLE_DIFF=$(diff -u \
  --label "本地 (当前)" \
  --label "上游 (官方默认)" \
  <(grep -vE '^\s*(#|$)' "$LOCAL_YAML") \
  <(grep -vE '^\s*(#|$)' "$UPSTREAM_YAML") \
  2>/dev/null || true)

# 截断过长的 diff（Issue body 限制 65536 字符）
MAX_DIFF_LEN=30000
if [[ ${#READABLE_DIFF} -gt $MAX_DIFF_LEN ]]; then
  READABLE_DIFF="${READABLE_DIFF:0:$MAX_DIFF_LEN}\n\n... (diff 过长已截断，请手动对比完整文件)"
fi

TITLE="🔄 上游配置变更: MoviePilot $LATEST_TAG category.yaml 有更新"
BODY=$(cat <<EOF
检测到 MoviePilot 官方 \`category.yaml\` 有变更，请检查是否需要同步到本仓库。

**上游版本**: ${LATEST_TAG:-unknown}
**本地版本**: $(head -1 "$VERSION_FILE" | tr -d '[:space:]')

### 差异摘要

\`\`\`diff
${READABLE_DIFF}
\`\`\`

### 上游原始文件

<${UPSTREAM_URL}>

### 本地文件

\`config/category.yaml\`

---

⚠️ **注意**：本仓库的配置是对官方默认的增强版（增加 Music 分离、东南亚剧、儿童等分类）。
合并前请评估差异是否影响现有分类逻辑。

<!-- 由 sync-upstream.sh 自动创建 -->
EOF
)

gh issue create --repo "$REPO" --title "$TITLE" --body "$BODY" --label "upstream-sync,automated"
echo "✅ 已创建 Issue: $TITLE"

# 清理临时文件
rm -f "$UPSTREAM_YAML"
