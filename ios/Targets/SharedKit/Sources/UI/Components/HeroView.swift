//
//  HeroView.swift
//  SharedKit (Generated by SwiftyLaunch 2.0)
//  https://docs.swiftylaun.ch/module/sharedkit/ui#hero-view-component
//

import SwiftUI

public enum HeroViewSize {
	case small
	case medium
	case large
	
	var iconSize: CGFloat {
		switch self {
		case .small: return 24
		case .medium: return 36
		case .large: return 56
		}
	}
}

/// Display important information with this view.
public struct HeroView: View {

	let sfSymbolName: String
	let title: LocalizedStringKey
	let subtitle: LocalizedStringKey?
	private let size: HeroViewSize
	@State private var isAnimating = false

	public init(
		sfSymbolName: String,
		title: LocalizedStringKey,
		subtitle: LocalizedStringKey? = nil,
		size: HeroViewSize = .large,
		bounceOnAppear: Bool = false
	) {
		self.sfSymbolName = sfSymbolName
		self.title = title
		self.subtitle = subtitle
		self.size = size
		self._isAnimating = State(initialValue: bounceOnAppear)
	}

	public var body: some View {
		VStack(spacing: 12) {
			Image(systemName: sfSymbolName)
				.font(.system(size: size.iconSize))
				.foregroundColor(.gray)
				.scaleEffect(isAnimating ? 1.1 : 1.0)
				.animation(isAnimating ? .spring(response: 0.3, dampingFraction: 0.5) : nil, value: isAnimating)

			Text(title)
				.font(.headline)
				.multilineTextAlignment(.center)

			if let subtitle {
				Text(subtitle)
					.font(.subheadline)
					.foregroundColor(.gray)
					.multilineTextAlignment(.center)
			}
		}
		.padding()
		.onAppear {
			if isAnimating {
				withAnimation {
					isAnimating.toggle()
				}
			}
		}
	}
}

private struct PreviewView: View {

	var body: some View {
		VStack(spacing: 20) {
			HeroView(
				sfSymbolName: "person.fill",
				title: "Example View",
				subtitle: "This is an example of what the HeroView looks like.",
				bounceOnAppear: true
			)
			
			HeroView(
				sfSymbolName: "person.fill",
				title: "Example View"
			)
		}
	}

}

#Preview { PreviewView() }
