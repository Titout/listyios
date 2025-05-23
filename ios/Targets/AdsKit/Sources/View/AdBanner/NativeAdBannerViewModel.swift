//
//  NativeAdBannerViewModel.swift
//  AdsKit (Generated by SwiftyLaunch 2.0)
//
import AnalyticsKit
import GoogleMobileAds
import SwiftUI

public class NativeAdBannerViewModel: NSObject, ObservableObject, GADNativeAdLoaderDelegate {

	/// Holds AdMob Native Ad Data
	@Published public var nativeAd: GADNativeAd?

	@Published public var isLoading: Bool = false
	private var adLoader: GADAdLoader!
	private var adUnitID: String

	/// When did we refresh the ad for the last time?
	private var lastRequestTime: Date?

	/// How long should the app wait until refetching a new ad?
	private var requestInterval: Int

	private static var cachedAds: [String: GADNativeAd] = [:]
	private static var lastRequestTimes: [String: Date] = [:]

	public init(adUnitID: String) {
		self.adUnitID = adUnitID
		self.requestInterval = 30
		self.nativeAd = NativeAdBannerViewModel.cachedAds[adUnitID]
		self.lastRequestTime = NativeAdBannerViewModel.lastRequestTimes[adUnitID]
	}

	public func refreshAd() {
		let now = Date()

		// if the last request was made less than 30 minutes ago, we won't refresh the ad
		if nativeAd != nil, let lastRequest = lastRequestTime,
			now.timeIntervalSince(lastRequest) < Double(requestInterval)
		{
			return
		}

		// cancel refreshing ad if the previous ad request is still loading
		guard !isLoading else {
			return
		}

		isLoading = true
		lastRequestTime = now
		NativeAdBannerViewModel.lastRequestTimes[adUnitID] = now

		let adViewOptions = GADNativeAdViewAdOptions()

		// position of google ad symbol
		adViewOptions.preferredAdChoicesPosition = .topRightCorner

		// Create an ad loader, and load the ad
		adLoader = GADAdLoader(adUnitID: adUnitID, rootViewController: nil, adTypes: [.native], options: [adViewOptions])
		adLoader.delegate = self
		adLoader.load(GADRequest())
	}

	/// Called by AdMob when an ad loads successfully
	public func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
		self.nativeAd = nativeAd
		nativeAd.delegate = self
		self.isLoading = false
		NativeAdBannerViewModel.cachedAds[adUnitID] = nativeAd
	}

	/// Called by AdMob when an ad fails to load
	public func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
		print("\(adLoader) failed with error: \(error.localizedDescription)")
		self.isLoading = false
	}
}

// MARK: - GADNativeAdDelegate implementation
extension NativeAdBannerViewModel: GADNativeAdDelegate {
	/// Track when your users views an ad
	public func nativeAdDidRecordImpression(_ nativeAd: GADNativeAd) {
		Analytics.capture(.info, id: "ad_impression", source: .adsKit)
	}

	/// Track when your users click on an ad
	public func nativeAdDidRecordClick(_ nativeAd: GADNativeAd) {
		Analytics.capture(.info, id: "ad_click", source: .adsKit)
	}
}
