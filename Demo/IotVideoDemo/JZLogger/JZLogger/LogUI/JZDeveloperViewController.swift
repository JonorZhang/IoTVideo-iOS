//
//  JZDeveloperViewController.swift
//  JZLogger
//
//  Created by JonorZhang on 2019/9/6.
//  Copyright © 2019 JonorZhang. All rights reserved.
//

import UIKit

func makeToast(_ msg: String) {
    let alert = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
    IVLogAssistant.shared.rootViewController?.present(alert, animated: true)
    DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
        alert.dismiss(animated: true)
    })
}

class JZDeveloperViewController: UITableViewController {
      
    override func viewDidLoad() {
        super.viewDidLoad()
    }
        
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if cell?.reuseIdentifier == "Minimize" {
            IVLogAssistant.shared.minimize()
        } else if cell?.reuseIdentifier == "Suspend" {
            IVLogAssistant.shared.suspend(content: .url(JZFileLogger.shared.currLogFileURL))
        }
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case let vc as JZFileLogListTableViewController:
            vc.dataSource = JZFileLogger.shared.getAllFileURLs()
        default:
            break
        }
    }
    
    deinit {
        print(#function, "JZDeveloperViewController")
    }
}
