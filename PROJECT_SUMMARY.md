# MangaFlow - Project Summary

## 项目概述

**MangaFlow** 是一个基于 Next.js 14 和 Supabase 的全栈 SaaS 应用，提供漫画自动翻译服务。用户可以上传漫画页面，系统通过 OCR 提取文字，使用 AI 翻译，然后将译文渲染回图像上。

## 核心功能

### 1. 用户功能
- ✅ 批量上传漫画页（支持图片文件夹和 ZIP/CBZ）
- ✅ OCR 文字识别（Tesseract.js + 可选 Google Vision）
- ✅ AI 翻译（Claude、GPT-4、DeepL 可切换）
- ✅ 可视化编辑器（调整文本位置、字体、大小）
- ✅ 智能渲染（文字回填到原图）
- ✅ 在线阅读器（逐页浏览）
- ✅ 导出 ZIP/CBZ
- ✅ 进度跟踪
- ✅ 多项目管理

### 2. 安全与审核
- ✅ 内容分级系统（general/teen/mature/explicit）
- ✅ 年龄验证门禁
- ✅ 三层审核网关：
  - 关键词过滤
  - 年龄限制检查
  - AI 内容审核（OpenAI Moderation API）
- ✅ 人工复核队列
- ✅ 用户举报系统
- ✅ 版权声明记录

### 3. 付费与计费
- ✅ 三档订阅计划（Free/Pro/Enterprise）
- ✅ 基于用量的计费（按 token、页数）
- ✅ Stripe 集成（订阅管理）
- ✅ 配额限制与检查
- ✅ 计费记录审计

### 4. 管理后台
- ✅ 审核面板（处理被标记内容）
- ✅ 举报管理
- ✅ 用户管理（修改角色、配额）
- ✅ 使用统计

## 技术栈

### 前端
- **框架**: Next.js 14 (App Router)
- **语言**: TypeScript
- **样式**: Tailwind CSS
- **组件**: shadcn/ui (Radix UI)
- **状态**: React Hooks（无需额外状态管理）

### 后端
- **运行时**: Node.js (Vercel Serverless)
- **数据库**: Supabase PostgreSQL
- **认证**: Supabase Auth (Magic Link + Google OAuth)
- **安全**: Row Level Security (RLS)
- **存储**: Vercel Blob
- **队列**: 简化队列系统（可升级为 Vercel Queue）

### 外部服务
- **OCR**: Tesseract.js / Google Vision API
- **翻译**: Anthropic Claude / OpenAI / DeepL
- **审核**: OpenAI Moderation API
- **支付**: Stripe
- **广告**: Google AdSense（可选）

### 开发工具
- **测试**: Jest + React Testing Library
- **日志**: Pino
- **类型**: TypeScript + Supabase 生成类型
- **部署**: Vercel

## 项目结构

```
mangaflow/
├── app/                          # Next.js App Router
│   ├── api/                      # API 路由
│   │   ├── upload/               # 上传端点
│   │   ├── projects/[id]/        # 项目 CRUD
│   │   ├── jobs/process/         # 任务处理
│   │   └── webhooks/stripe/      # Stripe webhook
│   ├── dashboard/                # 用户仪表板
│   ├── projects/                 # 项目页面
│   │   ├── new/                  # 新建项目
│   │   └── [id]/                 # 项目详情
│   ├── read/[id]/                # 在线阅读器
│   ├── admin/                    # 管理后台
│   │   ├── review/               # 审核面板
│   │   └── reports/              # 举报管理
│   ├── auth/                     # 认证页面
│   ├── billing/                  # 计费管理
│   ├── layout.tsx                # 根布局
│   ├── page.tsx                  # 首页
│   └── globals.css               # 全局样式
│
├── lib/                          # 核心库
│   ├── supabase/                 # Supabase 客户端
│   │   ├── client.ts             # 客户端（RLS 保护）
│   │   └── server.ts             # 服务端（service role）
│   ├── ocr/                      # OCR 模块
│   │   ├── index.ts              # 统一接口
│   │   ├── tesseract.ts          # Tesseract.js 实现
│   │   └── google-vision.ts      # Google Vision 实现
│   ├── translate/                # 翻译模块
│   │   ├── index.ts              # 统一接口
│   │   ├── claude.ts             # Claude API
│   │   ├── openai.ts             # OpenAI API
│   │   └── deepl.ts              # DeepL API
│   ├── moderation/               # 审核网关
│   │   └── index.ts              # 多层审核逻辑
│   ├── render/                   # 渲染引擎
│   │   └── index.ts              # Sharp + SVG 合成
│   ├── queue/                    # 任务队列
│   │   └── index.ts              # 任务处理器
│   ├── database.types.ts         # Supabase 类型定义
│   ├── constants.ts              # 常量配置
│   ├── utils.ts                  # 工具函数
│   └── logger.ts                 # 日志工具
│
├── components/                   # React 组件
│   ├── ui/                       # shadcn/ui 组件
│   │   ├── button.tsx
│   │   ├── card.tsx
│   │   ├── dialog.tsx
│   │   ├── select.tsx
│   │   └── ...
│   ├── upload-zone.tsx           # 上传区域
│   ├── page-editor.tsx           # 页面编辑器
│   └── reader.tsx                # 阅读器组件
│
├── supabase/                     # Supabase 配置
│   └── migrations/               # 数据库迁移
│       └── 0001_init.sql         # 初始化 schema + RLS
│
├── __tests__/                    # 测试文件
│   ├── ocr.test.ts               # OCR 单元测试
│   ├── moderation.test.ts        # 审核测试
│   └── fixtures/                 # 测试数据
│
├── public/                       # 静态资源
│   └── fonts/                    # 漫画字体
│
├── .env.example                  # 环境变量模板
├── .gitignore
├── next.config.js                # Next.js 配置
├── tailwind.config.ts            # Tailwind 配置
├── tsconfig.json                 # TypeScript 配置
├── jest.config.js                # Jest 配置
├── vercel.json                   # Vercel 配置（Cron）
├── package.json
├── README.md                     # 项目文档
├── DEPLOYMENT.md                 # 部署指南
├── ARCHITECTURE.md               # 架构文档
├── QUICKSTART.md                 # 快速开始
└── PROJECT_SUMMARY.md            # 本文档
```

