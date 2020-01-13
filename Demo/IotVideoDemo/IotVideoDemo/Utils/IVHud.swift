//
//  IVHud.swift
//  IotVideoDemo
//
//  Created by ZhaoYong on 2020/1/7.
//  Copyright © 2020 gwell. All rights reserved.
//

import UIKit
import MBProgressHUD

func ivHud(_ msg: String?, icon: String? = nil,inView view: UIView? = nil, isMask mask: Bool = false)  {
    guard let showView = view ?? UIApplication.shared.windows.last else {return}
    let hud = MBProgressHUD.showAdded(to: showView, animated: true)
    hud.label.text = msg
    hud.label.numberOfLines = 0
    if let icon = icon {
        hud.customView = UIImageView(image: UIImage(named: icon))
        hud.mode = .customView
    } else {
        hud.mode = .text
    }
    if mask {
        hud.backgroundView.color = UIColor(white: 0, alpha: 0.4)
        hud.isUserInteractionEnabled = true
    } else {
        hud.isUserInteractionEnabled = true
    }
    hud.removeFromSuperViewOnHide = true
    hud.hide(animated: true, afterDelay: 1.5)
}

func ivLoadingHud(_ msg: String? = nil, inView view: UIView? = nil,  isMask mask: Bool = false) -> MBProgressHUD {
    let showView = view ?? UIApplication.shared.keyWindow!
    let hud = MBProgressHUD.showAdded(to: showView, animated: true)
    hud.label.text = msg
    hud.mode = .indeterminate
    if mask {
        hud.backgroundView.color = UIColor(white: 0, alpha: 0.4)
        hud.isUserInteractionEnabled = true
    } else {
        hud.isUserInteractionEnabled = true
    }
    hud.removeFromSuperViewOnHide = true
    return hud
}


extension MBProgressHUD {
    func hide() {
        self.hide(animated: true)
    }
}
