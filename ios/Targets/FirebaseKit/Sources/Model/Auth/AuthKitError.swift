//
//  Errors.swift
//  FirebaseKit (Generated by SwiftyLaunch 2.0)
//

import AnalyticsKit
import FirebaseAuth
import Foundation
import SharedKit

//MARK: - AuthKit Errors

/// Only user-facing errors are defined here, errors that users have no business to know about land in catch-all errors
public enum AuthKitError: Error {

	//Sign In with Email Errors
	case invalidCredential
	case invalidEmail
	case emailAlreadyInUse
	case wrongPassword
	case userDisabled
	case userNotFound
	case defaultSignInWithEmailError

	// Sign in with Apple Errors
	case defaultSignInWithAppleError

	// Sign Up with Email Errors
	case defaultSignUpWithEmailError

	// Sign Out Error
	case defaultSignOutError

	// Account Deletion Errors
	case defaultUserDeletionError  // catch-all error for account Deletion

	case noUserSignedIn  // no user is signed in (for operations that are relevant to the user - account deletion, rename, etc)

	case reauthRequired  // sensitive operation requires re-authentication

	case defaultUserNameUpdateError  // catch-all error for errors that happen when user tries to change account name

	case defaultUserDataRefreshError  // catch-all error for errors that happen when we try to refresh user data

	// Email Verification Errors
	case invalidRecipientEmail  // error that indicated that the verification email recipient is invalid
	case defaultSendVerificationEmailError  // catch-all error for errors that happen when we try to request verification email

	// New Password Errors
	case weakPassword  // when user tries to create an account with a weak password or change password to a weak password
	case defaultNewPasswordError  // catch-all error for errors that happen when we try to reset password

	case defaultResetPasswordError  // catch-all error for errors that happen when the user tries to reset the password (forgot password)

	case catchAllError  // unhandled error

	// Note: AnalyticsID will only be used if AnalyticsKit is enabled
	var values: (notifContent: InAppNotificationContent, analyticsID: String) {
		switch self {
			case .invalidCredential:
				return (
					.init(title: "Couldn't Sign In", message: "Invalid Input"),
					"email_signin_invalid_credential"
				)
			case .invalidEmail:
				return (
					.init(title: "Invalid Email Address", message: "Email Address is malformed"),
					"email_auth_invalid_email"
				)
			case .emailAlreadyInUse:
				return (
					.init(title: "Email Already in Use", message: "Choose another Email Address"),
					"email_signup_email_already_in_use"
				)
			case .wrongPassword:
				return (
					.init(title: "Incorrect Password", message: "Try another password"),
					"email_signin_wrong_password"
				)
			case .userDisabled:
				return (
					.init(title: "User Disabled", message: "This User's Account is disabled"),
					"email_signin_user_disabled"
				)
			case .userNotFound:
				return (
					.init(title: "Couldn't find User", message: "User's Account could not be found"),
					"email_signin_user_not_found"
				)
			case .defaultSignInWithEmailError:
				return (
					.init(title: "Couldn't Sign In", message: "Error Signing In with Email"),
					"email_signin_catchall"
				)
			case .defaultSignInWithAppleError:
				return (
					.init(title: "Couldn't Sign In", message: "Error Signing In with Apple"),
					"signin_with_apple_catchall"
				)
			case .noUserSignedIn:
				return (
					.init(title: "Couldn't Delete User", message: "No User is currently signed in"),
					"delete_noone_signed_in"
				)
			case .defaultUserDeletionError:
				return (.init(title: "Couldn't Delete User", message: "Try again later"), "delete_user_catchall")
			case .reauthRequired:
				return (
					.init(title: "Re-Authentication Required", message: "Please, re-authenticate"),
					"reauth_required"
				)
			case .defaultSignUpWithEmailError:
				return (.init(title: "Couldn't Sign Up", message: "Try again later"), "email_signup_catchall")
			case .defaultUserNameUpdateError:
				return (
					.init(title: "Error Updating Username", message: "Try again later"),
					"username_update_catchall"
				)
			case .defaultUserDataRefreshError:
				return (
					.init(title: "Error Refreshing User Data", message: "Try again later"),
					"user_data_refresh_catchall"
				)
			case .invalidRecipientEmail:
				return (
					.init(title: "Error Sending Verification Email", message: "Invalid Email Address"),
					"verification_email_invalid_recipient"
				)
			case .defaultSendVerificationEmailError:
				return (.init(title: "Error Sending Verification Email", message: "Try again later"), "")
			case .defaultSignOutError:
				return (.init(title: "Error Signing Out", message: "Try again later."), "sign_out")
			case .weakPassword:
				return (
					.init(title: "Weak Password", message: "Password doesn't meet security requirements"),
					"weak_password"
				)
			case .defaultNewPasswordError:
				return (
					.init(title: "Error Setting New Password", message: "Try again later"),
					"new_password_catchall"
				)
			case .defaultResetPasswordError:
				return (
					.init(title: "Error Resetting Password", message: "Try again later"),
					"reset_password_catchall"
				)
			case .catchAllError:
				return (.init(title: "Error Performing Operation", message: "Try again later"), "catchall")

		}
	}

