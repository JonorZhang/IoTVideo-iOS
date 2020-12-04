//
//  IVConfigListViewController.swift
//  IVLogger
//
//  Created by Zhang on 2019/9/7.
//  Copyright © 2019 JonorZhang. All rights reserved.
//

import UIKit


class IVConfigListViewController: UITableViewController {

    var dataSource: [Config] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.clearsSelectionOnViewWillAppear = false
        self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dataSource = IVConfigMgr.allConfigs
        tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConfigCell", for: indexPath) as! IVServerConfigCell
        cell.nameLabel?.text = dataSource[indexPath.row].name
        cell.descLabel?.text = "\(dataSource[indexPath.row].key):\(dataSource[indexPath.row].value)"
        cell.enableSwitch.isOn = dataSource[indexPath.row].enable
        return cell
    }
  
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            IVConfigMgr.deleteCfg(dataSource[indexPath.row])
            dataSource.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? IVNewConfigViewController {
            if segue.identifier == "EditConfig", let indexPath = tableView.indexPathForSelectedRow {
                vc.config = dataSource[indexPath.row]
            }
        }
    }
    
}

class IVServerConfigCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var enableSwitch: UISwitch!
    
    @IBAction func enableSwitchChanged(_ sender: UISwitch) {
        IVConfigMgr.enableCfg(nameLabel.text!, sender.isOn)
//        makeToast("修改成功,重启后生效")
    }
    
}
