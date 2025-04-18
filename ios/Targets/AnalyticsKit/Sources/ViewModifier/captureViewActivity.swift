//
//  captureViewActivity.swift
//  AnalyticsKit (Generated by SwiftyLaunch 2.0)
//  https://docs.swiftylaun.ch/module/analyticskit/capture-view-activity
//

import PostHog
import SwiftUI

struct CaptureScreenModifier: ViewModifier {

	@Environment(\.scenePhase) var scenePhase
	let viewName: String

	func body(content: Content) -> some View {
		content
			.onAppear {
				captureScreenView(viewName)
			}
	}

	private func captureScreenView(_ screenName: String) {
		var propertiesToSend: [String: Any] = [:]
		// additionally attach the source of the event, because we will also capture events from the backend (source will be "backend")
		propertiesToSend["endpoint_source"] = "app"
		print("[ANALYTICS] Captured active screen: \(screenName)")
		PostHogSDK.shared.screen(screenName, properties: propertiesToSend)
	}

}

extension View {
	/// This modifier will notify PostHog when a View is active
	public func captureViewActivity(as viewName: String) -> some View {
		modifier(CaptureScreenModifier(viewName: viewName))
	}
}
