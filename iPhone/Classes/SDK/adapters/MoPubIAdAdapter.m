//
//  MoPubIAdAdapter.m
//  SimpleAds
//
//  Created by Nafis Jamal on 10/25/10.
//  Copyright 2010 Stanford. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MoPubIAdAdapter.h"
#import "MoPubNativeSDKRegistry.h"
#import "AdController.h"

@implementation MoPubIAdAdapter

@synthesize adView;

+ (NSString *)networkType { 
	return @"iAd";
}

+ (void)load {
	[[MoPubNativeSDKRegistry sharedRegistry] registerClass:self];
}


- (void)getAdWithParams:(NSDictionary *)params{	
	Class cls = NSClassFromString(@"ADBannerView");
	if (cls != nil) {
		adBannerView = [[ADBannerView alloc] initWithFrame:self.adController.view.frame];
		adBannerView.requiredContentSizeIdentifiers = [NSSet setWithObjects:ADBannerContentSizeIdentifier320x50, ADBannerContentSizeIdentifier480x32, nil];
		adBannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifier320x50;
		adBannerView.delegate = self;
		
		// put an AdBanner on top of the current view so it can 
		// do animations and Z ordering properly on click... 
		self.adController.nativeAdView = adBannerView;
		[self.adController.view.superview addSubview:adBannerView];
		
		// hide the webview so that it doesn't shine through
		self.adController.webView.hidden = YES;
	} else {
		// iOS versions before 4 
		[self bannerView:nil didFailToReceiveAdWithError:nil];
	}
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner{
	NSLog(@"MOPUB: iAd Load Succeeded");
	[self.adController nativeAdLoadSucceededWithResults:nil];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
	NSLog(@"MOPUB: Failed to load iAd");
	[self.adController nativeAdLoadFailedwithError:error];
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave {	
	[self.adController nativeAdTrackAdClick];
	return YES;
}

- (void)rotateToOrientation:(UIInterfaceOrientation)orientation {
	ADBannerView *iAdView = (ADBannerView *)self.adController.nativeAdView;
	if (iAdView == nil) return;
	if (UIInterfaceOrientationIsLandscape(orientation)) {
		iAdView.currentContentSizeIdentifier = ADBannerContentSizeIdentifier480x32;
	}
	else {
		iAdView.currentContentSizeIdentifier = ADBannerContentSizeIdentifier320x50;
	}
	// ADBanner positions itself in the center of the super view, which we do not
	// want, since we rely on publishers to resize the container view.
	// position back to 0,0
	iAdView.frame = CGRectMake(0.0, 
							   0.0, 
							   iAdView.frame.size.width, 
							   iAdView.frame.size.height);
}

- (void)dealloc{
	[adBannerView release];
	[super dealloc];
}


@end