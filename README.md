# XYBluetoothKit
一个简单易用的蓝牙库.

## Pods Install

``` pod 'XYBluetoothKit', '~> 1.0.5' ```

## 如何使用

### 1.创建解析器类继承着XYBaseParser并重写reciveData方法，处理接收到的蓝牙数据
```swift
class MyParser: XYBaseParser {

    override func reciveData(data: Data, peripheral: CBPeripheral, characteristic: CBCharacteristic) {
        // 处理接收到的蓝牙数据 data
    }

}
```

### 2.初始化CentralManager
```swift
var centralManager = XYCentralManager.manager
```

### 3.扫描设备
```swift
centralManager.scanWithServices(serviceUUIDStrs: nil, duration: 20, discoveryHandle: { (discovery, name) in
    // discovery 发现的外设对象
}) { (isTimeout) in
    // isTimeout true为扫描超时 false为主动停止扫描
}
```

### 3.连接设备 
```swift
// 创建解析对象
self.parser = MyParser.init(discovery: discovery)
// 连接
centralManager.connect(self.parser, connectSuccess: { (centralManager, peripheral) in
    // 连接成功
}, disConnectHandle: {
    // 断开连接
}) { (error) in
    // 连接失败
}
```

### 4.蓝牙状态监听
```swift
// 蓝牙状态监听
centralManager.centralState { (state) in

    switch state {

    // 未知
    case .unknown:
    // 重置中
    case .resetting:
    // 不支持
    case .unsupported:
    // 未授权
    case .unauthorized:
    // 蓝牙已关闭
    case .poweredOff:
    // 蓝牙已开启
    case .poweredOn:

    }
}

```


### 5.其他功能
```swift

// 写入蓝牙数据
try? self.parser.writeData(Data.init(), characterUUIDStr: "FFF1", isResponse: true)

// 读取特征数据 通过reciveData方法获取读到的数据
try? self.parser.readCharacteristic("FFF1")

// 停止扫描
centralManager.stopScan()

// 断开连接
centralManager.cancelConnect(self.parser)

// 断开所有连接
centralManager.cancelAllConnect()

```

### 6.蓝牙恢复
####据WWDC2013视频介绍,因为内存紧张或其他原因,app在后台被杀掉,系统也会自动帮我们重新启动app进行蓝牙数据传输
AppDelegate.swift
```swift

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
// Override point for customization after application launch.

    // 蓝牙恢复连接 （需要打开蓝牙后台运行开关Background Modes->Uses Bluetooth LE accessories）
    centralManager.restore { [weak self] (discoveryList) in

        guard let `self` = self else {return}

        let discovery = discoveryList[0]
        self.parser = MyParser.init(discovery: discovery)

        centralManager.connect(self.parser, connectSuccess: { (central, peripheral) in
            // 连接成功
        }, disConnectHandle: {
            // 断开连接
        }, failHandle: { (error) in
            // 连接失败
        })
    }

    return true
}

```
