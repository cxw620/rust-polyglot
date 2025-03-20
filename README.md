版权说明
========

[comment]: # (版权所有 2021-2022 Ian Jackson 及贡献者)
[comment]: # (SPDX-License-Identifier: MIT)
[comment]: # (本文档不提供任何保证. )

这是一本 Rust 编程语言指南, 由 Ian Jackson 撰写并对内容和观点负责.

本指南中文版由 Hantong Chen 翻译, 遵照原作者的版权声明.

最后修订和审核时间为 2022 年 12 月(第一版发布于 2021 年 9 月), 翻译于 2025 年 4 月.

### 规范位置

渲染后的文档可以在这里找到: [https://rust-polyglot.han.rs](https://rust-polyglot.han.rs)

### 贡献

囿于译者自身水平, 译文虽已力求准确, 但仍可能词不达意, 欢迎提 Issue 或 PR 批评指正.

原文贡献说明参见英文原文.

Contributions are very welcome, ideally via Issue or Merge Request:

   [https://salsa.debian.org/iwj/rust-polyglot/](https://salsa.debian.org/iwj/rust-polyglot/)

I am happy to hear contrary views,
especially about the recommendations about particular crates.
However,
I will make the final decision about the content of this guide.

**格式, 构建**:

文档采用 [mdbook](https://rust-lang.github.io/mdBook/) 和 [pandoc](https://pandoc.org/) Markdown 的交集格式, 
内容位于 `src/` 目录中.

要格式化为 HTML, 你需要 `cargo install mdbook` 并运行 `make`, 
但我们也欢迎未经测试的贡献.

**法律信息**:

请确保表明你同意 [开发者原创声明](#developer-certificate-of-origin-developer-certificate) 中的声明,
例如在你的提交中添加 `Signed-off-by` 行.

**致谢你的贡献**:

如果你希望在下面的列表中得到致谢, 请在那里添加你的名字 (作为你的合并请求的一部分).

**隐私**:

请注意, 由于本指南在 git 中维护, 你的贡献和任何致谢
将永久记录在 git 历史中, 以便追溯、审计、透明度和致谢.

### 致谢

感谢以下人员提供有益的审阅、评论和建议：
Simon Tatham,
Mark Wooding,
Daniel Silverstone,
以及其他人.

感谢 Mark Wooding 提供 LaTeX/PDF 支持.

### 法律声明

面向多语言程序员的 Rust 指南

版权所有 2021-2022 Ian Jackson 及贡献者.

`SPDX-License-Identifier: MIT`.

**不提供任何保证**

[comment]: #(额外数据由 generate-inputs 附加在此处:)
