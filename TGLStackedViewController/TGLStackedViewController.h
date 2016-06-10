//
//  TGLStackedViewController.h
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

#import "TGLStackedLayout.h"
#import "TGLExposedLayout.h"

@interface TGLStackedViewController : UICollectionViewController

/** The collection view layout object used when all items are collapsed.
 *
 * When using storyboards, this property is only intialized in method
 * `-viewDidLoad`.
 */
@property (nonatomic, readonly, nullable) TGLStackedLayout *stackedLayout;

/** The collection view layout object used when a single item is exposed. */
@property (nonatomic, readonly, nullable) TGLExposedLayout *exposedLayout;

/** Margins between collection view and items when exposed.
 *
 * Changes to this property take effect on next
 * item being selected, i.e. exposed.
 *
 * Default value is UIEdgeInsetsMake(40.0, 0.0, 0.0, 0.0)
 */
@property (nonatomic, assign) IBInspectable UIEdgeInsets exposedLayoutMargin;

/** Size of items when exposed if set to value not equal CGSizeZero.
 *
 * Changes to this property take effect on next
 * item being selected, i.e. exposed.
 *
 * Default value is CGSizeZero
 */
@property (nonatomic, assign) IBInspectable CGSize exposedItemSize;

/** Amount of overlap for items above exposed item.
 *
 * The value is effective only if `-exposedPinningMode`
 * is equal to `TGLExposedLayoutPinningModeNone` and
 * ignored otherwise. Changes to this property take
 * effect on next item being selected, i.e. exposed.
 *
 * Default value is 20.0
 */
@property (nonatomic, assign) IBInspectable CGFloat exposedTopOverlap;

/** Amount of overlap for items below exposed item.
 *
 * The value is effective only if `-exposedPinningMode`
 * is equal to `TGLExposedLayoutPinningModeNone` and
 * ignored otherwise. Changes to this property take
 * effect on next item being selected, i.e. exposed.
 *
 * Default value is 20.0
 */
@property (nonatomic, assign) IBInspectable CGFloat exposedBottomOverlap;

/** Number of items overlapping below exposed item.
 *
 * The value is effective only if `-exposedPinningMode`
 * is equal to `TGLExposedLayoutPinningModeNone` and
 * ignored otherwise. Changes to this property take
 * effect on next item being selected, i.e. exposed.
 *
 * Default value is 1
 */
@property (nonatomic, assign) IBInspectable NSUInteger exposedBottomOverlapCount;

/** Layout mode for other than exposed items.
 *
 * Controls how the items surrounding the exposed item
 * above and below should be layed out. When set to
 * `TGLExposedLayoutPinningModeNone` items are pushed to
 * the top and the bottom edges of the exposed item,
 * overlapping upwards and downwards by `-exposedTopOverlap`
 * and `-exposedBottomOverlap`. This is the default.
 *
 * When set to `TGLExposedLayoutPinningModeBelow` the
 * items above the exposed item are pushed to the exposed
 * item's top edge as above, while the items below are pinned
 * to the collection view's bottom edge, and overlapping upwards.
 *
 * When set to `TGLExposedLayoutPinningModeAll` all items but
 * the exposed item are pinned to the collection view's bottom
 * edge, and overlapping upwards.
 *
 * Default value is `TGLExposedLayoutPinningModeNone`
 */
@property (nonatomic, assign) TGLExposedLayoutPinningMode exposedPinningMode;

/** The number of items above the exposed item to be pinned.
 *
 * The value is effective only if `-exposedPinningMode`
 * is not equal to `TGLExposedLayoutPinningModeNone` and
 * ignored otherwise. Changes to this property take
 * effect on next item being selected, i.e. exposed.
 *
 * Default value is 2
 */
@property (nonatomic, assign) IBInspectable NSUInteger exposedTopPinningCount;

/** The number of items below the exposed item to be pinned.
 *
 * The value is effective only if `-exposedPinningMode`
 * is not equal to `TGLExposedLayoutPinningModeNone` and
 * ignored otherwise. Changes to this property take
 * effect on next item being selected, i.e. exposed.
 *
 * Default value is 2
 */
@property (nonatomic, assign) IBInspectable NSUInteger exposedBottomPinningCount;

/** Index path of currently exposed item.
 *
 * The exposed item's selected state is YES.
 *
 * When user exposes an item this property
 * contains the item's index path. The value
 * is nil if no item is exposed.
 *
 * Set this property to a valid item index path
 * location to expose it, instead of the current
 * one, or set to nil to collapse all items.
 */
@property (nonatomic, strong, nullable) NSIndexPath *exposedItemIndexPath;

/** Allow the overlapping parts of unexposed items
 * to be tapped and thus select another item.
 *
 * If set to NO (default), the currently exposed item
 * has to be tapped to deselect before another item
 * may be selected.
 */
@property (nonatomic, assign) IBInspectable BOOL unexposedItemsAreSelectable;

/** Factor used to scale items while moving them.
 *
 * Default value is 0.95
 */
@property (nonatomic, assign) IBInspectable CGFloat movingItemScaleFactor;

/** Returns the class to use when creating the exposed layout.
 *
 * If you subclass `TGLExposedLayout` overwrite this method
 * and return your subclass.
 */
+ (nonnull Class)exposedLayoutClass;

@end