	func sendToAnalytics(longDescription: String) {
		Analytics.capture(.error, id: self.values.analyticsID, longDescription: longDescription, source: .auth)
	}

	func showAsInAppNotification() {
		showInAppNotification(.error, content: self.values.notifContent, size: .compact)
	}

}

// Extension of FirebaseAuthErrors to be able to convert to AuthKit Errors declared above.
extension AuthErrorCode {
	public var asAuthKitError: AuthKitError {
		switch self {
			case .invalidCredential:
				return .invalidCredential
			case .invalidEmail:
				return .invalidEmail
			case .emailAlreadyInUse:
				return .emailAlreadyInUse
			case .wrongPassword:
				return .wrongPassword
			case .userDisabled:
				return .userDisabled
			case .userNotFound:
				return .userNotFound
			case .requiresRecentLogin:
				return .reauthRequired
			case .invalidRecipientEmail:
				return .invalidRecipientEmail
			case .invalidSender:
				return .defaultSendVerificationEmailError
			case .invalidMessagePayload:
				return .defaultSendVerificationEmailError
			case .keychainError:
				return .defaultSignOutError
			case .weakPassword:
				return .weakPassword
			default:
				return .catchAllError
		}
	}
}

/// Default way to handle firebase error
/// We usually want to pass up the error, so we rethrow it
/// We take an error, see that its an authkit error, if not, we set it to default error and throw it.
/// We also send the error to analytics (If AnalyticsKit is enabled)
func handleFirebaseError(error: Error, defaultAuthKitError: AuthKitError) throws {
	if let authError = (error as? AuthErrorCode)?.asAuthKitError {
		authError.sendToAnalytics(longDescription: error.localizedDescription)
		throw authError
	}

	let fallbackError = defaultAuthKitError
	fallbackError.sendToAnalytics(longDescription: error.localizedDescription)
	throw fallbackError
}

/// Will try the passed closure function and if an error occurs, it will show an error notification.
/// Fallback notification is shown if an error occurs but the error isnt an AuthKitError, meaning we dont have a specific error to show.
/// For that reason a fallback notification should be a vague error describing what has failed.
/// For example: Error signing in should say *What* has failed -> "Sign in Error" or "Error Signing In", and not something like "Operation Failed"
func tryFunctionOtherwiseShowInAppNotification(fallbackNotificationContent: InAppNotificationContent, function: () throws -> Void)
{
	do {
		try function()
	} catch {
		guard let error = error as? AuthKitError else {
			showInAppNotification(.error, content: fallbackNotificationContent, size: .compact)
			return
		}
		error.showAsInAppNotification()
	}
}

/// Will try the passed closure function and if an error occurs, it will show an error notification.
/// Fallback notification is shown if an error occurs but the error isnt an AuthKitError, meaning we dont have a specific error to show.
/// For that reason a fallback notification should be a vague error describing what has failed.
/// For example: Error signing in should say *What* has failed -> "Sign in Error" or "Error Signing In", and not something like "Operation Failed"
func tryFunctionOtherwiseShowInAppNotification(
	fallbackNotificationContent: InAppNotificationContent, function: () async throws -> Void
) async {
	do {
		try await function()
	} catch {
		guard let error = error as? AuthKitError else {
			showInAppNotification(.error, content: fallbackNotificationContent)
			return
		}
		error.showAsInAppNotification()
	}
}
