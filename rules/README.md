# rules — 优先级规则

`default.json` 定义了资源搜索和下载时的优先级排序规则，覆盖电影/剧集按质量和来源的排序策略。

## 导入方式

在 MP WebUI → **设定 → 自定义规则** 中，点击右上角「导入」，粘贴 `default.json` 内容即可。

## 规则结构

```json
{
  "id": "规则标识",
  "name": "规则名称",
  "rule_string": "优先级表达式（用 > 分隔，越靠左优先级越高）",
  "media_type": "电影/电视剧",
  "category": "对应 category.yaml 中的二级分类名"
}
```

## 文件说明

| 文件 | 说明 |
|------|------|
| `default.json` | 优先级规则模板（含过滤组 + 分类规则 + 全局黑名单） |

### 过滤组（Filter）

| ID | 用途 |
|----|------|
| filterMovie | 电影大小限制（0-22GB） |
| filterSeries | 剧集大小限制（0-4GB/集） |
| filterGlobal | 全局黑名单（排除低质量组） |

### 制作组白名单

AnimeGroup、Audiences、HHWEB、Crunchyroll、Netflix、B-Global、AMZN

### 分类规则

覆盖：动画电影、华语电影、外语电影、日番、国漫、欧美漫、纪录片、综艺、国产剧、欧美剧、日韩剧、现场