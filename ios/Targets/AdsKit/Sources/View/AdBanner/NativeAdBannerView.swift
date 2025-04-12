//
//  NativeAdBannerView.swift
//  AdsKit (Generated by SwiftyLaunch 2.0)
//

import GoogleMobileAds
import SwiftUI
import UIKit

// NOTE: This ad banner was built following google admob native ad guidelines:
// https://support.google.com/admob/answer/6329638
// Make sure to follow them if you make any changes to the ad
class NativeAdBannerView: GADNativeAdView {

	let adContainerView = UIView()
	let adIcon = UIImageView()
	let adHeadlineLabel = UILabel()
	let adBodyLabel = UILabel()
	let adCTAButton = UIButton()
	let adTagLabel = UILabelPadded()

	init() {
		super.init(frame: .zero)
		setupViews()
	}

	func setupViews() {

		// top and bottom borders
		self.borders(for: [.top, .bottom], width: 0.75, color: UIColor.secondarySystemFill)

		// set up all the view variables
		setupAdContainerView()
		setupAdHeadlineLabel()
		setupAdBodyLabel()
		setupAdCTAButton()
		setupAdTagLabel()
		setupAdIcon()

		// and add all the views to the containers
		adContainerView.addSubview(adHeadlineLabel)
		adContainerView.addSubview(adBodyLabel)
		adContainerView.addSubview(adIcon)
		adContainerView.addSubview(adCTAButton)

		// add the container and ad tag label to the parent ad view (=self.)
		self.addSubview(adContainerView)
		self.addSubview(adTagLabel)

		NSLayoutConstraint.activate([
			// fill the view with 5 padding on vertical edges and 7.5 padding on horizontal edges
			adContainerView.topAnchor.constraint(equalTo: self.topAnchor, constant: 7.5),
			adContainerView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -7.5),
			adContainerView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5),
			adContainerView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5),

			// set the icon to go edge to edge with 7.5 padding
			adIcon.topAnchor.constraint(equalTo: adContainerView.topAnchor, constant: 7.5),
			adIcon.bottomAnchor.constraint(equalTo: adContainerView.bottomAnchor, constant: -7.5),
			adIcon.leadingAnchor.constraint(equalTo: adContainerView.leadingAnchor, constant: 7.5),
			// first we set the height according to the container, and because the icon is a square
			// we set the width to be qual to height
			adIcon.widthAnchor.constraint(equalTo: adIcon.heightAnchor, multiplier: 1.0),

			// set the cta button to go edge to edge with 7.5 padding
			adCTAButton.topAnchor.constraint(equalTo: adContainerView.topAnchor, constant: 7.5),
			adCTAButton.bottomAnchor.constraint(equalTo: adContainerView.bottomAnchor, constant: -7.5),
			adCTAButton.trailingAnchor.constraint(equalTo: adContainerView.trailingAnchor, constant: -7.5),

			// set the headline to be placed 6.5 from the top (instead of 7.5 for visual balance)
			// and between the icon and the cta button with 5 padding
			adHeadlineLabel.topAnchor.constraint(equalTo: adContainerView.topAnchor, constant: 6.5),
			adHeadlineLabel.leadingAnchor.constraint(equalTo: adIcon.trailingAnchor, constant: 5),
			adHeadlineLabel.trailingAnchor.constraint(equalTo: adCTAButton.leadingAnchor, constant: -5),

			// ad body is placed right under the headline
			// also goes from where the headline begins (leading sides aligned) to
			// the cta button (with 5 padding)
			adBodyLabel.topAnchor.constraint(equalTo: adHeadlineLabel.bottomAnchor, constant: 0),
			adBodyLabel.leadingAnchor.constraint(equalTo: adHeadlineLabel.leadingAnchor, constant: 0),
			adBodyLabel.trailingAnchor.constraint(equalTo: adCTAButton.leadingAnchor, constant: -5),

