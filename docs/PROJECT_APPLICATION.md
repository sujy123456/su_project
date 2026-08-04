# MoonTrace 项目申报书

## 基本信息

- 项目名称：MoonTrace：面向 MoonBit 项目的可复现任务流水线与审计报告引擎
- 参赛者：苏楗轶
- 联系方式：2821775174@qq.com
- GitHub 仓库链接：https://github.com/sujy123456/su_project
- 项目方向：MoonBit 开发工具 / 自动化构建与项目验收辅助
- 是否为移植项目：否

## 项目简介

MoonTrace 是一个使用 MoonBit 实现的原创开发工具库，用来描述、记录和审计一次开发任务的完整过程。项目提供轻量 DSL、工作流模型、事件记录、规则检查、报告生成和 CLI 示例，适合黑客松项目验收、开源仓库 CI、课程实验评测、AI 辅助开发过程留痕等场景。它关注“任务是否按预期完成、测试和文档是否可追踪、过程是否能复现”，而不是替代现有 CI 或项目管理工具。

## 本次计划开发或新增内容

本次计划完成 MoonBit 原生数据模型、DSL 解析器、审计规则引擎、Markdown/JSON 风格报告输出、内置工作流模板目录、命令行示例、示例输入文件、README、技术设计文档、CHANGELOG、GitHub Actions CI 和可运行测试。项目有效 MoonBit 代码规模计划控制在 4,000 至 10,000 行之间，核心逻辑以 MoonBit 实现。

## 预期目标和技术路线

技术路线采用“模型层 + 解析层 + 审计层 + 报告层 + 模板目录”的结构。先定义 TraceWorkflow、TraceStep、TraceEvent、TraceRule 和 TraceFinding，再实现 DSL 到工作流对象的转换，随后根据事件日志生成审计结果，最后输出可保存的验收报告。内置模板目录覆盖 design、build、verify、docs、release、license、publish、review 等常见阶段，便于后续扩展为真实 CI 输入和 mooncakes 发布检查。

## 预计完成的功能、测试和文档

项目预计提供可构建的 MoonBit 包、可运行 CLI、基础 DSL 示例、不少于 4,000 行有效 MoonBit 代码、可运行单元测试、GitHub Actions CI、完整 README、技术设计说明、更新日志和 MIT 开源许可证。验收前会公开 GitHub 仓库，并按要求发布到 mooncakes.io。

## 原创性与开源合规说明

本项目为原创项目，不移植现有开源项目，不把他人成果作为原创提交。项目仅参考 CI、任务流水线、事件溯源、策略检查等通用工程思想；如后续增加第三方依赖，会在 README 和许可证说明中列明名称、来源链接和许可证。
