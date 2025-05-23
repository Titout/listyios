//
//  squircle.swift
//  SharedKit (Generated by SwiftyLaunch 2.0)
//  https://docs.swiftylaun.ch/module/sharedkit/view-modifier/squircle
//

import SwiftUI

struct Squircle: ViewModifier {

	let width: CGFloat  // = height

	func body(content: Content) -> some View {
		content
			.frame(width: width, height: width)
			// App Squircle corner radius estimation
			.clipShape(RoundedRectangle(cornerRadius: width * (2 / 9), style: .continuous))

	}
}

extension View {

	/// Makes the view an Squircle to mimic iOS App icon shape
	/// - Parameter width: The width of the view (height will be equal to it)
	public func squircle(width: CGFloat) -> some View {
		modifier(Squircle(width: width))
	}
}

#Preview {
	Image(.appIconPreview)
		.resizable()
		.squircle(width: 256)
}
