//
//  XYBaseParser.swift
//  XYBluetoothKit
//
//  Created by zhong on 2018/3/24.
//  Copyright © 2018年 zhong. All rights reserved.
//

import UIKit
import CoreBluetooth

/// 异常
public enum XYBluetoothParserError: Error {
    // 写入特征有误
    case wrongCharacterUUIDStr
}

/// 解析器基类
open class XYBaseParser:NSObject, XYParserSession {
    
    // 重连次数 -1为无限次
    public var autoReconnectCount: Int = -1
    
    // 是否自动重连
    public var isAutoReconnect = false
    
    // 是否已连接
    public var isConnected: Bool {
        return peripheral.state == CBPeripheralState.connected
    }
    
    // 外设对象
    public var peripheral: CBPeripheral
    
    // 连接成功回调
    public var connectSuccess: XYCentralManager.ConnectSuccessHandle?
    
    // 连接失败回调
    public var connectFail: XYCentralManager.ConnectFailHandle?
    
    // 断开连接回调
    public var disConnectd: XYCentralManager.DisConnectHandle?
    
    public var containCharacteristics = [CBCharacteristic].init()
    
    public var retriveServiceIndex = 0
    
    public var completeHandle: (() -> Void)?
    
    /// 初始化
    @objc public init(discovery: XYDiscovery) {
        self.peripheral = discovery.peripheral
        super.init()
    }
    
    /// 设置连接回调
    @objc public func connectHandle(successHandle: XYCentralManager.ConnectSuccessHandle?, disConnectHandle: XYCentralManager.DisConnectHandle?, failHandle: XYCentralManager.ConnectFailHandle?) {
        
        self.connectSuccess = successHandle
        self.connectFail = failHandle
        self.disConnectd = disConnectHandle
    }
    
    /// 接受数据
    @objc open func reciveData(data:Data, peripheral:CBPeripheral, characteristic:CBCharacteristic){
    }
    
    /// 当发数据到外设的某一个特征值上面,并且响应的类型是CBCharacteristicWriteWithResponse,会走此方法响应发送是否成功
    @objc open func didWriteValue(_ peripheral:CBPeripheral,characteristic:CBCharacteristic,error:Error?) {
        
    }
    
    /// 开始获取外设服务,特征
    ///
    /// - Parameter complete: 获取完成回调
    @objc public func startRetrivePeripheral(_ complete: (() -> Void)?) {
        containCharacteristics.removeAll()
        retriveServiceIndex = 0
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        completeHandle = complete
    }
    
    /// 读特征
    ///
    /// - Parameter characterUUIDStr: UUID
    /// - Throws: 未发现UUID对应特征
    @objc public func readCharacteristic(_ characterUUIDStr: String) throws {
        
        do {
            
            let characteristics = try prepareForAction(characterUUIDStr)
            peripheral.readValue(for: characteristics)
            
        } catch let error {
            throw error
        }
    }
    
    /// 写入数据
    ///
    /// - Parameters:
    ///   - data: 数据
    ///   - characterUUIDStr: UUID
    ///   - withResponse: 是否有响应
    /// - Throws: 未发现UUID对应特征
    @objc public func writeData(_ data: Data, characterUUIDStr: String, isResponse: Bool) throws {
        
        do {
            
            let characteristics = try prepareForAction(characterUUIDStr)
            let type: CBCharacteristicWriteType = isResponse ? .withResponse : .withoutResponse
            peripheral.writeValue(data, for: characteristics, type: type)
            
        } catch let error {
            throw error
        }
    }

    /// 获取特征对象
    ///
    /// - Parameter UUIDStr: UUID
    /// - Returns: 特征对象
    /// - Throws: 未发现UUID对应特征
    func prepareForAction(_ UUIDStr: String) throws -> CBCharacteristic {

        let results = containCharacteristics.compactMap { (characteristic) -> CBCharacteristic? in
            if characteristic.uuid.uuidString.lowercased().hasPrefix(UUIDStr.lowercased()) {
                return characteristic
            }
            return nil
        }
        
        if results.count > 0 ,let characteristic = results.first {
            return characteristic
        }
        throw XYBluetoothParserError.wrongCharacterUUIDStr
    }
    
    deinit {
        XYCentralManager.manager.cancelConnect(self)
        print("[Release: ]" + self.classForCoder.description())
    }
}

// MARK: - CBPeripheralDelegate
extension XYBaseParser:CBPeripheralDelegate {
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        _ = services.map({ (service) in
            peripheral.discoverCharacteristics(nil, for: service)
        })
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        _ = characteristics.map { (characteristic) in
            self.containCharacteristics.append(characteristic)

            if (characteristic.properties.rawValue & 16 == 16) {
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
        
        retriveServiceIndex += 1
        
        if retriveServiceIndex == peripheral.services?.count {
            
            //已获取全部特征
            completeHandle?()
            completeHandle = nil
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        guard let value = characteristic.value else { return }
        
        DispatchQueue.main.async {
            self.reciveData(data: value, peripheral: peripheral, characteristic: characteristic)
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        
        didWriteValue(peripheral, characteristic: characteristic, error: error)
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
    }
}