## 数据模型

### 核心表

**profiles** - 用户资料
- `id` (UUID, PK, references auth.users)
- `email`, `role` (admin/user), `plan` (free/pro/enterprise)
- `credits`, `age_verified`

**projects** - 项目
- `id` (UUID, PK)
- `owner_id` (UUID, FK → profiles)
- `title`, `status` (pending/processing/ready/failed)
- `source_language`, `target_language`
- `content_rating`, `rights_declaration`

**pages** - 页面
- `id` (UUID, PK)
- `project_id` (UUID, FK → projects)
- `page_index`, `width`, `height`
- `original_blob_url`, `processed_blob_url`, `thumbnail_blob_url`

**text_blocks** - 文本块
- `id` (UUID, PK)
- `page_id` (UUID, FK → pages)
- `bbox` (JSONB: {x, y, width, height, rotation})
- `ocr_text`, `translated_text`, `confidence`
- `status`, `font_family`, `font_size`, `is_vertical`

**jobs** - 任务
- `id` (UUID, PK)
- `project_id` (UUID, FK → projects)
- `job_type` (ocr/translate/render/export)
- `state` (pending/running/done/failed)
- `attempts`, `last_error`

**review_items** - 审核项
- `id` (UUID, PK)
- `text_block_id` (UUID, FK → text_blocks)
- `reason` (low_conf/policy_flag/user_report)
- `resolved`, `reviewer_id`, `reviewer_notes`

**billing_usage** - 计费记录
- `id` (UUID, PK)
- `user_id` (UUID, FK → profiles)
- `project_id`, `tokens`, `pages`, `amount_cents`

**reports** - 举报
- `id` (UUID, PK)
- `reporter_id`, `project_id`
- `reason`, `status`, `resolution_notes`

### RLS 策略示例

所有表都启用了 Row Level Security，确保：
- 用户只能访问自己的项目和数据
- 管理员可以访问所有数据
- 服务端作业使用 service role 绕过 RLS

## 工作流程

### 完整处理流程

```
1. 用户上传漫画页
   ↓
2. 创建 Project 和 Pages 记录
   ↓
3. 图片上传到 Vercel Blob
   ↓
4. 创建 OCR Jobs（每页一个）
   ↓
5. Cron 触发 /api/jobs/process
   ↓
6. OCR Job 处理：
   - 下载图片
   - Tesseract 提取文字
   - 保存到 text_blocks 表
   - 低置信度的标记为需审核
   ↓
7. 创建 Translation Job
   ↓
8. Translation Job 处理：
   - 批量翻译文本块
   - 通过审核网关
   - 更新 text_blocks
   - 记录计费用量
   ↓
9. 创建 Render Jobs（每页一个）
   ↓
10. Render Job 处理：
    - 生成 SVG 叠层
    - Sharp 合成图片
    - 上传到 Vercel Blob
    ↓
11. Project 状态 → 'ready'
    ↓
12. 用户查看、编辑、导出
```

## 环境变量清单

### 必需
```env
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=
SUPABASE_SERVICE_ROLE_KEY=
BLOB_READ_WRITE_TOKEN=
ANTHROPIC_API_KEY= (或 OPENAI_API_KEY 或 DEEPL_API_KEY)
```

### 可选
```env
STRIPE_SECRET_KEY=
STRIPE_WEBHOOK_SECRET=
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=
GOOGLE_VISION_API_KEY=
OPENAI_MODERATION_API_KEY=
NEXT_PUBLIC_ADSENSE_CLIENT_ID=
NEXT_PUBLIC_ADSENSE_ENABLED=
```

