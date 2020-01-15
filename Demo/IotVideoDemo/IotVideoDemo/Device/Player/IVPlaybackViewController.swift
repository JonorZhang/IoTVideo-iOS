//
//  IVPlaybackViewController.swift
//  IotVideoDemo
//
//  Created by JonorZhang on 2019/12/11.
//  Copyright © 2019 gwell. All rights reserved.
//

import UIKit
import IoTVideo
import Photos

class IVPlaybackViewController: IVDevicePlayerViewController {
    
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var speakerBtn: UIButton!
    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet weak var screenshotBtn: UIButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var timelineView: IVTimelineView?
    
    var playbackList: [IVPlaybackItem] = [] {
        didSet {
            timelineView?.items = [playbackList.map({ IVTimelineItem(startTime: $0.startTime,
                                                                     duration: $0.endTime-$0.startTime,
                                                                     color: .random) })]
        }
    }
    
    var playbackPlayer: IVPlaybackPlayer {
        get { return player as! IVPlaybackPlayer }
        set { player = newValue }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playbackPlayer = IVPlaybackPlayer(deviceId: device.deviceID, playbackItem: nil)
        playbackPlayer.delegate = self
        playbackPlayer.videoView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        playbackPlayer.videoView!.frame = videoView.bounds
        videoView.autoresizesSubviews = true
        videoView.insertSubview(playbackPlayer.videoView!, at: 0)
        
        IVPlaybackPlayer.getPlaybackList(ofDevice: device.deviceID, pageIndex: 0, countPerPage: 50, startTime: 0, endTime: Date().timeIntervalSince1970, completionHandler: { (page, err) in
            guard let items = page?.items else {
                logError(err as Any)
                return
            }
            self.playbackList += items
        })

        timelineView?.didSelectItemCallback = didSelectItemCallback

//        timelineView?.items = [
//            [
//                IVTimelineItem(),
//                IVTimelineItem(),
//                IVTimelineItem(),
//                IVTimelineItem(),
//                IVTimelineItem()
//            ],
//            [
//                IVTimelineItem(),
//                IVTimelineItem(),
//                IVTimelineItem(),
//                IVTimelineItem(),
//                IVTimelineItem(),
//                IVTimelineItem(),
//                IVTimelineItem(),
//                IVTimelineItem(),
//                IVTimelineItem(),
//                IVTimelineItem()
//            ],
//            [
//                IVTimelineItem(),
//                IVTimelineItem(),
//                IVTimelineItem()
//            ]
//        ]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AppDelegate.shared.allowRotation = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AppDelegate.shared.allowRotation = false
        UIDevice.setOrientation(.portrait)
        playbackPlayer.stop()
    }

//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        playbackPlayer.videoView?.frame = videoView.bounds
//    }

    deinit {
        print(self.classForCoder, #function)
    }

    // MARK: - 点击事件

    func didSelectItemCallback(_ item: IVTimelineItem) {
        if playbackPlayer.status != .stoped {
            playbackPlayer.stop()
        }
        let playbackItem = playbackList.first(where: { $0.startTime == item.startTime })
        playbackPlayer.playbackItem = playbackItem
        playbackPlayer.play()        
    }
    
    @IBAction func playClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            playbackPlayer.play()
        } else {
            playbackPlayer.pause()
        }
    }
    
    @IBAction func speakerClicked(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        playbackPlayer.mute = sender.isSelected
    }
    
    @IBAction func recordClicked(_ sender: UIButton) {
        if sender.isSelected {
            playbackPlayer.stopRecord()
        } else {
            let docPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            let mp4Path = docPath + "/hahaha.mp4"
            playbackPlayer.startRecord(mp4Path) { (savePath, error) in
                guard let savePath = savePath else {
                    print("录像失败", error as Any)
                    return
                }
                print("录像成功", savePath)
                let url = URL(fileURLWithPath: savePath)
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
                }) { (success, error) in
                    guard success == true else {
                        print("视频保存到相册失败", error as Any)
                        return
                    }
                    print("视频保存到相册成功", url)
                }
            }
        }
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func screenshotClicked(_ sender: UIButton) {
        playbackPlayer.takeScreenshot({ (image) in
            guard let image = image else { return }
            DispatchQueue.main.sync {
                let imgW: CGFloat = 150
                let imgH = imgW / image.size.width * image.size.height
                let imgVrect = CGRect(x: 8, y: self.videoView.bounds.size.height - imgH - 8, width: imgW, height: imgH)
                let imgView = UIImageView(frame: imgVrect)
                imgView.image = image
                self.videoView.addSubview(imgView)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    imgView.removeFromSuperview()
                }
            }
        })
    }
    
    @IBAction func playbackListClicked(_ sender: UIButton) {
        
    }
}

extension IVPlaybackViewController: IVPlayerDelegate {
    func player(_ player: IVPlayer, didUpdate status: IVPlayerStatus) {
        status == .loading ? activityIndicatorView.startAnimating() : activityIndicatorView.stopAnimating()
        playBtn.isSelected = (status == .playing)
        speakerBtn.isSelected = playbackPlayer.mute
    }
    
    func player(_ player: IVPlayer, didUpdatePTS PTS: TimeInterval) {
        logVerbose(PTS)
    }
    
    func player(_ player: IVPlayer, didReceiveError error: Error) {
        logError(error)
    }
    
    func player(_ player: IVPlayer, didReceive avHeader: IVAVHeader) {
//        logInfo(avHeader)
    }
    
    func player(_ player: IVPlayer, didReceiveUserData userData: Data) {
        logInfo(userData)
    }
}
