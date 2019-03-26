//
//  ConnectViewController.swift
//  XYBluetoothKitDemo
//
//  Created by 钟晓跃 on 2019/3/27.
//  Copyright © 2019 钟晓跃. All rights reserved.
//

import UIKit
import XYBluetoothKit

class ConnectViewController: UIViewController {
    
    let centralManager = XYCentralManager.manager
    
    let textView = UITextView.init()
    
    var parser: MYParser?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // UI
        setupUI()
        
        // 连接蓝牙
        connect()

    }
    
    // 断开连接
    @objc func didClickDisconnectBtn(_ sender: UIButton) {
        
        guard let parser = parser else { return }
        centralManager.cancelConnect(parser)
    }
    
}

// MARK: - Bluetooth
extension ConnectViewController {
    
    /// 连接蓝牙
    func connect() {
        
        centralManager.connect(parser!, connectSuccess: { [weak self] (central, peripheral) in
            
            guard let `self` = self else { return }
            
            debugPrint("连接成功")
            
            // 监听蓝牙数据
            self.listenData()
            
            
        }, disConnectHandle: {
            
            debugPrint("断开连接")
        }) { (error) in
            
            debugPrint("连接失败")
        }
        
    }
    
    // 监听数据
    func listenData() {
        
        parser?.listenData({ [weak self] (data) in
            
            guard let `self` = self else { return }
            
            let str = (data as NSData).description
            self.textView.text += (str + "\n")
        })
    }
}

// MARK: - UI
extension ConnectViewController {
    
    func setupUI() {
        
        view.addSubview(textView)
        textView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        let rightItemBtn = UIButton.init()
        rightItemBtn.setTitle("断开连接", for: .normal)
        rightItemBtn.setTitleColor(UIColor(red:0.08, green:0.49, blue:0.98, alpha:1.00), for: .normal)
        rightItemBtn.addTarget(self, action: #selector(didClickDisconnectBtn(_:)), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: rightItemBtn)
        
    }
}
