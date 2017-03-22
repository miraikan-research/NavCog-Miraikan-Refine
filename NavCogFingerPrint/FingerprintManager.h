/*******************************************************************************
 * Copyright (c) 2014, 2016  IBM Corporation, Carnegie Mellon University and others
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *******************************************************************************/

#import <Foundation/Foundation.h>
#import "HLPFingerprint.h"
#import "HLPBeaconSampler.h"

@class FingerprintManager;

@protocol FingerprintManagerDelegate

@required
// return if observe one more fingerprint sample
-(void)manager:(FingerprintManager*)manager didStatusChanged:(BOOL)isReady;
-(BOOL)manager:(FingerprintManager*)manager didObservedBeacons:(int)beaconCount atSample:(int)sampleCount;
-(void)manager:(FingerprintManager*)manager didSendData:(NSString*)idString withError:(NSError*)error;
@end

@interface FingerprintManager : NSObject <HLPBeaconSamplerDelegate>

@property id<FingerprintManagerDelegate> delegate;
@property (readonly) BOOL isReady;
@property (readonly) BOOL isSampling;
@property (readonly) long visibleBeaconCount;
@property (readonly) long beaconsSampleCount;
@property NSArray *floorplans;
@property NSMutableDictionary *refpoints;
@property NSMutableArray *samples;
@property (readonly) HLPRefpoint *selectedRefpoint;


+(instancetype)sharedManager;

-(void)load;
-(void)select:(HLPRefpoint*)rp;
-(void)startSamplingAtLat:(double)lat Lng:(double)lng;
-(void)cancel;
-(void)sendData;
-(void)deleteFingerprint:(NSString*)idString;

@end
