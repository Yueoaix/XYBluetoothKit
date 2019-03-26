//
//  MYParser.swift
//  XYBluetoothKitDemo
//
//  Created by 钟晓跃 on 2019/3/25.
//  Copyright © 2019年 钟晓跃. All rights reserved.
//

import UIKit
import XYBluetoothKit
import CoreBluetooth

class MYParser: XYBaseParser {
    
    var dataHandle: ((Data) -> Void)?

    override func reciveData(data: Data, peripheral: CBPeripheral, characteristic: CBCharacteristic) {
        
        dataHandle?(data)
    }
    
    func listenData(_ dataHandle: ((Data) -> Void)?) {
        
        self.dataHandle = dataHandle
    }
    
}
