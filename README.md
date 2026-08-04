# MoonAttest

MoonAttest 是一个用 MoonBit 实现的项目验收证据与可复现质量证明引擎。它把构建、测试、CI、许可证、代码规模、文档和发布状态等不同来源的结果统一为结构化 `Evidence`，按声明式 `Policy` 评估，并生成带确定性指纹的证明包。项目只负责“证明当前项目状态”，不执行任务、不调度工作流，也不替代 GitHub Actions。

仓库地址：[github.com/sujy123456/su_project](https://github.com/sujy123456/su_project)

## 核心能力

- 将 `moon check`、`moon test`、覆盖率、Git、CI、文件和 mooncakes 状态归一化为证据；
- 使用 `eq`、`contains`、`min_int`、`between`、`one_of` 等谓词执行加权验收策略；
- 校验证据结构、唯一标识、许可证来源、文件变更边界和生成代码占比；
- 检测同一证据的冲突观察，并按来源优先级与采集时间合并；
- 生成 Markdown、JSON、行式清单、指标表、时间线和两次验收差异报告；
- 对证明包和证据时间线计算稳定指纹，用于 CI 制品复核；
- 内置黑客松验收策略目录，并提供可执行样例和 89 项测试。

## 构建与测试

安装 MoonBit 工具链后，在仓库根目录运行：

```powershell
moon fmt
moon check
moon test
moon run cmd/main -- sample
```

当前样例输出：

```text
MoonAttest moonattest-proof/1
Project: MoonAttest
Revision: sample-revision
Evidence: 22
Policies: 24
Verdict: ready
Score: 100%
Failures: 0
Fingerprint: ma1-5952159-4672918-8643
```

## CLI 示例

```powershell
moon run cmd/main -- sample    # 控制台验收摘要
moon run cmd/main -- json      # 机器可读证明包
moon run cmd/main -- manifest  # 无依赖行式清单
moon run cmd/main -- diff      # 两次验收结果差异
moon run cmd/main -- timeline  # 带指纹链的证据历史
```

`examples/basic.attest` 是可解析清单示例，字段顺序为项目元数据、证据和策略。格式保持无第三方依赖，便于 CI 脚本直接生成。

## MoonBit API

```mbt
test "project acceptance proof" {
  let attestation = sample_attestation()
  let bundle = build_proof_bundle(attestation)
  inspect(bundle.score.verdict, content="ready")
  inspect(verify_bundle_fingerprint(bundle), content="true")
}
```

接入真实项目时，可使用 `evidence_from_moon_check`、`evidence_from_moon_test`、`evidence_from_ci`、`evidence_from_license` 等适配器组装证据，再替换样例元数据与策略。证明指纹是确定性完整性校验值，不是密码学签名。

## 模块结构

- `model.mbt`：证据、策略、发现、证明包和指标模型；
- `adapters.mbt`：MoonBit、Git、CI、文件、许可证和发布结果适配器；
- `policy.mbt` / `catalog.mbt`：谓词评估、加权评分和验收策略目录；
- `schema.mbt` / `provenance.mbt` / `boundary.mbt`：结构、来源和文件边界审计；
- `ledger.mbt` / `metrics.mbt`：证据冲突合并和质量指标；
- `fingerprint.mbt` / `timeline.mbt` / `compare.mbt`：完整性链和跨版本差异；
- `manifest.mbt` / `report.mbt`：清单解析及 Markdown、JSON 输出；
- `cmd/main`：可运行 CLI 演示。

## 与工作流项目的区别

公开检索中已存在 MoonFlow、moonbit-workflow-engine 等工作流实现，也存在名为 MoonTrace 的 OpenTelemetry 包。MoonAttest 因此不再提供任务 DAG、状态机、重试、定时器或执行器，而专注于验收证据归一化、合规来源、证明指纹和版本差异。这一功能边界可与现有 CI、工作流工具组合，而不是重复实现它们。详细对照见 `docs/DUPLICATION_REVIEW.md`。

## 发布状态

仓库已配置 GitHub Actions。正式验收前仍需使用参赛者自己的 mooncakes.io 身份执行 `moon login` 和 `moon publish`，并把真实包版本及发布链接写入发布记录。

## 许可证

项目采用 MIT License。来源与许可证说明见 `SOURCE_ATTRIBUTION.md`。
