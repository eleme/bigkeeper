# spec - spec 管理

## 背景

模块化推进过程中势必存在业务模块间的横向依赖，原则上这种依赖我们都需要通过 router 进行解耦，不能直接源码依赖其他业务模块，因为这样的依赖会导致如下的问题：

- 因为直接横向依赖业务模块，导致业务模块无法独立编译运行。
- 各个业务模块如果存在大量类似依赖，必将导致后期模块代码依赖错综复杂，难以维护。

## 功能简介

直接在命令行执行 `big spec --help` 可以查看其提供的所有功能：

```
NAME
    spec - Spec operations

SYNOPSIS
    big [global options] spec [command options] add
    big [global options] spec [command options] analyze
    big [global options] spec [command options] delete
    big [global options] spec [command options] list
    big [global options] spec [command options] search

COMMAND OPTIONS
    -a, --[no-]all -

COMMANDS
    add     - Add a spec (Coming soon).
    analyze - Analyze spec dependency infomation.
    delete  - Delete a spec (Coming soon).
    list    - List all the specs.
    search  - Search a spec with name (Coming soon).
```

功能列表如下：

- analyze：分析所有指定模块之间的依赖，通常为业务模块。
- list：显示当前所有的业务 spec。
