# Flutter TiDB Hello

这是一个 Flutter 应用程序，演示如何连接到 TiDB Cloud 数据库并记录事件日志。

## 功能特性

- 连接到 TiDB Cloud (MySQL 兼容数据库)
- 自动检查并创建数据库表结构
- 记录按钮点击事件到数据库
- 实时显示数据库连接状态

## 数据库表结构

应用会自动创建一个名为 `event_logs` 的表，包含以下字段：

- `id`: 自增主键 (BIGINT)
- `timestamp`: 数据库时间戳 (TIMESTAMP, 默认当前时间)
- `event_type`: 事件类型 (VARCHAR(50))
- `event_time`: 客户端时间 (DATETIME)

## 如何运行

1. 确保您有有效的 TiDB Cloud 连接信息
2. 运行 `flutter pub get` 安装依赖
3. 使用以下命令之一运行应用：
   - macOS: `flutter run -d macos`
   - iOS: `flutter run -d ios`
   - Android: `flutter run -d android`
   - Web: `flutter run -d chrome`

## 使用方法

1. 启动应用后，应用会自动连接到数据库
2. 等待数据库连接状态显示为"数据库已就绪"
3. 点击"记录事件到数据库"按钮，每次点击都会向数据库插入一条新的事件记录
4. 应用会显示操作结果的提示信息

## 依赖

- Flutter SDK
- mysql_client: ^0.0.27

## 注意事项

- 确保网络连接正常，能够访问 TiDB Cloud
- 数据库连接信息已硬编码在应用中，生产环境建议使用环境变量或配置文件
