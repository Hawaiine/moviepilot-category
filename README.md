# 🎬 moviepilot-category

> MoviePilot v2 二级分类策略配置 — **开箱即用 · 贴近中文用户 · 持续追踪上游**

[![validate](https://github.com/Hawaiine/moviepilot-category/actions/workflows/validate.yml/badge.svg)](https://github.com/Hawaiine/moviepilot-category/actions/workflows/validate.yml)
[![sync-upstream](https://github.com/Hawaiine/moviepilot-category/actions/workflows/sync-upstream.yml/badge.svg)](https://github.com/Hawaiine/moviepilot-category/actions/workflows/sync-upstream.yml)
[![release](https://github.com/Hawaiine/moviepilot-category/actions/workflows/release.yml/badge.svg)](https://github.com/Hawaiine/moviepilot-category/actions/workflows/release.yml)
![VERSION](https://img.shields.io/badge/MP-v2.10.7-blue)
![LICENSE](https://img.shields.io/badge/license-MIT-green)

---

## ✨ 它有什么特别的？

| 特点 | 说明 |
|------|------|
| 🎯 **全品类覆盖** | 电影/剧集/动漫/纪录片/综艺/儿童/现场，一个不落 |
| 🔄 **上游追踪** | 每天自动对比官方 `category.yaml`，有变就通知你 |
| 🧪 **自动校验** | push 就跑 CI，YAML 语法、字段合法性、死分类全检查 |
| 🚀 **一键发布** | 打 tag 自动生成 Release + changelog |
| 🧩 **不止于分类** | 还带了优先级规则 + 识别词库，拿来即用 |

---

## 🏃 30 秒上手

把配置放进去就行：

```bash
# 方式一：直接复制
cp config/category.yaml /path/to/moviepilot/config/category.yaml

# 方式二：git 管理（推荐，以后 git pull 就能更新）
cd /path/to/moviepilot/config
git clone https://github.com/Hawaiine/moviepilot-category.git .
```

然后到 MoviePilot WebUI **重启** 或 **重载配置**，搞定。🎉

---

## 📂 看看里面有什么

```
moviepilot-category/
├── 📄 VERSION                          ← 当前对应的 MoviePilot 版本
├── 📁 config/
│   └── 📄 category.yaml                ← 🎯 二级分类策略（核心！）
├── 📁 rules/
│   └── 📄 default.json                 ← ⚖️ 优先级规则（搜索/订阅/洗版）
├── 📁 words/
│   └── 📄 common-words.txt             ← 🔤 自定义识别词共享库
├── 📁 docs/
│   └── 📄 reference.md                 ← 📖 字典速查表 + 配置说明
├── 📁 scripts/
│   ├── 📄 validate.sh                  ← 🔍 YAML 语法校验 + 结构检查
│   └── 📄 sync-upstream.sh             ← 🔄 检测 MP 上游变更
├── 📁 .github/
│   └── 📁 workflows/
│       ├── 📄 validate.yml             ← 🤖 CI: 自动校验
│       ├── 📄 sync-upstream.yml        ← 🤖 CI: 每日检测上游
│       └── 📄 release.yml              ← 🤖 CI: tag 自动发布
│       └── 📄 README.md                ← 🤖 CI 工作流说明
├── 📄 README.md                        ← 👈 就这个文件
└── 📄 LICENSE                          ← ⚖️ MIT 开源
```

---

## 🎮 分类策略说明书

### 🧠 匹配规则

```
从上到下 ⇩  依次匹配，谁先命中谁带走
同一个分类里 → 多个条件是「且」
同一个条件里 → 逗号分隔是「或」
! 前缀 → 排除！
```

### 🎥 电影分类（`movie`）

```
动 画 电 影  →  华 语 电 影  →  港 台 电 影  →  现 场  →  音 乐 电 影  →  日 韩 电 影  →  外 语 电 影  →  未 分 类
```

| 二级目录 | 匹配条件 | 🎬 举个例子 |
|----------|----------|------------|
| 🐉 **动画电影** | `genre_ids` 包含 16 | 你的名字、千与千寻 |
| 🀄 **华语电影** | `original_language` = `zh,cn,bo,za` | 流浪地球、让子弹飞 |
| 🏯 **港台电影** | `production_countries` = `HK,TW` | 无间道、那些年 |
| 🎤 **现场/演唱会** | `genre_ids` = 10402 + `ja,ko` | 宇多田光 Live、BTS 演唱会 |
| 🎵 **音乐电影** | `genre_ids` = 10402 + 非 `ja,ko` | 爱乐之城、波西米亚狂想曲 |
| 🇯🇵🇰🇷 **日韩电影** | `production_countries` = `JP,KP,KR` | 寄生虫、天气之子 |
| 🌍 **外语电影** | 欧美国家兜底 | 阿凡达、盗梦空间 |
| ❓ **未分类** | 以上都不匹配 | 奇奇怪怪的统统归这里 |

> ⚠️ **顺序很重要！** 「现场」必须在「日韩电影」前面，不然日韩演唱会被当成日韩电影了🤦

### 📺 剧集分类（`tv`）

```
国漫 → 日番 → 欧美动漫 → 纪录片 → 儿童 → 综艺 → 国产剧 → 港台剧 → 日剧 → 韩剧 → 东南亚剧 → 欧美剧 → 未分类
```

| 二级目录 | 匹配条件 | 🎬 举个例子 |
|----------|----------|------------|
| 🇨🇳 **国漫** | `genre_ids`=16 + `origin_country`=`CN,TW,HK` | 一人之下、时光代理人 |
| 🇯🇵 **日番** | `genre_ids`=16 + `origin_country`=`JP` | 进击的巨人、间谍过家家 |
| 🌎 **欧美动漫** | `genre_ids`=16 + 欧美国家 | 瑞克和莫蒂、英雄联盟双城之战 |
| 🎬 **纪录片** | `genre_ids`=99 | 地球脉动、舌尖上的中国 |
| 👶 **儿童** | `genre_ids`=10762 | 小猪佩奇、汪汪队立大功 |
| 🎪 **综艺** | `genre_ids`=10764,10767 | 奔跑吧、极限挑战 |
| 🏮 **国产剧** | `origin_country`=`CN` | 狂飙、漫长的季节 |
| 🌉 **港台剧** | `origin_country`=`HK,TW` | 繁花、想见你 |
| 🍣 **日剧** | `origin_country`=`JP` | 轮到你了、非自然死亡 |
| 🥘 **韩剧** | `origin_country`=`KP,KR` | 鱿鱼游戏、黑暗荣耀 |
| 🏝️ **东南亚剧** | `origin_country`=`TH,IN,SG,...` | 泰剧、印度剧等 |
| 🌍 **欧美剧** | 欧美国家 | 权力的游戏、绝命毒师 |
| ❓ **未分类** | 兜底 | 不知道啥的放这儿 |

---

## ⚖️ 优先级规则

`rules/default.json` 定义了哪些资源"更好"，下载时优先选它。

**涵盖的分类规则：**
- 🎞️ 电影类：动画电影、华语电影、外语电影、现场
- 📺 剧集类：日番、国漫、欧美漫、纪录片、综艺、国产剧、欧美剧、日韩剧

**🔍 搜索时的偏好：**
```
4K + 原盘/Bluray > 4K + WEB-DL > 1080P + Bluray > 1080P + WEB-DL > 1080P > 720P
```

**🚫 全局黑名单（自动过滤低质量资源）：**
`(?i)SubsPlease|TELESYNC|HDTV|NTb|...`

**怎么导入？** MP WebUI → **设定 → 自定义规则** → 导入

---

## 🔤 识别词库

`words/common-words.txt` 解决资源命名不规范问题：

| 类型 | 示例 | 有什么用 |
|------|------|---------|
| ❌ **屏蔽词** | `CMCT`、`HDSWEB` | 从资源名里删掉这些水印词 |
| 🔄 **替换** | `BluRay => Blu-ray` | 统一写法 |
| 🎯 **集数定位** | `第<>话 >> 0` | 让 MP 知道集数在哪 |

**怎么导入？** MP WebUI → **设定 → 词表** → 粘贴

---

## 🔄 上游同步

这个仓库基于 [jxxghp/MoviePilot](https://github.com/jxxghp/MoviePilot) 官方配置做了增强。

**GitHub Actions 每天 UTC 02:00 🤖 自动：**
1. 📥 拉取官方 `category.yaml`
2. 🔍 和本地对比（忽略注释空行）
3. 📢 发现差异 → 自动创建 Issue

**对比与我增强的部分（同步时不会被覆盖）：**

- 🎤 **Music 分离** — 现场（日韩 ja/ko）vs 音乐电影（非日韩）
- 👶 **儿童单独分类** — `genre_ids=10762`
- 🏝️ **东南亚剧** — TH/IN/SG/VN/MY/PH
- 🏯 **港台剧/国产剧分离** — 用 `!` 排除避免重叠
- 🛡️ **兜底分类** — 每级末尾保留空值 fallback
- 🆚 **正确区分** — movie 用 `production_countries`，tv 用 `origin_country`

## 🧪 本地校验

```bash
bash scripts/validate.sh config/category.yaml
```

会检查：YAML 语法 ✅ | 兜底空值 ✅ | 字段合法性 ✅ | JSON ✅ | TXT 格式 ✅

## 🔐 安全说明

- 🔒 本项目 **不含任何 API Key、Token、密码**
- 🔑 `GH_TOKEN` 只通过 GitHub Secrets 传入，不写进代码
- ✅ 建议设置 `GH_TOKEN` Secret 以开启自动 Issue 功能

## 📚 相关链接

- 📖 [MoviePilot 官方 Wiki](https://wiki.movie-pilot.org/advanced)
- 🎬 [TMDB 电影 API](https://developer.themoviedb.org/reference/movie-details)
- 📺 [TMDB 剧集 API](https://developer.themoviedb.org/reference/tv-series-details)
- 🐙 [MoviePilot GitHub](https://github.com/jxxghp/MoviePilot)

## ⚖️ License

MIT — 随便用，随便改 ✌️