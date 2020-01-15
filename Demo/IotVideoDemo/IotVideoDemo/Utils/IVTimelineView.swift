//
//  IVTimelineView.swift
//  IotVideoDemo
//
//  Created by JonorZhang on 2020/1/8.
//  Copyright © 2020 gwell. All rights reserved.
//

import UIKit

struct IVTimelineItem {
    var startTime: TimeInterval
    var duration: TimeInterval
    var color: UIColor
}

class IVTimelineView: UIView {
    
    lazy var timelineLayout = IVTimelineLayout()
    lazy var collectionView: UICollectionView = {
        let col = UICollectionView(frame: self.bounds, collectionViewLayout: timelineLayout)
        col.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        col.dataSource = self
        col.delegate   = self
        col.register(IVTimelineCell.self, forCellWithReuseIdentifier: "IVTimelineCell")
        col.showsHorizontalScrollIndicator = false
        col.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 100, bottom: 0, right: 100)
        col.backgroundColor = .white
        return col
    }()
    
    var items: [[IVTimelineItem]] = [] {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.collectionView.reloadData()
            }
        }
    }
    
    var didSelectItemCallback: ((IVTimelineItem) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        addSubview(collectionView)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addSubview(collectionView)
    }
}

extension IVTimelineView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return items.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IVTimelineCell", for: indexPath)
        cell.backgroundColor = items[indexPath.section][indexPath.row].color
        return cell
    }

}


extension IVTimelineView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = items[indexPath.section][indexPath.row]
        didSelectItemCallback?(item)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemW = CGFloat(items[indexPath.section][indexPath.row].duration * 0.5)
        return CGSize(width: itemW, height: bounds.height)
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return .zero
    }
}

class IVTimelineCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .random
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class IVTimelineLayout: UICollectionViewFlowLayout {
    
    var layoutAttributes: [UICollectionViewLayoutAttributes] = []
    
    override init() {
        super.init()
        minimumLineSpacing = 0
        minimumInteritemSpacing = 0
        scrollDirection = .horizontal
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
