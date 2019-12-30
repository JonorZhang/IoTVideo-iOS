//
//  IVRegisterVC.swift
//  IotVideoDemo
//
//  Created by ZhaoYong on 2019/12/2.
//  Copyright © 2019 gwell. All rights reserved.
//

import UIKit
import IVAccountMgr

class IVRegisterVC: UIViewController {
    var comeInType: IVAccountCheckCodeType = .register
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var commitButton: UIButton!
    
    @IBOutlet weak var areaCodeTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var phPasswordTextField: UITextField!
    @IBOutlet weak var phVerificationCodeTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        switch comeInType {
        case .register:
            self.title = "注册"
            titleLabel.text = "手机号注册 Phone"
            commitButton.setTitle("注册", for: .normal)
        case .findBackPwd:
            self.title = "重置密码"
            titleLabel.text = "手机号重置 Phone"
            commitButton.setTitle("重置", for: .normal)
        case .sendOneMsg:
            assertionFailure("这个选项错误")
            break
        }
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func phoneNumReg(_ sender: Any) {
        if comeInType == .register { // 注册
            
            //            IVAccountMgr.shared
            //                .registerBy(mobile: phoneNumberTextField.text ?? "",
            //                          mobileArea: areaCodeTextField.text ?? "",
            //                          password: phPasswordTextField.text ?? "",
            //                          verificationCode: phVerificationCodeTextField.text ?? "",
            //                          ivCid: "") { (json, error) in
            //
            //            }
            
            IVAccountMgr.shared
                .register(by: .mobile(phoneNumberTextField.text ?? "", mobileArea: areaCodeTextField.text ?? ""),
                          password: phPasswordTextField.text ?? "",
                          verificationCode: phVerificationCodeTextField.text ?? "")
                { (json, error) in
                    if let error = error {
                        self.handleWebCallback(json: json, error: error)
                        return
                    }
                    self.navigationController?.popViewController(animated: true)
                    
            }
        } else { // 重置
            IVAccountMgr.shared
                .resetPasswordBy(mobile: phoneNumberTextField.text ?? "",
                                 mobileArea: areaCodeTextField.text ?? "",
                                 password: phPasswordTextField.text ?? "",
                                 verificationCode: phVerificationCodeTextField.text ?? "") { (json, error) in
                                    if let error = error {
                                        self.handleWebCallback(json: json, error: error)
                                        return
                                    }
                                    self.navigationController?.popViewController(animated: true)
            }
            
            
        }
    }
    
    @IBAction func sendPhoneVerCode(_ sender: UIButton) {
        //        IVAccountMgr.shareInstance
        //            .getVerificationCode(phoneNumber: phoneNumberTextField.text ?? "",
        //                                 mobileArea: areaCodeTextField.text ?? "",
        //                                 checkType: comeInType) { (json, errpr) in
        sender.isEnabled = false
        IVAccountMgr.shared.getVerificationCode(for: .mobile(phoneNumberTextField.text ?? "", mobileArea: areaCodeTextField.text ?? ""), checkType: comeInType) { (json, error) in
            sender.isEnabled = true
        }
    }
    
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "IVAccountUseEmail" {
            let vc: IVRegisterEmailVC = segue.destination as! IVRegisterEmailVC
            vc.comeInType = self.comeInType
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

struct RegisterJson: Codable {
    var msg: String?
    var data: RegisterModel?
    var code: Int = 0
}

struct RegisterModel: Codable {
    var checkCode: String?
    var ivUid: String?
}
