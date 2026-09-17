# Civilization VI Map Tack Blueprints

把一套规划一次性导入为《文明 6》原生地图钉，并与 **Detailed Map Tacks** 配合显示相邻加成。

当前 `v0.1.1` 是可玩的首个原型，内置风云变幻官方 **真实开局位置极大地球** 的澳大利亚港商规划：

- 澳洲核心 6 城；
- 澳大利亚 + 新西兰 8 城；
- 向北方群岛扩张 10 城；
- 每城导入市中心、港口、商业中心三个地图钉；
- 重复导入会更新已有蓝图，而不是制造重复项；
- 只管理名称以 `[MTB-AU]` 开头的地图钉，保留所有手工钉；
- 用地图尺寸和固定地形锚点校验地图，防止导错图。

## 技术与依赖

Mod 本体使用《文明 6》原生的 **Lua + XML + `.modinfo`**，不需要 Node.js、Python、编译器或外部程序。

- 《文明 6：风云变幻》：当前内置蓝图所需；
- [Detailed Map Tacks](https://steamcommunity.com/sharedfiles/filedetails/?id=2428969051)：推荐但不是硬依赖。安装后会自动计算导入钉的相邻加成；
- Windows PowerShell：仅供开发目录一键复制安装，手工复制也可以。

## 安装开发版

在 PowerShell 中进入仓库目录后运行：

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

默认安装到：

```text
Documents\My Games\Sid Meier's Civilization VI\Mods\MapTackBlueprints
```

进入游戏的“额外内容 → 模组”启用 **Map Tack Blueprints**。打开一局游戏后，点左下角地图钉列表，列表底部会出现 **“蓝图方案…”**。

## 使用

1. 打开官方“真实开局位置极大地球”地图。
2. 在地图钉列表中点击“蓝图方案…”。
3. 选择 6、8 或 10 城方案。
4. 点击“导入 / 更新方案”。
5. Detailed Map Tacks 会继续负责显示港口、商业中心的预计相邻加成。

“移除本蓝图地图钉”只删除本 Mod 创建且仍保留 `[MTB-AU]` 前缀的地图钉。

## 当前限制

- 首版只内置一张固定地图的一套蓝图族；
- 尚未加入“把当前手工地图钉保存为自定义方案”和配置码导入/导出；
- 需要在实际游戏里确认未探索迷雾区域是否允许由 UI API 直接创建地图钉；
- 坐标方案是经济蓝图，不会自动响应战争、城邦占位、忠诚度或资源揭示。

## 路线图

- 自定义方案保存、配置码导入/导出；
- 方案预览、逐城启用和冲突定位；
- 更多官方固定地图与文明蓝图；
- Steam Workshop 打包发布。

## License

[MIT](LICENSE)
