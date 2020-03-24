//
//  NSObject+ClassName.swift
//  LargeTitleView
//
//  Created by berec on 24/03/2020.
//  Copyright © 2020 Noname. All rights reserved.
//

import Foundation

@objc public extension NSObject {
    class var className: String {
        return String(describing: self)
    }
    
    var className: String {
        return type(of: self).className
    }
}
