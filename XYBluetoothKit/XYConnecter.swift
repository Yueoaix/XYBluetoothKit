//
//  XYConnecter.swift
//  XYBluetoothKit
//
//  Created by zhong on 2018/3/22.
//  Copyright © 2018年 zhong. All rights reserved.
//

import UIKit
import CoreBluetooth

class XYConnecter: NSObject {
    
    var centralManager: CBCentralManager?
    
    // 弱引用字典
    var parserDic = NSMapTable<CBPeripheral, XYBaseParser>.init(keyOptions: NSPointerFunctions.Options.weakMemory, valueOptions: NSPointerFunctions.Options.weakMemory)
    
    // 连接
    func connect(_ parser:XYBaseParser) -> Bool {
        
        if !parser.isConnected {
            
            parserDic.setObject(parser, forKey: parser.peripheral)
            centralManager?.connect(parser.peripheral, options: nil)
            return true
        }
        
        return false
    }
    
    // 断开连接
    func disConnect(peripheral: CBPeripheral) {
        
        if let parser = parserDic.object(forKey: peripheral) {
            
            //取消自动重连
            parser.isAutoReconnect = false
            
            //主动断开连接不会走代理方法
            DispatchQueue.main.async {
                parser.disConnectd?()
            }
        }
        
        centralManager?.cancelPeripheralConnection(peripheral)
        parserDic.removeObject(forKey: peripheral)
        
    }
    
    // 断开所有连接
    func cancelAllConnect() {
        
        let keys = parserDic.keyEnumerator().allObjects as! [CBPeripheral]
        
        for key in keys {
            disConnect(peripheral: key)
        }
    }
    
}

extension XYConnecter: CentralManagerConnectionDelegate {
    
    /// 连接成功
    func centralManager(_ central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        
        guard let parser = parserDic.object(forKey: peripheral),let centralManager = self.centralManager else { return }
        
        parser.peripheral = peripheral
        parser.startRetrivePeripheral {
            
            DispatchQueue.main.async(execute: {
                parser.connectSuccess?(centralManager,peripheral)
            })
        }
    }
    
    /// 连接失败
    func centralManager(_ central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        
        guard let parser = parserDic.object(forKey: peripheral) else { return }
        
        parser.connectFail?(error)
        if parser.autoReconnectCount == -1 || parser.autoReconnectCount > 0 {
            if parser.isAutoReconnect {
                centralManager?.connect(parser.peripheral, options: nil)
                parser.autoReconnectCount -= 1
            }
        }else{
            parserDic.removeObject(forKey: peripheral)
        }
    }
    
    /// 断开连接
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        guard let parser = parserDic.object(forKey: peripheral) else { return }
        
        if parser.autoReconnectCount == -1 || parser.autoReconnectCount > 0 {
            
            if parser.isAutoReconnect {
                
                centralManager?.connect(parser.peripheral, options: nil)
                parser.autoReconnectCount -= 1
            }
        }else{
            parserDic.removeObject(forKey: peripheral)
        }
        
        DispatchQueue.main.async {
            parser.disConnectd?()
        }
    }
    
}
