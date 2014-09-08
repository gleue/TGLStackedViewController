//
//  TGLStackedViewController.m
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

#import "TGLStackedViewController.h"
#import "TGLStackedLayout.h"
#import "TGLExposedLayout.h"

#define MOVE_ZOOM 0.95

#define SCROLL_PER_FRAME 5.0
#define SCROLL_ZONE_TOP 100.0
#define SCROLL_ZONE_BOTTOM 100.0

typedef NS_ENUM(NSInteger, TGLStackedViewControllerScrollDirection) {

    TGLStackedViewControllerScrollDirectionNone = 0,
    TGLStackedViewControllerScrollDirectionDown,
    TGLStackedViewControllerScrollDirectionUp
};

@interface TGLStackedViewController ()

@property (assign, nonatomic) CGPoint stackedContentOffset;

@property (strong, nonatomic) UIView *movingView;
@property (strong, nonatomic) NSIndexPath *movingIndexPath;
@property (strong, nonatomic) UILongPressGestureRecognizer *moveGestureRecognizer;

@property (assign, nonatomic) TGLStackedViewControllerScrollDirection scrollDirection;
@property (strong, nonatomic) CADisplayLink *scrollDisplayLink;

@end

@implementation TGLStackedViewController

@synthesize stackedLayout = _stackedLayout;

