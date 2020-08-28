//
//  IVTimelineView.swift
//  IotVideoDemo
//
//  Created by JonorZhang on 2020/1/8.
//  Copyright © 2020 Tencentcs. All rights reserved.
//

import UIKit
import SnapKit

protocol IVTimelineViewDelegate: class {
    /// （滚动中）到达某时刻
    /// - Parameters:
    ///   - timelineView: 时间轴对象
    ///   - time: 时间值（UTC时间，不是偏移量）
    func timelineView(_ timelineView: IVTimelineView, didScrollTo time: TimeInterval)

    /// （滚动停止）选中某时刻
    /// - Parameters:
    ///   - timelineView: 时间轴对象
    ///   - item: 时间片段
    ///   - time: 时间值（UTC时间，不是偏移量）
    func timelineView(_ timelineView: IVTimelineView, didSelect item: IVTimelineItem?, at time: TimeInterval)
    
    /// 数据源
    /// - Parameters:
    ///   - timelineView: 时间轴对象
    ///   - time: 时间片段
    ///   - completionHandler: 数据获取完成回调
    func timelineView(_ timelineView: IVTimelineView, itemsForTimelineAt time: IVTime, completionHandler: @escaping ([IVTimelineItem]?) -> Void)
    
    /// 获取打点日期
    /// - Parameters:
    ///   - timelineView: 时间轴对象
    ///   - time: 时间片段
    ///   - completionHandler: 数据获取完成回调
    func timelineView(_ timelineView: IVTimelineView, markListForCalendarAt time: IVTime, completionHandler: @escaping ([IVCSMarkItem]?) -> Void)
}

class IVTimelineView: UIControl {
    
    // MARK: Property

    /// 时间轴事件代理
    weak var delegate: IVTimelineViewDelegate?
       
    /// 视图模型
    var viewModel: IVTimelineViewModel = IVTimelineViewModel(time: .today)
                    
    private var autoScrollEnable = true
    
    private var loadingTimes: [IVTime] = []
    
    // MARK: UI

    lazy var indicatorLine: UIView = {
        let ind = UIView()
        ind.backgroundColor  = UIColor.red
        return ind
    }()

    lazy var scaleLabel: UILabel = {
        let lb = UILabel(frame: CGRect(x: (timeCollView.bounds.width-40)/2, y: (timeCollView.bounds.height-40)/2, width: 40, height: 40))
        lb.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
        lb.backgroundColor = UIColor(white: 0.8, alpha: 0.8)
        lb.textColor = .black
        lb.textAlignment = .center
        lb.font = .systemFont(ofSize: 12)
        lb.layer.cornerRadius = 20
        lb.layer.masksToBounds = true
        lb.isHidden = true
        self.addSubview(lb)
        return lb
    }()
    
    lazy var calendarBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("📅", for: .normal)
        btn.backgroundColor = UIColor(white: 0.98, alpha: 1)
        btn.addEvent { [unowned self](_) in
            let superview = self.nextViewController?.view
            superview?.addSubview(self.calendarView)
            self.calendarView.snp.remakeConstraints { (make) in
                make.height.equalTo(400)
                make.width.equalTo(375)
                make.centerX.equalToSuperview()
                make.bottom.equalTo(superview!.snp.bottomMargin)
            }
            
            if self.calendarView.alpha < 0.01 {
                self.calendarView.alpha = 0
                self.calendarView.transform = CGAffineTransform(translationX: 0, y: 400)
                UIView.animate(withDuration: 0.3, animations: {
                    self.calendarView.alpha = 1
                    self.calendarView.transform = .identity
                })
                self.calendarView.currentDate = self.viewModel.current.date
                if self.calendarView.markableDates.isEmpty {
                    self.loadMarkList(at: self.viewModel.current.time)
                }
            }
        }
        return btn
    }()
    
    /// 日期容器视图
    let datelineView = IVDatelineView()
    
    /// 时间轴容器视图
    lazy var timeCollView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        let col = UICollectionView(frame: .zero, collectionViewLayout: layout)
        col.register(IVTimelineCell.self, forCellWithReuseIdentifier: "IVTimelineCell")
        col.register(IVTimelineHeaderFooter.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: UICollectionView.elementKindSectionHeader)
        col.register(IVTimelineHeaderFooter.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: UICollectionView.elementKindSectionFooter)
        col.showsHorizontalScrollIndicator = false
        col.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 100, bottom: 0, right: 100)
        col.backgroundColor = UIColor(white: 0.98, alpha: 1)
        col.dataSource = self
        col.delegate   = self
        col.addGestureRecognizer(pinchGesture)
        return col
    }()

    private var headerBtn: UIButton?
    private var footerBtn: UIButton?
    
    /// 缩放手势
    private lazy var pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchGestureHandler(_:)))
    
    lazy var calendarView: IVCalendarView = {
        let cal = IVCalendarView()
        cal.backgroundColor = .white
        cal.alpha = 0
        cal.currentDate = viewModel.current.date
        return cal
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepareView()
        prepareEvent()
        prepareLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        prepareView()
        prepareEvent()
        prepareLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if viewModel.current.isPlaceholder {
            loadAndDisplaySection(at: viewModel.current.time)
        } else {
            scrollToTime(viewModel.pts, force: true, animated: false)
        }
    }
    
    override var isTracking: Bool {
        return !autoScrollEnable || isInteracting || datelineView.isTracking || timeCollView.isTracking
    }
}

