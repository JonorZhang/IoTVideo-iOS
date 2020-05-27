//
//  IVView.swift
//  IotVideoDemoDev
//
//  Created by JonorZhang on 2020/4/14.
//  Copyright © 2020 Tencentcs. All rights reserved.
//

import UIKit

// MAKR: -
extension UIView {
    @objc var nextViewController: UIViewController? {
        var responder = next
        while responder != nil {
            if let vc = responder as? UIViewController { return vc }
            responder = responder?.next
        }
        return nil
    }

    /// 视图本身是否可见
    var isVisible: Bool {
        if isHidden { return false }
        if !isOpaque  { return false }
        if alpha <= 0.01 { return false }
        if bounds.size.width == 0 || bounds.size.height == 0 { return false }
        return true
    }

    /// 视图作为容器是否可见（并且子控件可见）
    var isVisibleAsContainer: Bool {
        if !isVisible { return false }
        if subviews.count == 0 { return false }
        if subviews.filter({ !$0.isVisible }).count == 0 { return false }
        return true
    }
    
    func getAllSubviews() -> [UIView] {
        return subviews.flatMap { subView -> [UIView] in
            var result = subView.getAllSubviews()
            result.append(subView)
            return result
        }
    }
    
    func getAllSubviews<T: UIView>(of type: T.Type) -> [T] {
        return getAllSubviews().compactMap({ $0 as? T })
    }
}

extension UIView {
    @objc enum Gesture: Int {
        case longPress
        case tap
        case pinch
        case pan
        case swipe
        case rotation
        case screenEdgePan
        
        fileprivate var type: UIGestureRecognizer.Type {
            switch self {
            case .longPress: return UILongPressGestureRecognizer.self
            case .tap: return UITapGestureRecognizer.self
            case .pinch: return UIPinchGestureRecognizer.self
            case .pan: return UIPanGestureRecognizer.self
            case .swipe: return UISwipeGestureRecognizer.self
            case .rotation: return UIRotationGestureRecognizer.self
            case .screenEdgePan: return UIScreenEdgePanGestureRecognizer.self
            }
        }
    }
    
    /// Attaches a gesture recognizer to the view.
    ///
    /// Attaching a gesture recognizer to a view defines the scope of the represented gesture, causing it to receive touches hit-tested to that view and all of its subviews. The view establishes a **strong reference** to the gesture recognizer.
    /// - Parameters:
    ///   - gesture: gesture enum
    ///   - action: action callback
    @discardableResult
    @objc func addGesture(_ gesture: Gesture, action: ((UIGestureRecognizer)->())?) -> UIGestureRecognizer {
        isUserInteractionEnabled = true
        
        let ges = gesture.type.init(target: self, action: #selector(gestureRecognizerHandler(gesture:)))
        addGestureRecognizer(ges)

        let key = UnsafeRawPointer(Unmanaged.passUnretained(ges).toOpaque())
        objc_setAssociatedObject(self, key, action, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        return ges
    }
    
    @objc func gestureRecognizerHandler(gesture: UIGestureRecognizer) {
        let key = UnsafeRawPointer(Unmanaged.passUnretained(gesture).toOpaque())
        if let action = objc_getAssociatedObject(self, key) as? ((UIGestureRecognizer)->()) {
            action(gesture)
        }
    }
}
