# `Chiskat/Artalk-Go-Full`

[![](https://img.shields.io/docker/v/chiskat/artalk-go-full?sort=semver)](https://hub.docker.com/r/chiskat/artalk-go-full) ![](https://img.shields.io/docker/image-size/chiskat/artalk-go-full)

[Chiskat/Artalk-Go-Full](https://hub.docker.com/r/chiskat/artalk-go-full) 是基于 [Artalk](https://artalk.js.org/) 的官方镜像 [`artalk/artalk-go`](https://hub.docker.com/r/artalk/artalk-go/) 的全依赖 All-In-One 开箱即用版。Artalk 是一个自托管的 “Web 评论” 系统；[GitHub 仓库](https://github.com/ArtalkJS/Artalk)，[在线文档](https://artalk.js.org/)。

[Chiskat/Artalk-Go-Full](https://hub.docker.com/r/chiskat/artalk-go-full) 解决了 Artalk 原始镜像的依赖项需要手动下载和挂载的问题，做到了 “All-In-One”；[GitHub 仓库](https://github.com/chiskat/artalk-go-full)，[源码镜像](https://git.paperplane.cc/chiskat/artalk-go-full)。

## 特性

基于原始 `artalk/artalk-go` 镜像，解决了以下问题：

- 如果用到了 [图片上传](https://artalk.js.org/zh/guide/backend/img-upload.html) 功能，原版需手动下载并挂载 [upgit](https://github.com/pluveto/upgit)，而且无法直接运行，因为 Artalk 基于 `alpine` 镜像，它缺少新版 `upgit` 的依赖包，会引起报错；此镜像已安装好 `upgit`，开箱即用
- 如果用到了 [IP 属地](https://artalk.js.org/zh/guide/frontend/ip-region.html) 功能，原版需手动下载并挂载 [ip2region](https://github.com/lionsoul2014/ip2region) 中的 [ip2region_v4.xdb](https://github.com/lionsoul2014/ip2region/blob/master/data/ip2region_v4.xdb) 数据库；此镜像中自带了最新版的 `ip2region_v4.xdb`，可以直接使用

## 使用方式

使用方法和 `artalk/artalk-go` 完全相同。

---

如果你用需要使用 `upgit` 进行图片上传，无需自己安装它，直接准备好 `upgit.toml` 配置文件，挂载到镜像里即可，例如挂载到 `/data/upgit.toml`，然后配置 Artalk：

```yaml
img_upload:
  # ... 省略
  upgit:
    # 这里只需要把配置文件的路径配置为挂载路径即可
    exec: upgit -c /data/upgit.toml
```

即可直接使用 `upgit`。

---

如果你需要使用 IP 属地功能，无需自己下载 IP 数据库，直接配置 Artalk：

```yaml
ip_region:
  # ... 省略
  # 请配置成下面的固定路径
  db_path: /ip2region/ip2region.xdb
```

文件已经打包在镜像里，这个路径是写死的，按照上面的代码直接修改即可。

## 关于版本号

此镜像通过 GitHub 定时任务定期构建，每次构建均会同步最新的 `artalk`、`upgit`、`ip2region` 版本。

每次构建都会推送两个 TAG：

- 构建日期，例如 `2026.4.1`
- 版本号拼接，例如 `artalk_2.9.1-upgit_0.2.25-ip2region_83d6faf`，这样可以精确确定预装的各个依赖项的版本。

一般来说，如无特殊需要，直接使用 `latest` 最新版本号标签即可。

## 自行构建

如果你对第三方的镜像不放心，也可以自己构建，以下是方法：

1. 打开 [GitHub 仓库](https://github.com/chiskat/artalk-go-full) 克隆此项目，或者，只下载此项目中的 [`Dockerfile`](https://github.com/chiskat/artalk-go-full/blob/main/Dockerfile) 文件
2. 运行 `docker build -t 镜像名 .`，这里的镜像名你可以自己随便取，构建时会自动使用最新版本的 `artalk`、`upgit`、`ip2region`；如果构建失败，报错和 `TARGETARCH` 有关，那么构建命令改为 `docker build --build-arg TARGETARCH=amd64 -t 镜像名 .`，如果你是 ARM 处理器的电脑，请把 `amd64` 改为 `arm64`
