//
//  UIColorExtension.m
//  NavCogMiraikan
//
/*******************************************************************************
 * Copyright (c) 2023 © Miraikan - The National Museum of Emerging Science and Innovation
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

#import "UIColorExtension.h"
#import "NavUtil.h"

@implementation UIColor (Extension)


#define TALK_COLOR              [UIColor colorWithRed: 50.0/255.0 green:92.0/255.0 blue:128.0/255.0 alpha:1]
#define TALK_DARK_COLOR         [UIColor colorWithRed: 50.0/255.0 green:92.0/255.0 blue:128.0/255.0 alpha:1]
#define TALK_BACKGROUND_COLOR         [UIColor colorWithRed: 243.5/255.0 green:243.5/255.0 blue:243.5/255.0 alpha:1]
#define TALK_BACKGROUND_DARK_COLOR    [UIColor colorWithRed: 243.5/255.0 green:243.5/255.0 blue:243.5/255.0 alpha:1]
#define WAIT_COLOR              [UIColor colorWithRed: 255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1]
#define WAIT_DARK_COLOR         [UIColor colorWithRed: 255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1]
#define WAIT_BACKGROUND_COLOR         [UIColor colorWithRed: 0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.5]
#define WAIT_BACKGROUND_DARK_COLOR    [UIColor colorWithRed: 0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.5]
#define OVERLAY_BACKGROUND_COLOR          [UIColor colorWithRed: 255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.75]
#define OVERLAY_BACKGROUND_DARK_COLOR     [UIColor colorWithRed: 255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.75]

+ (UIColor*)talkColor                   { return [NavUtil isDarkMode] ? TALK_DARK_COLOR : TALK_COLOR; }
+ (UIColor*)talkBackgroundColor         { return [NavUtil isDarkMode] ? TALK_BACKGROUND_DARK_COLOR : TALK_BACKGROUND_COLOR; }
+ (UIColor*)waitColor                   { return [NavUtil isDarkMode] ? WAIT_DARK_COLOR : WAIT_COLOR; }
+ (UIColor*)waitBackgroundColor         { return [NavUtil isDarkMode] ? WAIT_BACKGROUND_DARK_COLOR : WAIT_BACKGROUND_COLOR; }
+ (UIColor*)overlayBackgroundkColor     { return [NavUtil isDarkMode] ? OVERLAY_BACKGROUND_DARK_COLOR : OVERLAY_BACKGROUND_COLOR; }

@end
