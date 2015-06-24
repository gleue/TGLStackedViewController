//
//  TGLExposedLayout.h
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

typedef NS_ENUM(NSInteger, TGLExposedLayoutPinningMode) {

    TGLExposedLayoutPinningModeNone = 0,    /* Do not pin unexpsed items */
    TGLExposedLayoutPinningModeBelow,       /* Pin items below exposed item */
    TGLExposedLayoutPinningModeAll          /* Pin all unexposed items */
};

/** Collection view layout showing a single exposed
 *  item full size and adjacent items collapsed with
 *  configurable overlap.
 *
 * Scrolling is not possible since -collectionViewContentSize
 * is the same as the collection view's bounds.size.
 */
@interface TGLExposedLayout : UICollectionViewLayout

/** Margins between collection view and items. Default is UIEdgeInsetsMake(40.0, 0.0, 0.0, 0.0) */
@property (assign, nonatomic) UIEdgeInsets layoutMargin;

/** Size of items or automatic dimensions when 0.
 *
 * If either width or height or both are set to 0 (default)
 * the respective dimensions are computed automatically
 * from the collection view's bounds minus the margins
 * defined in property -layoutMargin.
 */
@property (assign, nonatomic) CGSize itemSize;

/** Amount of overlap for items above exposed item. Default 20.0 */
@property (assign, nonatomic) CGFloat topOverlap;

/** Amount of overlap for items below exposed item. Default 20.0 */
@property (assign, nonatomic) CGFloat bottomOverlap;

/** Number of items overlapping below exposed item. Default 1 */
@property (assign, nonatomic) NSUInteger bottomOverlapCount;

/** Layout mode for other than exposed items. Default `TGLExposedLayoutPinningModeNone` */
@property (assign, nonatomic) TGLExposedLayoutPinningMode pinningMode;

/** The number of items above the exposed item to be pinned. Default 2 */
@property (assign, nonatomic) NSUInteger topPinningCount;

/** The number of items below the exposed item to be pinned. Default 2 */
@property (assign, nonatomic) NSUInteger bottomPinningCount;

- (instancetype)initWithExposedItemIndex:(NSInteger)exposedItemIndex;

@end
