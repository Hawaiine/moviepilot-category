# config — 二级分类策略配置

核心配置文件 `category.yaml`，定义 movie/tv 两大分类下的二级目录匹配规则。

## 使用方式

### Docker 部署

```bash
# 直接替换 MP 配置目录下的文件
cp config/category.yaml /path/to/moviepilot/config/category.yaml
```

### 本地部署

```bash
cp config/category.yaml ~/.moviepilot/config/category.yaml
```

### 插件方式

在 MP WebUI「插件市场」安装「二级分类策略」插件，粘贴本配置内容。

## 文件说明

| 文件 | 说明 |
|------|------|
| `category.yaml` | 二级分类策略配置（主文件） |

> 详情见 [docs/reference.md](../docs/reference.md) 的字典速查表。