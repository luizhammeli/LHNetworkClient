//
//  UIView+Anchor.swift
//  
//
//  Created by Luiz Diniz Hammerli on 18/08/23.
//

import UIKit

// swiftlint:disable file_types_order
struct AnchoredPositionConstraints {
    var top, leading, bottom, trailing: NSLayoutConstraint?
}

struct AnchoredSizeConstraints {
    var width, height: NSLayoutConstraint?
}

struct AnchoredXYConstraints {
    var x: NSLayoutXAxisAnchor?
    var y: NSLayoutYAxisAnchor?
}

extension UIView {
    @discardableResult
    func anchor(
        top: NSLayoutYAxisAnchor? = nil,
        leading: NSLayoutXAxisAnchor? = nil,
        bottom: NSLayoutYAxisAnchor? = nil,
        trailing: NSLayoutXAxisAnchor? = nil,
        padding: UIEdgeInsets = .zero
    ) -> AnchoredPositionConstraints {
        translatesAutoresizingMaskIntoConstraints = false
        var anchoredConstraints = AnchoredPositionConstraints()

        if let top = top {
            anchoredConstraints.top = topAnchor.constraint(equalTo: top, constant: padding.top)
        }

        if let leading = leading {
            anchoredConstraints.leading = leadingAnchor.constraint(equalTo: leading, constant: padding.left)
        }

        if let bottom = bottom {
            anchoredConstraints.bottom = bottomAnchor.constraint(equalTo: bottom, constant: -padding.bottom)
        }

        if let trailing = trailing {
            anchoredConstraints.trailing = trailingAnchor.constraint(equalTo: trailing, constant: -padding.right)
        }

        [anchoredConstraints.top,
         anchoredConstraints.leading,
         anchoredConstraints.bottom,
         anchoredConstraints.trailing].forEach { $0?.isActive = true }

        return anchoredConstraints
    }

    @discardableResult
    func fillSuperview(padding: UIEdgeInsets = .zero) -> AnchoredPositionConstraints {
        translatesAutoresizingMaskIntoConstraints = false
        var anchoredConstraints = AnchoredPositionConstraints()

        if let top = superview?.topAnchor {
            anchoredConstraints.top = topAnchor.constraint(equalTo: top, constant: padding.top)
        }

        if let leading = superview?.leadingAnchor {
            anchoredConstraints.leading = leadingAnchor.constraint(equalTo: leading, constant: padding.left)
        }

        if let bottom = superview?.bottomAnchor {
            anchoredConstraints.bottom = bottomAnchor.constraint(equalTo: bottom, constant: -padding.bottom)
        }

        if let trailing = superview?.trailingAnchor {
            anchoredConstraints.trailing = trailingAnchor.constraint(equalTo: trailing, constant: -padding.right)
        }

        [anchoredConstraints.top,
         anchoredConstraints.leading,
         anchoredConstraints.bottom,
         anchoredConstraints.trailing].forEach { $0?.isActive = true }

        return anchoredConstraints
    }

    func centerInSuperview(size: CGSize = .zero) {
        translatesAutoresizingMaskIntoConstraints = false

        if let superviewCenterXAnchor = superview?.centerXAnchor {
            centerXAnchor.constraint(equalTo: superviewCenterXAnchor).isActive = true
        }

        if let superviewCenterYAnchor = superview?.centerYAnchor {
            centerYAnchor.constraint(equalTo: superviewCenterYAnchor).isActive = true
        }

        if size.width != 0 {
            widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }

        if size.height != 0 {
            heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }
    }

    func centerXInSuperview(constant: CGFloat = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        if let superViewCenterXAnchor = superview?.centerXAnchor {
            centerXAnchor.constraint(equalTo: superViewCenterXAnchor, constant: constant).isActive = true
        }
    }

    func centerX(in view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }

    func centerYInSuperview(constant: CGFloat = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        if let centerY = superview?.centerYAnchor {
            centerYAnchor.constraint(equalTo: centerY, constant: constant).isActive = true
        }
    }

    func centerY(in view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }

    @discardableResult
    func anchor(size: CGSize) -> AnchoredSizeConstraints {
        translatesAutoresizingMaskIntoConstraints = false
        var anchoredSizeConstraints = AnchoredSizeConstraints()

        if size.width > 0 {
            anchoredSizeConstraints.width = widthAnchor.constraint(equalToConstant: size.width)
        }

        if size.height > 0 {
            anchoredSizeConstraints.height = heightAnchor.constraint(equalToConstant: size.height)
        }

        [anchoredSizeConstraints.width, anchoredSizeConstraints.height].forEach { $0?.isActive = true }

        return anchoredSizeConstraints
    }

    func addSubviews(_ views: UIView...) {
        views.forEach { addSubview($0) }
    }

    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        if #available(iOS 11, *) {
            var cornerMask = CACornerMask()

            if corners.contains(.topLeft) {
                cornerMask.insert(.layerMinXMinYCorner)
            }
            if corners.contains(.topRight) {
                cornerMask.insert(.layerMaxXMinYCorner)
            }
            if corners.contains(.bottomLeft) {
                cornerMask.insert(.layerMinXMaxYCorner)
            }
            if corners.contains(.bottomRight) {
                cornerMask.insert(.layerMaxXMaxYCorner)
            }
            self.layer.cornerRadius = radius
            self.layer.maskedCorners = cornerMask

        } else {
            let path = UIBezierPath(roundedRect: self.bounds,
                                    byRoundingCorners: corners,
                                    cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            self.layer.mask = mask
        }
    }

    @discardableResult
    func anchor(
        heightAnchor: NSLayoutDimension? = nil,
        heightMultiplier: CGFloat = 1,
        widthAnchor: NSLayoutDimension? = nil,
        widthMultiplier: CGFloat = 1
    ) -> AnchoredSizeConstraints {
        translatesAutoresizingMaskIntoConstraints = false
        var anchoredSizeConstraints = AnchoredSizeConstraints()

        var heightConstraint: NSLayoutConstraint?
        var widthConstraint: NSLayoutConstraint?

        if let heightAnchor = heightAnchor {
            heightConstraint = self.heightAnchor.constraint(equalTo: heightAnchor, multiplier: heightMultiplier)
            heightConstraint?.isActive = true

            anchoredSizeConstraints.height = heightConstraint
        }

        if let widthAnchor = widthAnchor {
            widthConstraint = self.widthAnchor.constraint(equalTo: widthAnchor, multiplier: widthMultiplier)
            widthConstraint?.isActive = true

            anchoredSizeConstraints.width = widthConstraint
        }

        return anchoredSizeConstraints
    }
}

