# Flutter TiDB Hello

这是一个 Flutter 应用程序，演示如何连接到 TiDB Cloud 数据库并记录事件日志。该项目支持多平台部署，包括 macOS、iOS、Android 和 Web。

## 🚀 功能特性

- ✅ 连接到 TiDB Cloud (MySQL 兼容数据库)
- ✅ 自动检查并创建数据库表结构
- ✅ 记录按钮点击事件到数据库
- ✅ 实时显示数据库连接状态
- ✅ 跨平台支持 (macOS, iOS, Android, Web)
- ✅ 支持 iOS Release 模式部署到真机设备
- ✅ 安全的网络传输配置

## 📱 支持平台

| 平台 | 状态 | 测试设备 | 注意事项 |
|------|------|----------|----------|
| macOS | ✅ 已测试 | macOS 15.5 | 完全支持 |
| iOS | ✅ 已测试 | iPhone 12 Pro Max (iOS 18.5) | 完全支持 |
| Android | ✅ 支持 | - | 完全支持 |
| Linux | ✅ 支持 | - | 完全支持 |
| Windows | ✅ 支持 | - | 完全支持 |
| Web | ❌ 不支持 | - | mysql_client需要TCP socket连接，Web平台不支持 |

## 🗄️ 数据库表结构

应用会自动创建一个名为 `event_logs` 的表，包含以下字段：

```sql
CREATE TABLE event_logs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    event_type VARCHAR(50),
    event_time DATETIME
);
```

- `id`: 自增主键 (BIGINT)
- `timestamp`: 数据库时间戳 (TIMESTAMP, 默认当前时间)
- `event_type`: 事件类型 (VARCHAR(50))
- `event_time`: 客户端时间 (DATETIME)

## 🏗️ 项目结构

```
flutter_tidb_hello/
├── lib/
│   └── main.dart              # 主应用代码
├── ios/                       # iOS 平台配置
│   └── Runner/
│       └── Info.plist         # iOS 应用配置 (包含网络安全设置)
├── android/                   # Android 平台配置
├── macos/                     # macOS 平台配置
├── web/                       # Web 平台配置
├── pubspec.yaml              # Flutter 依赖配置
└── README.md                 # 项目说明文档
```

## 🛠️ 如何运行

### 环境准备

1. 安装 Flutter SDK (版本 >= 3.7.2)
2. 确保您有有效的 TiDB Cloud 连接信息

### 安装依赖

```bash
flutter pub get
```

### 运行应用

**开发模式：**
```bash
# macOS
flutter run -d macos --verbose

# iOS 模拟器
flutter run -d ios

# iOS 真机设备
flutter run -d [device-id]

# Android
flutter run -d android

# Web (不支持 - mysql_client库限制)
# flutter run -d chrome  # ❌ 不可用
```

**生产模式 (Release)：**
```bash
# iOS Release 构建
flutter build ios --release

# iOS Release 安装到设备
flutter install --device-id [device-id]

# iOS Release 运行
flutter run --device-id [device-id] --release

# Android Release 构建
flutter build apk --release

# macOS Release 构建
flutter build macos --release

# Windows Release 构建
flutter build windows --release

# Linux Release 构建
flutter build linux --release

# Web构建 (不推荐 - 运行时会出错)
# flutter build web  # ❌ 构建成功但运行时失败
```

## 📲 iOS 设备部署说明

### 首次部署到 iOS 设备

1. **构建 Release 版本：**
   ```bash
   flutter build ios --release
   ```

2. **安装到设备：**
   ```bash
   flutter install --device-id [your-device-id]
   ```

3. **信任开发者证书：**
   - 在 iPhone 上打开 "设置" → "通用" → "VPN与设备管理"
   - 找到开发者证书并点击信任
   - 确认信任该开发者

4. **运行应用：**
   - 可以直接在设备主屏幕点击应用图标启动
   - 或使用命令：`flutter run --device-id [device-id] --release`

