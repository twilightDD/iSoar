//
//  NotificationBanner.swift
//  Glider Tool
//
//  Created by sonic on 07.04.20.
//  Copyright © 2020 Denis Leupold. All rights reserved.
//

import UIKit

class NotificationBanner {
    static let labelLeftMarging = CGFloat(20)
    static let labelTopMargin = CGFloat(50)
    static let animateDuration = 0.5
    static let bannerAppearanceDuration: TimeInterval = 3

    static func show(_ text: String) {
        DispatchQueue.main.async {

            guard let superView = UIApplication.shared.windows.first?.rootViewController?.view
            else { return }

            let height = CGFloat(64)
            let width = superView.bounds.size.width

            let bannerView = UIView(frame: CGRect(x: 0,
                                                  y: 0-height,
                                                  width: width,
                                                  height: height))
            bannerView.layer.opacity = 0.95
            bannerView.layer.cornerRadius = 10
            bannerView.backgroundColor = UIColor.systemPink
            bannerView.translatesAutoresizingMaskIntoConstraints = false

            let label = UILabel(frame: CGRect.zero)
            label.textColor = UIColor.white
            label.numberOfLines = 0
            label.text = text
            label.translatesAutoresizingMaskIntoConstraints = false

            bannerView.addSubview(label)
            superView.addSubview(bannerView)

            let labelBottomConstraint = NSLayoutConstraint(item: label,
                                                           attribute: .bottom,
                                                           relatedBy: .equal,
                                                           toItem: bannerView,
                                                           attribute: .bottom,
                                                           multiplier: 1,
                                                           constant: -15)

            let bannerCenterXConstraint = NSLayoutConstraint(item: bannerView,
                                                             attribute: .leading,
                                                             relatedBy: .equal,
                                                             toItem: superView,
                                                             attribute: .leading,
                                                             multiplier: 1,
                                                             constant: 0)

            let bannerTrailingConstraint = NSLayoutConstraint(item: bannerView,
                                                             attribute: .trailing,
                                                             relatedBy: .equal,
                                                             toItem: superView,
                                                             attribute: .trailing,
                                                             multiplier: 1,
                                                             constant: 0)

            let bannerTopConstraint = NSLayoutConstraint(item: bannerView,
                                                         attribute: .top,
                                                         relatedBy: .equal,
                                                         toItem: superView,
                                                         attribute: .top,
                                                         multiplier: 1,
                                                         constant: 0-height)

            let labelCenterXConstraint = NSLayoutConstraint(item: label,
                                                            attribute: .centerX,
                                                            relatedBy: .equal,
                                                            toItem: bannerView,
                                                            attribute: .centerX,
                                                            multiplier: 1,
                                                            constant: 0)

            let labelTopConstraint = NSLayoutConstraint(item: label,
                                                        attribute: .top,
                                                        relatedBy: .equal,
                                                        toItem: bannerView,
                                                        attribute: .top,
                                                        multiplier: 1,
                                                        constant: labelTopMargin)

            NSLayoutConstraint.activate([bannerCenterXConstraint,
                                         bannerTrailingConstraint,
                                         bannerTopConstraint,
                                         labelCenterXConstraint,
                                         labelBottomConstraint,
                                         labelTopConstraint])

            // Show Notification Banner
            UIView.animate(withDuration: animateDuration) {
                bannerTopConstraint.constant = 0
                superView.layoutIfNeeded()
            }

            // Remove Notification Banner
            UIView.animate(withDuration: animateDuration,
                           delay: bannerAppearanceDuration,
                           options: [],
                           animations: {
                            bannerTopConstraint.constant = 0 - bannerView.frame.height
                            superView.layoutIfNeeded()
                           }, completion: { finished in
                            if finished {
                                bannerView.removeFromSuperview()
                            }
                           })
        }
    }
}
