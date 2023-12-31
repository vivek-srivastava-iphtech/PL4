// Copyright 2016 Google Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import <Foundation/Foundation.h>
#import <GoogleMobileAds/GoogleMobileAds.h>

typedef NS_ENUM(NSInteger, GADFBAdFormat) {
  GADFBAdFormatNative,        ///< Native.
  GADFBAdFormatNativeBanner,  ///< Native Banner.
};

/// Network extras for the Meta Audience Network adapter.
@interface GADFBNetworkExtras : NSObject <GADAdNetworkExtras>

/// The native ad format to request. Has no effect when applied to non-native ad requests.
@property(nonatomic, assign) GADFBAdFormat nativeAdFormat;

@end
