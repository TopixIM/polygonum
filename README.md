
Polygonum
------

> A chat app.

### Usages

使用 Node.js 24、Yarn 4.18.0、正式 [Calcit](https://github.com/calcit-lang/calcit) / `@calcit/procs` 0.27.0 和 caps 0.1.1。依赖由 caps 安装，不需要手工克隆模块。

```bash
caps --ci
yarn install --immutable
yarn watch-page # watch compile page code

yarn vite # for browser app

mode=dev calcit --entry server # native 服务；会访问持久化数据，按需启动
```

修改 Snapshot 前先读 `calcit docs agents --contract`，用官方 `calcit query` / `edit` / `tree` 操作 `calcit.cirru`；依赖由 `deps.cirru` 管理，不维护旧 Snapshot 或生成代码。

### Actions

组件回调和 client dispatch 都使用单参数 enum；`:states` 解包为 cursor/state，业务操作仍发送 `{:kind :op, :op tag, :data payload}`。无 payload 时省略 `:data`，既有服务端 `&map:get` 仍读取为 nil，不需要改服务端协议处理。

挂载元素和 location 使用 `js-ffi.browser` 的显式宿主接口，不再通过裸 JS 动态方法或函数签名 `unsafe-coerce` 适配。

Add card:

```cirru
d! $ :: :stack/add $ {} (:name :topics) (:data topic-id)
```

Close card:

```cirru
d! $ :: :stack/close idx
```

Add topic:

```cirru
d! $ :: :topic/add "|some text"
```

Add topic reply:

```cirru
d! $ :: :topic/reply $ {}
  :topic-id |demo-id
  :text |demo
```

### Workflow

https://github.com/Cumulo/calcium-workflow.calcit

### 构建与部署

CI 明确正式 Calcit 0.27，检查 browser/native 公开定义并保留原 `config/calcit-quality.cirru` 质量预算，不扩大预算。模块发布图仍有原版本 warning，沿用 `caps --ci`，不声称 strict 依赖图通过，也不用 hash/main 绕过。

前端 `dist/` 上传到 COS，生产 CDN 目录保持 `https://cos-sh.tiye.me/TopixIM/polygonum/`；同仓库 PR 使用 `pr/<编号>/<run-id>/<attempt>/`。上传校验完全由 `worktools/cos-upload-action@v1.2.0` 的 `public-base-url` 与内置 `verify-*` 默认配置完成。保留原有“同仓库 PR 缺少 secrets 时跳过、生产缺少时失败”的上传策略；这一选择步骤不校验上传结果，没有额外校验脚本。fork PR 只构建。

生产排队且不取消运行中上传，一次 main SHA 预检跳过旧提交，不保证原子发布。原 web rsync 和 `/servers/polygonum/` 后端路径、后端打包步骤不变，COS 不上传 `dist-server/`。本次没有启动服务或改动持久化数据；IR 是诊断输出，既有打包中的旧命名不代表推荐运行入口，服务仍应按 `calcit --entry server` 从 Snapshot 启动。

### License

MIT
