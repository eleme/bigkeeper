# Bigkeeper 文件

首先，我们在主项目 Podfile 所在的目录加入 `Bigkeeper` 文件。

## 配置版本

```
version '2.8.8'
```

版本号的用途有：

- feature 和 hotfix 流程里面做为分支名前缀的一部分，方便后期通过版本号匹配分支；
- release 流程里面做为发布版本号，影响范围包括业务模块和主项目。

## 配置主项目

```
home 'BigKeeperMain', :git => 'git@github.com:BigKeeper/BigKeeperMain.git', :pulls => 'https://github.com/BigKeeper/BigKeeperMain/pulls'
```

这个配置包含三个部分：

- 主项目的名字；
- 主项目的 git 远程仓库地址；
- 主项目的 pull request / merge request 页面地址，完成某个 feature / hotfix 时，会自动打开这个页面，让开发者提交 pull request / merge request。

## 配置业务模块

```
modules do
  pod 'BigKeeperModular', :git => 'git@github.com:BigKeeper/BigKeeperModular.git', :pulls => 'https://github.com/BigKeeper/BigKeeperModular/pulls'
end
```

这个配置包含可以配置多个业务模块，建议是把当前所有非第三方库都加入到这个配置里面：

- 业务模块在 Podfile 中的名字；
- 业务模块的 git 远程仓库地址；
- 业务模块的 pull request / merge request 页面地址，完成某个 feature / hotfix 时，会自动打开这个页面，让开发者提交 pull request / merge request。

## 配置用户自定义信息

```
user 'perry' do
  pod 'BigKeeperModular', :path => '../BigKeeperModular'
end
```

如果用户需要配置一些自定义信息，比如业务模块在本地的路径，就可以增加一个这样的配置。

这个配置同样支持对指定的用户名（上述代码中为 perry）配置多个业务模块，目前支持的是：

- 配置业务模块的本地路径，通过这个路径，我们就可以在主工程直接对业务模块做一些 CocoaPods 和 git 相关的操作。

> 注：
> 默认我们会把本地路径配置成 `../{业务模块在 Podfile 中的名字}` 的形式，因为大部分情况下，我们会把不同项目放在同一个目录下，这也是我们推荐的。
> 另外，在使用 big-keeper 相关功能时，如果某些业务模块并没有 clone 到本地，big-keeper 会根据之前配置的业务模块远程 git 地址 clone 业务模块仓库到**主项目同级目录下**