- (instancetype)init {

    self = [super init];
    
    if (self) [self initController];
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {

    self = [super initWithCoder:aDecoder];
    
    if (self) [self initController];
    
    return self;
}

- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout {
    
    self = [super initWithCollectionViewLayout:layout];

    if (self) [self initController];
    
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    if (self) [self initController];
    
    return self;
}

- (void)initController {
    
    _stackedLayout = [[TGLStackedLayout alloc] init];
    
    _exposedLayoutMargin = UIEdgeInsetsMake(40.0, 0.0, 0.0, 0.0);
    _exposedItemSize = CGSizeZero;
    _exposedTopOverlap = 20.0;
    _exposedMaxTopVisibleItems = 1;
    _exposedBottomOverlap = 20.0;
    _exposedMaxBottomVisibleItems = 1;
    
    _movingCellOpaque = NO;
}

#pragma mark - View life cycle

- (void)viewDidLoad {
    
    [super viewDidLoad];

    self.collectionView.collectionViewLayout = self.stackedLayout;
    
    self.moveGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    self.moveGestureRecognizer.delegate = self;

    [self.collectionView addGestureRecognizer:self.moveGestureRecognizer];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    [self.collectionView.collectionViewLayout invalidateLayout];
}

#pragma mark - Accessors

- (void)setExposedItemIndexPath:(NSIndexPath *)exposedItemIndexPath {

    if (![exposedItemIndexPath isEqual:_exposedItemIndexPath]) {

        typeof(self) weakSelf = self;
        
        if (exposedItemIndexPath) {
            [self exposeBeginAtIndexPath:exposedItemIndexPath exposed:YES];

            // Select newly exposed item, possibly
            // deslecting the previous selection,
            // and animate to exposed layout
            //
            [self.collectionView selectItemAtIndexPath:exposedItemIndexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
            
            self.stackedContentOffset = self.collectionView.contentOffset;
            
            TGLExposedLayout *exposedLayout = [[TGLExposedLayout alloc] initWithExposedItemIndex:exposedItemIndexPath.item];
            
            exposedLayout.layoutMargin = self.exposedLayoutMargin;
            exposedLayout.itemSize = self.exposedItemSize;
            exposedLayout.topOverlap = self.exposedTopOverlap;
            exposedLayout.bottomOverlap = self.exposedBottomOverlap;
            exposedLayout.maxTopVisibleItems = self.exposedMaxTopVisibleItems;
            exposedLayout.maxBottomVisibleItems = self.exposedMaxBottomVisibleItems;

            if ([self.collectionView respondsToSelector:@selector(setCollectionViewLayout:animated:completion:)]) {
                [self.collectionView setCollectionViewLayout:exposedLayout animated:YES completion:^(BOOL finished) {
                    if (finished) {
                        [weakSelf exposeEndedAtIndexPath:exposedItemIndexPath exposed:YES];
                    }
                }];
            } else {
                [self.collectionView setCollectionViewLayout:exposedLayout animated:YES];
                [self exposeEndedAtIndexPath:exposedItemIndexPath exposed:YES];
            }
            
        } else {
            NSIndexPath *lastIndexPath = _exposedItemIndexPath;
            [self exposeBeginAtIndexPath:lastIndexPath exposed:NO];
            
            // Deselect the currently exposed item
            // and animate back to stacked layout
            //
            [self.collectionView deselectItemAtIndexPath:self.exposedItemIndexPath animated:YES];
            
            self.stackedLayout.overwriteContentOffset = YES;
            self.stackedLayout.contentOffset = self.stackedContentOffset;
            
            if ([self.collectionView respondsToSelector:@selector(setCollectionViewLayout:animated:completion:)]) {
                [self.collectionView setCollectionViewLayout:self.stackedLayout animated:YES completion:^(BOOL finished) {
                    if (finished) {
                        [weakSelf exposeEndedAtIndexPath:lastIndexPath exposed:NO];
                    }
                }];
            } else {
                [self.collectionView setCollectionViewLayout:self.stackedLayout animated:YES];
                [self exposeEndedAtIndexPath:lastIndexPath exposed:NO];
            }
            [self.collectionView setContentOffset:self.stackedContentOffset animated:NO];
        }
        
        _exposedItemIndexPath = exposedItemIndexPath;
    }
}

#pragma mark - CollectionViewDataSource protocol

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    // Currently, only one single section is
    // supported, therefore MUST NOT be != 1
    //
    return 1;
}

#pragma mark - CollectionViewDelegate protocol

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // When selecting unexposed items is not allowed,
    // prevent them from being highlighted and thus
    // selected by the collection view
    //
    return self.unexposedItemsAreSelectable || self.exposedItemIndexPath == nil || [indexPath isEqual:self.exposedItemIndexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (!self.unexposedItemsAreSelectable && self.exposedItemIndexPath) {
        
        // When selecting unexposed items is not allowed
        // make sure the currently exposed item remains
        // selected
        //
        [collectionView selectItemAtIndexPath:self.exposedItemIndexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    if ([indexPath isEqual:self.exposedItemIndexPath]) {

        // Collapse currently exposed item
        //
        self.exposedItemIndexPath = nil;
        
    } else if (self.unexposedItemsAreSelectable || self.exposedItemIndexPath == nil) {
            
        // Expose new item, possibly collapsing
        // the currently exposed item
        //
        self.exposedItemIndexPath = indexPath;
    }
}

#pragma mark - GestureRecognizerDelegate protocol

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {

    // Long presses, i.e. moving items,
    // only allowed when stacked
    //
    return (self.collectionView.collectionViewLayout == self.stackedLayout);
}

#pragma mark - Methods

- (BOOL)canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // Overload this method to prevent items
    // from being dragged to another location
    //
    return YES;
}

- (NSIndexPath *)targetIndexPathForMoveFromItemAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
    
    // Overload this method to modify an item's
    // target location while being dragged to
    // another proposed location
    //
    return proposedDestinationIndexPath;
}

- (void)moveItemAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    
    // Overload method to update collection
    // view data source when item has been
    // dragged to another location
}

- (void)exposeBeginAtIndexPath:(NSIndexPath *)indexPath exposed:(BOOL)exposed {
    
    // Overload method to add any action
    // before the item expose
}

- (void)exposeEndedAtIndexPath:(NSIndexPath *)indexPath exposed:(BOOL)exposed {
    
    // Overload method to add any action
    // after the item expose
}

#pragma mark - Actions

