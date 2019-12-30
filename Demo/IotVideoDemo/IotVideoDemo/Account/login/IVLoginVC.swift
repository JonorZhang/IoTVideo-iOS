//
//  IVLoginVC.swift
//  IotVideoDemo
//
//  Created by ZhaoYong on 2019/12/2.
//  Copyright © 2019 gwell. All rights reserved.
//

import UIKit
import IVAccountMgr
import IoTVideo

let demo_ivTokenKey    = "IOT_VIDEO_DEMO_IVTOKEN"
let demo_accessIdKey   = "IOT_VIDEO_DEMO_ACCESSID"
let demo_expireTimeKey = "IOT_VIDEO_DEMO_EXPIRE_TIME"

class IVLoginVC: UIViewController {    
    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var pwdAccount: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    @IBAction func login(_ sender: Any) {
        IVAccountMgr.shared.login(account: accountTextField.text ?? "", password: pwdAccount.text ?? "") { (json, error) in
            if let error = error {
                self.handleWebCallback(json: json, error: error)
                return
            }
            let model = IVJson.decode(json: json!, type: IVModel<LoginModel>.self)
            if let ivToken = model?.data?.ivToken, let accessId = model?.data?.accessId {
                IoTVideo.sharedInstance.setupToken(ivToken, accessId: accessId)
                let expireTime = model?.data?.expireTime
                UserDefaults.standard.do {
                    $0.set(ivToken, forKey: demo_ivTokenKey)
                    $0.set(accessId, forKey: demo_accessIdKey)
                    $0.set(expireTime, forKey: demo_expireTimeKey)
                }
                self.dismiss(animated: true, completion: nil)
                
            }
        }
    }
    
    @IBAction func resetPwd(_ sender: Any) {
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let id = segue.identifier {
            let vc = segue.destination as! IVRegisterVC
            if id == "register" {
                vc.comeInType = .register
            } else if id == "resetPwd" {
                vc.comeInType = .findBackPwd
            }
        }
    }
    func handleWebCallback(json: String?, error: Error?) {
        if let error = error {
            self.showAlert(msg: "\(error)")
            return
        }
        self.showAlert(msg: json!)
    }
    
    func showAlert(msg: String?) {
        let alert = UIAlertController(title: "请求结果", message: msg, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
}

struct LoginModel: Codable {
    var headUrl: String?
    var nick: String?
    var ivToken: String?
    var accessId: String?
    var expireTime: Int = 0
}

