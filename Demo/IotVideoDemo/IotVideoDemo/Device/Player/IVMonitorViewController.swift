//
//  IVMonitorViewController.swift
//  IotVideoDemo
//
//  Created by JonorZhang on 2019/12/11.
//  Copyright © 2019 Tencentcs. All rights reserved.
//

import UIKit
import IoTVideo


class IVMonitorViewController: IVDevicePlayerViewController {
        
    var monitorPlayer: IVMonitorPlayer {
        get { return player as! IVMonitorPlayer }
        set { player = newValue }
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        monitorPlayer = IVMonitorPlayer(deviceId: device.deviceID)
    }
}


class IVMultiMonitorViewController: IVDeviceAccessableTVC {
   
    override func viewDidAppear(_ animated: Bool) {
        let section = deviceList.firstIndex(where: { $0.deviceID == device.deviceID }) ?? 0
        tableView.scrollToRow(at: IndexPath(row: 0, section: section), at: .bottom, animated: true)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return deviceList.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MonitorCell", for: indexPath)
        let monitorVC = storyboard?.instantiateViewController(withIdentifier: "IVMonitorViewController") as! IVMonitorViewController
        monitorVC.device = deviceList[indexPath.section]
        addChild(monitorVC)
        cell.contentView.addSubview(monitorVC.view)
        if device.deviceID == monitorVC.device.deviceID {
            monitorVC.monitorPlayer.play()
        }
        return cell
    }
     
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.width * 9 / 16 + 30;
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 8
    }
}