### 查看连接的设备

```bash
flutter devices
```

## 💻 使用方法

1. **启动应用**：使用上述任一运行命令
2. **等待连接**：应用会自动连接到 TiDB Cloud 数据库
3. **确认状态**：等待数据库连接状态显示为"数据库已就绪"
4. **记录事件**：点击"记录事件到数据库"按钮
5. **查看结果**：每次点击都会向数据库插入一条新的事件记录，应用会显示操作结果

## 📦 主要依赖

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  mysql_client: ^0.0.27              # MySQL客户端库

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
```

### 🔗 关于 mysql_client 库

**mysql_client ^0.0.27** 是本项目使用的MySQL数据库连接库，具有以下特点：

- **📌 版本说明**: 目前最新版本为 0.0.27 (发布于2022年)
- **🏗️ 技术特性**: 
  - 原生Dart编写的MySQL客户端
  - 支持MySQL 5.7、8.x 和 MariaDB 10.x
  - 支持TLS/SSL安全连接
  - 支持连接池和预编译语句
  - 支持事务处理
- **🌍 平台兼容性**: 
  - ✅ **移动端**: iOS、Android (原生socket支持)
  - ✅ **桌面端**: macOS、Windows、Linux (原生socket支持)  
  - ❌ **Web端**: 不支持 (Web平台限制socket连接)
- **🔧 替代方案**: 
  - Web平台需要通过HTTP API或WebSocket代理连接数据库
  - 可考虑使用 `mysql1` 库 (但同样不支持Web)
  - Web端建议使用 REST API + 后端服务的架构

## 🔧 配置说明

### 网络安全配置 (iOS)

应用已配置了必要的网络安全设置以连接 TiDB Cloud：

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
    <key>NSExceptionDomains</key>
    <dict>
        <key>gateway01.eu-central-1.prod.aws.tidbcloud.com</key>
        <dict>
            <key>NSExceptionAllowsInsecureHTTPLoads</key>
            <true/>
            <key>NSExceptionMinimumTLSVersion</key>
            <string>TLSv1.0</string>
            <key>NSIncludesSubdomains</key>
            <true/>
        </dict>
    </dict>
</dict>
```

## ⚠️ 注意事项

- **网络连接**：确保设备网络连接正常，能够访问 TiDB Cloud
- **数据库配置**：当前数据库连接信息硬编码在应用中，生产环境建议使用环境变量或配置文件
- **iOS 部署**：首次在 iOS 设备上运行需要信任开发者证书
- **版本兼容**：建议使用 Flutter 3.7.2 或更高版本
- **Web平台限制**：
  - ❌ mysql_client库不支持Web平台 (socket连接限制)
  - ⚠️ 如需Web支持，建议采用以下方案：
    - 使用HTTP API + 后端服务架构
    - 通过WebSocket代理连接数据库
    - 使用Firebase或其他Web兼容的数据库服务
- **数据库兼容性**：
  - ✅ 支持 MySQL 5.7、8.x
  - ✅ 支持 MariaDB 10.x  
  - ✅ 支持 TiDB Cloud (MySQL兼容)

## 🎯 测试状态

- ✅ macOS 本地运行测试通过
- ✅ iOS 真机 (iPhone 12 Pro Max) 部署测试通过
- ✅ 数据库连接和数据插入功能正常
- ✅ Release 模式构建和部署成功

## 📝 开发历史

- 初始化 Flutter 项目
- 集成 mysql_client 依赖
- 实现 TiDB Cloud 数据库连接
- 添加事件记录功能
- 配置多平台支持
- 完成 iOS 真机部署测试
- 优化网络安全配置

---

**开发环境**: macOS 15.5, Flutter 3.24.3, Xcode  
**测试设备**: iPhone 12 Pro Max (iOS 18.5)  
**数据库**: TiDB Cloud (MySQL 兼容)
