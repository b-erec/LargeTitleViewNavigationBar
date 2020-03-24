//
//  LargeTitleViewNavigationBar.swift
//  LargeTitleView
//
//  Created by berec on 24/03/2020.
//  Copyright © 2020 Noname. All rights reserved.
//

import UIKit

/// Along with `UINavigationItem+LargeTitleView` allows to present
/// custom title view in the way the navigation bar's large title's presented.
final public class LargeTitleViewNavigationBar: UINavigationBar {
    
    // MARK: - Nested Types
    
    private struct AssociatedKeys {
        static var titleView = "titleView"
        static var topItem = "topItem"
    }

    // MARK: - Private Properties

    private let titleViewTag = 1014
    private let largeTitleChangeThreshold: CGFloat = 62
    
    private var currentTitleView: UIView? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.titleView)
                as? UIView ?? nil
        }
        set {
            objc_setAssociatedObject(
                self,
                &AssociatedKeys.titleView,
                newValue,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }

    private weak var currentTopItem: UINavigationItem? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.topItem)
                as? UINavigationItem ?? nil
        }
        set {
            guard self.currentTopItem != newValue else { return }
            
            self.currentTopItem.map {
                self.observeTopItem($0, observe: false)
            }
            
            newValue.map {
                self.observeTopItem($0, observe: true)
            }
            
            objc_setAssociatedObject(
                self,
                &AssociatedKeys.topItem,
                newValue,
                .OBJC_ASSOCIATION_ASSIGN
            )
        }
    }
    
    // MARK: - Life Cycle
    
    public override func layoutSubviews() {
        self.updateTitleView()

        super.layoutSubviews()
    }
    
    // MARK: - Private Methods
    
    private func updateTitleView() {
        guard let topItem = self.topItem else { return }
        
        // Reset `currentTitleView` on top navigation item's change.
        self.currentTopItem.map {
            if $0 == topItem { return }
            
            self.observeTopItemTitleView($0, observe: false)
            self.currentTitleView = nil
        }

        topItem.largeTitleView.map {
            if self.currentTitleView != $0 {
                self.currentTitleView = $0
            }
        }

        self.currentTopItem = topItem

        guard let largeTitleView = self.currentTitleView else {
            self.stickViewToLargeTitleView(nil)
            return
        }
        
        //print("bar's height: \(self.bounds.height)")
        let hideLargeTitleView = self.bounds.height <= self.largeTitleChangeThreshold

        self.stickViewToLargeTitleView(hideLargeTitleView ? nil : largeTitleView)
        
        if (hideLargeTitleView) {
            topItem.titleView = topItem.standardTitleView ?? largeTitleView
        }
        else {
            topItem.titleView = nil
            topItem.title = nil
        }
        
        self.observeTopItemTitleView(topItem, observe: true)
    }
    
    private func stickViewToLargeTitleView(_ titleView: UIView?) {
        for view in self.subviews {
            if view.className.contains("LargeTitleView") {
                self.updateSubviews(view.subviews, with: titleView)
            }
        }
    }
    
    @discardableResult
    private func updateSubviews(_ subviews: [UIView], with titleView: UIView?) -> Bool {
        for view in subviews {
            if let label = view as? UILabel {
                if let titleView = titleView {
                    if label.contains(titleView) {
                        return true
                    }

                    titleView.tag = self.titleViewTag
                    titleView.translatesAutoresizingMaskIntoConstraints = false
                    titleView.include(into: label, top: 0, left: 0, bottom: 0)
                    titleView.widthAnchor
                        .constraint(equalTo: label.heightAnchor,
                                    multiplier: titleView.frame.width / titleView.frame.height)
                        .isActive = true
                    
                    label.addSubview(titleView)
                 
                    return true
                }
                else {
                    for view in label.subviews {
                        if view.tag == self.titleViewTag {
                            view.removeFromSuperview()
                            
                            return true
                        }
                    }
                }
            }
                
            if (self.updateSubviews(view.subviews, with: titleView)) {
                return true
            }
        }
        
        return false
    }
    
    // MARK: - Observers

    private func observeTopItemTitleView(_ topItem: UINavigationItem, observe: Bool) {
        topItem.removeBlockObserver(forKeyPath: "titleView")
        
        if !observe { return }
        
        topItem.addBlockObserver(forKeyPath: "titleView") { [weak topItem] (info) in
            guard let topItem = topItem else { return }
            guard self.bounds.height > self.largeTitleChangeThreshold else { return }
            
            topItem.titleView.map {
                self.currentTitleView = $0
                if topItem.titleView != nil {
                    topItem.titleView = nil
                    topItem.title = nil
                }
            }
        }
    }
    
    private func observeTopItem(_ topItem: UINavigationItem, observe: Bool) {
        let key = UINavigationItem.AssociatedKeys.largeTitleView

        topItem.removeBlockObserver(forKeyPath: key)

        if !observe { return }
        
        topItem.addBlockObserver(forKeyPath: key) { info in
            self.updateTitleView()
        }
    }
}
