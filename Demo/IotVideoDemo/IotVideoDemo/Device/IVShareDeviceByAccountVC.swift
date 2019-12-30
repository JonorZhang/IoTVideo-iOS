//
//  IVShareDeviceByAccountVC.swift
//  IotVideoDemo
//
//  Created by ZhaoYong on 2019/12/19.
//  Copyright © 2019 gwell. All rights reserved.
//

import UIKit
import IVAccountMgr
import SwiftyJSON

class IVShareDeviceByAccountVC: UIViewController, IVDeviceAccessable {
    var device: IVDevice!
    @IBOutlet weak var mobileAreaTF: UITextField!
    
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var mobielTF: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print(device ?? "")
    }
    
    @IBAction func emailShare(_ sender: Any) {
        IVAccountMgr.shared.findUserInfo(email: emailTF.text ?? "", responseHandler: { (jsonStr, error) in
            if let error = error {
                showAlert(msg: "\(error)")
                return
            }
            let json = JSON(parseJSON: jsonStr!)
            if let ivUid = json["data"]["ivUid"].string {
                IVAccountMgr.shared.shareDeviceForVisitor(deviceId: self.device.deviceID, accountId: ivUid) { (jsonStr, error) in
                    guard let json = jsonStr else {
                        showAlert(msg: "\(error!)")
                        return
                    }
                    showAlert(msg: "分享成功： \(json)")
                }
            } else {
                showAlert(msg: jsonStr)
            }
        })
//        IVAccountMgr.shared.shareDeviceForVisitor(deviceId:device.deviceId)
    }
    
    
    @IBAction func mobileShare(_ sender: Any) {
        IVAccountMgr.shared.findUserInfo(mobile: mobielTF.text ?? "", mobileArea: mobileAreaTF.text ?? "") { (jsonStr, error) in
            if let error = error {
                showAlert(msg: "\(error)")
                return
            }
            let json = JSON(parseJSON: jsonStr!)
            if let ivUid = json["data"]["ivUid"].string {
                IVAccountMgr.shared.shareDeviceForVisitor(deviceId: self.device.deviceID, accountId: ivUid) { (jsonStr, error) in
                    guard let json = jsonStr else {
                        showAlert(msg: "\(error!)")
                        return
                    }
                    showAlert(msg: "分享成功： \(json)")
                }
            } else {
                showAlert(msg: jsonStr)
            }
        }
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
