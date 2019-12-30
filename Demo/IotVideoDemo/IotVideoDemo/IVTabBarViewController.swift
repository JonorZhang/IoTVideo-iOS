//
//  IVTabBarViewController.swift
//  IotVideoDemo
//
//  Created by ZhaoYong on 2019/12/3.
//  Copyright © 2019 gwell. All rights reserved.
//

import UIKit
import IoTVideo
import IVAccountMgr
import SwiftyJSON

class IVTabBarViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.hidesBottomBarWhenPushed = true
        let ivToken = UserDefaults.standard.value(forKey: demo_ivTokenKey) as? String
        let accessId = UserDefaults.standard.value(forKey: demo_accessIdKey) as? String
        let expireTime = UserDefaults.standard.value(forKey: demo_expireTimeKey) as? TimeInterval
        if let ivToken = ivToken, let accessId = accessId, let expireTime = expireTime, !ivToken.isEmpty, !accessId.isEmpty {
            IoTVideo.sharedInstance.setupToken(ivToken, accessId: accessId)
            if expireTime - Date().timeIntervalSince1970 < 7 * 24 * 60 * 60 {
                DispatchQueue.global().async {
                    IVAccountMgr.shared.updateIvToken { (json, error) in
                        guard let json = json else {
                            showAlert(msg: "error")
                            return
                        }
                        let newJson = JSON(parseJSON: json)
                        UserDefaults.standard.do {
                            $0.set(newJson["data"]["ivToken"].string, forKey: demo_ivTokenKey)
                            $0.set(newJson["data"]["expireTime"].doubleValue, forKey:demo_expireTimeKey)
                        }
                        IoTVideo.sharedInstance.updateToken(newJson["data"]["ivToken"].string!)
                    }
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //        IoTVideo.sharedInstance.setupToken("010142271C6A0E01B6B84F626600000088BF8A936C85A3E5DF862E1D298FDECDF82E0FAEF9C5AAC21B1F47631242203BABDDE8D10054B143FC47BFE634676C88", accessId: "-9223371598768111613")
        if IoTVideo.sharedInstance.ivToken?.isEmpty ?? true {
            let board = UIStoryboard(name: "Login", bundle: nil)
            let loginVC = board.instantiateViewController(withIdentifier: "LogNav") as! UINavigationController
            loginVC.modalPresentationStyle = .fullScreen
            self.present(loginVC, animated: true, completion: nil)
        } else {
            print("ivToke:",IoTVideo.sharedInstance.ivToken!)
        }

        let window = (UIApplication.shared.delegate as! AppDelegate).window
        window?.addSubview(logAssistant)
        window?.bringSubviewToFront(logAssistant)
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

func showAlert(msg: String?) {
    let alert = UIAlertController(title: "请求结果", message: msg, preferredStyle: .alert)
    let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
    alert.addAction(ok)
    UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
}
