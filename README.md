# moviepilot-category

MoviePilot v2 二级分类策略配置 — 开箱即用、贴近中文用户习惯。

## 特点

- ✅ **完整覆盖** — 电影/剧集/动漫/纪录片/综艺/儿童/现场 全品类
- ✅ **最新官方规范** — 支持 `release_year`、`!` 排除语法、`production_countries`（电影）
- ✅ **兜底回退** — 未匹配的分类自动归入「未分类」
- ✅ **中文用户优先** — 国漫、日番、港台、国产剧、日韩剧等中文场景全覆盖
- ✅ **字典速查** — 附赠 genre/language/country 速查表
- ✅ **校验+CI** — 本地脚本验证 + GitHub Actions 自动校验
- ✅ **上游追踪** — 定时对比官方配置变更，自动创建 Issue

## 快速开始

### 方式一：直接复制

```bash
cp config/category.yaml /path/to/moviepilot/config/category.yaml
```

在 MoviePilot WebUI 中重启或重载配置即可生效。

### 方式二：Git 同步（推荐）

```bash
cd /path/to/moviepilot/config
git clone https://github.com/Hawaiine/moviepilot-category.git .
```

后续更新直接 `git pull` 即可。

## 目录结构

```
moviepilot-category/
├── VERSION                         ← 当前对应的 MoviePilot 版本
├── config/
│   └── category.yaml               ← 二级分类策略（核心文件）
├── rules/
│   └── default.json                ← 优先级规则（搜索/订阅/洗版）
├── words/
│   └── common-words.txt            ← 自定义识别词共享库
├── docs/
│   └── reference.md                ← 字典速查表 + 配置说明
├── scripts/
│   ├── validate.sh                 ← YAML 语法校验 + 结构检查
│   └── sync-upstream.sh            ← 检测 MP 上游版本变更
├── .github/
│   ├── workflows/
│   │   ├── validate.yml            ← CI: 校验 YAML（含 Node.js + Python）
│   │   ├── sync-upstream.yml       ← CI: 每日检测上游版本变更
│   │   └── release.yml             ← CI: tag push 自动发布 Release
│   └── workflows/README.md         ← CI 工作流说明
└── README.md
```

## 分类策略说明

### 匹配规则

- 配置按 **从上到下依次匹配**，匹配到第一个符合条件的即停
- 同个分类下的多个条件为 **与** 关系
- 同个条件内的多个值（逗号分隔）为 **或** 关系
- `!` 前缀表示排除该值

### 电影分类（`movie`）

| 二级目录 | 匹配条件 | 说明 |
|----------|----------|------|
| 动画电影 | genre_ids 包含 16 | Animation |
| 华语电影 | original_language 为 zh/cn/bo/za | 中文语种 |
| 港台电影 | production_countries 为 HK/TW | 香港/台湾 |
| 现场 | genre_ids 包含 10402 + original_language 为 ja/ko | 日韩演唱会/Live BD（必须在日韩电影前） |
| 音乐电影 | genre_ids 包含 10402 + 非 ja/ko | 爱乐之城等音乐题材（已在现场之后） |
| 日韩电影 | production_countries 为 JP/KP/KR | 日本/韩国 |
| 外语电影 | production_countries 为欧美国家 | 英文/欧语种兜底 |
| 未分类 | 无条件 | 最终兜底 |

各分类按**从上到下**顺序匹配：

```
动画电影 → 华语电影 → 港台电影 → 现场 → 音乐电影 → 日韩电影 → 外语电影 → 未分类
```

> **注意**：「现场」必须排在「日韩电影」前，否则日韩演唱会被日韩国家先行命中；
> 「音乐电影」跟在「现场」之后并用 `!original_language: ja,ko` 排除，日韩语 10402 归现场，外语 10402 归音乐电影。

### 剧集分类（`tv`）

