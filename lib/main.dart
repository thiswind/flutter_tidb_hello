import 'package:flutter/material.dart';
import 'package:mysql_client/mysql_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  MySQLConnection? _conn;
  bool _isConnecting = false;
  String _dbStatus = '正在连接数据库...';
  String? _dbPassword;

  @override
  void initState() {
    super.initState();
    _checkPasswordAndInit();
  }

  // 检查密码并初始化
  Future<void> _checkPasswordAndInit() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPassword = prefs.getString('tidb_password');
    
    if (savedPassword == null) {
      // 首次运行，显示密码输入对话框
      await _showPasswordDialog();
    } else {
      // 已有密码，直接使用
      _dbPassword = savedPassword;
      _initDatabase();
    }
  }

  // 显示密码输入对话框
  Future<void> _showPasswordDialog() async {
    final passwordController = TextEditingController();
    
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // 用户必须输入密码
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('TiDB 数据库配置'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('请输入 TiDB 数据库密码：'),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: '数据库密码',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('确认'),
              onPressed: () async {
                final password = passwordController.text.trim();
                if (password.isNotEmpty) {
                  // 保存密码
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('tidb_password', password);
                  
                  _dbPassword = password;
                  
                  // 检查 widget 是否仍然挂载
                  if (mounted) {
                    Navigator.of(context).pop();
                    
                    // 开始数据库连接
                    _initDatabase();
                  }
                } else {
                  // 显示错误提示
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('请输入有效的密码')),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _ensureTableExists() async {
    if (_conn == null) return;

    try {
      // 直接尝试创建表，如果存在则忽略错误
      await _conn!.execute('''
        CREATE TABLE IF NOT EXISTS event_logs (
          id BIGINT AUTO_INCREMENT PRIMARY KEY,
          timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          event_type VARCHAR(50) NOT NULL,
          event_time DATETIME NOT NULL,
          INDEX idx_timestamp (timestamp),
          INDEX idx_event_type (event_type)
        )
      ''');
      
      developer.log('事件日志表已确保存在');
      setState(() {
        _dbStatus = '数据库已就绪';
      });

    } catch (e) {
      developer.log('确保表存在时发生错误: $e');
      setState(() {
        _dbStatus = '表结构检查失败: $e';
      });
      rethrow;
    }
  }

  Future<void> _initDatabase() async {
    if (_dbPassword == null) {
      setState(() {
        _dbStatus = '密码未设置';
      });
      return;
    }

    try {
      setState(() {
        _isConnecting = true;
        _dbStatus = '正在连接到 TiDB Cloud...';
      });

      developer.log('尝试连接到数据库...');
      developer.log('Host: gateway01.eu-central-1.prod.aws.tidbcloud.com');
      developer.log('Port: 4000');
      developer.log('Database: test');

      _conn = await MySQLConnection.createConnection(
        host: "gateway01.eu-central-1.prod.aws.tidbcloud.com",
        port: 4000,
        userName: "3WfrZCWrsZcEjMB.root",
        password: _dbPassword!, // 使用用户输入的密码
        databaseName: "test",
        secure: true, // TiDB Cloud 需要 SSL 连接
      );
      
      developer.log('数据库连接对象已创建，正在尝试连接...');
      await _conn!.connect();
      developer.log('数据库连接成功！');
      
      setState(() {
        _dbStatus = '数据库连接成功，正在检查表结构...';
      });
      
      // 确保表存在且结构正确
      await _ensureTableExists();
      
      developer.log('数据库连接和表结构检查完成');

    } catch (e) {
      developer.log('数据库初始化错误: $e');
      developer.log('错误类型: ${e.runtimeType}');
      
      // 尝试替代连接方法
      if (e.toString().contains('Operation not permitted')) {
        developer.log('检测到权限错误，尝试不使用 SSL 连接...');
        try {
          _conn = await MySQLConnection.createConnection(
            host: "gateway01.eu-central-1.prod.aws.tidbcloud.com",
            port: 4000,
            userName: "3WfrZCWrsZcEjMB.root",
            password: _dbPassword!, // 使用用户输入的密码
            databaseName: "test",
            secure: false, // 尝试不使用 SSL
          );
          
          await _conn!.connect();
          developer.log('使用非 SSL 连接成功！');
          
          setState(() {
            _dbStatus = '数据库连接成功（非SSL），正在检查表结构...';
          });
          
          await _ensureTableExists();
          
        } catch (fallbackError) {
          developer.log('备用连接也失败: $fallbackError');
          setState(() {
            _dbStatus = '数据库连接失败: 密码错误或网络问题';
          });
          _conn = null;
          
          // 密码可能错误，提供重置选项
          _showPasswordResetOption();
        }
      } else {
        setState(() {
          _dbStatus = '数据库连接失败: $e';
        });
        _conn = null;
        
        // 可能是密码错误，提供重置选项
        if (e.toString().contains('Access denied')) {
          _showPasswordResetOption();
        }
      }
    } finally {
      setState(() {
        _isConnecting = false;
      });
    }
  }

  Future<void> _logEvent() async {
    if (_conn == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('数据库未连接')),
        );
      }
      return;
    }

    try {
      final now = DateTime.now();
      await _conn!.execute(
        "INSERT INTO event_logs (event_type, event_time) VALUES (:type, :time)",
        {"type": "button_click", "time": now.toIso8601String()},
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('事件已记录: ${now.toString()}')),
        );
      }
      developer.log('事件已记录到数据库: $now');
      
    } catch (e) {
      developer.log('记录事件错误: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('记录事件失败: $e')),
        );
      }
    }
  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  void dispose() {
    _conn?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            // 新增的日志记录按钮
            ElevatedButton.icon(
              onPressed: _isConnecting || _conn == null ? null : _logEvent,
              icon: const Icon(Icons.event_note),
              label: Text(_isConnecting ? '连接中...' : '记录事件到数据库'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
            const SizedBox(height: 10),
            // 数据库状态显示
            Text(
              _dbStatus,
              style: TextStyle(
                fontSize: 12,
                color: _conn != null ? Colors.green : Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            // 新增：重置密码按钮
            if (_dbPassword != null)
              TextButton.icon(
                onPressed: _showPasswordResetOption,
                icon: const Icon(Icons.settings, size: 16),
                label: const Text('重置数据库密码'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey[600],
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  // 显示密码重置选项
  void _showPasswordResetOption() {
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('连接失败'),
          content: const Text('数据库连接失败，可能是密码错误。是否重新设置密码？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                // 清除保存的密码
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('tidb_password');
                _dbPassword = null;
                // 重新显示密码输入对话框
                await _showPasswordDialog();
              },
              child: const Text('重新设置'),
            ),
          ],
        ),
      );
    }
  }
}
