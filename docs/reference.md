# 字典速查表

> 二级分类策略配置中使用的字段值参考。

---

## genre_ids 内容类型

| ID | 类型 |
|----|------|
| 28 | Action / 动作 |
| 12 | Adventure / 冒险 |
| 16 | Animation / 动画 |
| 35 | Comedy / 喜剧 |
| 80 | Crime / 犯罪 |
| 99 | Documentary / 纪录 |
| 18 | Drama / 剧情 |
| 10751 | Family / 家庭 |
| 14 | Fantasy / 奇幻 |
| 36 | History / 历史 |
| 27 | Horror / 恐怖 |
| 10402 | Music / 音乐 |
| 9648 | Mystery / 悬疑 |
| 10749 | Romance / 爱情 |
| 878 | Science Fiction / 科幻 |
| 10770 | TV Movie / 电视电影 |
| 53 | Thriller / 惊悚 |
| 10752 | War / 战争 |
| 37 | Western / 西部 |
| 10762 | Kids / 儿童 |
| 10764, 10767 | Talk/Reality / 综艺 |

---

## original_language 语种

| 代码 | 语种 |
|------|------|
| zh / cn | 中文 |
| bo | 藏语 |
| za | 粤语 |
| ja | 日语 |
| ko | 朝鲜语/韩语 |
| en | 英语 |
| fr | 法语 |
| de | 德语 |
| es | 西班牙语 |
| it | 意大利语 |
| pt | 葡萄牙语 |
| ru | 俄语 |
| th | 泰语 |
| vi | 越南语 |
| id | 印尼语 |
| ms | 马来语 |
| hi | 印地语 |

完整列表参考 [TMDB 语言代码](https://developer.themoviedb.org/reference/language-codes)。

---

## origin_country / production_countries 国家地区

| 代码 | 地区 |
|------|------|
| CN | 中国大陆 |
| TW | 中国台湾 |
| HK | 中国香港 |
| MO | 中国澳门 |
| JP | 日本 |
| KR | 韩国 |
| KP | 朝鲜 |
| US | 美国 |
| GB | 英国 |
| FR | 法国 |
| DE | 德国 |
| ES | 西班牙 |
| IT | 意大利 |
| RU | 俄罗斯 |
| AU | 澳大利亚 |
| CA | 加拿大 |
| NZ | 新西兰 |
| TH | 泰国 |
| IN | 印度 |
| SG | 新加坡 |
| VN | 越南 |
| MY | 马来西亚 |
| PH | 菲律宾 |
| BR | 巴西 |
| MX | 墨西哥 |
| AR | 阿根廷 |

---

## ⚠️ 特别注意：Music (10402) 分类

TMDB 的 `10402 Music` 类型下，**演唱会/现场录音** 和 **音乐电影** 混在一起。

### 解决方案

本项目采用**语种二次切割**：

| 二级目录 | 匹配条件 | 典型内容 |
|----------|----------|----------|
| 现场 | genre_ids=10402 + original_language=ja,ko | 日韩演唱会 Live BD |
| 音乐电影 | genre_ids=10402 + 非 ja/ko | 爱乐之城、波西米亚狂想曲 |

### 如果你需要调整

- **英文演唱会多**：把 `en` 加到「现场」的 `original_language` 里
- **华语演唱会多**：把 `zh,cn` 加到「现场」的 `original_language` 里
- **全部拆开**：取消音乐电影分类，全部归入「现场」，或反之

---

## 排除语法 `!`

在字段名前加 `!` 表示排除该值，例如：

```yaml
# 命中 production_countries 为 HK/TW，但排除 origin_country 为 CN 的（避免和华语电影重叠）
港台电影:
  production_countries: 'HK,TW'
  '!origin_country': 'CN'
```

---

## 年份范围

支持 `release_year` 字段，格式：`YYYY` 或 `YYYY-YYYY`

```yaml
# 仅匹配 2020-2024 年的电影
新片:
  release_year: '2020-2024'
```
