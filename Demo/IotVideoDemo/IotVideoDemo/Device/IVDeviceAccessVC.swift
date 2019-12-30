//
//  IVPlayerVC.swift
//  IotVideoDemo
//
//  Created by JonorZhang on 2019/12/18.
//  Copyright © 2019 gwell. All rights reserved.
//

import UIKit
import IVAccountMgr

protocol IVDeviceAccessable {
    var device: IVDevice! { get set }
}

class IVDeviceAccessVC: UITableViewController, IVDeviceAccessable {
    var device: IVDevice!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = device.deviceID
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCell") ?? UITableViewCell(style: .default, reuseIdentifier: "InfoCell")
            cell.textLabel?.text = """
                            deviceID:     \(device.deviceID)
                            productID:    \(device.productID)
                            deviceName:   \(device.deviceName)
                            serialNumber: \(device.serialNumber)
                            version:      \(device.version)
                            macAddr:      \(device.macAddr)
                            """
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.textColor = .lightGray
            cell.selectionStyle = .none
            
            return cell
        } else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return  UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 && indexPath.row == 1 { //解绑设备
            let unbind = IVPopupAction(title: "解绑", style: .destructive, handler: {
                IVAccountMgr.shared.deleteDevice(deviceId: self.device.deviceID) { (json, error) in
                    if let error = error {
                        showAlert(msg: "\(error)")
                        return
                    }
                    self.navigationController?.popToRootViewController(animated: true)
                }
            })
            IVPopupView(message: "确认解绑设备？", actions: [unbind, .cancel()]).show()
        }
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if var dstVC = segue.destination as? IVDeviceAccessable {
            dstVC.device = device
        }
    }

}