- (IBAction)handleLongPress:(UILongPressGestureRecognizer *)recognizer {
    
    static CGPoint startCenter;
    static CGPoint startLocation;
    
    switch (recognizer.state) {
            
        case UIGestureRecognizerStateBegan: {
            
            startLocation = [recognizer locationInView:self.collectionView];

            NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:startLocation];

            if (indexPath && [self canMoveItemAtIndexPath:indexPath]) {
                
                UICollectionViewCell *movingCell = [self.collectionView cellForItemAtIndexPath:indexPath];
                
                self.movingView = [[UIView alloc] initWithFrame:movingCell.frame];
                
                startCenter = self.movingView.center;
                
                UIImageView *movingImageView = [[UIImageView alloc] initWithImage:[self screenshotImageOfItem:movingCell]];
                
                movingImageView.alpha = 0.0f;
                
                [self.movingView addSubview:movingImageView];
                [self.collectionView addSubview:self.movingView];
                
                self.movingIndexPath = indexPath;
                
                __weak typeof(self) weakSelf = self;
                
                [UIView animateWithDuration:0.3
                                      delay:0.0
                                    options:UIViewAnimationOptionBeginFromCurrentState
                                 animations:^ (void) {
                                     
                                     __strong typeof(self) strongSelf = weakSelf;
                                     
                                     if (strongSelf) {
                                         
                                         strongSelf.movingView.transform = CGAffineTransformMakeScale(MOVE_ZOOM, MOVE_ZOOM);
                                         movingImageView.alpha = 1.0f;
                                     }
                                 }
                                 completion:^ (BOOL finished) {
                                 }];
                
                self.stackedLayout.movingIndexPath = self.movingIndexPath;
                [self.stackedLayout invalidateLayout];
            }

            break;
        }

        case UIGestureRecognizerStateChanged: {
            
            if (self.movingIndexPath) {

                CGPoint currentLocation = [recognizer locationInView:self.collectionView];
                CGPoint currentCenter = startCenter;
                
                currentCenter.y += (currentLocation.y - startLocation.y);
                
                self.movingView.center = currentCenter;

                if (currentLocation.y < CGRectGetMinY(self.collectionView.bounds) + SCROLL_ZONE_TOP && self.collectionView.contentOffset.y > SCROLL_ZONE_TOP) {
                    
                    [self startScrollingUp];

                } else if (currentLocation.y > CGRectGetMaxY(self.collectionView.bounds) - SCROLL_ZONE_BOTTOM && self.collectionView.contentOffset.y < self.collectionView.contentSize.height - CGRectGetHeight(self.collectionView.bounds) - SCROLL_ZONE_BOTTOM) {
                    
                    [self startScrollingDown];
                    
                } else if (self.scrollDirection != TGLStackedViewControllerScrollDirectionNone) {
                    
                    [self stopScrolling];
                }
                
                if (self.scrollDirection == TGLStackedViewControllerScrollDirectionNone) {
                    
                    [self updateLayoutAtMovingLocation:currentLocation];
                }
            }

            break;
        }

        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {

            if (self.movingIndexPath) {
                
                [self stopScrolling];
                
                UICollectionViewLayoutAttributes *layoutAttributes = [self.stackedLayout layoutAttributesForItemAtIndexPath:self.movingIndexPath];
                
                self.movingIndexPath = nil;
                
                __weak typeof(self) weakSelf = self;
                
                [UIView animateWithDuration:0.3
                                      delay:0.0
                                    options:UIViewAnimationOptionBeginFromCurrentState
                                 animations:^ (void) {
                                     
                                     __strong typeof(self) strongSelf = weakSelf;
                                     
                                     if (strongSelf) {
                                         
                                         strongSelf.movingView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
                                         strongSelf.movingView.frame = layoutAttributes.frame;
                                     }
                                 }
                                 completion:^ (BOOL finished) {
                                     
                                     __strong typeof(self) strongSelf = weakSelf;
                                     
                                     if (strongSelf) {
                                         
                                         [strongSelf.movingView removeFromSuperview];
                                         strongSelf.movingView = nil;
                                         
                                         self.stackedLayout.movingIndexPath = nil;
                                         [strongSelf.stackedLayout invalidateLayout];
                                     }
                                 }];
            }
            
            break;
        }
            
        default:
            
            break;
    }
}