private extension IVTimelineView {
        
    private func prepareView() {
        backgroundColor = .white
        addSubview(datelineView)
        addSubview(calendarBtn)
        addSubview(timeCollView)
        addSubview(indicatorLine)
    }
    
    private func prepareEvent() {
        viewModel.scrollToTimeIfNeed = { [weak self] pts, sectionTime in
            if pts < sectionTime.start {
                self?.loadAndDisplaySection(at: sectionTime.before(days: 1))
            } else if pts > sectionTime.end {
                self?.loadAndDisplaySection(at: sectionTime.after(days: 1))
            } else {
                DispatchQueue.main.async {
                    self?.scrollToTime(pts, force: false, animated: true)
                }
            }
        }
        
        datelineView.selectedDateCallback = { date in
            self.loadAndDisplaySection(at: IVTime(date: date))
        }
        
        calendarView.selectedDateCallback = { date in
            self.calendarView.alpha = 0
            self.loadAndDisplaySection(at: IVTime(date: date))
        }
    }
    
    private func prepareLayout() {
        calendarBtn.snp.makeConstraints { (make) in
            make.top.right.equalToSuperview()
            make.width.height.equalTo(40)
        }

        datelineView.snp.makeConstraints { (make) in
            make.top.left.equalToSuperview()
            make.height.equalTo(40)
            make.right.equalToSuperview()
        }

        timeCollView.snp.makeConstraints { (make) in
            make.top.equalTo(datelineView.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        indicatorLine.snp.makeConstraints { (make) in
            make.center.equalTo(timeCollView)
            make.width.equalTo(1)
            make.height.equalTo(timeCollView)
        }
    }
    
    /// 预加载数据
    func preloadSectionIfNeed(at time: IVTime, isBackward: Bool) {
        DispatchQueue.main.async {[weak self] in
            guard let `self` = self else { return }
                        
            if !self.viewModel.sections.contains(where: { time == $0.time }),
                !self.loadingTimes.contains(time) {
                self.loadingTimes.append(time)
                
                self.delegate?.timelineView(self, itemsForTimelineAt: time) {(items) in
                    DispatchQueue.main.async {[weak self] in
                        guard let `self` = self else { return }
                        self.loadingTimes.removeAll(where: { $0 == time})
                        if let items = items {
                            logInfo("下载成功 \(time.dateString) \(items)")
                            
                            self.viewModel.insertSection(items: items, for: time)
                            
                            if self.viewModel.current.time == time {
                                self.timeCollView.reloadData()
                                if let destItem = isBackward ? self.viewModel.current.items.last(where: { $0.isValid }) : self.viewModel.current.items.first(where: { $0.isValid }) {
                                    self.scrollToTime(destItem.start, force: true, animated: true)
                                } else {
                                    self.timeCollView.contentOffset.x = isBackward ? self.timeCollView.contentSize.width-self.timeCollView.frame.width : 0
                                }
                            }
                        } else {
                            logError("下载失败 \(time.dateString)")
                        }
                    }
                }
            }
        }
    }
    
    /// 加载并刷新UI
    func loadAndDisplaySection(at time: IVTime) {
        DispatchQueue.main.async {[weak self] in
            guard let `self` = self else { return }
            if self.viewModel.current.time != time || self.viewModel.current.isPlaceholder {
                let isBackward = time.start < self.viewModel.current.start

                self.datelineView.selectedDate = time.date

                self.viewModel.loadSection(for: time)
                self.timeCollView.reloadData()
                self.timeCollView.contentOffset.x = isBackward ? self.timeCollView.contentSize.width-self.timeCollView.frame.width : 0
                if !self.viewModel.current.isPlaceholder,
                    let destItem = isBackward ? self.viewModel.current.items.last(where: { $0.isValid }) : self.viewModel.current.items.first(where: { $0.isValid }) {
                    self.scrollToTime(destItem.start, force: true, animated: true)
                }

                self.timeCollView.transform = CGAffineTransform(translationX: isBackward ? -100 : 100, y: 0)
                UIView.animate(withDuration: 0.3) {
                    self.timeCollView.transform = .identity
                }

                if self.viewModel.current.isPlaceholder {
                    self.preloadSectionIfNeed(at: time, isBackward: isBackward)
                }
            }
        }
    }
        
    func loadMarkList(at time: IVTime) {
        self.delegate?.timelineView(self, markListForCalendarAt: time, completionHandler: { [weak self](markList) in
            if let markList = markList {
                self?.calendarView.markableDates = markList.map({ ($0.dateTime, $0.playable) })
            }
        })
    }
 
    func enableAutoScroll(after delay: TimeInterval) {
        autoScrollEnable = false
        IVDelayWork.asyncAfter(delay, key: "autoScrollEnable") {[weak self] in
            self?.autoScrollEnable = true
        }
    }
    
    var isInteracting: Bool {
        return timeCollView.isDragging ||
            timeCollView.isTracking ||
            timeCollView.isDecelerating ||
            !scaleLabel.isHidden
    }
    
    func scrollToTime(_ time: TimeInterval, force: Bool, animated: Bool) {
        if !force {
            if self.isInteracting {
                self.enableAutoScroll(after: 2)
                return
            }
            
            if !self.autoScrollEnable {
                return
            }
        }
        let time = min(max(time, viewModel.current.start), viewModel.current.end)
        viewModel.update(pts: time, needsScroll: false)
        let offsetX = CGFloat(time - viewModel.current.start) * CGFloat(viewModel.scale)
        let point = CGPoint(x: offsetX, y: timeCollView.contentOffset.y)
        self.timeCollView.setContentOffset(point, animated: animated)
    }
    
    @objc func pinchGestureHandler(_ pinch: UIPinchGestureRecognizer) {
        switch pinch.state {
        case .changed:
            let oldScale = viewModel.scale
            
            if viewModel.update(scale: oldScale * Double(pinch.scale)) {
                CATransaction.setDisableActions(true)
                timeCollView.reloadData()
                scrollToTime(viewModel.pts, force: true, animated: false)
                CATransaction.commit()
                scaleLabel.isHidden = false
                scaleLabel.text = viewModel.scale > 0.1 ? "\(Int(viewModel.scale * 100))%" : String(format: "%.1f%%", viewModel.scale * 100)
            }
        default:
            IVDelayWork.asyncAfter(1, key: "scaleLabel.isHidden") {[weak self] in
                self?.scaleLabel.isHidden = true
            }
        }
        pinch.scale = 1
    }
    
}

extension IVTimelineView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.current.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IVTimelineCell", for: indexPath) as! IVTimelineCell
        let item = viewModel.current.items[indexPath.item]
        let time = IVTime(start: item.start, end: item.end)
        cell.update(time: time, color: item.color, isValid: item.isValid, isLoading: item.isPlaceholder, scale: viewModel.scale)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerfooter = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: kind, for: indexPath) as! IVTimelineHeaderFooter
        let fmt = DateFormatter()
        fmt.dateFormat = "MM/dd"
        
