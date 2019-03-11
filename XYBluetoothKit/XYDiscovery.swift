//
//  XYDiscovery.swift
//  XYBluetoothKit
//
//  Created by zhong on 2018/3/22.
//  Copyright © 2018年 zhong. All rights reserved.
//

import UIKit
import CoreBluetooth

/// 蓝牙扫描对象
public class XYDiscovery: NSObject {
    
    // 外设对象
    @objc public var peripheral: CBPeripheral
    
    // 广播信息
    @objc public var advertisementData: [String : AnyObject]?
    
    // 信号强度
    @objc public var RSSI: Int 
    
    // 设备名称
    @objc public var name: String? {
        return peripheral.name
    }
    
    /// 构造方法
    ///
    /// - Parameters:
    ///   - peripheral: 外设对象
    ///   - advertisementData: 广播信息
    ///   - RSSI: 信号强度
    init(peripheral: CBPeripheral, advertisementData: [String : AnyObject]?, RSSI: Int){
        self.peripheral = peripheral
        self.advertisementData = advertisementData
        self.RSSI = RSSI
        super.init()
    }
    
}