#pragma mark - Scrolling

- (void)startScrollingUp {
    
    [self startScrollingInDirection:TGLStackedViewControllerScrollDirectionUp];
}

- (void)startScrollingDown {
    
    [self startScrollingInDirection:TGLStackedViewControllerScrollDirectionDown];
}

- (void)startScrollingInDirection:(TGLStackedViewControllerScrollDirection)direction {

    if (direction != TGLStackedViewControllerScrollDirectionNone && direction != self.scrollDirection) {

        [self stopScrolling];

        self.scrollDirection = direction;
        self.scrollDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(handleScrolling:)];

        [self.scrollDisplayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    }
}

- (void)stopScrolling {
    
    if (self.scrollDirection != TGLStackedViewControllerScrollDirectionNone) {
        
        self.scrollDirection = TGLStackedViewControllerScrollDirectionNone;
        
        [self.scrollDisplayLink invalidate];
        self.scrollDisplayLink = nil;
    }
}

- (void)handleScrolling:(CADisplayLink *)displayLink {
    
    switch (self.scrollDirection) {
            
        case TGLStackedViewControllerScrollDirectionUp: {

            CGPoint offset = self.collectionView.contentOffset;

            offset.y -= SCROLL_PER_FRAME;
            
            if (offset.y > 0.0) {
                
                self.collectionView.contentOffset = offset;
                
                CGPoint center = self.movingView.center;

                center.y -= SCROLL_PER_FRAME;
                self.movingView.center = center;

            } else {

                [self stopScrolling];

                CGPoint currentLocation = [self.moveGestureRecognizer locationInView:self.collectionView];
                
                [self updateLayoutAtMovingLocation:currentLocation];
            }

            break;
        }
            
        case TGLStackedViewControllerScrollDirectionDown: {
            
            CGPoint offset = self.collectionView.contentOffset;
            
            offset.y += SCROLL_PER_FRAME;
            
            if (offset.y < self.collectionView.contentSize.height - CGRectGetHeight(self.collectionView.bounds)) {

                self.collectionView.contentOffset = offset;

                CGPoint center = self.movingView.center;

                center.y += SCROLL_PER_FRAME;
                self.movingView.center = center;

            } else {
                
                [self stopScrolling];
                
                CGPoint currentLocation = [self.moveGestureRecognizer locationInView:self.collectionView];
                
                [self updateLayoutAtMovingLocation:currentLocation];
            }
            
            break;
        }
            
        default:
            break;
    }
}

#pragma mark - Helpers

- (UIImage *)screenshotImageOfItem:(UICollectionViewCell *)item {
    
    UIGraphicsBeginImageContextWithOptions(item.bounds.size, _movingCellOpaque, 0.0f);
    
    [item.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();

    return image;
}

- (void)updateLayoutAtMovingLocation:(CGPoint)movingLocation {
    
    [self.stackedLayout invalidateLayoutIfNecessaryWithMovingLocation:movingLocation
                                                          targetBlock:^ (NSIndexPath *sourceIndexPath, NSIndexPath *proposedDestinationIndexPath) {
        
                                                              return [self targetIndexPathForMoveFromItemAtIndexPath:sourceIndexPath toProposedIndexPath:proposedDestinationIndexPath];
                                                          }
                                                          updateBlock:^ (NSIndexPath *fromIndexPath, NSIndexPath *toIndexPath){
                                                              
                                                              [self moveItemAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
                                                              
                                                              self.movingIndexPath = toIndexPath;
                                                          }];
}

@end
