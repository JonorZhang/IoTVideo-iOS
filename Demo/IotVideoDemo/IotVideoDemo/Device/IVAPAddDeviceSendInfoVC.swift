//
//  IVAPAddDeviceSendInfoVC.swift
//  IotVideoDemoDev
//
//  Created by zhaoyong on 2020/5/20.
//  Copyright © 2020 Tencentcs. All rights reserved.
//

import UIKit
import IoTVideo
import MBProgressHUD
import SwiftyJSON



class IVAPAddDeviceSendInfoVC: UIViewController {

    @IBOutlet weak var deviceInfoLabel: UILabel!
    @IBOutlet weak var currentAPLabel: UILabel!
    @IBOutlet weak var helpView: UIView!
    @IBOutlet weak var sendBtn: UIButton!
    
    var hud: MBProgressHUD?
    var preInfo: APPreInfo!
    var device: IVLANDevice! {
        didSet {
            deviceInfoLabel.text = """
            DeviceId: \(device.deviceID)
            
            Version: \(device.version)
            
            MAC: \(device.macAddr)
            """
        }
    }
    var apInfoGet = false {
        didSet {
            if apInfoGet {
                if let dev = IVNetConfig.lan.getDeviceList().first {
                    device = dev
                    sendBtn.isEnabled = true
                    deviceInfoLabel.isHidden = false
                    helpView.isHidden = true
                } else {
                    sendBtn.isEnabled = false
                    deviceInfoLabel.isHidden = true
                    helpView.isHidden = false
                }
            } else {
                sendBtn.isEnabled = false
                deviceInfoLabel.isHidden = true
                helpView.isHidden = false
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        currentAPLabel.addObserver(self, forKeyPath: "text", options: .new, context: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(getWifiSSIDInfo), name: UIApplication.didBecomeActiveNotification, object: nil)
        getWifiSSIDInfo()
    }
    
    @objc func getWifiSSIDInfo() {
        currentAPLabel.text = IVWifiTool.currentSSID
    }
    
    
    @IBAction func goSysSetting(_ sender: Any) {
        let settingUrl = URL(string: UIApplication.openSettingsURLString)!
        if UIApplication.shared.canOpenURL(settingUrl) {
            UIApplication.shared.openURL(settingUrl)
        }
    }
    
    @IBAction func sendAction(_ sender: Any) {
        let hud = ivLoadingHud("正在发送配网信息",isMask: true)
        IVNetConfig.lan.sendWifiName(preInfo.ssid, wifiPassword: preInfo.pwd, language: .CN, token: preInfo.token, extraInfo: nil, toDevice: self.device.deviceID) { (success, error) in
            logDebug(success, error ?? "")
            hud.hide()
            if success {
                self.registerDeviceNetConfig()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 40) {
                    self.hud?.hide()
                }
                
            } else {
                self.hud?.hide()
                ivHud("发送失败，\(error!)");
            }
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let ap = change?[NSKeyValueChangeKey.newKey] as? String, ap.uppercased().hasPrefix("IOT") {
            apInfoGet = true
        } else {
            apInfoGet = false
        }
    }
    
    func registerDeviceNetConfig() {
        self.hud = ivLoadingHud("等待设备上线", isMask: true)
        IVNetConfig.registerDeviceOnlineCallback { (devId, error) in
            let err: NSError = error as NSError
            self.hud?.hide()
            if err.code == 0 || err.code == 8023 {
                let hud = ivLoadingHud("正在绑定设备", isMask: true)
                IVDemoNetwork.addDevice(devId!, responseHandler: { (data, error) in
                    hud.hide()
                    guard let succ = data as? Bool, error == nil else {return}
                    
                    IVPopupView(title: "添加结果", message: succ ? "成功" : "失败", input: nil, actions: [.iKnow({ (_) in
                        if succ {
                            self.navigationController?.popToRootViewController(animated: true)
                            IVNotiPost(.deviceListChange(by: .add))
                        }
                    })]).show()
                })
            } else {
                showError(error)
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
