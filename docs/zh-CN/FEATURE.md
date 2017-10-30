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

## start - 开始一个新的 feature
