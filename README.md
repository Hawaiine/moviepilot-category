# moviepilot-category

MoviePilot v2 二级分类策略配置 — 开箱即用、贴近中文用户习惯。

## 特点

- ✅ **完整覆盖** — 电影/剧集/动漫/纪录片/综艺/儿童/现场 全品类
- ✅ **最新官方规范** — 支持 `release_year`、`!` 排除语法、`production_countries`（电影）
- ✅ **兜底回退** — 未匹配的分类自动归入「未分类」
- ✅ **中文用户优先** — 国漫、日番、港台、国产剧、日韩剧等中文场景全覆盖
- ✅ **字典速查** — 附赠 genre/language/country 速查表
- ✅ **校验脚本** — 验证 YAML 语法正确性

## 快速开始

### 方式一：直接复制

将 `config/category.yaml` 复制到 MoviePilot 的配置目录：

```bash
cp config/category.yaml /path/to/moviepilot/config/category.yaml
```

然后在 MoviePilot WebUI 中重启或重载配置。

### 方式二：Git 同步

```bash
cd /path/to/moviepilot/config
git clone https://github.com/your-username/moviepilot-category.git .
```

## 配置结构

```
moviepilot-category/
├── VERSION                   ← 当前配置对应的 MoviePilot 版本
├── config/
│   └── category.yaml         ← 二级分类策略配置（核心文件）
├── rules/
│   └── default.json          ← 优先级规则（搜索/订阅/洗版）
├── words/
│   └── common-words.txt      ← 自定义识别词共享库
├── docs/
│   └── reference.md          ← 字典速查表 + 配置说明
├── scripts/
│   ├── validate.sh           ← YAML 语法校验 + 结构检查
│   └── sync-upstream.sh      ← 检测 MP 上游版本变更
├── .github/
│   └── workflows/
│       ├── validate.yml      ← CI: 校验 YAML
│       ├── sync-upstream.yml ← CI: 定时检测上游版本
│       └── release.yml       ← CI: tag push 自动发布 Release
└── README.md
```

## 分类策略说明

### 匹配规则

- 配置按**从上到下依次匹配**，匹配到第一个符合条件的即停
- 同个分类下的多个条件为 **与** 关系
- 同个条件内的多个值（逗号分隔）为 **或** 关系
- `!` 前缀表示排除该值

### 电影分类（`movie`）

| 二级目录 | 匹配条件 | 说明 |
|----------|----------|------|
| 动画电影 | genre_ids 包含 16 | Animation |
| 华语电影 | original_language 为 zh/cn/bo/za | 中文语种 |
| 港台电影 | production_countries 为 HK/TW | 香港/台湾 |
| 现场/演唱会 | genre_ids 包含 10402 + original_language ja/ko | 日韩演唱会/Live BD（必须在日韩电影前） |
| 音乐电影 | genre_ids 包含 10402 + 非 ja/ko | 爱乐之城等音乐题材电影 |
| 日韩电影 | production_countries 为 JP/KP/KR | 日本/韩国 |
| 外语电影 | 兜底 | 以上均不匹配时 |
| 未分类 | 兜底 | 纯 fallback |

### 剧集分类（`tv`）

| 二级目录 | 匹配条件 | 说明 |
|----------|----------|------|
| 国漫 | genre_ids=16 + origin_country=CN/TW/HK | 国产动漫 |
| 日番 | genre_ids=16 + origin_country=JP | 日本动漫 |
| 欧美动漫 | genre_ids=16 + origin_country=US/FR/GB/... | 欧美动漫 |
| 纪录片 | genre_ids=99 | Documentary |
| 儿童 | genre_ids=10762 | Kids |
| 综艺 | genre_ids=10764,10767 | Variety/Talk |
| 国产剧 | origin_country=CN/TW/HK | 中国大陆 |
| 港台剧 | origin_country=HK/TW | 港台地区 |
| 日剧 | origin_country=JP | 日本 |
| 韩剧 | origin_country=KP,KR | 韩国 |
| 东南亚剧 | origin_country=TH/IN/SG/VN/MY | 东南亚 |
| 欧美剧 | origin_country=US/FR/GB/... | 欧美国家 |
| 未分类 | 兜底 | 以上均不匹配时 |

## 自定义指南

参考 `docs/reference.md` 中的字典和官方 Wiki：

- 官方 Wiki: https://wiki.movie-pilot.org/advanced
- TMDB 电影 API: https://developer.themoviedb.org/reference/movie-details
- TMDB 剧集 API: https://developer.themoviedb.org/reference/tv-series-details

## 上游同步

本仓库的 `config/category.yaml` 基于 [jxxghp/MoviePilot](https://github.com/jxxghp/MoviePilot) 官方默认配置增强而来。

### 同步机制

| 机制 | 说明 |
|------|------|
| **定时检测** | GitHub Actions 每天自动拉取官方 `main` 分支的 `category.yaml` |
| **Diff 对比** | 忽略注释/空行后对比配置内容差异 |
| **自动 Issue** | 发现差异时自动创建 Issue，附带 unified diff |
| **版本追踪** | `VERSION` 文件记录当前对应的 MP 版本 |

### 手动同步

```bash
# 拉取官方最新配置并对比
bash scripts/sync-upstream.sh

# 如需强制同步（覆盖本地配置）
curl -Lo config/category.yaml https://raw.githubusercontent.com/jxxghp/MoviePilot/main/config/category.yaml
```

### 增强项说明

以下为本仓库对官方默认配置的增强，同步时需保留：

- **Music 分离**：现场（日韩 ja/ko）vs 音乐电影（非日韩）
- **儿童分类**：`genre_ids=10762` 单独分类
- **东南亚剧**：TH/IN/SG/VN/MY/PH 单独分类
- **港台剧/国产剧分离**：用 `!` 排除语法避免重叠
- **未分类兜底**：每级分类末尾保留空值兜底
- **`production_countries`**（电影）vs `origin_country`（剧集）正确区分

## License

MIT