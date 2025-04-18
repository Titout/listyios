//
//  showNotificationsPermissionSheetIfNeeded.swift
//  NotifKit (Generated by SwiftyLaunch 2.0)
//  https://docs.swiftylaun.ch/module/notifkit/ask-for-permission
//

import SharedKit
import SwiftUI

// NOTE: Don't confuse Notifications with Push Notifications
// Notifications via Notifications Center -> Internal way to communicate within the application
// Push Notifications -> Alerts, Messages, etc. that are sent to the user from the server

extension PushNotifications {
	/// Call this to show the sheet (will be shown if the user has already given his permission to send push notifications
	/// Recommended: Use @MainActor when calling this function to avoid calling it from a background thread
	static public func showNotificationsPermissionsSheet() {
		NotificationCenter.default
			.post(
				name: Constants.Notifications.PushNotifications.shouldShowNotificationRequestSheet,
				object: nil
			)
	}
}

/// Will show a sheet that will ask the user to give permission for push notifications, when `showNotificationsPermissionsSheet()` is called
public struct ShowPushNotificationPermissionSheetIfNeededModifier: ViewModifier {
	@State private var showSheet = false

	public init() {}

	public func body(content: Content) -> some View {
		content
			.sheet(isPresented: $showSheet) {
				NotificationsPermissionView(onDismiss: {
					showSheet = false
				})
			}
			// If we receive a Notification, show the sheet
			.onReceive(
				NotificationCenter.default.publisher(
					for: Constants.Notifications.PushNotifications.shouldShowNotificationRequestSheet)
			) { _ in
				Task {
					if !(await PushNotifications.hasNotificationsPermission()) {  //Don't show the sheet if the user already gave permission
						showSheet = true
					}
				}
			}
	}
}
