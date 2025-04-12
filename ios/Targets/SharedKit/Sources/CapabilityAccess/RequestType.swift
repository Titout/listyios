//
//  RequestType.swift
//  SharedKit (Generated by SwiftyLaunch 2.0)
//  https://docs.swiftylaun.ch/module/sharedkit/request-permissions
//

import AVFoundation  // camera, microphone access
import Contacts  // contact access
import CoreLocation  // location access
import EventKit  //calendar, reminders access
import Photos  // photo library access
import StoreKit  // app review prompt
import SwiftUI

// The Request Process is as follows: (for permissions)
// First time we request -> Show Sheet that says "Allow Access".
// If the user presses on "Allow Access" -> Request Access via system alert.
// If the user presses on "Allow Acccess" and then doesn't allow access via system alert,
// we will show the same sheet every time we request access, but instead of "Allow Access" it will say "Open Settings".
// If the user presses on "Open Settings" -> We open the settings app on the app's page.

public enum RequestType: Identifiable {

	/// Ask the user for a review
	case appRating

	/// Ask the user for photo library access
	case photosAccess

	/// Ask the user for camera access
	case cameraAccess

	/// Ask the user for microphone access
	case microphoneAccess

	/// Ask the user for location access
	case locationAccess

	/// Ask the user for contact access
	case contactsAccess

	/// Ask the user for calendar access
	case calendarAccess

	/// Ask the user for reminders access
	case remindersAccess

	// Note:  Notification Access is provided through NotifKit! (see showNotificationsPermissionsSheet.swift)

	public var id: Int {
		hashValue
	}

	public var data: RequestTypeData {
		switch self {
			case .appRating:
				return RequestTypeData(
					sfSymbolName: "star.leadinghalf.filled",
					title: "Rate the App",
					subtitle:
						"If you like the app, please consider rating it on the App Store. It helps a lot!",
					footerNote: nil,
					ctaText: "Rate the App"
				)
			case .photosAccess:
				return RequestTypeData(
					sfSymbolName: "photo.on.rectangle.angled",
					title: "Allow Access to Photos?",
					subtitle: "With Access to your Photo\nLibrary, we can do cool stuff.",
					footerNote: "We won't spy on you, we promise.",
					ctaText: "Allow Photos Access"
				)
			case .cameraAccess:
				return RequestTypeData(
					sfSymbolName: "camera.viewfinder",
					title: "Allow Camera Access?",
					subtitle: "With Access to your Camera,\nwe can do cool stuff.",
					footerNote: "We won't spy on you, we promise.",
					ctaText: "Allow Camera Access"
				)
			case .microphoneAccess:
				return RequestTypeData(
					sfSymbolName: "mic.circle",
					title: "Allow Microphone Access?",
					subtitle: "With Access to your Microphone,\nwe can do cool stuff.",
					footerNote: "We won't spy on you, we promise.",
					ctaText: "Allow Microphone Access"
				)

			case .locationAccess:
				return RequestTypeData(
					sfSymbolName: "location.fill.viewfinder",
					title: "Allow Location Access?",
					subtitle: "With Access to your Location,\nwe can do cool stuff.",
					footerNote: "We won't spy on you, we promise.",
					ctaText: "Allow Location Access"
				)

			case .contactsAccess:
				return RequestTypeData(
					sfSymbolName: "rectangle.stack.badge.person.crop",
					title: "Sync your Contacts?",
					subtitle: "With Access to your Contacts,\nwe can do cool stuff.",
					footerNote: "We won't spy on you, we promise.",
					ctaText: "Allow Contacts Sync"
				)

			case .calendarAccess:
				return RequestTypeData(
					sfSymbolName: "calendar.badge.plus",
					title: "Sync your Calendar?",
					subtitle: "With Access to your Calendar,\nwe can do cool stuff.",
					footerNote: "We won't spy on you, we promise.",
					ctaText: "Allow Calendar Access"
				)

			case .remindersAccess:
				return RequestTypeData(
					sfSymbolName: "checklist",
					title: "Sync your Reminders?",
					subtitle: "With Access to your Reminders,\nwe can do cool stuff.",
					footerNote: "We won't spy on you, we promise.",
					ctaText: "Allow Reminders Access"
				)

		}
	}

