# Docker NodeMCU build
[![Docker Pulls](https://img.shields.io/docker/pulls/marcelstoer/nodemcu-build.svg)](https://hub.docker.com/r/marcelstoer/nodemcu-build/) [![Docker Stars](https://img.shields.io/docker/stars/marcelstoer/nodemcu-build.svg)](https://hub.docker.com/r/marcelstoer/nodemcu-build/) [![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](https://github.com/marcelstoer/docker-nodemcu-build/blob/master/LICENSE)


克隆 [NodeMCU firmware](https://github.com/nodemcu/nodemcu-firmware) 并自定义本地配置文件，使用这个 Dcoker 镜像可以方便的编译出固件 [下载到 ESP8266](http://nodemcu.readthedocs.org/en/dev/en/flash/)。

## 目标群体
NodeMCU 开发者可以分为三类：
- 应用开发者

  他们需要一个现成的固件, 我创建 [云端构建服务](http://nodemcu-build.com/index.php) 具有界面友好的配置选项。但是，如果是使用 [LFS](https://nodemcu.readthedocs.io/en/latest/en/lfs/) ，他们可能想建立他们的LFS映像作为 [Terry Ellison's online service](https://blog.ellisons.org.uk/article/nodemcu/a-lua-cross-compile-web-service/) 在线服务的替代品。  
  **这个镜像正是你们心中所求!**

- 固件极客

  他们不需要完全控制整个工具链，也不希望在构建环境中设置 Linux 虚拟机。  
  **这个镜像正是你们心中所求!**

- 固件开发者

  他们在 GitHub 上提交或贡献项目，并且需要 [自己构建完整的编译环境和完整的工具链](http://www.esp8266.com/wiki/doku.php?id=toolchain#how_to_setup_a_vm_to_host_your_toolchain) 。他们肯定会发现这个镜像有用。

## 用法

### 安装 Docker
Docker 是一个开源项目，让应用程序布署在软件容器下的工作可以自动化进行，借此在Linux操作系统上，提供一个额外的软件抽象层，以及操作系统层虚拟化的自动管理机制。Docker 现在拥有不同系统平台的安装包，查看[官方文档](https://docs.docker.com/get-started/)可以获取方便的安装教程。

### 克隆仓库
运行下面命令克隆代码到你喜欢的目录：
```bash
git clone https://github.com/nodemcu/nodemcu-firmware.git
```

### 配置要使用的模块和特性
**注意**构建脚本会将下面设的置选项添加到 NodeMCU 引导信息(在应用程序启动时转储到控制台)。
配置要构建的模块功能编辑 `app/include/user_modules.h` 文件，也可以考虑在 `app/include/user_config.h `中打开 SSL 或 LFS。在同一个文件中的`#define LUA_NUMBER_INTEGRAL`参数，可以控制是否使用浮点支持构建固件。有关构建选项的其他选项和详细信息，请参阅 [NodeMCU 文档](https://nodemcu.readthedocs.io/en/latest/en/build/#build-options)。

### 使用 Docker 运行此镜像创建 LFS 固件
启动 Docker 并切换到 NodeMCU 固件目录, 运行下面命令创建 LFS 固件:
```
docker run --rm -ti -v `pwd`:/opt/nodemcu-firmware -v {PathToLuaSourceFolder}:/opt/lua marcelstoer/nodemcu-build lfs-image
```
这将编译并存储给定文件夹及其目录中中的所有 Lua 文件。

#### 输出
根据你构建的固件类型的不同，这将在 lua 文件夹的根目录中创建一个或两个 LFS 映像。

### Windows 用户笔记
Docker 在 Windows 平台处理路径略有不同，你需要在命令中指定 NodeMCU 固件目录的完整路径，且需要在 Windows 路径中添加一个额外的正斜杠('/')。这样命令就变成了(即c盘, "c:")：
```
docker run --rm -it -v //c/Users/<user>/<nodemcu-firmware>:/opt/nodemcu-firmware marcelstoer/nodemcu-build
```
如果Windows路径包含空格，那么它必须像往常一样在 Windows 上用引号括起来。  
```
docker run --rm -it -v "//c/Users/monster tune/<nodemcu-firmware>":/opt/nodemcu-firmware marcelstoer/nodemcu-build
```
如果这个 Docker 容器挂载存储 hang 死了，请检查 Windows 服务 “LanmanServer” 是否正在运行，[详见 DockerBug #2196](https://github.com/docker/for-win/issues/2196)。

### ‼️ 如果你以前拉取过 docker 镜像(例如根据上面的命令)，你应该经常更新镜像，以获得最新的错误修复:
```
docker pull marcelstoer/nodemcu-build
```

## 支持
希望大家不要在 Docker Hub 提问。 首先，Docker Hub 不会通知我。第二，问题在不集中保持下去这样意义不太大。欢迎在 [StackOverflow](http://stackoverflow.com/) 提问并且打上 `nodemcu` 和 `docker` 标签。

对于错误和改进建议，可以在这里提出问题 [https://github.com/marcelstoer/docker-nodemcu-build/issues](https://github.com/marcelstoer/docker-nodemcu-build/issues)

## 贡献
感谢 [Paul Sokolovsky](http://pfalcon-oe.blogspot.com/) 创建并维护 [esp-open-sdk](https://github.com/pfalcon/esp-open-sdk)。  
把更多的感谢给  [Gregor Hartmann](https://github.com/HHHartmann) ，他实现了 LFS 支持，并删除了此镜像的设计不良的 `INTEGER_ONLY` / `FLOAT_ONLY` 参数。

## 作者
[http://frightanic.com](http://frightanic.com)
