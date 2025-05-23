//
//  VoiceRecordingViewModel.swift
//  AIKit (Generated by SwiftyLaunch 2.0)
//  https://docs.swiftylaun.ch/module/aikit/ai-translator-example
//

import AnalyticsKit
import Combine
import SharedKit
import SwiftUI

// The View Name for Analytics Capture (in this case view model)
private let viewName = "VoiceRecordingViewModel"

/// Is used to connect VoiceRecordingManager with the UI
class VoiceRecordingViewModel: ObservableObject {

	/// Recording flag to show the UI that we are currently recording
	@Published public private(set) var isCurrentlyRecording: Bool = false

	/// Mirrors the currentAudioTranscription variable of VoiceTranscriptionModel (in init)
	@Published var currentAudioTranscription: String? = nil

	/// The VoiceRecordingManager that will handle the recording
	@ObservedObject var voiceRecordingManager = VoiceRecordingManager()

	/// We can call generalAudioModel to play audio via its playAudio function
	public var generalAudioModel = GeneralAudioModel()

	private var holdingDownFor: Float = 0

	/// Cancellable storage for Combine subscribers.
	private var cancelables = Set<AnyCancellable>()

	init() {
		voiceRecordingManager.voiceTranscriptionModel.$currentAudioTranscription.sink { [weak self] audioTranscription in
			self?.currentAudioTranscription = audioTranscription
		}.store(in: &cancelables)
	}

	/// Usually called when a user pressed the recording button for some time, will start the recording session (to avoid accidental recordings)
	func shouldStartRecording() {
		print("[VOICE RECORDING VM]: SHOULD START RECORDING")
		Analytics.capture(.info, id: "should_start_recording", source: .aikit, fromView: viewName)
		Haptics.impact(style: .rigid)

		Task {
			try? await Task.sleep(for: .seconds(0.15))  // a little delay for the haptic to be felt

			withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.40, blendDuration: 0.5)) {

				/// Start recording
				voiceRecordingManager.startRecording()

				/// Set the recording flag to true
				self.isCurrentlyRecording = true
			}
		}
	}

	/// Usually called when a user releases the recording button, will end the recording session
	func shouldStopRecording() {
		print("[VOICE RECORDING VM]: SHOULD STOP RECORDING")
		Analytics.capture(.info, id: "should_stop_recording", source: .aikit, fromView: viewName)
		Haptics.impact(style: .soft)
		/// Stop recording, success is true because we cancelled the recording ourselves and not because of an error
		voiceRecordingManager.stopRecording(success: true)

		withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.40, blendDuration: 0.5)) {
			/// Set the recording flag to false
			self.isCurrentlyRecording = false
		}
	}
}
