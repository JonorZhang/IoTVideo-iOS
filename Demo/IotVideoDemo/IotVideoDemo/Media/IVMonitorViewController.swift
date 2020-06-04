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
         
    // IVMonitorPlayer
    @IBOutlet var definitionSegment: UISegmentedControl!

    var monitorPlayer: IVMonitorPlayer? {
        get { return player as? IVMonitorPlayer }
        set { player = newValue }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        monitorPlayer = IVMonitorPlayer(deviceId: device.deviceID)
        monitorPlayer?.definition = IVVideoDefinition(rawValue: IVVideoDefinition.RawValue(definitionSegment.selectedSegmentIndex)) ?? .high
    }
    
    @IBAction func definitionSegmentChanged(_ sender: UISegmentedControl) {
        monitorPlayer?.definition = IVVideoDefinition(rawValue: IVVideoDefinition.RawValue(sender.selectedSegmentIndex)) ?? .high
    }
}

class IVMultiMonitorViewController: IVDeviceAccessableVC {
    
    @IBOutlet weak var splitViewBtn: UIBarButtonItem!
    
    @IBOutlet weak var collectionView: UICollectionView!

    var selectMode: Bool = false
    
    var allDevices: [IVDevice] {
        let userDevs = userDeviceList.map { IVDevice($0) }
        return userDevs.isEmpty ? [device] : userDevs
    }
    
    lazy var dataSource: [IVDevice] = [device]

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.allowsMultipleSelection = true
        splitViewBtn.isEnabled = (allDevices.count > 1)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let row = dataSource.firstIndex(where: { $0.deviceID == device.deviceID }) ?? 0
        let idxPath = IndexPath(row: row, section: 0)
        collectionView.scrollToItem(at: idxPath, at: .bottom, animated: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        UIDevice.setOrientation(.portrait)
    }
    
    @IBAction func splitViewClicked(_ sender: Any) {
        if selectMode {
            let newDat = collectionView.indexPathsForSelectedItems?.map({ allDevices[$0.item] }) ?? []
            if newDat.count < 1 || newDat.count > MAX_CONNECTION_NUM {
                IVPopupView(title: newDat.isEmpty ? "请选择至少一台设备" : "最多选择\(MAX_CONNECTION_NUM)台设备").show()
                return
            }

            dataSource = newDat
            splitViewBtn.title = "分屏"
            
            switch dataSource.count {
            case 2, 3:
                UIDevice.setOrientation(.portrait)
            case 4:
                UIDevice.setOrientation(.landscapeLeft)
            default:
                break
            }
        } else {
            dataSource = allDevices
            splitViewBtn.title = "✅"
        }
        selectMode.toggle()
        collectionView.reloadData()
    }
}


extension IVMultiMonitorViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IVMultiMonitorCell", for: indexPath) as! IVMultiMonitorCell
        if selectMode {
            cell.nameLabel.isHidden = false
            cell.nameLabel.text = dataSource[indexPath.row].deviceID
            cell.monitorVC = nil
        } else {
            cell.nameLabel.isHidden = true
            let vc = storyboard?.instantiateViewController(withIdentifier: "IVMonitorViewController") as! IVMonitorViewController
            vc.device = dataSource[indexPath.row]
            cell.monitorVC = vc
        }
        return cell
    }
}


extension IVMultiMonitorViewController: UICollectionViewDelegateFlowLayout {
     
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if selectMode {
            return CGSize(width: collectionView.bounds.width, height: 50)
        } else {
            switch dataSource.count {
            case 2, 3:
                return CGSize(width: collectionView.bounds.width - 1, height: collectionView.bounds.height / CGFloat(dataSource.count) - 1)
            case 4:
                return CGSize(width: collectionView.bounds.width/2 - 1, height: collectionView.bounds.height / 2 - 1)
            default:
                return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
}

class IVMultiMonitorCell: UICollectionViewCell {
    
    lazy var nameLabel = UILabel().then {
        $0.textColor = .darkGray
        $0.textAlignment = .left
        $0.font = .systemFont(ofSize: 15)
        $0.numberOfLines = 0
        $0.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        $0.frame = self.contentView.bounds.offsetBy(dx: 8, dy: 0)
        self.contentView.addSubview($0)
    }
    
    var monitorVC: IVMonitorViewController? {
        didSet {
            oldValue?.view.removeFromSuperview()
            if let vc = monitorVC {
                vc.view!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                vc.view!.frame = self.contentView.bounds
                self.contentView.addSubview(vc.view)
                vc.monitorPlayer?.play()
            }
        }
    }
    
    override var isSelected: Bool {
        didSet {
            backgroundColor = isSelected ? .systemBlue : nil
        }
    }
}

