//
//  IVDeviceTableViewController.swift
//  IotVideoDemo
//
//  Created by ZhaoYong on 2019/12/18.
//  Copyright © 2019 gwell. All rights reserved.
//

import UIKit
import IoTVideo
import IVAccountMgr

class IVDeviceTableViewController: UITableViewController {
    
    var mineDevice: [IVDeviceModel] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return super.numberOfSections(in: tableView)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return super.tableView(tableView, numberOfRowsInSection: section)
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if IoTVideo.sharedInstance.ivToken != nil {
            IVAccountMgr.shared.deviceList { (json, error) in
                if let error = error {
                    showAlert(msg: "\(error)")
                    return
                }
                self.mineDevice = json!.ivArrayDecode(IVDeviceModel.self) as! [IVDeviceModel]
            }
        }
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let segueId = segue.identifier {
            if segueId == "IVMineDeviceTableVC" {
                let vc = segue.destination as! IVMineDeviceTableVC
                vc.dataSource = self.mineDevice
            } else if segueId == "IVLANDeviceTableVC" {
                let vc = segue.destination as! IVLANDeviceTableVC
                vc.mineDeviceId = self.mineDevice.map({($0.did)})
            }
        }
    }
}
