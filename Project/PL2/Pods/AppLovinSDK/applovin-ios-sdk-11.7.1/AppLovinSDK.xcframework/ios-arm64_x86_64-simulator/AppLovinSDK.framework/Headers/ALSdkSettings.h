//
//  ALSdkSettings.h
//  AppLovinSDK
//
//  Copyright © 2020 AppLovin Corporation. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN

/**
 * This class contains settings that enable the AppLovin consent flow.
 */
@interface ALConsentFlowSettings : NSObject
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@end

/**
 * This class contains settings for the AppLovin SDK.
 */
@interface ALSdkSettings : NSObject

/**
 * Settings relating to the AppLovin consent flow.
 */
@property (nonatomic, strong, readonly) ALConsentFlowSettings *consentFlowSettings;

/**
 * A toggle for verbose logging for the SDK. This is set to @c NO by default. Set it to @c NO if you want the SDK to be silent (this is recommended for App Store
 * submissions).
 *
 * If set to @c YES AppLovin messages will appear in the standard application log which is accessible via the console. All AppLovin log messages are prefixed
 * with the @code /AppLovinSdk: [AppLovinSdk] @endcode tag.
 *
 * Verbose logging is <em>disabled</em> (@c NO) by default.
 *
 * @see <a href="https://dash.applovin.com/documentation/mediation/ios/getting-started/advanced-settings#enable-verbose-logging">MAX Integration Guide ⇒ iOS ⇒ Advanced Settings ⇒ Enable Verbose Logging</a>
 */
@property (nonatomic, assign, getter=isVerboseLoggingEnabled) BOOL verboseLoggingEnabled;

/**
 * Whether to begin video ads in a muted state or not. Defaults to @c NO unless you change this in the dashboard.
 *
 * @see <a href="https://dash.applovin.com/documentation/mediation/ios/getting-started/advanced-settings#mute-audio">MAX Integration Guide ⇒ iOS ⇒ Advanced Settings ⇒ Mute Audio</a>
 */
@property (nonatomic, assign, getter=isMuted) BOOL muted;

/**
 * Whether the Creative Debugger will be displayed after flipping the device screen down twice. Defaults to @c YES.
 *
 * @see <a href="https://dash.applovin.com/documentation/mediation/ios/testing-networks/creative-debugger">MAX Integration Guide ⇒ iOS ⇒ Testing Networks ⇒ Creative Debugger</a>
 */
@property (nonatomic, assign, getter=isCreativeDebuggerEnabled) BOOL creativeDebuggerEnabled;

/**
 * Enable devices to receive test ads by passing in the advertising identifier (IDFA) of each test device.
 * Refer to AppLovin logs for the IDFA of your current device.
 */
@property (nonatomic, copy) NSArray<NSString *> *testDeviceAdvertisingIdentifiers;

/**
 * The MAX ad unit IDs that you will use for this instance of the SDK. This initializes third-party SDKs with the credentials configured for these ad unit IDs.
 */
@property (nonatomic, copy) NSArray<NSString *> *initializationAdUnitIdentifiers;

/**
 * Whether or not the AppLovin SDK listens to exceptions. Defaults to @c YES.
 */
@property (nonatomic, assign, getter=isExceptionHandlerEnabled) BOOL exceptionHandlerEnabled;

/**
 * Whether or not the AppLovin SDK will collect the device location from `CLLocationManager` if available. Defaults to @c YES.
 */
@property (nonatomic, assign, getter=isLocationCollectionEnabled) BOOL locationCollectionEnabled;

/**
 * A copy of the extra parameters that are currently set.
 */
@property (nonatomic, copy) NSDictionary<NSString *, NSString *> *extraParameters;

/**
 * Set an extra parameter to pass to the AppLovin server.
 *
 * @param key   Parameter key. Must not be nil.
 * @param value Parameter value. May be nil.
 */
- (void)setExtraParameterForKey:(NSString *)key value:(nullable NSString *)value;

@end

@interface ALSdkSettings (ALDeprecated)
@property (nonatomic, assign) BOOL isVerboseLogging __deprecated_msg("This property is deprecated and will be removed in a future SDK version. Please use `-[ALSdkSettings isVerboseLoggingEnabled]` instead.");
@end

@interface ALConsentFlowSettings (ALDeprecated)
@property (nonatomic, assign, getter=isEnabled) BOOL enabled __deprecated_msg("This API has been deprecated and will be removed in a future release.");
@property (nonatomic, copy, nullable) NSURL *privacyPolicyURL __deprecated_msg("This API has been deprecated and will be removed in a future release.");
@property (nonatomic, copy, nullable) NSURL *termsOfServiceURL __deprecated_msg("This API has been deprecated and will be removed in a future release.");
@end

NS_ASSUME_NONNULL_END
