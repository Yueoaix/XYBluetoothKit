//
//  ScanViewController.swift
//  XYBluetoothKitDemo
//
//  Created by 钟晓跃 on 2019/3/27.
//  Copyright © 2019 钟晓跃. All rights reserved.
//

import UIKit
import SnapKit
import XYBluetoothKit

class ScanViewController: UIViewController {
    
    let centralManager = XYCentralManager.manager
    
    var tableView = UITableView.init()
    
    var discoveryList = [XYDiscovery].init()

    override func viewDidLoad() {
        super.viewDidLoad()

        // UI
        setupUI()
        
        // 监听蓝牙状态
        bluetoothState()
    }
    
    @objc func didClickRefreshBtn(_ sender: UIButton) {
        
        discoveryList.removeAll()
        tableView.reloadData()
        scan()
    }

}

// MARK: - Bluetooth
extension ScanViewController {
    
    func bluetoothState() {
        
        centralManager.centralState { [weak self] (state) in
            
            guard let `self` = self else { return }
            
            switch state {
            case .poweredOff:
                
                self.title = "蓝牙状态:关闭"
            case .poweredOn:
                
                self.title = "蓝牙状态:开启"
                // 扫描
                self.scan()
            case .resetting:
                
                self.title = "蓝牙状态:复位"
            case .unauthorized:
                
                self.title = "蓝牙状态:未授权"
            case .unknown:
                
                self.title = "蓝牙状态:未知"
            case .unsupported:
                
                self.title = "蓝牙状态:设备不支持"
            @unknown default:
                break
            }
        }
    }
    
    func scan() {
        
        centralManager.scanWithServices(serviceUUIDStrs: nil, duration: 20, discoveryHandle: { [weak self] (discovery, name) in
            
            guard let `self` = self else { return }
            self.discoveryList.append(discovery)
            self.tableView.insertRows(at: [IndexPath.init(row: self.discoveryList.count - 1, section: 0)], with: .left)
            
        }) { (isTimeout) in
            
            debugPrint("扫描结束")
        }
    }
    
}

// MARK: - UITableViewDelegate,UITableViewDataSource
extension ScanViewController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return discoveryList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let identifier = "DiscoveryCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        
        if cell == nil {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: identifier)
        }
        
        cell?.textLabel?.text = discoveryList[indexPath.row].name ?? "未知"
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let VC = ConnectViewController.init()
        VC.parser = MYParser.init(discovery: discoveryList[indexPath.row])
        navigationController?.pushViewController(VC, animated: true)
    }
    
}

// MARK: - UI
extension ScanViewController {
    
    func setupUI() {
        
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        let rightItemBtn = UIButton.init()
        rightItemBtn.setTitle("刷新", for: .normal)
        rightItemBtn.setTitleColor(UIColor(red:0.08, green:0.49, blue:0.98, alpha:1.00), for: .normal)
        rightItemBtn.addTarget(self, action: #selector(didClickRefreshBtn(_:)), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: rightItemBtn)
        
    }
    
}
