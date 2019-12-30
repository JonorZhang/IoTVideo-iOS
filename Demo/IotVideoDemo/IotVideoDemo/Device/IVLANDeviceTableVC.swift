//
//  IVLANDeviceTableVC.swift
//  IotVideoDemo
//
//  Created by JonorZhang on 2019/12/17.
//  Copyright © 2019 gwell. All rights reserved.
//

import UIKit
import IoTVideo.IVLanNetConfig
import IVAccountMgr

class IVLANDeviceTableVC: UITableViewController {

    var mineDeviceId: [String] = []
    var dataSource: [IVLANDevice] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = IVLanNetConfig.getDeviceList()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LANDeviceCell", for: indexPath)
        cell.textLabel?.text = dataSource[indexPath.row].deviceID
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dev = dataSource[indexPath.row]
        let dstVC = UIStoryboard(name: "IVDeviceAccess", bundle: .main).instantiateInitialViewController() as! IVDeviceAccessVC
        if mineDeviceId.contains(dev.deviceID) {
            dstVC.device = IVDevice(deviceID: dev.deviceID, productID: dev.productID, deviceName: "\"\"", serialNumber: dev.serialNumber, version: dev.version, macAddr: dev.macAddr)
            self.navigationController?.pushViewController(dstVC, animated: true)
        } else {
            let alert = UIAlertController(title: "绑定设备", message: "绑定：\(dev.deviceID) 这台设备", preferredStyle: .alert)
            let ok = UIAlertAction(title: "绑定", style: .default) { (_) in
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                IVAccountMgr.shared.addDevice(deviceId: dev.deviceID) { (json, error) in
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    if let error = error {
                        showAlert(msg: "\(error)")
                        return
                    }
                    self.mineDeviceId.append(dev.deviceID)
                    dstVC.device = IVDevice(deviceID: dev.deviceID, productID: dev.productID, deviceName: "\"\"", serialNumber: dev.serialNumber, version: dev.version, macAddr: dev.macAddr)
                    self.navigationController?.pushViewController(dstVC, animated: true)
                }
            }
            let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            let hacking = UIAlertAction(title: "☠️Hacking", style: .destructive) { [weak self](_) in
                if let vc = UIStoryboard(name: "IVDeviceAccess", bundle: .main).instantiateInitialViewController() as? IVDeviceAccessVC {
                    guard let `self` = self else { return }
                    let dev = self.dataSource[indexPath.row]
                    vc.device = IVDevice(deviceID: dev.deviceID, productID: dev.productID, deviceName: "\"\"", serialNumber: dev.serialNumber, version: dev.version, macAddr: dev.macAddr)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            alert.addAction(ok)
            alert.addAction(cancel)
            alert.addAction(hacking)
            self.present(alert, animated: true, completion: nil)
        }
    }

}
