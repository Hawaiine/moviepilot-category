# GitHub Actions 工作流说明

本项目使用以下 CI/CD 工作流，全部在 tag push 或代码变更时自动触发。

## 工作流列表

| 文件 | 名称 | 触发条件 | 功能 |
|------|------|----------|------|
| `validate.yml` | validate-category | push/PR 修改 category.yaml 或 validate.sh | 校验 YAML 语法、分类结构、JSON/TXT 格式 |
| `sync-upstream.yml` | sync-upstream | 每日 UTC 02:00（定时） | 拉取官方 category.yaml 对比，有差异自动创建 Issue |
| `release.yml` | release | push `v*` tag | 自动生成 Release 与 changelog |

## 所需 Secrets

| Secret | 用途 | 必填 |
|--------|------|------|
| `GH_TOKEN` | `sync-upstream.yml` 自动创建 Issue 需用（需 repo 权限） | 建议设置 |

> `GITHUB_TOKEN` 为 GitHub 自动注入，无需手动配置。

## 本地运行

```bash
# 校验配置
bash scripts/validate.sh config/category.yaml

# 模拟上游同步检测
bash scripts/sync-upstream.sh
```