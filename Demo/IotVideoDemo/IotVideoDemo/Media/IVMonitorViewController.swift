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
    @IBOutlet weak var definitionSegment: UISegmentedControl!
    
    var monitorPlayer: IVMonitorPlayer? {
        get { return player as? IVMonitorPlayer }
        set { player = newValue }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        definitionSegment.selectedSegmentIndex = UserDefaults.standard.integer(forKey: "definitionSegment.selectedSegmentIndex")

        monitorPlayer = IVMonitorPlayer(deviceId: device.deviceID, sourceId: UInt16(self.sourceID))
        monitorPlayer?.definition = IVVideoDefinition(rawValue: IVVideoDefinition.RawValue(definitionSegment.selectedSegmentIndex)) ?? .high
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        monitorPlayer?.play()
    }
    
    @IBAction func definitionSegmentChanged(_ sender: UISegmentedControl) {
        UserDefaults.standard.set(definitionSegment.selectedSegmentIndex, forKey: "definitionSegment.selectedSegmentIndex")
        let defn = IVVideoDefinition(rawValue: IVVideoDefinition.RawValue(sender.selectedSegmentIndex)) ?? .high
        if device.sdkVer.isEmpty {
            IVMessageMgr.sharedInstance.readProperty(ofDevice: device.deviceID, path: "ProConst._versionInfo.sdkVer") { [weak self](json, err) in
                guard let json = json?.replacingOccurrences(of: "\"", with: ""), err == nil else { return }
                self?.device.sdkVer = json
                self?.monitorPlayer?.setVideoDefinition(defn, sdkVer: json)
            }
        } else {
            monitorPlayer?.setVideoDefinition(defn, sdkVer: device.sdkVer)
        }
    }
        
    override func player(_ player: IVPlayer, didUpdate status: IVPlayerStatus) {
        super.player(player, didUpdate: status)
        DispatchQueue.main.async {[weak self] in
            self?.definitionSegment?.isEnabled = (status != .preparing && status != .stopping)
        }
    }
}

extension IVMonitorPlayer {
    
    func setVideoDefinition(_ defn: IVVideoDefinition, sdkVer: String) {
        // 切换清晰度
        self.definition = defn
        
        // ⚠️如果设备端sdkVer版本小于`16.18.4718`需要额外执行stop()再play()
        if sdkVer < "16.18.4718" {
            self.stop()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.play() // 延时是为了防止play先到达设备
            }
        }
    }
}

class IVMultiMonitorViewController: IVDeviceAccessableVC {
    
    @IBOutlet weak var splitViewBtn: UIBarButtonItem!
    
    @IBOutlet weak var collectionView: UICollectionView!

    private var selectMode: Bool = false

    lazy var allDevsSrcs: [(srcId: Int, dev: IVDevice)] = {
        var alldevices = userDeviceList
        if !alldevices.contains(where: { $0.deviceID == device.deviceID }) {
            alldevices.append(device)
        }
        return getDevsSrcs(alldevices)
    }()
        
    lazy var dataSource: [(srcId: Int, dev: IVDevice)] = [(0, device)]

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.allowsMultipleSelection = true
        collectionView.collectionViewLayout.invalidateLayout()
        self.automaticallyAdjustsScrollViewInsets = false
        splitViewBtn.isEnabled = (allDevsSrcs.count > 1)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let row = dataSource.firstIndex(where: { $0.dev.deviceID == device.deviceID }) ?? 0
        let idxPath = IndexPath(row: row, section: 0)
        collectionView.scrollToItem(at: idxPath, at: .bottom, animated: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        UIDevice.setOrientation(.portrait)
    }
    
    func getDevsSrcs(_ devs: [IVDevice]) -> [(srcId: Int, dev: IVDevice)] {
        var devsrcs: [(srcId: Int, dev: IVDevice)] = []
        for dev in devs {
            for srcIdx in 0 ..< dev.sourceNum {
                devsrcs.append((srcId: srcIdx, dev: dev))
            }
        }
        return devsrcs
    }

    @IBAction func splitViewClicked(_ sender: Any) {
        if selectMode {
            let seldevsrcs = collectionView.indexPathsForSelectedItems?.map({ allDevsSrcs[$0.item] }) ?? []
            if seldevsrcs.count < 1 || seldevsrcs.count > 8 {
                IVPopupView(title: seldevsrcs.isEmpty ? "请选择至少一个设备(源)" : "最多选择8个设备(源)").show()
                return
            }

            dataSource = seldevsrcs.sorted(by: { $0.srcId < $1.srcId })
            splitViewBtn.title = "分屏"
        
            let ori: UIDeviceOrientation = dataSource.count > 3 ? .landscapeLeft : .portrait
            UIDevice.setOrientation(ori)
        } else {
            dataSource = allDevsSrcs
            splitViewBtn.title = "✅"
        }
        
        selectMode.toggle()
        collectionView.reloadData()
        collectionView.collectionViewLayout.invalidateLayout()
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
            cell.nameLabel.text = dataSource[indexPath.row].dev.deviceID + "_\(dataSource[indexPath.row].srcId)"
            cell.monitorVC = nil
        } else {
            cell.nameLabel.isHidden = true
            let vc = storyboard?.instantiateViewController(withIdentifier: "IVMonitorViewController") as! IVMonitorViewController
            vc.device = dataSource[indexPath.row].dev
            vc.sourceID = dataSource[indexPath.row].srcId
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
            let splitCols = (dataSource.count < 4 ? 1 : 2)
            let roundNum = round(CGFloat(dataSource.count) / CGFloat(splitCols))
            if collectionView.bounds.height > collectionView.bounds.width {
                return CGSize(width: collectionView.bounds.width / CGFloat(splitCols) - (dataSource.count > 3 ? 1 : 0),
                              height: collectionView.bounds.height / roundNum - (dataSource.count > 1 ? 1 : 0))
            } else {
                return CGSize(width: collectionView.bounds.width / roundNum - (dataSource.count > 1 ? 1 : 0),
                              height: collectionView.bounds.height / CGFloat(splitCols) - (dataSource.count > 3 ? 1 : 0))
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
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
//                vc.monitorPlayer?.play()
            }
        }
    }
    
    override var isSelected: Bool {
        didSet {
            backgroundColor = isSelected ? .systemBlue : nil
        }
    }
}

