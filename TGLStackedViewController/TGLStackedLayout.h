//
//  TGLStackedLayout.h
//  TGLStackedViewController
//
//  Created by Tim Gleue on 07.04.14.
//  Copyright (c) 2014 Tim Gleue ( http://gleue-interactive.com )
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import <UIKit/UIKit.h>

@interface TGLStackedLayout : UICollectionViewLayout

/** Margins between collection view and items. Default is UIEdgeInsetsMake(20.0, 0.0, 0.0, 0.0) */
@property (nonatomic, assign) IBInspectable UIEdgeInsets layoutMargin;

/** Size of items or automatic dimensions when 0.
 *
 * If either width or height or both are set to 0 (default)
 * the respective dimensions ares computed automatically
 * from the collection view's bounds minus the margins
 * defined in property -layoutMargin.
 */
@property (nonatomic, assign) IBInspectable CGSize itemSize;

/** Amount to show of each stacked item. Default is 120.0 */
@property (nonatomic, assign) IBInspectable CGFloat topReveal;

/** Amount of compression/expansing when scrolling bounces. Default is 0.2 */
@property (nonatomic, assign) IBInspectable CGFloat bounceFactor;

/** Scale factor for moving item. Default is 0.95 */
@property (nonatomic, assign) IBInspectable CGFloat movingItemScaleFactor;

/** Set to YES to ignore -topReveal and arrange items evenly in collection view's bounds, if items do not fill entire height. Default is `NO` */
@property (nonatomic, assign, getter = isFillingHeight) IBInspectable BOOL fillHeight;

/** Set to YES to center a single item vertically, honoring -layoutMargin. When multiple items are present this property is ignored. Defualt is `NO` */ 
@property (nonatomic, assign, getter = isCenteringSingleItem) IBInspectable BOOL centerSingleItem;

/** Set to YES to enable bouncing even when items do not fill entire height. Default is `NO` */
@property (nonatomic, assign, getter = isAlwaysBouncing) IBInspectable BOOL alwaysBounce;

/** Use -contentOffset instead of collection view's actual content offset for next layout */
@property (nonatomic, assign) BOOL overwriteContentOffset;

/** Content offset value to replace actual value when -overwriteContentOffset is `YES` */
@property (nonatomic, assign) CGPoint contentOffset;

@end
