//
//  NearbyGliderCalloutView.swift
//  Glider Tool
//
//  Created by Peter Hauke on 23.03.20.
//  Copyright © 2020 Denis Leupold. All rights reserved.
//

// https://docs.mapbox.com/ios/maps/examples/custom-callout/

import Mapbox

// MARK: - NearbyGliderCalloutView
class NearbyGliderCalloutView: UIView {

    // MARK: Lets and Vars
    // MARK: ... own

    // MARK: ... for MGLCalloutViewProtocol
    var representedObject: MGLAnnotation
    private lazy var nearbyGliderAnnotation: NearbyGliderAnnotation = {
        guard let nearbyGliderAnnotation = representedObject as? NearbyGliderAnnotation
            else { fatalError("Must be a NearbyGliderAnnotaion.") }
        return nearbyGliderAnnotation
    }()

    // Allow the callout to remain open during panning.
    let dismissesAutomatically: Bool = false
    let isAnchoredToAnnotation: Bool = true

    // https://github.com/mapbox/mapbox-gl-native/issues/9228
    override var center: CGPoint {

        get {
            return super.center
        }

        set {
            var newCenter = newValue
            newCenter.y -= bounds.midY
            super.center = newCenter

            updateAltitudeAndClimbrateLabel()

        }

    }

    lazy var leftAccessoryView = UIView() /* unused */
    lazy var rightAccessoryView = UIView() /* unused */

    weak var delegate: MGLCalloutViewDelegate?

    // MARK: IBOutlets
    @IBOutlet weak var flarmIDLabel: UILabel!
    @IBOutlet weak var altitudeLabel: UILabel!
    @IBOutlet weak var climbRateLabel: UILabel!
    @IBOutlet weak var climRateImage: UIImageView!

    // MARK: - Init&Co.
    required init(representedObject: MGLAnnotation) {
        fatalError("Not implemented yet. See init(decoder:)")
    }

    required init?(coder decoder: NSCoder) {
        self.representedObject = MGLPointAnnotation()

        super.init(coder: decoder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        setupOutline(radius: 5)
    }

    // MARK: - Custom view styling
    private func setupOutline(radius: CGFloat,
                              corners: UIRectCorner = .allCorners) {
        // Hint: corners = [.topLeft, .topRight]
        let path = UIBezierPath(roundedRect: bounds,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))

        // mask
        let mask = CAShapeLayer()
        mask.path = path.cgPath

        // color line
        mask.strokeColor = UIColor.darkGray.cgColor
        mask.fillColor = nil

        layer.mask = mask
        layer.addSublayer(mask)
    }

    private func updateAltitudeAndClimbrateLabel() {
        altitudeLabel.text = String(format: "%.0fm", nearbyGliderAnnotation.gliderTelemetryData.altitude)
        climbRateLabel.text =  "\(nearbyGliderAnnotation.gliderTelemetryData.climbRate)m/s"

        // ClimRate Indicator Image
        if nearbyGliderAnnotation.gliderTelemetryData.climbRate < 0 {
            climRateImage.image = UIImage(systemName: "arrowtriangle.down.fill")?.withTintColor(.red,
                                                                                                renderingMode: .alwaysOriginal)
        } else {
            climRateImage.image = UIImage(systemName: "arrowtriangle.up.fill")?.withTintColor(.green,
                                                                                              renderingMode: .alwaysOriginal)
        }
    }

}

// MARK: - Extension - MGLCalloutView Protocol
extension NearbyGliderCalloutView: MGLCalloutView {

    func presentCallout(from rect: CGRect,
                        in view: UIView,
                        constrainedTo constrainedRect: CGRect,
                        animated: Bool) {

        delegate?.calloutViewWillAppear?(self)

        // UI
        var flarmIDText: String // Alternativ: = Buddy.forFlarmID(gliderTelemetryData.flarmID)?.name ?? gliderTelemetryData.flarmID
        if let buddy = Buddy.forFlarmID(nearbyGliderAnnotation.gliderTelemetryData.flarmID) {
            flarmIDText = buddy.name
        } else {
            flarmIDText = nearbyGliderAnnotation.gliderTelemetryData.flarmID
        }
        flarmIDLabel.text = flarmIDText

        updateAltitudeAndClimbrateLabel()

        // View handling
        view.addSubview(self)

        delegate?.calloutViewDidAppear?(self)
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

    // MARK: Callout interaction handlers
//    func isCalloutTappable() -> Bool {
//        if let delegate = delegate {
//            if delegate.responds(to: #selector(MGLCalloutViewDelegate.calloutViewShouldHighlight)) {
//                return delegate.calloutViewShouldHighlight!(self)  //swiftlint:disable:this force_unwrapping
//            }
//        }
//        return false
//    }
//
//    @objc func calloutTapped() {
//        if isCalloutTappable()
//            && ((delegate?.responds(to: #selector(MGLCalloutViewDelegate.calloutViewTapped))) != nil) {
//            delegate?.calloutViewTapped!(self)  //swiftlint:disable:this force_unwrapping
//        }
//    }

}

// MARK: - Extension - NibName()
extension NearbyGliderCalloutView {

    class func nibName() -> String {
        let typeString: String = String(describing: self)
        return typeString
    }

}
