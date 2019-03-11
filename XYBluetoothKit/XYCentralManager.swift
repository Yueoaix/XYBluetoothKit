//
//  XYCentralManager.swift
//  XYBluetoothKit
//
//  Created by zhong on 2018/3/22.
//  Copyright © 2018年 zhong. All rights reserved.
//

import UIKit
import CoreBluetooth

/// 蓝牙中心端管理类
public class XYCentralManager: NSObject {
    
    // 扫描发现设备block 类型
    public typealias ScanDiscoveryHandle = ((_ discovery: XYDiscovery,_ name: String) -> Void)
    
    // 扫描完成block 类型
    public typealias ScanCompleteHandle = ((_ isTimeOut:Bool) -> Void)
    
    // 连接成功Block 类型
    public typealias ConnectSuccessHandle = ((_ central: CBCentralManager, _ peripheral: CBPeripheral) -> Void)
    
    // 断开连接Block 类型
    public typealias DisConnectHandle = (() -> Void)
    
    // 连接失败Block 类型
    public typealias ConnectFailHandle = ((_ error: NSError?) -> Void)
    
    // swift单例对象
    public static let manager = XYCentralManager.init()
    
    // 恢复蓝牙连接标识
    public static var XYRestoreIdentifier = "XYRestoreIdentifier"
    
    /// OC单例对象
    ///
    /// - Returns: XYCentralManager对象
    @objc public class func managerInstance() -> XYCentralManager
    {
        return XYCentralManager.manager
    }
    
    private override init() {
        super.init()
        _ = centerManager
    }
    
    // 恢复外设连接Block
    @objc public var restoreStateHandle: (([XYDiscovery]) -> Void)?
    
    // 获取设备蓝牙状态值
    @objc public var centralState:CBCentralManagerState {
        get {
            
            return CBCentralManagerState.init(rawValue: centerManager.state.rawValue) ?? .unknown
        }
    }
    
    // CBCentralManager对象
    @objc public lazy var centerManager:CBCentralManager = {
        let bleQueue = DispatchQueue(label: "com.zhong.XYBluetoothKit", attributes: [])
        var centerManager = CBCentralManager.init(delegate: self.centralProxy, queue: bleQueue, options: [CBCentralManagerOptionShowPowerAlertKey : true,CBCentralManagerOptionRestoreIdentifierKey:XYCentralManager.XYRestoreIdentifier])
        return centerManager
    }()
    
    // centralManager代理者
    lazy var centralProxy:XYCentralProxy = {
        return XYCentralProxy.init(stateDelegate: self, restoreStateDelegate: self, discoveryDelegate: self.scanner, connectionDelegate: self.connecter)
    }()
    
    // 扫描对象
    private lazy var scanner:XYScanner = {
        let scanner = XYScanner.init()
       return scanner
    }()
    
    // 连接对象
    private lazy var connecter:XYConnecter = {
        let connecter = XYConnecter.init()
        return connecter
    }()
    
    /// 重新设置代理
    @objc public func resetDelegate() {
        centerManager.delegate = centralProxy
    }
    
    // 设备蓝牙状态监听Block
    private var centralStateHandle: ((_ state: CBCentralManagerState) -> Void)?
    
    /// 监听蓝牙状态
    ///
    /// - Parameter centralStateHandle: 蓝牙状态回调
    @objc public func centralState(_ centralStateHandle: ((_ state: CBCentralManagerState) -> Void)?) {
        self.centralStateHandle = centralStateHandle
    }
    
    /// 扫描蓝牙设备
    ///
    /// - Parameters:
    ///   - serviceUUIDStrs: 查找被系统连接的蓝牙的serviceUUID (手环配对后有可能被系统自动连接 不传"180F"扫描不到被系统连接的蓝牙)
    ///   - duration: 扫描时间 0为不限制时间
    ///   - discoveryHandle: 发现设备回调
    ///   - completeHandle: 扫描结束回调
    @objc public func scanWithServices(serviceUUIDStrs: [String]?, duration: TimeInterval, discoveryHandle: ScanDiscoveryHandle?, completeHandle: ScanCompleteHandle?) {
        scanner.centralManager = centerManager
        _ = scanner.scanWithDuration(serviceUUIDStrs:serviceUUIDStrs, duration, discoveryHandle: discoveryHandle, completeHandle: completeHandle)
    }
    
    /// 停止扫描
    @objc public func stopScan() {
        scanner.stopScan()
    }
    
    /// 连接
    ///
    /// - Parameters:
    ///   - parser: 需要连接的parser对象
    ///   - connectSuccess: 连接成功回调
    ///   - disConnectHandle: 断开连接回调
    ///   - failHandle: 连接失败回调
    @objc public func connect(_ parser:XYBaseParser, connectSuccess: ConnectSuccessHandle?,disConnectHandle:DisConnectHandle?, failHandle: ConnectFailHandle?) {
        
        parser.connectSuccess = connectSuccess
        parser.disConnectd = disConnectHandle
        parser.connectFail = failHandle
        connecter.centralManager = centerManager
        _ = connecter.connect(parser)
        
    }
    
    /// 连接
    ///
    /// - Parameter parser: 需要连接的parser对象
    @objc public func connect(_ parser:XYBaseParser) {
        
        connecter.centralManager = centerManager
        _ = connecter.connect(parser)
    }
    
    
    /// 断开连接
    ///
    /// - Parameter parser: 需要断开连接的parser对象
    @objc public func cancelConnect(_ parser:XYBaseParser) {
        connecter.disConnect(peripheral: parser.peripheral)
    }
    
    /// 断开所有连接
    @objc public func cancelAllConnect() {
        connecter.cancelAllConnect()
    }
    
    /// 恢复蓝牙连接
    ///
    /// - Parameter restoreStateHandle: 应用重新启动时回调Block
    @objc public func restore(restoreStateHandle: @escaping (([XYDiscovery]) -> Void)) {
        
        self.restoreStateHandle = restoreStateHandle
        
    }
}

// MARK: - CentralManagerStateDelegate
extension XYCentralManager: CentralManagerStateDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        DispatchQueue.main.async {
            self.centralStateHandle?(CBCentralManagerState.init(rawValue: central.state.rawValue)!)
        }
    }
    
}

extension XYCentralManager: CentralManagerRestoreStateDelegate {
    
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        
        var discoveryList = [XYDiscovery].init()
        
        if let peripheralList = dict[CBCentralManagerRestoredStatePeripheralsKey] as? [CBPeripheral],peripheralList.count > 0 {
            
            for peripheral in peripheralList {
                
                discoveryList.append(XYDiscovery.init(peripheral: peripheral, advertisementData: nil, RSSI: 0))
            }
        }
        
        if discoveryList.count > 0 {
            
            DispatchQueue.main.async {
                self.restoreStateHandle?(discoveryList)
            }
        }
        
    }
    
}