        if kind == UICollectionView.elementKindSectionHeader {
            headerBtn = headerfooter.btn
            let prevDay = self.viewModel.current.before(days: 1)
            headerBtn?.setTitle("\(fmt.string(from: prevDay.date))   ☜=((・∀・*)☜=", for: .normal)
            headerBtn?.setTitle("╰(￣▽￣)╭", for: .selected)
            headerBtn?.addEvent { (_) in
                self.loadAndDisplaySection(at: prevDay)
            }
        } else {
            footerBtn = headerfooter.btn
            if viewModel.current.time == .today {
                footerBtn?.setTitle("(＞﹏＜)||", for: .normal)
                footerBtn?.addEvent { _ in }
            } else {
                let nextDay = self.viewModel.current.after(days: 1)
                footerBtn?.setTitle("=☞(*・∀・))=☞   \(fmt.string(from: nextDay.date))", for: .normal)
                footerBtn?.setTitle("╰(￣▽￣)╭", for: .selected)
                footerBtn?.addEvent { (_) in
                    self.loadAndDisplaySection(at: nextDay)
                }
            }
        }
        return headerfooter
    }
}


extension IVTimelineView: UICollectionViewDelegateFlowLayout {
        
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = viewModel.current.items[indexPath.item]
        if !item.isValid { return }
        scrollToTime(item.start, force: true, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = viewModel.current.items[indexPath.item]
        let floorStart = floor(Double(UIScreen.main.scale) * item.start * viewModel.scale) / Double(UIScreen.main.scale)
        let floorEnd = floor(Double(UIScreen.main.scale) * item.end * viewModel.scale) / Double(UIScreen.main.scale)
        let newItemW = CGFloat(floorEnd - floorStart)
        return CGSize(width: newItemW, height: collectionView.bounds.height)
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
        return CGSize(width: collectionView.bounds.width/2, height: collectionView.bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width/2, height: collectionView.bounds.height)
    }
    
