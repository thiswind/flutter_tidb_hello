# Flutter TiDB Hello

这是一个 Flutter 应用程序，演示如何连接到 TiDB Cloud 数据库并记录事件日志。该项目支持多平台部署，包括 macOS、iOS、Android 和 Web。

## 🚀 功能特性

- ✅ 连接到 TiDB Cloud (MySQL 兼容数据库)
- ✅ 安全的密码管理系统 (本地存储，首次运行输入)
- ✅ 自动检查并创建数据库表结构
- ✅ 记录按钮点击事件到数据库
- ✅ 实时显示数据库连接状态
- ✅ 密码重置和重新配置功能
- ✅ 跨平台支持 (macOS, iOS, Android, Web)
- ✅ 支持 iOS Release 模式部署到真机设备
- ✅ 安全的网络传输配置
- ✅ 智能连接策略 (SSL/非SSL自动切换)

## 📱 支持平台

| 平台 | 状态 | 测试设备 | 注意事项 |
|------|------|----------|----------|
| macOS | ✅ 已测试 | macOS 15.5 | 完全支持，热重载测试通过 |
| iOS | ✅ 已测试 | iPhone 12 Pro Max (iOS 18.5) | 完全支持，真机部署测试通过 |
| Android | ✅ 支持 | - | 完全支持 |
| Linux | ✅ 支持 | - | 完全支持 |
| Windows | ✅ 支持 | - | 完全支持 |
| Web | ❌ 不支持 | - | mysql_client需要TCP socket连接，Web平台不支持 |

## 🔐 安全功能

### 密码管理
- **首次运行**: 应用会提示输入 TiDB 数据库密码
- **安全存储**: 密码使用 `shared_preferences` 安全存储在本地
- **密码重置**: 提供密码重置功能，支持重新配置数据库连接
- **错误处理**: 智能检测密码错误并提供重置选项

### 连接安全
- **SSL 优先**: 首先尝试 SSL 安全连接
- **降级支持**: SSL 连接失败时自动尝试非 SSL 连接
- **错误检测**: 智能识别权限错误和密码错误

## 🗄️ 数据库表结构

应用会自动创建一个名为 `event_logs` 的表，包含以下字段：

```sql
CREATE TABLE IF NOT EXISTS event_logs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    event_type VARCHAR(50) NOT NULL,
    event_time DATETIME NOT NULL,
    INDEX idx_timestamp (timestamp),
    INDEX idx_event_type (event_type)
);
```

- `id`: 自增主键 (BIGINT)
- `timestamp`: 数据库时间戳 (TIMESTAMP, 默认当前时间)
- `event_type`: 事件类型 (VARCHAR(50), 不允许为空)
- `event_time`: 客户端时间 (DATETIME, 不允许为空)
- `idx_timestamp`: 时间戳索引（提高查询性能）
- `idx_event_type`: 事件类型索引（提高查询性能）

## 🏗️ 项目结构

```
flutter_tidb_hello/
├── lib/
│   └── main.dart              # 主应用代码 (包含密码管理和数据库连接)
├── ios/                       # iOS 平台配置
│   ├── Podfile                # iOS 依赖管理
│   └── Runner/
│       └── Info.plist         # iOS 应用配置 (包含网络安全设置)
├── macos/                     # macOS 平台配置
│   └── Podfile                # macOS 依赖管理
├── android/                   # Android 平台配置
├── web/                       # Web 平台配置 (不支持运行)
├── pubspec.yaml              # Flutter 依赖配置
└── README.md                 # 项目说明文档
```

## 🛠️ 如何运行

### 环境准备

1. 安装 Flutter SDK (版本 >= 3.7.2)
2. 准备您的 TiDB Cloud 连接信息
3. 确保网络连接正常，可访问 TiDB Cloud

### 安装依赖

```bash
flutter pub get
```

### 首次运行配置

1. **启动应用**：使用下方的运行命令
2. **密码配置**：首次运行时会弹出密码输入对话框
3. **输入密码**：输入您的 TiDB Cloud 数据库密码
4. **保存配置**：密码会自动保存到本地，下次启动无需重新输入

### 运行应用

**开发模式：**
```bash
# macOS (推荐用于开发)
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
2. **首次配置**：输入 TiDB Cloud 数据库密码
3. **等待连接**：应用会自动连接到 TiDB Cloud 数据库
4. **确认状态**：等待数据库连接状态显示为"数据库已就绪"
5. **记录事件**：点击"记录事件到数据库"按钮
6. **查看结果**：每次点击都会向数据库插入一条新的事件记录，应用会显示操作结果

### 密码管理

- **重置密码**：点击"重置数据库密码"按钮可以重新配置密码
- **连接失败处理**：如果连接失败，应用会智能判断是否为密码错误并提供重置选项
- **安全存储**：密码使用 Flutter 安全存储机制，不会明文保存

## 📦 主要依赖

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  mysql_client: ^0.0.27              # MySQL客户端库
  shared_preferences: ^2.2.2         # 本地数据存储 (密码管理)

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
```

### 🔗 关于主要依赖库

**mysql_client ^0.0.27** - MySQL数据库连接库：
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

**shared_preferences ^2.2.2** - 本地数据存储库：
- **📌 版本说明**: 2.2.2 版本，稳定可靠
- **🏗️ 技术特性**:
  - 跨平台本地数据持久化存储
  - 安全的键值对存储系统
  - 异步读写操作
  - 支持多种数据类型 (String, int, bool, double, List<String>)
- **🌍 平台兼容性**:
  - ✅ **iOS**: 使用 NSUserDefaults
  - ✅ **Android**: 使用 SharedPreferences
  - ✅ **macOS**: 使用 NSUserDefaults
  - ✅ **Windows**: 使用注册表
  - ✅ **Linux**: 使用文件系统
  - ✅ **Web**: 使用 localStorage

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
- **密码安全**：数据库密码安全存储在本地，首次运行需要用户输入
- **连接策略**：应用支持 SSL 和非 SSL 连接，会自动选择最佳连接方式
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

- ✅ macOS 本地运行测试通过 (开发模式热重载正常)
- ✅ iOS 真机 (iPhone 12 Pro Max) 部署测试通过
- ✅ 数据库连接和数据插入功能正常
- ✅ Release 模式构建和部署成功
- ✅ 密码管理系统测试通过
- ✅ SSL/非SSL 连接自动切换功能正常
- ✅ 错误处理和密码重置功能测试通过

## 🛡️ 安全性说明

- **密码存储**: 使用 `shared_preferences` 安全存储，不明文保存
- **连接加密**: 优先使用 SSL 加密连接，确保数据传输安全
- **错误处理**: 智能检测连接错误，避免密码泄露
- **权限管理**: 应用只请求必要的网络权限

## 📝 开发历史

- 初始化 Flutter 项目
- 集成 mysql_client 依赖
- 实现 TiDB Cloud 数据库连接
- 添加事件记录功能
- 配置多平台支持
- 完成 iOS 真机部署测试
- 优化网络安全配置
- **新增**: 集成 shared_preferences 依赖
- **新增**: 实现安全的密码管理系统
- **新增**: 添加密码重置和重新配置功能
- **新增**: 智能连接策略 (SSL/非SSL 自动切换)
- **新增**: 改进的错误处理和用户提示
- **新增**: 数据库表索引优化

---

**开发环境**: macOS 15.5, Flutter 3.24.3, Xcode  
**测试设备**: iPhone 12 Pro Max (iOS 18.5)  
**数据库**: TiDB Cloud (MySQL 兼容)  
**最后测试**: 2025年1月 - 所有功能正常运行