	/// We will use this function to check if the user has already given permission, so we just ignore the request
	@MainActor public var permissionStatus: () async -> RequestPermissionStatus {
		switch self {

			// in this case, its not permission, but rather have we already asked for a review
			// We want to show the review prompt every 10th time the user performs some action. (For example, 10th to-do is completed)
			// So, every 10th time, we prompt the user our sheet. If he denies rating in our sheet, we will show it again the next 10th action time.
			// If he presses on "Rate the App" in our sheet, we will show him the system prompt. After the system prompt has been shown once,
			// we will just consume the askUserFor(.appRating) and not show anything.
			case .appRating:
				return {

					// We obviously don't want to show it the first time the user opens the app.
					// If yes, just return .gotPermission, which equals to "successful" (don't show the sheet, continue with the app)
					let lastAppVersionAppWasOpenedAt =
						UserDefaults.standard.string(
							forKey: Constants.UserDefaults.General.lastAppVersionAppWasOpenedAt)
						?? "NONE"
					if lastAppVersionAppWasOpenedAt == "NONE"
						|| lastAppVersionAppWasOpenedAt != Constants.AppData.appVersion
					{
						return .gotPermission
					}

					// Check if user already clicked on "Rate the App" Button in our sheet (meaning, that we've already showed the system review prompt)
					// If yes, we just return .gotPermission (don't show the sheet, continue with the app)
					if UserDefaults.standard.bool(
						forKey: Constants.UserDefaults.General.alreadyAskedForAppReviewThroughSystemPrompt
					) {
						return .gotPermission
					}

					// Check if its the 10th time the user performs an action, only then we will show the sheet (and reset the counter back to 0)
					let userPerformedActionCount = UserDefaults.standard.integer(
						forKey: Constants.UserDefaults.General.positiveActionPerformedCount
					)

					print(
						"Action executed \(userPerformedActionCount) times. Will show review sheet on exection no. \(Constants.General.positiveActionThreshold)."
					)

					if userPerformedActionCount >= Constants.General.positiveActionThreshold {

						print("Showing Review Sheet!")

						// set it back to 0
						UserDefaults.standard.set(
							0, forKey: Constants.UserDefaults.General.positiveActionPerformedCount)

						// We can show the sheet now
						return .notYetAsked
					} else {

						// otherwise, we increment the counter and return .gotPermission
						UserDefaults.standard.set(
							userPerformedActionCount + 1,
							forKey: Constants.UserDefaults.General.positiveActionPerformedCount)
						return .gotPermission
					}

				}
			case .photosAccess:
				return {
					let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
					switch status {
						case .notDetermined:
							return .notYetAsked
						case .restricted:
							return .denied
						case .denied:
							return .denied
						case .authorized:
							return .gotPermission
						case .limited:  // means that we do have access to the library, but just not all of it.
							return .gotPermission
						@unknown default:  // This is for future proofing, if Apple adds more cases.
							return .denied
					}
				}
			case .cameraAccess:
				return {
					let status = AVCaptureDevice.authorizationStatus(for: .video)
					switch status {
						case .notDetermined:
							return .notYetAsked
						case .restricted:
							return .denied
						case .denied:
							return .denied
						case .authorized:
							return .gotPermission
						@unknown default:  // This is for future proofing, if Apple adds more cases.
							return .denied
					}
				}
			case .microphoneAccess:
				return {
					let status = AVCaptureDevice.authorizationStatus(for: .audio)
					switch status {
						case .notDetermined:
							return .notYetAsked
						case .restricted:
							return .denied
						case .denied:
							return .denied
						case .authorized:
							return .gotPermission
						@unknown default:  // This is for future proofing, if Apple adds more cases.
							return .denied
					}
				}
			case .locationAccess:
				return {
					if !CLLocationManager.locationServicesEnabled() {
						// means that users device doesn't even have location services enabled!
						showInAppNotification(
							.warning,
							content: .init(
								title: "Location Services Disabled",
								message: "Enable it in Privacy & Security Settings"))
						return .denied
					}
					let status = CLLocationManager().authorizationStatus
					switch status {
						case .notDetermined:
							return .notYetAsked
						case .authorizedAlways:
							return .gotPermission
						case .authorizedWhenInUse:
							return .gotPermission
						case .restricted:
							return .denied
						case .denied:
							return .denied
						@unknown default:  // This is for future proofing, if Apple adds more cases.
							return .denied
					}
				}
			case .contactsAccess:
				return {
					let status = CNContactStore.authorizationStatus(for: CNEntityType.contacts)

					switch status {
						case .notDetermined:
							return .notYetAsked
						case .authorized:
							return .gotPermission
						case .denied:
							return .denied
						case .restricted:
							return .denied
						case .limited:
							return .gotPermission
						@unknown default:
							return .denied  // This is for future proofing, if Apple adds more cases.
					}
				}
			case .calendarAccess:
				return {
					do {
						let eventStore = EKEventStore()
						let granted = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Bool, Error>) in
							eventStore.requestAccess(to: .event) { granted, error in
								if let error = error {
									continuation.resume(throwing: error)
								} else {
									continuation.resume(returning: granted)
								}
							}
						}
						return granted ? .gotPermission : .denied
					} catch {
						return .denied
					}
				}
			case .remindersAccess:
				return {
					do {
						let eventStore = EKEventStore()
						let granted = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Bool, Error>) in
							eventStore.requestAccess(to: .reminder) { granted, error in
								if let error = error {
									continuation.resume(throwing: error)
								} else {
									continuation.resume(returning: granted)
								}
							}
						}
						return granted ? .gotPermission : .denied
					} catch {
						return .denied
					}
				}
		}
	}

	/// True -> the user has accepted the request
	/// False -> the user has denied the request (dimissed the sheet)
	public var requestAction: () async -> Bool {
		switch self {
			case .appRating:
				return {
					let windowScene = await UIApplication.shared.connectedScenes.first as? UIWindowScene

					if let windowScene {
						// if we got window, show the app rating prompt in it
						await AppStore.requestReview(in: windowScene)

						// set in userdefaults that we have shown the prompt
						UserDefaults.standard.set(
							true,
							forKey: Constants.UserDefaults.General
								.alreadyAskedForAppReviewThroughSystemPrompt)
					}
					return true
				}
			case .photosAccess:
				return {
					let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)

					switch status {
						case .notDetermined:
							return false
						case .restricted:
							return false
						case .denied:
							return false
						case .authorized:
							return true
						case .limited:  // means that we do have access to the library, but just not all of it.
							return true
						@unknown default:  // This is for future proofing, if Apple adds more cases.
							return false
					}
				}
			case .cameraAccess:
				return {
					return await AVCaptureDevice.requestAccess(for: .video)
				}
			case .microphoneAccess:
				return {
					return await AVCaptureDevice.requestAccess(for: .audio)
				}
			case .locationAccess:
				return {
					// we are going to check it anyways, as the screenState changes with the location permission alert.  (see onAppearAndChange of RequestSheetView)
					CLLocationManager().requestAlwaysAuthorization()
					return false
				}
			case .contactsAccess:
				return {
					do {
						return try await CNContactStore().requestAccess(for: .contacts)
					} catch {
						return false
					}
				}
			case .calendarAccess:
				return {
					do {
						let eventStore = EKEventStore()
						return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Bool, Error>) in
							eventStore.requestAccess(to: .event) { granted, error in
								if let error = error {
									continuation.resume(throwing: error)
								} else {
									continuation.resume(returning: granted)
								}
							}
						}
					} catch {
						return false
					}
				}
			case .remindersAccess:
				return {
					do {
						let eventStore = EKEventStore()
						return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Bool, Error>) in
							eventStore.requestAccess(to: .reminder) { granted, error in
								if let error = error {
									continuation.resume(throwing: error)
								} else {
									continuation.resume(returning: granted)
								}
							}
						}
					} catch {
						return false
					}
				}
		}
	}

}

public enum RequestPermissionStatus {

	/// Means the user has not yet given permission
	case notYetAsked

	/// Means the user has already given permission
	case gotPermission

	/// Means the user has denied and we  should send the user to the settings
	case denied
}

/// Data to be shown on the RequestSheet
public struct RequestTypeData: Identifiable {
	public let id = UUID()
	let sfSymbolName: String
	let title: LocalizedStringKey
	let subtitle: LocalizedStringKey
	let footerNote: LocalizedStringKey?
	var ctaText: LocalizedStringKey
}
