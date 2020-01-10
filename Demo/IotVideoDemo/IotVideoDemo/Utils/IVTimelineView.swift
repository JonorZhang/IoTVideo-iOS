//
//  IVTimelineView.swift
//  IotVideoDemo
//
//  Created by JonorZhang on 2020/1/8.
//  Copyright © 2020 gwell. All rights reserved.
//

import UIKit

struct IVTimelineItem {
    var startTime: TimeInterval = 20
    var duration: TimeInterval = 30
    var color: UIColor = .random
}

class IVTimelineView: UIView {
    
    lazy var timelineLayout = IVTimelineLayout()
    lazy var collectionView: UICollectionView = {
        let col = UICollectionView(frame: self.bounds, collectionViewLayout: timelineLayout)
        col.dataSource = self
        col.delegate   = self
        col.register(IVTimelineCell.self, forCellWithReuseIdentifier: "IVTimelineCell")
        return col
    }()
    
    var items: [[IVTimelineItem]] = [] {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.collectionView.reloadData()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
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

extension IVTimelineView: UICollectionViewDelegate {

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
//        minimumLineSpacing = 0
//        minimumInteritemSpacing = 0
//        estimatedItemSize = CGSize(width: 20, height: 64)
//        scrollDirection = .horizontal
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attr = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        attr.size = CGSize(width: 50, height: 50)
        return attr
    }
}
