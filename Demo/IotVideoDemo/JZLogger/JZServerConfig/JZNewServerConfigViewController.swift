//
//  JZNewServerConfigViewController.swift
//  JZLogger
//
//  Created by Zhang on 2019/9/7.
//  Copyright © 2019 JonorZhang. All rights reserved.
//

import UIKit

class JZNewServerConfigViewController: UIViewController {
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var configField: UITextView!
    @IBOutlet weak var saveBtn: UIButton!
    
    var config: ServerConfig?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nameField.text = config?.name
        configField.text = config?.config
        
        nameField.delegate = self
        configField.delegate = self
    }

    private func makeToast(_ msg: String) {
        let alert = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
        present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
            alert.dismiss(animated: true)
        })
    }
    
    @IBAction func saveConfigClicked(_ sender: Any) {
        guard let name = nameField.text, !name.isEmpty else {
            makeToast("缺少配置名称")
            return
        }

        guard let cfg = configField.text, !cfg.isEmpty else {
            makeToast("缺少配置内容")
            return
        }

        nameField.resignFirstResponder()
        configField.resignFirstResponder()
        
        if JZServerConfig.existsCfg(name), config?.name != name {
            let alert = UIAlertController(title: nil, message: "已存在名为“\(name)”的配置文件，是否覆盖？", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "覆盖", style: .destructive, handler: { _ in
                let newCfg = ServerConfig(name: name, config: cfg, enable: true)
                JZServerConfig.updateCfg(self.config?.name ?? "", newCfg)
                self.makeToast("覆盖成功,重启后生效")
                DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: {
                    self.navigationController?.popViewController(animated: true)
                })
            }))
            present(alert, animated: true)
        } else {
            let newCfg = ServerConfig(name: name, config: cfg, enable: true)
            JZServerConfig.addCfg(newCfg)
            self.makeToast("保存成功,重启后生效")
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: {
                self.navigationController?.popViewController(animated: true)
            })
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
 

}

extension JZNewServerConfigViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension JZNewServerConfigViewController: UITextViewDelegate {
    
}
