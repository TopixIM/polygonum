
Polygonum
------

> A chat app.

### Usages

使用 Node.js 24、Yarn 4.18.0、正式 Calcit 与 `@calcit/procs` 0.38.0 和 caps 0.1.1。模块以 `deps.cirru` 中的正式 tag 为准。上线前准备后端依赖、原生库和独立存档备份，再同步切换前后端。

数据库、会话、账户、话题、回复和操作已建立具体类型，reducer 与容器/成员/卡片投影有定义附加测试。投影区分用户缺失、话题缺失和未知卡片，公开作者视图不包含密码字段。话题、回复、卡片堆栈、个人页、登录和导航已接入这些类型；保留话题倒序、回复正序、未知卡片内容和原有按钮。两端检查、构建及发布模式的回环浏览器验收覆盖注册、创建话题和 Unicode 回复。历史双客户端同步、保存和冷恢复记录见下文。旧服务进程不能直接搭配新前端，上线前必须确认后端依赖与启动命令，并准备存档备份及回滚。

```bash
caps --strict --ci
yarn install --immutable
yarn watch-page # watch compile page code

yarn vite # for browser app

mode=dev calcit --entry server # native 服务；会访问持久化数据，按需启动
```

修改 Snapshot 前先读 `calcit docs agents --contract`，用官方 `calcit query` / `edit` / `tree` 操作 `calcit.cirru`；依赖由 `deps.cirru` 管理，不维护旧 Snapshot 或生成代码。

### Actions

领域 reducer 和 UI 回调已使用单参数名义 `schema/Op`。前后端通过 `app.protocol` 编解码 Enum 操作和具体 Store，原始 Recollect patch 缓存与 UI Store 分离，候选数据验证失败不会覆盖当前状态。协议由旧 Map 信封改为 Enum，前后端必须协调切换。下面描述新的 UI 调用合同。

客户端不再打印完整 dispatch 载荷，避免登录口令进入日志，口令输入框明确使用 password 类型遮挡显示。保存的旧登录信息仍通过公开 storage 接口读取并验证，不在迁移中主动删除；隔离浏览器验收仅用合成账户和内存存储。URL 参数通过公开 search-params 接口读取，不再依赖 url-parse 或伪宿主对象强转。

挂载元素和 location 使用 `js-ffi.browser` 的显式宿主接口，不再通过裸 JS 动态方法或函数签名 `unsafe-coerce` 适配。

Add card:

```cirru
d! $ schema/Op :stack/add $ schema/Stack :name :topics :data nil
```

Close card:

```cirru
d! $ schema/Op :stack/close idx
```

Add topic:

```cirru
d! $ schema/Op :topic/add "|some text"
```

Add topic reply:

```cirru
d! $ schema/Op :topic/reply $ schema/ReplyPayload
  :topic-id |demo-id
  :text |demo
```

### Workflow

https://github.com/Cumulo/calcium-workflow.calcit

### 构建与部署

CI 固定 Calcit 0.36.0，检查 browser/native 公开定义并保留原 `config/calcit-quality.cirru` 质量预算，不扩大预算。新增定义附加测试由同一套已发布共享 runner 回放 native/JS，不复制项目专用测试框架。两端完整入口及各自公开定义已通过，原质量门禁仍因逐定义边界差异失败，不声称远端 CI 已通过；远端依赖解析要求 `caps --strict --ci`，不使用 hash/main 绕过。

后端保存时仍清空会话，主存档和 `backups/<month>/<day>-snapshot.cirru` 的目录约定不变。存档入口兼容已有 nil/Option 作者 ID 包装并保留真实 ID、内容和时间；未知字段、错误类型或缺字段的残缺话题会阻止启动，不静默丢数据或伪造默认时间。WebSocket 缓存只在发送被接受后推进，背压时保留重试；退出时取消任务后保存。开发用 Reel 重放保留会话，生产禁用开发态持久化/重置/合并操作。隔离验收可设置 `POLYGONUM_BIND_ADDRESS=127.0.0.1`；未设置时仍为原 `0.0.0.0`。

前端 `dist/` 上传到 COS，生产 CDN 目录保持 `https://cos-sh.tiye.me/TopixIM/polygonum/`；同仓库 PR 使用 `pr/<编号>/<run-id>/<attempt>/`。上传校验完全由 `worktools/cos-upload-action@v1.2.0` 的 `public-base-url` 与内置 `verify-*` 默认配置完成。保留原有“同仓库 PR 缺少 secrets 时跳过、生产缺少时失败”的上传策略；这一选择步骤不校验上传结果，没有额外校验脚本。fork PR 只构建。

生产排队且不取消运行中上传，一次 main SHA 预检跳过旧提交，不保证原子发布。原 web rsync 和 `/servers/polygonum/` 后端路径不变，COS 不上传 `dist-server/`。后端包只放 `calcit.cirru`、`deps.cirru` 和 `package.json`，不再将诊断 IR 冒充 `compact.cirru`；服务从 Snapshot 使用 `calcit --entry server` 启动。原 rsync 不安装模块或升级服务器进程，部署准备必须另外完成。本分支只在 `/private/tmp` 副本启动隔离服务并保存合成数据，未改动真实持久化数据或部署。

### License

MIT
