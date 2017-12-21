### master分支保证是线上最新包的代码。
### develop分支保证是下一个发布包的代码，保证随时发布。
<h3>开发和测试流程： </h3> feature分支为feature开发和提测分支，提测前需要rebase/merge develop的代码，测试完成后，pr到develop分支，确定下个版本发布才accept pr。
<h3>develop分支bug：</h3> 单独开分支，fix完成后，pr到develop分支。
<h3>发布流程：</h3> develop->release->master 瞬间操作，release不能长期存在。
<h3>hot fix流程：</h3> master拉出hotfix，fix完成后分别pr到master、develop两个分支，完成后新建发布版本。
