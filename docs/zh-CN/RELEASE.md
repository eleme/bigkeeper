饿了么物流模块化效率提升思考 -  发布流程篇
### 背景
bigkeeper 的目的是为了在项目的模块化过渡阶段提升效率,在过渡到模块化的过程中要做很多的代码抽离,而越来越多的 Pod依赖(假设用Cocoapods做包管理)对项目管理者的负担越来越大.
移动端完成一个需求迭代,除了代码开发外,还需要有模块发版,集成,打包,回归这些步骤,而往往在回归到发版的时候,研发同学要花较多时间在发版,这严重影响了开发效率.
### 解决方案
为了提高要提高发布流程的发布效率,我们开发了big release 功能是来提升发布效率.首先说明,bigkeeper的开发以及发布流程是完全遵循[git-flow 流程](https://jeffkreeftmeijer.com/git-flow/).
我们建议直接把`Pods`和`Podfile.lock`移出版本控制系统，因为模块化的操作会频繁进行 `Pods`的增删以及更新，但是这会带来版本锁定的困扰,我们建议把版本锁定的工作从 `Podfile.lock`移到`Podfile`中,为此我们做了一个功能 [big pod](---.).
`bigkeeper`提供了`release module`模块发版和`release home`主工程发版,每种发版方式分为` start`和` finish`, 这两种方式的最大区别是` start`没有`git push`,不会因为可能存在的问题而污染`origin`仓库,这也留一个口子给研发人员进行二次确认.
#### 模块发版
在过渡到模块化和已经模块化的项目中, 会存在很多依赖库, 一般会分为:
* 业务模块库 
* 业务基础库
* 二方库(公司内部库)
* 三方库
一般来说,二方库和三方库的版本稳定,而每次业务迭代频繁改动往往就是业务模块库与业务基础库,这这两种类型的库在发布的时候往往因为会因为依赖库的原因而导致发版失败,浪费开发人员的时间.
所以,模块发布提供了两种解决方案:
```
big release module finish ExampleModule
Options:
    -s, --spec : 模块需要发布版本
```
`--spec`指令决定模块需要发版,如果不需要,那仅会在`master`分支打上`tag`.
而在`start`指令中我们也做了一些安全性检查:
* 根据开发流程的分支命名规范(branch: feature/x.x.x),检查当前是否有分支还没有合并到`develop`分支;
* 检查`master`分支相较于`develop`分支是否有超前的` commit`,防止有不规范的操作导致污染` master`分支代码.
```
big release module start ExampleModule
Options:
    -i, --ignore : 忽略安全性检查(默认开启)
```
#### 主工程发版
在模块化完成之后,主工程基本上是个壳工程,只会有`Podfile`和配置文件的改动, 根据`git-flow`的规则`bigkeeper`在发布主工程时会从`develop`切出` release/x.x.x`分支,`release`分支是一个暂时性分支,在代码已经并入`master`之后会删除`release`分支.
`release home start`中有两种模块的引用方式:
```
pod 'ExampleModule', '0.1.0'
or
pod 'ExampleModule', :git => 'ExampleModule.git', :tag => '0.1.0'
```
如果模块没有发布,` bigkeeper`会根据在根据仓库里的最新`tag`和`.cocoapods/repos` 里的已发布版本去找到合适的依赖方式.
在` release home finish`中有一个需要注意的地方就是` release`分支合并到` develop`之前`reset`掉对` Podfile`的操作,这样保持了不会有在` Podfile`文件不会有冲突.
### 举个例子
模块发版:
```
big -v 0.1.0 release module start ExampleModule
big -v 0.1.0 release module finish ExampleModule
Options:
    -v : 发布是指定版本号,如未指定,则用bigkeeper文件中的vesion
```
主工程发版:
```
big -v 0.1.0 release home start
big -v 0.1.0 release home finish
Options:
    -v : 发布是指定版本号,如未指定,则用bigkeeper文件中的vesion
```
### 展望
对于很多中大型公司来说都是自己的CI系统,可以把发版本这种耗时而且占内存的工作放在CI机器上,所以我们也有计划把`release module`最后一步的发版本的步骤留个口子,研发同学可以在这里去触发各自CI系统的发版流程.
### 结束语
`bigkeeper`在饿了么物流已经实践了半年多了,从数个模块到现在40+的模块数量,仅`release`流程节省项目管理者非常多的时间,提升了效率而且规范化了开发流程,也希望大家在使用中有` issue`反馈给到我们.

