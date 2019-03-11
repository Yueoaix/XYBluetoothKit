//
//  XYParserSession.swift
//  XYBluetoothKit
//
//  Created by zhong on 2018/3/23.
//  Copyright © 2018年 zhong. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol XYParserSession {
    
    // 外设对象
    var peripheral: CBPeripheral { get set }
    
    // 是否已连接
    var isConnected: Bool { get }
    
    // 自动重连次数 -1为无限次 （isAutoReconnect = true 才有效）
    var autoReconnectCount: Int { get set }
    
    // 是否自动重连
    var isAutoReconnect: Bool { get set }

    // 连接成功回调
    var connectSuccess: XYCentralManager.ConnectSuccessHandle? { get set }
    
    // 连接失败回调
    var connectFail: XYCentralManager.ConnectFailHandle? { get set }
    
    // 断开连接回调
    var disConnectd: XYCentralManager.DisConnectHandle? { get set }
    
    /// 设置连接回调
    func connectHandle(successHandle: XYCentralManager.ConnectSuccessHandle?, disConnectHandle: XYCentralManager.DisConnectHandle?, failHandle: XYCentralManager.ConnectFailHandle?)
    
    /// 接受数据
    func reciveData(data:Data, peripheral:CBPeripheral, characteristic:CBCharacteristic)
    
    /// 当发数据到外设的某一个特征值上面,并且响应的类型是CBCharacteristicWriteWithResponse,会走此方法响应发送是否成功
    func didWriteValue(_ peripheral:CBPeripheral,characteristic:CBCharacteristic,error:Error?)
    
    /// 获取外设服务,特征
    func startRetrivePeripheral(_ complete: (() -> Void)?)
    
    /// 读取特征
    func readCharacteristic(_ characterUUIDStr: String) throws
    
    /// 写入数据到外设
    func writeData(_ data: Data, characterUUIDStr: String, isResponse: Bool) throws
    
}
