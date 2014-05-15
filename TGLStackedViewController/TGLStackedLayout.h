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
@property (assign, nonatomic) UIEdgeInsets layoutMargin;

/** Size of items if set to value not equal CGSizeZero.
 *
 * If set to CGSizeZero (default) item sizes are computed
 * from the collection view's bounds minus the margins defined
 * in property -layoutMargin.
 */
@property (assign, nonatomic) CGSize itemSize;

/** Amount to show of each stacked item. Default is 120.0 */
@property (assign, nonatomic) CGFloat topReveal;

/** Amount of compression/expansing when scrolling bounces. Default is 0.2 */
@property (assign, nonatomic) CGFloat bounceFactor;

/** Set to YES to ignore -topReveal and arrange items evenly in collection view's bounds, if items do not fill entire height. Default is NO. */
@property (assign, nonatomic, getter = isFillingHeight) BOOL fillHeight;

/** Set to YES to enable bouncing even when items do not fill entire height. Default is NO. */
@property (assign, nonatomic, getter = isAlwaysBouncing) BOOL alwaysBounce;

/** Use -contentOffset instead of collection view's actual content offset for next layout */
@property (assign, nonatomic) BOOL overwriteContentOffset;

/** Content offset value to replace actual value when -overwriteContentOffset is YES */
@property (assign, nonatomic) CGPoint contentOffset;

/** Index path of item currently being moved, and thus being hidden */
@property (strong, nonatomic) NSIndexPath *movingIndexPath;

/** Check if layout needs update for new moving location.
 *
 * This method is called by the view controller, when an item
 * is moved around interactively by the user, e.g. via a gesture
 * recognizer. Invalidates layout and updates -movingIndexPath
 * if required.
 *
 * @param movingLocation Location of item at -movingIndexPath to test
 *        and update layout for if necessary.
 * @param targetBlock Block being called to retarget proposed destinationIndexPath
 *        computed from movingLocation. The block returns the new location, or
 *        nil if teh item's location should not be updated.
 * @param updateBlock Block being called when movingLocation results in
 *        in a new location for item at -movingIndexPath.
 */
- (void)invalidateLayoutIfNecessaryWithMovingLocation:(CGPoint)movingLocation targetBlock:(NSIndexPath* (^) (NSIndexPath *sourceIndexPath, NSIndexPath *proposedDestinationIndexPath))targetBlock updateBlock:(void (^) (NSIndexPath *fromIndexPath, NSIndexPath *toIndexPath))updateBlock;

@end
