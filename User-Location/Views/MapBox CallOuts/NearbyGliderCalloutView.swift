//
//  NearbyGliderCalloutView.swift
//  Glider Tool
//
//  Created by Peter Hauke on 23.03.20.
//  Copyright © 2020 Denis Leupold. All rights reserved.
//

// https://docs.mapbox.com/ios/maps/examples/custom-callout/

import Mapbox

class NearbyGliderCalloutView: UIView, MGLCalloutView {

    class func nibName() -> String {
        let typeString: String = String(describing: self)
        return typeString
    }

    @IBOutlet weak var flarmIDLabel: UILabel!
    @IBOutlet weak var altitudeLabel: UILabel!
    @IBOutlet weak var climbRateLabel: UILabel!

    var representedObject: MGLAnnotation

    // Allow the callout to remain open during panning.
    let dismissesAutomatically: Bool = false
    let isAnchoredToAnnotation: Bool = true

    // https://github.com/mapbox/mapbox-gl-native/issues/9228
    override var center: CGPoint {
        set {
            var newCenter = newValue
            newCenter.y -= bounds.midY
            super.center = newCenter
        }
        get {
            return super.center
        }
    }

    lazy var leftAccessoryView = UIView() /* unused */
    lazy var rightAccessoryView = UIView() /* unused */

    weak var delegate: MGLCalloutViewDelegate?

    let tipHeight: CGFloat = 10.0
    let tipWidth: CGFloat = 20.0

    //let mainBody: UIButton

    required init(representedObject: MGLAnnotation) {
        fatalError("Not implemented yet. See init(decoder:)")
//        self.representedObject = representedObject

//        self.mainBody = UIButton(type: .system)

//        super.init(frame: .zero)

//        backgroundColor = .clear
//
//        mainBody.backgroundColor = .darkGray
//        mainBody.tintColor = .white
//        mainBody.contentEdgeInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
//        mainBody.layer.cornerRadius = 4.0
//
//        addSubview(mainBody)
    }

    required init?(coder decoder: NSCoder) {
        self.representedObject = MGLPointAnnotation()

        super.init(coder: decoder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        roundCorners(radius: 5)
    }

    // MARK: - MGLCalloutView API
    func presentCallout(from rect: CGRect,
                        in view: UIView,
                        constrainedTo constrainedRect: CGRect,
                        animated: Bool) {

        delegate?.calloutViewWillAppear?(self)

        guard let nearbyGliderAnnotaion = representedObject as? NearbyGliderAnnotaion
            else { fatalError("Must be a NearbyGliderAnnotaion.") }
        
        flarmIDLabel.text = nearbyGliderAnnotaion.gliderTelemetryData.flarmID
        altitudeLabel.text = "\(nearbyGliderAnnotaion.gliderTelemetryData.altitude)"
        climbRateLabel.text = "\(nearbyGliderAnnotaion.gliderTelemetryData.climbRate)"

        view.addSubview(self)

        delegate?.calloutViewDidAppear?(self)

//        view.addSubview(self)
//
//        // Prepare title label.
//        mainBody.setTitle(representedObject.title!, for: .normal)
//        mainBody.sizeToFit()
//
//        if isCalloutTappable() {
//            // Handle taps and eventually try to send them to the delegate (usually the map view).
//            mainBody.addTarget(self, action: #selector(CustomCalloutView.calloutTapped), for: .touchUpInside)
//        } else {
//            // Disable tapping and highlighting.
//            mainBody.isUserInteractionEnabled = false
//        }
//
//        // Prepare our frame, adding extra space at the bottom for the tip.
//        let frameWidth = mainBody.bounds.size.width
//        let frameHeight = mainBody.bounds.size.height + tipHeight
//        let frameOriginX = rect.origin.x + (rect.size.width/2.0) - (frameWidth/2.0)
//        let frameOriginY = rect.origin.y - frameHeight
//        frame = CGRect(x: frameOriginX, y: frameOriginY, width: frameWidth, height: frameHeight)
//
//        if animated {
//            alpha = 0
//
//            UIView.animate(withDuration: 0.2) { [weak self] in
//                guard let strongSelf = self else {
//                    return
//                }
//
//                strongSelf.alpha = 1
//                strongSelf.delegate?.calloutViewDidAppear?(strongSelf)
//            }
//        } else {
//            delegate?.calloutViewDidAppear?(self)
//        }
    }

    func dismissCallout(animated: Bool) {
        if superview != nil {
            if animated {
                UIView.animate(withDuration: 0.2, animations: { [weak self] in
                    self?.alpha = 0
                    }, completion: { [weak self] _ in
                        self?.removeFromSuperview()
                })
            } else {
                removeFromSuperview()
            }
        }
    }

    // MARK: - Callout interaction handlers

    func isCalloutTappable() -> Bool {
        if let delegate = delegate {
            if delegate.responds(to: #selector(MGLCalloutViewDelegate.calloutViewShouldHighlight)) {
                return delegate.calloutViewShouldHighlight!(self)
            }
        }
        return false
    }

    @objc func calloutTapped() {
        if isCalloutTappable() && delegate!.responds(to: #selector(MGLCalloutViewDelegate.calloutViewTapped)) {
            delegate!.calloutViewTapped!(self)
        }
    }



    // MARK: - Custom view styling
    func roundCorners(radius: CGFloat,
                      corners: UIRectCorner = .allCorners) {
        // Hint: corners = [.topLeft, .topRight]
        let path = UIBezierPath(roundedRect: bounds,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }

//Keep it! 25.03.2020, ph
//    override func draw(_ rect: CGRect) {
//
//        // Draw the pointed tip at the bottom.
//        let fillColor: UIColor = .darkGray
//
//        let tipLeft = rect.origin.x + (rect.size.width / 2.0) - (tipWidth / 2.0)
//        let tipBottom = CGPoint(x: rect.origin.x + (rect.size.width / 2.0), y: rect.origin.y + rect.size.height)
//        let heightWithoutTip = rect.size.height - tipHeight - 1
//
//        let currentContext = UIGraphicsGetCurrentContext()!
//
//        let tipPath = CGMutablePath()
//        tipPath.move(to: CGPoint(x: tipLeft, y: heightWithoutTip))
//        tipPath.addLine(to: CGPoint(x: tipBottom.x, y: tipBottom.y))
//        tipPath.addLine(to: CGPoint(x: tipLeft + tipWidth, y: heightWithoutTip))
//        tipPath.closeSubpath()
//
//        fillColor.setFill()
//        currentContext.addPath(tipPath)
//        currentContext.fillPath()
//    }

}
