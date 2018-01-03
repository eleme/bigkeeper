# feature - 功能开发流程 & hotfix - 线上修复流程

> 注：hotfix 除了基础分支是 **master**，其他操作和 feature 一致，所以我们这里以 feature 为例说明。

直接在命令行执行 `bigkeeper feature --help` 可以查看其提供的所有功能：

```
NAME
    feature - Feature operations

SYNOPSIS
    bigkeeper [global options] feature [command options] finish
    bigkeeper [global options] feature [command options] list
    bigkeeper [global options] feature [command options] pull
    bigkeeper [global options] feature [command options] push
    bigkeeper [global options] feature [command options] start
    bigkeeper [global options] feature [command options] switch
    bigkeeper [global options] feature [command options] update

COMMANDS
    finish - Finish current feature
    list   - List all the features
    pull   - Pull remote changes for current feature
    push   - Push local changes to remote for current feature
    start  - Start a new feature with name for given modules and main project
    switch - Switch to the feature with name
    update - Update moduels for the feature with name
```

功能列表如下：

- start：
  开始一个新的 feature，输入参数依次为：
  - feature 的名字;
  - 开发该 feature 需要改动的业务模块名。可以多个，用空格隔开；如果不指定，取 **Bigkeeper 文件中所有的业务模块名**。
- finish：结束当前 feature；
- switch：切换到一个已经存在的 feature，输入参数为 feature 名；
- update：
  更新一个 feature 需要改动的业务模块，输入参数依次为：
  - feature 的名字;
  - 开发该 feature 需要改动的业务模块名。可以多个，用空格隔开；如果不指定，取 **Bigkeeper 文件中所有的业务模块名**。
- pull：拉取当前 feature 主项目和业务模块的远程 git 仓库更新；
- push：提交并推送当前 feature 主项目和业务模块的本地变更到远程 git 仓库，输入参数为提交信息；
- list：显示当前的 feature 列表。

## feature 的工作区

![](../../resources/keynote/big-keeper-readme-feature/big-keeper-readme-feature.002.jpeg)

feature 的工作区主要由两部分组成：

- 主项目；
- 相关业务模块，我们把 Podfile 中引用方式为 `:path => {业务模块本地路径}` 的模块做为相关业务模块。

主项目和每个相关业务模块又有各自的工作区，由三个部分组成：

- 当前代码区改动；
- stash 缓存区，当用户需要切换新的 feature 时，对于用户来不及提交的改动，我们会缓存到各个项目的 stash 中，（PS：所以代码突然不见了不要担心，都在 git 的 stash 里面），而当用户切换回某个 feature 时，我们会把和该 feature 分支同名的 stash 恢复回来，从而使用户可以继续开发之前未完成的部分，因为需要通过 feature 的分支名来匹配 stash，而 git stash 又没有提供给 stash 命名的功能，所以我们实现了 [big-stash](https://github.com/BigKeeper/big-stash) 来完成这个功能；
- git。

## 工作区缓存流程

![stash 当前工作区](../../resources/keynote/big-keeper-readme-feature/big-keeper-readme-feature.003.jpeg)

## master／develop 分支状态检查流程

![检查 master／develop 分支状态](../../resources/keynote/big-keeper-readme-feature/big-keeper-readme-feature.004.jpeg)

## 切换分支流程

![切换分支](../../resources/keynote/big-keeper-readme-feature/big-keeper-readme-feature.005.jpeg)

## 同步业务模块与主项目分支流程

![同步业务模块与主项目分支](../../resources/keynote/big-keeper-readme-feature/big-keeper-readme-feature.006.jpeg)

## finish 业务模块 feature／hotfix 流程

![finish 业务模块 feature／hotfix](../../resources/keynote/big-keeper-readme-feature/big-keeper-readme-feature.007.jpeg)

## 从 feature／hotfix 移除模块流程

![从 feature／hotfix 移除模块](../../resources/keynote/big-keeper-readme-feature/big-keeper-readme-feature.008.jpeg)

## feature start 流程

![](../../resources/keynote/big-keeper-readme-feature/big-keeper-readme-feature.009.jpeg)

## feature finish 流程

![](../../resources/keynote/big-keeper-readme-feature/big-keeper-readme-feature.010.jpeg)

## feature switch 流程

![](../../resources/keynote/big-keeper-readme-feature/big-keeper-readme-feature.011.jpeg)

## feature update 流程

![](../../resources/keynote/big-keeper-readme-feature/big-keeper-readme-feature.012.jpeg)

## feature pull 流程

![](../../resources/keynote/big-keeper-readme-feature/big-keeper-readme-feature.013.jpeg)

## feature push 流程

![](../../resources/keynote/big-keeper-readme-feature/big-keeper-readme-feature.014.jpeg)
