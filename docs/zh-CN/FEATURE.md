# feature - 功能开发流程

直接在命令行执行 `big-keeper feature --help` 可以查看其提供的所有功能：

```
NAME
    feature - Feature operations

SYNOPSIS
    big-keeper [global options] feature [command options] finish
    big-keeper [global options] feature [command options] list
    big-keeper [global options] feature [command options] pull
    big-keeper [global options] feature [command options] push
    big-keeper [global options] feature [command options] start
    big-keeper [global options] feature [command options] switch
    big-keeper [global options] feature [command options] update

COMMAND OPTIONS
    -u, --user=arg - (default: mmoaay)

COMMANDS
    finish - Finish current feature
    list   - List all the features
    pull   - Pull remote changes for current feature
    push   - Push local changes to remote for current feature
    start  - Start a new feature with name for given modules and main project
    switch - Switch to the feature with name
    update - Update moduels for the feature with name
```

全局参数如下：

- -u, --user：用户名，默认是 git global config 的 user.name，会显示在命令提示信息中，比如上述提示信息中的默认用户名是 mmoaay

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

![](../../resources/readme/big-keeper-readme.001.png)

feature 的工作区主要由两部分组成：

- 主项目；
- 相关业务模块，我们把 Podfile 中引用方式为 `:path => {业务模块本地路径}` 的模块做为相关业务模块。

主项目和每个相关业务模块又有各自的工作区，由三个部分组成：

- 当前代码区改动；
- stash 缓存区，当用户需要切换新的 feature 时，对于用户来不及提交的改动，我们会缓存到各个项目的 stash 中，（PS：所以代码突然不见了不要担心，都在 git 的 stash 里面），而当用户切换回某个 feature 时，我们会把和该 feature 分支同名的 stash 恢复回来，从而使用户可以继续开发之前未完成的部分，因为需要通过 feature 的分支名来匹配 stash，而 git stash 又没有提供给 stash 命名的功能，所以我们实现了 [big-stash](https://github.com/BigKeeper/big-stash) 来完成这个功能；
- git。

## feature start 流程

![](../../resources/readme/big-keeper-readme.002.png)

## feature finish 流程

![](../../resources/readme/big-keeper-readme.003.png)

## feature switch 流程

![](../../resources/readme/big-keeper-readme.004.png)

## feature update 流程

![](../../resources/readme/big-keeper-readme.005.png)

## feature pull 流程

![](../../resources/readme/big-keeper-readme.006.png)

## feature push 流程

![](../../resources/readme/big-keeper-readme.007.png)
