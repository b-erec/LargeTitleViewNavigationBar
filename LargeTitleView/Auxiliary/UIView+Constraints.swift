//
//  UIView+Constraints.swift
//  LargeTitleView
//
//  Created by berec on 24/03/2020.
//  Copyright © 2020 Noname. All rights reserved.
//

import UIKit

extension UIView {

    @discardableResult
    public func include(into container: UIView,
                        at index: Int? = nil,
                        insets: UIEdgeInsets = .zero) -> [NSLayoutConstraint]
    {
        return self.include(into: container,
                            at: index,
                            top: insets.top,
                            left: insets.left,
                            bottom: insets.bottom,
                            right: insets.right)
    }

    @discardableResult
    @objc public func include(into container: UIView,
                       insets: UIEdgeInsets = .zero) -> [NSLayoutConstraint]
    {
        return self.include(into: container, at: nil, insets: insets)
    }

    /// Create constraints only for non-nil parameters
    @discardableResult
    public func include(into container: UIView,
                        at index: Int? = nil,
                        top: CGFloat? = nil,
                        left: CGFloat? = nil,
                        bottom: CGFloat? = nil,
                        right: CGFloat? = nil) -> [NSLayoutConstraint]
    {
        self.translatesAutoresizingMaskIntoConstraints = false

        if let index = index {
            container.insertSubview(self, at: index)
        }
        else {
            container.addSubview(self)
        }

        return self.activeConstraintsToSuperview(top: top, left: left, bottom: bottom, right: right)
    }

    @discardableResult
    public func activeConstraintsToSuperview(top: CGFloat? = nil,
                                      left: CGFloat? = nil,
                                      bottom: CGFloat? = nil,
                                      right: CGFloat? = nil) -> [NSLayoutConstraint]
    {
        guard let container = self.superview else { return [] }
        
        var result = [NSLayoutConstraint]()
        
        let add = { (constraint: NSLayoutConstraint?) -> () in
            constraint.map { result.append($0) }
        }

        add(self.getConstraint(anchor: self.topAnchor,
                               equalTo: container.topAnchor,
                               constant: top,
                               identifier: "top"))

        add(self.getConstraint(anchor: self.bottomAnchor,
                               equalTo: container.bottomAnchor,
                               constant: bottom,
                               isConstantNegative: true,
                               identifier: "bottom"))

        add(self.getConstraint(anchor: self.leftAnchor,
                               equalTo: container.leftAnchor,
                               constant: left,
                               identifier: "left"))

        add(self.getConstraint(anchor: self.rightAnchor,
                               equalTo: container.rightAnchor,
                               constant: right,
                               isConstantNegative: true,
                               identifier: "right"))

        NSLayoutConstraint.activate(result)
        
        return result
    }
    
    private func getConstraint<AnchorType>(anchor: NSLayoutAnchor<AnchorType>,
                                           equalTo: NSLayoutAnchor<AnchorType>,
                                           constant: CGFloat?,
                                           isConstantNegative: Bool = false,
                                           identifier: String) -> NSLayoutConstraint?
    {
        guard let _constant = constant, !_constant.isNaN else { return nil }
        
        let constant = _constant * (isConstantNegative ? -1 : 1)
        let constraint = anchor.constraint(equalTo: equalTo, constant: constant)
        constraint.identifier = identifier
        
        return constraint
    }
}
