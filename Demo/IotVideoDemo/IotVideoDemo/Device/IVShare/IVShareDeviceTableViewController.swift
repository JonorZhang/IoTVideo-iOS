//
//  IVShareDeviceTableViewController.swift
//  IotVideoDemo
//
//  Created by ZhaoYong on 2019/12/19.
//  Copyright © 2019 gwell. All rights reserved.
//

import UIKit


class IVShareDeviceTableViewController: UITableViewController, IVDeviceAccessable {
    var device: IVDevice!
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if var dstVC = segue.destination as? IVDeviceAccessable {
            dstVC.device = device
        }
    }

}
