//
//  IVRegisterEmailVC.swift
//  IotVideoDemo
//
//  Created by ZhaoYong on 2019/12/3.
//  Copyright © 2019 gwell. All rights reserved.
//

import UIKit
import IVAccountMgr

class IVRegisterEmailVC: UIViewController {
    var comeInType: IVAccountCheckCodeType = .register
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var commitButton: UIButton!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailPasswordTextfiled: UITextField!
    @IBOutlet weak var emailVerificationCodeTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        switch comeInType {
        case .register:
            self.title = "注册"
            titleLabel.text = "邮箱注册 Email"
            commitButton.setTitle("注册", for: .normal)
        case .findBackPwd:
            self.title = "重置密码"
            titleLabel.text = "邮箱重置 Email"
            commitButton.setTitle("重置", for: .normal)
        case .sendOneMsg:
            assertionFailure("这个选项错误")
            break
        }
    }
    
    @IBAction func emailReg(_ sender: Any) {
        if comeInType == .register { //注册
            //            IVAccountMgr.shared
            //                .registerBy(email: emailTextField.text ?? "",
            //                          password: emailPasswordTextfiled.text ?? "",
            //                          verificationCode: emailVerificationCodeTextField.text ?? "") { (json, error) in
            //
            //            }
            
            IVAccountMgr.shared.register(by: .email(emailTextField.text ?? ""),
                                         password: emailPasswordTextfiled.text ?? "",
                                         verificationCode: emailVerificationCodeTextField.text ?? "")
            { (json, error) in
                if let error = error {
                    self.handleWebCallback(json: json, error: error)
                }
                self.navigationController?.popToRootViewController(animated: true)
                
            }
        } else { // 重置
            IVAccountMgr.shared
                .resetPasswordBy(email: emailTextField.text ?? "",
                                 password: emailPasswordTextfiled.text ?? "",
                                 verificationCode: emailVerificationCodeTextField.text ?? "") { (json, error) in
                                    if let error = error {
                                        self.handleWebCallback(json: json, error: error)
                                    }
                                    self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    
    @IBAction func sendEmailVerCode(_ sender: UIButton) {
        sender.isEnabled = false
        IVAccountMgr.shared.getVerificationCode(for: .email(emailTextField.text ?? ""), checkType: comeInType) { (json, error) in
            sender.isEnabled = true
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