    // MARK: UIScrollViewDelegate
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scaleLabel.isHidden = true
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView.isDecelerating { return }
        
        if scrollView.contentOffset.x < -60 {
            let prevDay = viewModel.current.before(days: 1)
            loadAndDisplaySection(at: prevDay)
        } else if viewModel.current.time != .today,
            scrollView.contentOffset.x - scrollView.contentSize.width > -(scrollView.frame.width-60) {
            let nextDay = viewModel.current.after(days: 1)
            loadAndDisplaySection(at: nextDay)
        }
        
        if decelerate { return }
        
        scrollHandler(didEnd: true)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollHandler(didEnd: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        headerBtn?.isSelected = (scrollView.isDragging && scrollView.contentOffset.x < -60)
        footerBtn?.isSelected = (scrollView.isDragging && viewModel.current.time < .today && scrollView.contentOffset.x - scrollView.contentSize.width > -(scrollView.frame.width-60))
        
        scrollHandler(didEnd: false)
    }
    
    private func scrollHandler(didEnd: Bool) {
        guard !viewModel.current.items.isEmpty else {
            return
        }
        
        for cell in timeCollView.visibleCells {
            guard let cell = cell as? IVTimelineCell else {
                continue
            }
            let newRect = timeCollView.convert(cell.frame, to: self)
            let indRect = indicatorLine.frame
            
            guard newRect.contains(CGPoint(x: indRect.midX, y: indRect.midY)) else {
                continue
            }
            
            var seekTime = Double(timeCollView.contentOffset.x) / self.viewModel.scale + viewModel.current.start
            seekTime = min(max(seekTime, viewModel.current.start), viewModel.current.end)
            
            viewModel.update(pts: seekTime, needsScroll: false)
            delegate?.timelineView(self, didScrollTo: seekTime)

            if didEnd {
                let item = viewModel.currentRawItem
                logDebug("selected item \(String(describing: item)) at \(seekTime)")
                delegate?.timelineView(self, didSelect: item, at: seekTime)
            }
            return
        }
    }
}


// MARK: -

class IVTimelineCell: UICollectionViewCell {
    
    private(set) var time: IVTime = .today
    private(set) var color: UIColor = .white
    private(set) var isValid: Bool = false
    private(set) var scale = 1.0
        
    func update(time: IVTime, color: UIColor, isValid: Bool, isLoading: Bool, scale: Double) {
        self.time = time
        self.color = color
        self.isValid = isValid
        self.scale  = scale
        removeAllTextLayer()
        timeMarks = IVTimeMark.all.filter { scale * Double($0.rawValue) >= 4.8 } // 距离大于 4.8 pt
        isLoading ? self.loadingAnim.startAnimating() : self.loadingAnim.stopAnimating()
        setNeedsDisplay()
    }
            
    /// === 时间刻度 ===
    private var timeMarks: [IVTimeMark] = [.hour]
       
    private func FontSize(of mark: IVTimeMark) -> CGFloat {
        var fontSize: CGFloat
        if mark.rawValue >= IVTimeMark.hour.rawValue {
            fontSize = CGFloat(CGFloat(mark.rawValue) * CGFloat(scale) / 800) * 20
            fontSize = fontSize < 14 ? 14 : (fontSize > 20 ? 20 : fontSize)
        } else if mark.rawValue >= IVTimeMark.min1.rawValue  {
            fontSize = CGFloat(CGFloat(mark.rawValue) * CGFloat(scale) / 800) * 17
            fontSize = fontSize < 12 ? 12 : (fontSize > 17 ? 17 : fontSize)
        } else {
            fontSize = CGFloat(CGFloat(mark.rawValue) * CGFloat(scale) / 800) * 15
            fontSize = fontSize < 8 ? 8 : (fontSize > 15 ? 15 : fontSize)
        }
        return fontSize
    }
    