### 配置
```env
NEXT_PUBLIC_APP_URL=
DEFAULT_TRANSLATION_PROVIDER=claude
DEFAULT_OCR_PROVIDER=tesseract
FREE_TIER_MAX_PROJECTS=3
FREE_TIER_MAX_PAGES_PER_PROJECT=50
ADMIN_EMAILS=admin@example.com
```

## 部署步骤（简要）

1. **创建 Supabase 项目**
   - 运行数据库迁移
   - 获取 URL 和 API Keys

2. **创建 Vercel Blob 存储**
   - 获取 BLOB_READ_WRITE_TOKEN

3. **获取翻译 API Key**
   - Claude / OpenAI / DeepL

4. **推送到 GitHub**

5. **连接 Vercel**
   - 导入仓库
   - 配置环境变量
   - 部署

6. **配置 Cron Job**
   - 添加 `vercel.json`
   - 重新部署

7. **创建管理员用户**
   - 注册账号
   - 在 Supabase SQL 中设置角色

详见 `DEPLOYMENT.md` 完整部署指南。

## 安全特性

### 认证与授权
- ✅ Supabase Auth（Magic Link + OAuth）
- ✅ JWT token 验证
- ✅ Row Level Security（数据库级）
- ✅ API 路由权限检查

### 内容安全
- ✅ 关键词黑名单过滤
- ✅ 年龄分级与门禁
- ✅ AI 内容审核（OpenAI Moderation）
- ✅ 人工复核机制
- ✅ 无任何绕过机制

### 数据保护
- ✅ 敏感环境变量隔离
- ✅ Service Role Key 仅在服务端使用
- ✅ HTTPS 强制
- ✅ CORS 配置
- ✅ SQL 注入防护（Supabase 自动）

## 性能优化

### 已实现
- ✅ 数据库索引优化
- ✅ Sharp 图像处理（libvips）
- ✅ 并发上传页面
- ✅ 批量翻译（20 块/批）
- ✅ 缩略图懒加载

### 待优化
- ⏳ Redis 缓存层
- ⏳ CDN 图片分发
- ⏳ 增量静态生成（ISR）
- ⏳ 流式响应

## 测试覆盖

### 单元测试
- ✅ OCR 模块
- ✅ 审核网关
- ✅ 工具函数

### 集成测试
- ⏳ API 路由（待完善）
- ⏳ 任务处理流程

### E2E 测试
- ⏳ 完整上传-处理-导出流程

## 成本估算

### 免费层（适合开发/小规模）
- Vercel: $0
- Supabase: $0
- 翻译 API: ~$5-10/月（低用量）
- **总计**: ~$5-10/月

### 推荐配置（中等用量）
- Vercel Pro: $20/月
- Supabase Pro: $25/月
- 翻译 API: ~$30-50/月
- **总计**: ~$75-95/月

## 已知限制

1. **简化队列系统**
   - 当前使用数据库轮询
   - 生产环境建议升级为 Vercel Queue 或 Upstash

2. **OCR 性能**
   - Tesseract 较慢（3-5秒/页）
   - 建议升级 Google Vision（0.5秒/页）

3. **无实时更新**
   - 需手动刷新查看进度
   - 计划实现 Supabase Realtime

4. **单语言界面**
   - 当前仅英文
   - 已预留 next-intl 国际化

## 后续计划

### 短期（v1.1）
- [ ] 实时进度更新（Supabase Subscriptions）
- [ ] 完善编辑器 UI
- [ ] 添加更多字体选项
- [ ] 实现批量导出

### 中期（v2.0）
- [ ] 多人协作编辑
- [ ] 自定义词汇表
- [ ] API 访问（公开 API）
- [ ] Webhook 通知

### 长期（v3.0）
- [ ] 移动应用
- [ ] 本地离线模式
- [ ] 自托管选项
- [ ] 插件生态

## 文档链接

- **README.md**: 项目介绍与功能列表
- **QUICKSTART.md**: 10 分钟快速上手
- **DEPLOYMENT.md**: 完整部署指南
- **ARCHITECTURE.md**: 技术架构详解
- **PROJECT_SUMMARY.md**: 本文档

## 贡献指南

欢迎贡献！请遵循：
1. Fork 仓库
2. 创建 feature 分支
3. 提交测试通过的代码
4. 发起 Pull Request

详见 `CONTRIBUTING.md`（待创建）。

## 许可证

MIT License - 详见 LICENSE 文件

## 联系方式

- GitHub Issues: 问题反馈
- Email: support@mangaflow.app（示例）
- Discord: 社区讨论（待建立）

---

**版本**: 1.0.0
**最后更新**: 2025-01-10
**作者**: MangaFlow Team (Claude Code Generated)