			// ad tag label is placed in the bottom right corner
			// bottom of 1 because we have a border there and we don't want to cover it
			adTagLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -1),
			adTagLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
		])
	}

	func setupAdContainerView() {
		adContainerView.translatesAutoresizingMaskIntoConstraints = false

		// Will probably not show up as the correct accent color in the preview,
		// but works correctly when running on an actual device.
		adContainerView.borders(for: [.all], width: 1, color: UIColor(Color.accent))
		adContainerView.layer.cornerRadius = 12.5
		adContainerView.layer.cornerCurve = .continuous
		adContainerView.clipsToBounds = true
	}

	func setupAdIcon() {
		// hidden until the app is loaded, see updateUIView in AdBanner
		adIcon.isHidden = true
		adIcon.translatesAutoresizingMaskIntoConstraints = false
		adIcon.layer.cornerRadius = 7.5
		adIcon.layer.cornerCurve = .continuous

		// border for when there icons background is white
		adIcon.layer.borderWidth = 0.3
		adIcon.layer.borderColor = UIColor(Color.black.opacity(0.3)).cgColor
		adIcon.clipsToBounds = true
		self.iconView = adIcon
	}

	func setupAdHeadlineLabel() {
		// hidden until the app is loaded, see updateUIView in AdBanner
		adHeadlineLabel.isHidden = true
		adHeadlineLabel.translatesAutoresizingMaskIntoConstraints = false

		// placeholder default text. will not be shown in the app, because we hide the label until
		// we load its contents and then set the views to the value of the fetched data.
		// but you can use this text as for debugging, as it meets the requirement of google admob for
		// ad headline being at least 25 chars before being truncated.
		adHeadlineLabel.text = "Lorem ipsum dolor sit ama"
		adHeadlineLabel.font = .systemFont(ofSize: 17, weight: .semibold)
		adHeadlineLabel.numberOfLines = 1
		adHeadlineLabel.lineBreakMode = .byTruncatingTail
		self.headlineView = adHeadlineLabel
	}

	func setupAdBodyLabel() {
		// hidden until the app is loaded, see updateUIView in AdBanner
		adBodyLabel.isHidden = true
		adBodyLabel.translatesAutoresizingMaskIntoConstraints = false

		// placeholder default text. will not be shown in the app, because we hide the label until
		// we load its contents and then set the views to the value of the fetched data.
		// but you can use this text as for debugging, as it meets the requirement of google admob for
		// body text being at least 90 chars before being truncated.
		adBodyLabel.text = "Lorem ipsum dolor sit amet, consectetur adip iscing elit, sed do eiusmod tempor incididunt"
		adBodyLabel.font = .preferredFont(forTextStyle: .caption2)
		adBodyLabel.numberOfLines = 2
		adBodyLabel.lineBreakMode = .byTruncatingTail
		adBodyLabel.textColor = .secondaryLabel
		self.bodyView = adBodyLabel
	}

	func setupAdCTAButton() {
		// hidden until the app is loaded, see updateUIView in AdBanner
		adCTAButton.isHidden = true
		adCTAButton.translatesAutoresizingMaskIntoConstraints = false
		adCTAButton.isUserInteractionEnabled = false  // must be false for google ads to work

		// placeholder, will be replaced when ad is loaded
		adCTAButton.setTitle("Install", for: .normal)
		adCTAButton.setTitleColor(.white, for: .normal)

		adCTAButton.layer.cornerRadius = 7.5
		adCTAButton.layer.cornerCurve = .continuous
		adCTAButton.clipsToBounds = true
		adCTAButton.backgroundColor = UIColor(Color.accent)
		adCTAButton.titleLabel?.textAlignment = .center

		var buttonConfig = UIButton.Configuration.plain()
		buttonConfig.contentInsets = .init(top: 7.5, leading: 10, bottom: 7.5, trailing: 10)
		adCTAButton.configuration = buttonConfig

		// can't set the font the normal way, because we use configuration
		// https://stackoverflow.com/a/77177403/12596719
		adCTAButton.configuration?.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
			var outgoing = incoming
			outgoing.font = .systemFont(ofSize: 16, weight: .bold)
			return outgoing
		}

		// so that the button doesn't stretch beyond its needed size (text + 12.5 horizontal)
		// https://stackoverflow.com/a/46141544
		adCTAButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)

		self.callToActionView = adCTAButton
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func setupAdTagLabel() {
		adTagLabel.translatesAutoresizingMaskIntoConstraints = false
		adTagLabel.text = String(localized: "Ad")
		adTagLabel.font = .systemFont(ofSize: 11, weight: .bold)
		adTagLabel.textColor = .secondaryLabel
		adTagLabel.numberOfLines = 1
		adTagLabel.lineBreakMode = .byClipping
		adTagLabel.backgroundColor = .systemBackground
		adTagLabel.leftPadding = 2.5
		adTagLabel.rightPadding = 2.5
	}

	/// A subclass of UILabel that allows us to add padding to the label
	/// Inspired by https://stackoverflow.com/a/54722542
	final class UILabelPadded: UILabel {

		var topPadding: CGFloat = 0
		var bottomPadding: CGFloat = 0
		var leftPadding: CGFloat = 0
		var rightPadding: CGFloat = 0

		override func drawText(in rect: CGRect) {
			let insets = UIEdgeInsets(
				top: topPadding,
				left: leftPadding,
				bottom: bottomPadding,
				right: rightPadding
			)

			super.drawText(in: rect.inset(by: insets))
		}

		override var intrinsicContentSize: CGSize {
			let size = super.intrinsicContentSize
			return CGSize(
				width: size.width + leftPadding + rightPadding,
				height: size.height + topPadding + bottomPadding
			)
		}
	}
}
