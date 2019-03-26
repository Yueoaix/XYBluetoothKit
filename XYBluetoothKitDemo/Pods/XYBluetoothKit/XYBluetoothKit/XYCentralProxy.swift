//
//  XYCentralProxy.swift
//  XYBluetoothKit
//
//  Created by zhong on 2018/3/22.
//  Copyright © 2018年 zhong. All rights reserved.
//

import UIKit
import CoreBluetooth

protocol CentralManagerStateDelegate: class {
    func centralManagerDidUpdateState(_ central: CBCentralManager)
}

protocol CentralManagerRestoreStateDelegate: class {
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any])
}

protocol CentralManagerDiscoveryDelegate: class {
    func centralManager(_ central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber)
}

protocol CentralManagerConnectionDelegate: class {
    func centralManager(_ central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral)
    func centralManager(_ central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?)
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?)
}

class XYCentralProxy: NSObject,CBCentralManagerDelegate {
    
    weak var stateDelegate: CentralManagerStateDelegate?
    weak var restoreStateDelegate: CentralManagerRestoreStateDelegate?
    weak var discoveryDelegate: CentralManagerDiscoveryDelegate?
    weak var connectionDelegate: CentralManagerConnectionDelegate?
    
    init(stateDelegate: CentralManagerStateDelegate?,
         restoreStateDelegate: CentralManagerRestoreStateDelegate?,discoveryDelegate: CentralManagerDiscoveryDelegate?, connectionDelegate: CentralManagerConnectionDelegate?) {
        
        self.stateDelegate = stateDelegate
        self.discoveryDelegate = discoveryDelegate
        self.connectionDelegate = connectionDelegate
        super.init()
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        stateDelegate?.centralManagerDidUpdateState(central)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        discoveryDelegate?.centralManager(central, didDiscoverPeripheral: peripheral, advertisementData: advertisementData as [String : AnyObject], RSSI: RSSI)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        connectionDelegate?.centralManager(central, didConnectPeripheral: peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        
        connectionDelegate?.centralManager(central, didFailToConnectPeripheral: peripheral, error: error as NSError?)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
        connectionDelegate?.centralManager(central, didDisconnectPeripheral: peripheral, error: error as NSError?)
    }
    
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        
        restoreStateDelegate?.centralManager(central, willRestoreState: dict)
    }

}
