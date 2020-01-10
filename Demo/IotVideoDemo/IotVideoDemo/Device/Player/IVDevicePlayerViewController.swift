//
//  IVDevicePlayerViewController.swift
//  IotVideoDemo
//
//  Created by JonorZhang on 2019/12/25.
//  Copyright © 2019 gwell. All rights reserved.
//

import UIKit
import IoTVideo

class IVDevicePlayerViewController: UIViewController, IVDeviceAccessable {
    var device: IVDevice!
    var player: IVPlayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(stopPlayerIfNeed), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(stopPlayerIfNeed), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(stopPlayerIfNeed), name: UIApplication.willTerminateNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func stopPlayerIfNeed() {
        if player.status != .stoped {
            player.stop()
        }
    }
}


class MyViewController: UIViewController, IVMessageDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        IVMessageMgr.sharedInstance.delegate = self
    }
    
    func didReceiveEvent(_ event: String, topic: String) {
        logInfo(event, topic)
    }
    
    func didUpdateStatus(_ json: String, path: String, deviceId: String) {
        logInfo(json, path, deviceId)
    }
}
