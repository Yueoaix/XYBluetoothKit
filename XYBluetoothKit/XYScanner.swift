//
//  XYScanner.swift
//  XYBluetoothKit
//
//  Created by zhong on 2018/3/22.
//  Copyright © 2018年 zhong. All rights reserved.
//

import UIKit
import CoreBluetooth

class XYScanner: NSObject {

    var centralManager: CBCentralManager?
    
    // 获取可能被系统蓝牙连接的外设servicesUUID
    var servicesUUIDStrs: [String]?
    
    // 扫描定时器
    private var scanTimer: Timer?
    
    // 发现对象回调
    private var discoveryHandle: XYCentralManager.ScanDiscoveryHandle?
    
    // 扫描完成回调
    private var completeHandle: XYCentralManager.ScanCompleteHandle?

    /// 扫描
    func scanWithDuration(serviceUUIDStrs: [String]?,_ duration: TimeInterval, discoveryHandle: XYCentralManager.ScanDiscoveryHandle?, completeHandle: XYCentralManager.ScanCompleteHandle?) -> Bool {
        
        stopScan()
        scanTimer = Timer.scheduledTimer(timeInterval: duration == 0 ? Double(MAXFLOAT) : duration, target: self, selector: #selector(timeOut), userInfo: nil, repeats: false)
        
        self.servicesUUIDStrs = serviceUUIDStrs
        self.discoveryHandle = discoveryHandle
        self.completeHandle = completeHandle
        
        // key默认值为NO表示不会重复扫描已经发现的设备,如需要不断获取最新的信号强度RSSI所以一般设为YES了
        let scanOption = [CBCentralManagerScanOptionAllowDuplicatesKey : false]
        centralManager?.scanForPeripherals(withServices: nil, options: scanOption)
        
        /// 查找系统蓝牙中符合servicesUUID的蓝牙
        retriveConnectedDiscovery()
        return true
    }
    
    /// 停止扫描
    func stopScan() {
        
        centralManager?.stopScan()
        completeHandle?(scanTimer == nil)
        invalidateTimer()
        completeHandle = nil
        discoveryHandle = nil
    }
    
    /// 获取可能被系统蓝牙连接的外设
    private func retriveConnectedDiscovery() {
        
        let servicesUUIDs = servicesUUIDStrs?.map({ (UUIDStr) -> CBUUID in
            return CBUUID.init(string: UUIDStr)
        })
        
        if let servicesUUIDs = servicesUUIDs, let discoveryHandle = discoveryHandle {
            
            _ = centralManager?.retrieveConnectedPeripherals(withServices: servicesUUIDs).map({ (peripheral) in
                DispatchQueue.main.async {
                    
                    discoveryHandle(XYDiscovery.init(peripheral: peripheral, advertisementData: nil, RSSI: -1),peripheral.name ?? "未知")
                }
            })
        }
    }
    
    @objc private func timeOut() {
        invalidateTimer()
        stopScan()
    }
    
    private func invalidateTimer() {
        scanTimer?.invalidate()
        scanTimer = nil
    }
    
}

// MARK: - CentralManagerDiscoveryDelegate acffa0c1 b9ecb401>
extension XYScanner:CentralManagerDiscoveryDelegate {
    
    func centralManager(_ central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        
        let discovery = XYDiscovery.init(peripheral: peripheral, advertisementData: advertisementData, RSSI: RSSI.intValue)
        
        DispatchQueue.main.async {
            self.discoveryHandle?(discovery,peripheral.name ?? "未知")
        }
    }
}
