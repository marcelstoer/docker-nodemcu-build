# Docker NodeMCU build
[![Docker Pulls](https://img.shields.io/docker/pulls/marcelstoer/nodemcu-build.svg)](https://hub.docker.com/r/marcelstoer/nodemcu-build/) [![Docker Stars](https://img.shields.io/docker/stars/marcelstoer/nodemcu-build.svg)](https://hub.docker.com/r/marcelstoer/nodemcu-build/) [![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](https://github.com/marcelstoer/docker-nodemcu-build/blob/master/LICENSE)


克隆 [NodeMCU firmware](https://github.com/nodemcu/nodemcu-firmware) 并自定义本地配置文件，使用这个 Dcoker 镜像可以方便的编译出固件 [下载到 ESP8266](http://nodemcu.readthedocs.org/en/dev/en/flash/)。

## 目标群体
NodeMCU 开发者可以分为三类：
- 应用开发者

    他们需要一个现成的固件, 我创建 [云端构建服务](http://nodemcu-build.com/index.php) 界面友好具有可配置选项，使用起来可以得心应手。

- 固件极客

  他们不需要完全控制整个工具链，也不希望在构建环境中设置 Linux 虚拟机。
  **这个镜像正是你们心中所求!**

- 固件开发者

  他们在 GitHub 上提交或参与项目，并需要自己的完整功能。 [使用完整的工具链构建环境](http://www.esp8266.com/wiki/doku.php?id=toolchain#how_to_setup_a_vm_to_host_your_toolchain). _他们肯定会发现这个镜像有用._

## 用法

### 安装 Docker
Docker 是一个开源项目，让应用程序布署在软件容器下的工作可以自动化进行，借此在Linux操作系统上，提供一个额外的软件抽象层，以及操作系统层虚拟化的自动管理机制。Docker 现在拥有不同系统平台的安装包，查看[官方文档](https://docs.docker.com/get-started/)可以获取方便的安装教程。

### 克隆仓库
运行下面命令克隆代码到你喜欢的目录：
```bash
git clone https://github.com/nodemcu/nodemcu-firmware.git
```

### 进行编译
首先启动 Docker 并切换到 NodeMCU firmware 的目录，运行下面命令：
```
docker run --rm -ti -v `pwd`:/opt/nodemcu-firmware marcelstoer/nodemcu-build
```
根据系统的性能，需要 1-3 分钟，直到编译完成。第一次运行它需要更长的时间，因为 Docker 需要下载镜像并创建容器。如果您之前已经下载了这个 Docker 镜像，您应该经常更新镜像，运行下面命令以获取最新的版本：
```
docker pull marcelstoer/nodemcu-build
```

**Windows 用户笔记**  
(Docker on) Windows 处理路径略有不同，您需要指定命令中 NodeMCU 固件目录的完整路径，您需要在 Windows 路径中添加一个额外的正斜杠('/')。这样命令就变成了(即c盘, "c:")：
```
docker run --rm -it -v //c/Users/<user>/<nodemcu-firmware>:/opt/nodemcu-firmware marcelstoer/nodemcu-build
```
如果Windows路径包含空格，那么它必须像往常一样在 Windows 上用引号括起来。  
```
docker run --rm -it -v "//c/Users/monster tune/<nodemcu-firmware>":/opt/nodemcu-firmware marcelstoer/nodemcu-build
```

#### 输出固件
两个固件文件(integer和float)是在 NodeMCU 根目录的”bin"子文件夹中创建的。您还将在“bin”文件夹中找到与固件文件同名的 mapfile，但使用".map"结尾。

#### 可选参数
您可以像这样将下列可选参数传递给 Docker `docker run -e "<parameter>=value" -e ...`. 

- `IMAGE_NAME` 默认的固件文件名是`nodemcu_float|integer_<branch>_<timestamp>.bin`。如果您定义了图片名称，则会替换`<branch>_<timestamp>` 后缀，并且完整的图片名称会变成`nodemcu_float|integer_<image_name>.bin`。
- `INTEGER_ONLY` 如果您不需要支持浮动支持的 NodeMCU，则将其设置为 1，将构建时间减半。
- `FLOAT_ONLY` 如果您只需要支持浮动支持的 NodeMCU，则将其设置为 1，将构建时间减半。
- `TZ` 默认情况下，Docker 容器将以 UTC 时区运行。因此默认镜像名称（参见 `IMAGE_NAME` 上面的选项）的时间戳中的时间，不会与主机系统时间相同。要解决此问题，您可以将 `TZ` 参数设置为任何[有效的时区名称](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) 例如 `-e TZ=Asia/Shanghai`。



### 下载固件
使用固件 [下载工具](http://nodemcu.readthedocs.org/en/dev/en/flash/) 可以下载固件到 ESP8266。例如你使用 [esptool](https://github.com/themadinventor/esptool)（我喜欢这样用）可以运行如下命令下载固件:
```
esptool.py --port <USB-port-with-ESP8266> write_flash 0x00000 <NodeMCU-firmware-directory>/bin/nodemcu_[integer|float]_<Git-branch>.bin
```

## 支持
希望大家不要在 Docker Hub 提问。 首先，Docker Hub 不会通知我。第二，问题在不集中保持下去这样意义不太大。欢迎在 [StackOverflow](http://stackoverflow.com/) 提问并且打上 `nodemcu` 和 `docker` 标签。

对于错误和改进建议，可以在这里提出问题 [https://github.com/marcelstoer/docker-nodemcu-build/issues](https://github.com/marcelstoer/docker-nodemcu-build/issues)

## 贡献
感谢 [Paul Sokolovsky](http://pfalcon-oe.blogspot.com/) 创建并维护 [esp-open-sdk](https://github.com/pfalcon/esp-open-sdk)。

## 作者
[http://frightanic.com](http://frightanic.com)
