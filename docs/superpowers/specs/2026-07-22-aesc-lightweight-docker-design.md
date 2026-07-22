# AESC 轻量版 Blockscout Docker 部署设计

## 目标

为本地 AESC 开发链运行轻量版 Blockscout，并通过 `http://localhost` 提供区块浏览器服务。

## 架构

复用 `docker-compose/no-services.yml` 提供 PostgreSQL、Redis、Blockscout 后端、前端和 Nginx。新增 `docker-compose/aesc-local.yml` 作为 Compose 覆盖文件，使 AESC 专用配置与 Blockscout 上游默认配置相互隔离。

后端从 Docker 容器访问宿主机发布的 AESC RPC 端点：

- HTTP 与 Trace RPC：`http://host.docker.internal:8545`
- WebSocket RPC：`ws://host.docker.internal:8546`
- EVM Chain ID：`71602`

前端将网络显示为 AESC Devnet，原生币显示为 AEX，精度为 18 位小数。

## 组件

- PostgreSQL：保存已索引的链上数据。
- Redis：支持缓存及后台任务。
- Blockscout 后端：索引区块并提供 API。
- Blockscout 前端：提供区块浏览器界面。
- Nginx：通过宿主机 80 端口统一提供前后端服务。

本次部署不包含 Stats、Visualizer、Sig Provider、User Ops Indexer 和 NFT Media Handler。

## 数据流

AESC 节点在宿主机发布 EVM RPC 端口 8545 和 8546。Blockscout 后端通过 `host.docker.internal` 访问这些端点，将区块数据索引到 PostgreSQL，并通过 Nginx 向前端提供数据。

## 错误处理

遇到以下情况时停止部署并诊断：Compose 配置错误、宿主机 80 端口被占用、AESC RPC 无法访问、数据库迁移失败或后端健康检查失败。任何修正前，先检查合并后的 Compose 配置、容器状态和对应服务日志。

## 验证方式

1. 验证合并后的 Compose 配置。
2. 确认 AESC 节点返回 EVM Chain ID `0x117b2`。
3. 启动轻量版 Compose 服务栈。
4. 确认必要容器正在运行，并且后端已完成数据库迁移。
5. 确认可以通过 `http://localhost` 访问 Blockscout API。
6. 确认 Blockscout 已索引非零高度的区块，并持续追赶 AESC 节点高度。

## 非目标

- 生产环境加固、TLS、公共域名、备份及外部数据库托管。
- 修改 AESC 节点行为。
- 启用 Blockscout 可选微服务。
