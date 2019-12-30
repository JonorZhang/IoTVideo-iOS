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
//        IVAccountMgr.shared.deviceList { (json, error) in
//            if let error = error {
//                showAlert(msg: "\(error)")
//                return
//            }
//            let modelArr = json!.ivArrayDecode(IVDeviceModel.self)
//            self.dataSource = modelArr as! [IVDeviceModel]
//        }
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
        cell.textLabel?.text = "\(dataSource[indexPath.row].did)"
        return cell
    }
   
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let dstVC = segue.destination as? IVDeviceAccessVC,
            let selectedRow = tableView.indexPathForSelectedRow?.row {
            let dev = dataSource[selectedRow]
            dstVC.device = IVDevice(deviceID: dev.did, productID: "", deviceName:"", serialNumber: "", version: "", macAddr: "")
        }
    }
}