    private func TimeOffset(of mark: IVTimeMark) -> TimeInterval {
        let remain: TimeInterval = time.start - floor(time.start) // 小数点后的余数
        let mod: TimeInterval = TimeInterval(Int(time.start) % mark.rawValue) + remain // 小数点前整数
        let offset: TimeInterval = mod > 0.001 ? TimeInterval(mark.rawValue) - mod : 0
        return offset
    }
    
    private func DateFormat(of mark: IVTimeMark) -> String {
        return mark < .min1 ? "ss" : "HH:mm"
    }
    
    private func LabelWidth(of mark: IVTimeMark) -> CGFloat {
        let text = DateFormat(of: mark) as NSString
        let width = text.boundingRect(with: CGSize(width: 100, height: 20),
                                      options: .usesFontLeading,
                                      attributes: [.font : UIFont.systemFont(ofSize: FontSize(of: mark))],
                                      context: nil).width
        return max(width, 30)
        //        return FontSize(of: mark) * CGFloat(DateFormat(of: mark).count)
    }

    private func MarkHeight(of mark: IVTimeMark) -> Double {
        switch mark {
        case .hour4, .hour2, .hour: return 20
        case .min30: return 18
        case .min10: return 16
        case .min5, .min1: return 14
        case .sec30: return 12
        case .sec10: return 10
        case .sec5, .sec1: return 8
        }
    }
    
    private func StrokeColor(of mark: IVTimeMark) -> UIColor {
        let alpha = ((CGFloat(mark.rawValue) * CGFloat(scale) - 2) / 200) + 0.2
        let color = UIColor(white: 0, alpha: alpha)
        return color
    }
    
    private func removeAllTextLayer() {
        layer.sublayers?.forEach({
            if $0.name == "textLayer" { $0.removeFromSuperlayer() }
        })
    }
    
    private func addTextLayer(frame: CGRect, text: String, color: UIColor, fontSize: CGFloat) {
        let timeLayer = CATextLayer()
        timeLayer.frame = frame
        timeLayer.string = text
        timeLayer.alignmentMode = .center
        timeLayer.foregroundColor = color.cgColor
        timeLayer.fontSize = fontSize
        timeLayer.contentsScale = UIScreen.main.scale
        timeLayer.name = "textLayer"
        layer.addSublayer(timeLayer)
    }
    
    // === 刻度\文字 ===
    private func drawTimelineMark(_ ctx: CGContext?, mark: IVTimeMark) {
        let markHeight = MarkHeight(of: mark)
        var offset = TimeOffset(of: mark)
        
        let color = StrokeColor(of: mark)
        let fontSize = FontSize(of: mark)
        
        let fmt = DateFormatter()
        fmt.dateFormat = DateFormat(of: mark)

        let labelWidth = LabelWidth(of: mark)
        let showText = CGFloat(mark.rawValue) * CGFloat(scale) > labelWidth
        
        ctx?.setLineWidth(1)
        ctx?.setStrokeColor(color.cgColor)
        
        while offset <= time.duration {
            if mark.upperMark == nil || Int(time.start + offset) % mark.upperMark!.rawValue != 0 {
                ctx?.move(to: CGPoint(x: scale * offset, y: 0))
                ctx?.addLine(to: CGPoint(x: scale * offset, y: markHeight))
                
                if showText, mark >= .sec10 {
                    for divisor in IVTimeMark.divisors {
                        if Int(time.start + offset) % divisor == 0 {
                            addTextLayer(frame: CGRect(x: CGFloat(scale * offset)-labelWidth/2, y: bounds.height-20, width: labelWidth, height: 20),
                                         text: fmt.string(from: Date(timeIntervalSince1970: time.start + offset)),
                                         color: color,
                                         fontSize: fontSize)
                            break
                        }
                    }
                }
            }
            
            offset += Double(mark.rawValue)
        }
        
        ctx?.strokePath()
    }
    
    let loadingAnim = UIActivityIndicatorView(style: .gray)

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        contentView.addSubview(loadingAnim)
        loadingAnim.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        print(self.classForCoder, "alloc")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.clear(rect)

        // 颜色块
        ctx?.setFillColor(color.cgColor)
        let rect = CGRect(x: 0, y: bounds.height / 3, width: bounds.width, height: bounds.height / 3)
        ctx?.fill(rect)
        
        timeMarks.forEach { (mark) in
            drawTimelineMark(ctx, mark: mark)
        }
    }
}

class IVTimelineHeaderFooter: UICollectionReusableView {
    
    lazy var btn: UIButton = {
        let btn = UIButton(frame: bounds)
        btn.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        btn.setTitleColor(.blue, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 15)
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(btn)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


