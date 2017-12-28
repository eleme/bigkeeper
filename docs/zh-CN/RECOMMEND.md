# 代码管理规范
### master 分支保证是线上最新包的代码。
### develop 分支保证是下一个发布包的代码，保证随时发布。
<h3>开发和测试流程： </h3> feature 分支为 feature 开发和提测分支，提测前需要 rebase/merge develop 的代码，测试完成后，pr 到 develop 分支，确定下个版本发布才 accept pr。
<h3>develop 分支 bug ：</h3> 单独开分支，fix 完成后，pr 到 develop 分支。
<h3>发布流程：</h3> develop->release->master 瞬间操作，release 不能长期存在。
<h3>hot fix 流程：</h3> master 拉出 hotfix，fix 完成后分别 pr 到 master、develop 两个分支，完成后新建发布版本。
