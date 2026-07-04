# scripts — 工具脚本

## validate.sh

YAML/JSON 语法和结构校验脚本，在本地开发时用于检查 category.yaml 的正确性。

```bash
# 校验配置
bash scripts/validate.sh config/category.yaml
```

校验内容：
- YAML 语法正确性
- 兜底分类是否存在（值是否为空）
- 字段名合法性（匹配官方 Wiki 定义）
- 分类顺序合理性
- rules/*.json JSON 语法
- words/*.txt 格式
- 项目结构完整性

## sync-upstream.sh

检测 MoviePilot 官方上游配置变更。

```bash
bash scripts/sync-upstream.sh
```

功能：
- 拉取 jxxghp/MoviePilot 官方 main 分支的 category.yaml
- 与本地配置做 diff 对比（忽略注释/空行）
- 发现差异时自动创建 GitHub Issue（需设置 GH_TOKEN）
- 自动更新 VERSION 文件

> sync-upstream.sh 在 GitHub Actions 中每天 UTC 02:00 自动运行。