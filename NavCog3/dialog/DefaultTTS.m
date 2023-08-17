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

#import "DefaultTTS.h"
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "NavDeviceTTS.h"
#import "NavSound.h"

@implementation DefaultTTS

- (void)speak:(NSString * _Nullable)text callback:(void (^ _Nonnull)(void))callback
{
    [[NavDeviceTTS sharedTTS] speak:text withOptions:@{@"selfspeak": @YES, @"quickAnswer": @NO} completionHandler:callback];
}

- (void)stop
{
    [self stop:NO];
}

- (void)stop:(BOOL)immediate
{
    [[NavDeviceTTS sharedTTS] stop:immediate];
}

- (void)pauseToggle:(BOOL)immediate forcedPause:(BOOL)forcedPause {
    [[NavDeviceTTS sharedTTS] pauseToggle:immediate forcedPause:forcedPause];
}

- (void)vibrate
{
    [[NavSound sharedInstance] vibrate:nil];
}

- (void)playVoiceRecoStart
{
    [[NavSound sharedInstance] playVoiceRecoStart];
}

@end
