//
//  IVQRCodeAddDevice.swift
//  IotVideoDemo
//
//  Created by ZhaoYong on 2019/12/18.
//  Copyright © 2019 gwell. All rights reserved.
//

import UIKit
import IoTVideo.IVQRCodeNetConfig
class IVQRCodeAddDevice: UIViewController {

    @IBOutlet weak var ssidTF: UITextField!
    @IBOutlet weak var pwdTF: UITextField!
    @IBOutlet weak var QRImgView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func createQRCode(_ sender: Any) {
        view.endEditing(true)
      self.QRImgView.image = IVQRCodeNetConfig.createQRCode(withWifiName: ssidTF.text ?? "", wifiPwd: pwdTF.text, netConfigId: "", qrSize: QRImgView.frame.size)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
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
