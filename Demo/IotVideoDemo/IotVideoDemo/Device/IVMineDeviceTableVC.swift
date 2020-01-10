//
//  IVMineDeviceTableVC.swift
//  IotVideoDemo
//
//  Created by JonorZhang on 2019/12/18.
//  Copyright © 2019 gwell. All rights reserved.
//

import UIKit
import IVAccountMgr

class IVMineDeviceTableVC: UITableViewController {
    
    var dataSource: [IVDeviceModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.dataSource.count;
    }

  
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                let cell = tableView.dequeueReusableCell(withIdentifier: "MineDeviceCell", for: indexPath)
        cell.textLabel?.text = "did: \(dataSource[indexPath.row].did ?? "???")"
        cell.detailTextLabel?.text = "tid: \(dataSource[indexPath.row].devId ?? "???")"
        let isOnline = (dataSource[indexPath.row].online == true)
        cell.imageView?.image = UIImage(named: isOnline ? "tabBar_icon_device_S" : "tabBar_icon_device_N")
        cell.textLabel?.textColor = isOnline ? UIColor.black : UIColor.gray
        cell.detailTextLabel?.textColor = isOnline ? UIColor.black : UIColor.gray

        return cell
    }
   
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dstVC = segue.destination as? IVDeviceAccessVC,
            let selectedRow = tableView.indexPathForSelectedRow?.row {
            let dev = dataSource[selectedRow]
            dstVC.device = IVDevice(deviceID: dev.did ?? "???",tencentID: dev.devId ?? "???", productID: "", deviceName:dev.deviceName ?? "", serialNumber: "", version: "", macAddr: "")
        }
    }
}



