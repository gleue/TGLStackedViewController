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

@interface TGLStackedViewController : UICollectionViewController <UIGestureRecognizerDelegate>

/** The collection view layout object used when all items are collapsed. */
@property (strong, readonly, nonatomic) TGLStackedLayout *stackedLayout;

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
@property (strong, nonatomic) NSIndexPath *exposedItemIndexPath;

/** Allow the overlapping parts of unexposed items
 * to be tapped and thus select another item.
 *
 * If set to NO (default), the currently exposed item
 * has to be tapped to deselect before another item
 * may be selected.
 */
@property (assign, nonatomic) BOOL unexposedItemsAreSelectable;

/** Check whether a given cell can be moved.
 *
 * Overload this method to prevent items from
 * being dragged to another location.
 *
 * @param indexPath Index path of item to be moved.
 *
 * @return YES if item can be moved (default); otherwise NO.
 */
- (BOOL)canMoveItemAtIndexPath:(NSIndexPath *)indexPath;

/** Retarget a item's proposed index path while being moved.
 *
 * Overload this method to modify an item's target location
 * while being dragged to another location, e.g. to prevent
 * it from being moved to certain locations.
 *
 * @param sourceIndexPath Moving item's original index path.
 * @param proposedDestinationIndexPath The item's proposed index path during move.
 *
 * @return The item's desired index path. Return proposedDestinationIndexPath if
 *         it is suitable (default); or nil if item should not be moved.
 */
- (NSIndexPath *)targetIndexPathForMoveFromItemAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath;

/** Move item in data source while dragging.
 *
 * Overload this method to update the collection
 * view's data source.
 *
 * @param fromIndexPath Original item indexPath
 * @param toIndexPath New item indexPath
 */
- (void)moveItemAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath;

@end
