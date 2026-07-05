# 部署参考

## Docker 部署

`docker/compose.example.yaml` 是通用模板，按需修改路径后使用。

## 软链接映射（可选）

如果你用下载工具（qBittorrent/transmission）下载后需要整理到媒体库，
可以用软链接把下载目录映射到媒体库目录：

```bash
# 示例：下载目录 → 媒体库目录
ln -s /PATH/TO/downloads/电影/日韩电影 /PATH/TO/media/电影/日韩电影
ln -s /PATH/TO/downloads/剧集/日剧 /PATH/TO/media/剧集/日剧
# ... 依此类推
```

完整映射参考（按分类策略生成）：

```
/media/downloads/电影/动漫电影:/media/link/电影/动漫电影
/media/downloads/电影/港台电影:/media/link/电影/港台电影
/media/downloads/电影/华语电影:/media/link/电影/华语电影
/media/downloads/电影/日韩电影:/media/link/电影/日韩电影
/media/downloads/电影/现场:/media/link/电影/现场
/media/downloads/电影/音乐电影:/media/link/电影/音乐电影
/media/downloads/电影/欧美电影:/media/link/电影/欧美电影
/media/downloads/电影/外语电影:/media/link/电影/外语电影
/media/downloads/动漫/国漫:/media/link/动漫/国漫
/media/downloads/动漫/日番:/media/link/动漫/日番
/media/downloads/动漫/欧美动漫:/media/link/动漫/欧美动漫
/media/downloads/其它/纪录片:/media/link/其它/纪录片
/media/downloads/其它/儿童:/media/link/其它/儿童
/media/downloads/其它/综艺:/media/link/其它/综艺
/media/downloads/剧集/港台剧:/media/link/剧集/港台剧
/media/downloads/剧集/国产剧:/media/link/剧集/国产剧
/media/downloads/剧集/日剧:/media/link/剧集/日剧
/media/downloads/剧集/韩剧:/media/link/剧集/韩剧
/media/downloads/剧集/东南亚剧:/media/link/剧集/东南亚剧
/media/downloads/剧集/欧美剧:/media/link/剧集/欧美剧
```

> 以上路径仅为参考，请替换为你实际的下载目录和媒体库目录。
