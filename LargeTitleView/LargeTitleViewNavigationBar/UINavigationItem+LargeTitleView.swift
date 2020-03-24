//
//  UINavigationItem+LargeTitleView.swift
//  LargeTitleView
//
//  Created by berec on 24/03/2020.
//  Copyright © 2020 Noname. All rights reserved.
//

import UIKit

@objc public extension UINavigationItem {
    
    struct AssociatedKeys {
        static var largeTitleView = "largeTitleView"
        static var standardTitleView = "standardTitleView"
    }

    var largeTitleView: UIView? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.largeTitleView)
                as? UIView ?? nil
        }
        set {
            if newValue == self.largeTitleView { return }
            
            if newValue != nil {
                self.title = nil
            }
            
            objc_setAssociatedObject(
                self,
                &AssociatedKeys.largeTitleView,
                newValue,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }

    var standardTitleView: UIView? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.standardTitleView)
                as? UIView ?? nil
        }
        set {
            if newValue == self.standardTitleView { return }
            
            objc_setAssociatedObject(
                self,
                &AssociatedKeys.standardTitleView,
                newValue,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
}