| 二级目录 | 匹配条件 | 说明 |
|----------|----------|------|
| 国漫 | genre_ids=16 + origin_country=CN/TW/HK | 国产动漫 |
| 日番 | genre_ids=16 + origin_country=JP | 日本动漫 |
| 欧美动漫 | genre_ids=16 + origin_country=US/FR/GB/... | 欧美动漫 |
| 纪录片 | genre_ids=99 | Documentary |
| 儿童 | genre_ids=10762 | Kids |
| 综艺 | genre_ids=10764,10767 | Variety/Talk |
| 国产剧 | origin_country=CN | 中国大陆（用 `!origin_country: HK,TW` 排除港台） |
| 港台剧 | origin_country=HK,TW | 港台地区 |
| 日剧 | origin_country=JP | 日本 |
| 韩剧 | origin_country=KP,KR | 韩国 |
| 东南亚剧 | origin_country=TH/IN/SG/VN/MY/PH | 东南亚 |
| 欧美剧 | origin_country=US/FR/GB/... | 欧美国家 |
| 未分类 | 无条件 | 最终兜底 |

```
国漫 → 日番 → 欧美动漫 → 纪录片 → 儿童 → 综艺 → 国产剧 → 港台剧 → 日剧 → 韩剧 → 东南亚剧 → 欧美剧 → 未分类
```

## 优先级规则（rules/）

`rules/default.json` 定义了按资源质量排序的优先级规则，覆盖：

- **电影**：动画电影、华语电影、外语电影、现场
- **剧集**：日番、国漫、欧美漫、纪录片、综艺、国产剧、欧美剧、日韩剧
- **全局过滤**：排除低质量组（SubsPlease、TELESYNC 等）
- **制作组白名单**：AnimeGroup、Audiences、Crunchyroll、Netflix 等

优先级规则直接在 MoviePilot「设定 → 自定义规则」中导入即可。

## 识别词（words/）

`words/common-words.txt` 是共享词库，包含：

- 通用屏蔽词（CMCT、HDSWEB、CHDBits 等水印）
- 常见替换规则（BluRay → Blu-ray、WEB-DL → WEBDL 等）
- 集数定位模板（第<>话、第<>集、EP<> 等）

可在 MoviePilot「设定 → 词表」中导入使用。

## 上游同步

本仓库基于 [jxxghp/MoviePilot](https://github.com/jxxghp/MoviePilot) 官方默认配置增强而来。

GitHub Actions **每天 UTC 02:00** 自动拉取官方 `main` 分支的 `category.yaml` 做 diff 对比。发现差异时自动创建 Issue，附带详细差异和上游链接。

### 增强项（同步时需保留）

- **Music 分离**：现场（日韩 ja/ko）vs 音乐电影（非日韩）
- **儿童分类**：`genre_ids=10762` 单独分类
- **东南亚剧**：TH/IN/SG/VN/MY/PH 单独分类
- **港台剧/国产剧分离**：用 `!` 排除语法避免重叠
- **未分类兜底**：每级分类末尾保留空值兜底
- **`production_countries`**（电影）vs `origin_country`（剧集）正确区分

### 手动同步

```bash
# 拉取官方最新配置并对比
bash scripts/sync-upstream.sh
```

## 本地校验

```bash
bash scripts/validate.sh config/category.yaml
```

校验内容：
- YAML 语法正确性
- 二级分类兜底是否为空（未分类）
- 字典字段合法性（匹配官方 Wiki 定义）
- rules/*.json JSON 语法
- words/*.txt 格式

## 安全说明

- 本项目不包含任何 API Key、Token、密码等凭证
- CI 中的 `GH_TOKEN` 通过 GitHub Secrets 传入，不写入代码
- 建议 fork 后自行设置 `GH_TOKEN` Secret 以开启自动 Issue 功能

## 相关链接

- [MoviePilot 官方 Wiki](https://wiki.movie-pilot.org/advanced)
- [TMDB 电影 API](https://developer.themoviedb.org/reference/movie-details)
- [TMDB 剧集 API](https://developer.themoviedb.org/reference/tv-series-details)
- [MoviePilot GitHub](https://github.com/jxxghp/MoviePilot)

## License

MIT