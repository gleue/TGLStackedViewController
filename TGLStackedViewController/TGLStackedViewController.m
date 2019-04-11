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

@interface TGLStackedViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDropDelegate,UIGestureRecognizerDelegate>

@property (nonatomic, strong) TGLStackedLayout *stackedLayout;
@property (nonatomic, strong) TGLExposedLayout *exposedLayout;
@property (nonatomic, weak) UICollectionViewTransitionLayout *transitionLayout;

@property (nonatomic, strong) UILongPressGestureRecognizer *moveGestureRecognizer;
@property (nonatomic, strong) NSIndexPath *movingIndexPath;
@property (nonatomic, strong) NSIndexPath *dragSourceIndexPath;

@property (nonatomic, readonly) UIGestureRecognizer *collapseGestureRecognizer;
@property (nonatomic, readonly) UIPanGestureRecognizer *collapsePanGestureRecognizer;
@property (nonatomic, readonly) UIPinchGestureRecognizer *collapsePinchGestureRecognizer;

@property (nonatomic, assign, getter=isFinishingInteractiveTransition) BOOL finishingInteractiveTransition;
@property (nonatomic, assign, getter=isDragging) BOOL dragging;

@end

@implementation TGLStackedViewController

@synthesize collapsePanGestureRecognizer = _collapsePanGestureRecognizer;
@synthesize collapsePinchGestureRecognizer = _collapsePinchGestureRecognizer;

+ (Class)exposedLayoutClass {

    return TGLExposedLayout.class;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {

    self = [super initWithCoder:aDecoder];
    
    if (self) [self initController];
    
    return self;
}

- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout {
    
    NSAssert([layout isKindOfClass:TGLStackedLayout.class], @"TGLStackedViewController collection view layout is not a TGLStackedLayout");

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
    
    self.installsStandardGestureForInteractiveMovement = NO;

    _exposedLayoutMargin = UIEdgeInsetsMake(40.0, 0.0, 0.0, 0.0);
    _exposedItemSize = CGSizeZero;
    _exposedTopOverlap = 10.0;
    _exposedBottomOverlap = 10.0;
    _exposedBottomOverlapCount = 1;
    
    _exposedPinningMode = TGLExposedLayoutPinningModeAll;
    _exposedTopPinningCount = -1;
    _exposedBottomPinningCount = -1;
    
    _exposedItemsAreCollapsible = YES;
    
    _movingItemScaleFactor = 0.95;
    _movingItemOnTop = YES;

    _collapsePanMinimumThreshold = 120.0;
    _collapsePanMaximumThreshold = 0.0;
    _collapsePinchMinimumThreshold = 0.25;
}

#pragma mark - View life cycle

- (void)viewDidLoad {

    [super viewDidLoad];
    
    NSAssert([self.collectionViewLayout isKindOfClass:TGLStackedLayout.class], @"TGLStackedViewController collection view layout is not a TGLStackedLayout");
    
    self.stackedLayout = (TGLStackedLayout *)self.collectionViewLayout;

    if (@available(iOS 11, *)) {

        // Issue #45: Use UIKit's new drag and drop API for
        //            reordering, since interactive movement
        //            layout attributes are not applied
        //            correctly breaking z ordering.
        //
        self.collectionView.dragDelegate = self;
        self.collectionView.dragInteractionEnabled = YES;

        self.collectionView.dropDelegate = self;

    } else {

        self.moveGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleMovePressGesture:)];
        self.moveGestureRecognizer.delegate = self;

        [self.collectionView addGestureRecognizer:self.moveGestureRecognizer];
    }
}

#pragma mark - Accessors

- (UIGestureRecognizer *)collapseGestureRecognizer {

    if (self.exposedLayout == nil || !self.exposedItemsAreCollapsible) return nil;

    if (self.exposedLayout.pinningMode > TGLExposedLayoutPinningModeNone) {
        
        return self.collapsePanGestureRecognizer;

    } else {
        
        return self.collapsePinchGestureRecognizer;
    }
}

- (UIPanGestureRecognizer *)collapsePanGestureRecognizer {

    if (_collapsePanGestureRecognizer == nil) {
    
        _collapsePanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleCollapsePanGesture:)];
        _collapsePanGestureRecognizer.delegate = self;
    }
    
    return _collapsePanGestureRecognizer;
}

- (UIPinchGestureRecognizer *)collapsePinchGestureRecognizer {
    
    if (_collapsePinchGestureRecognizer == nil) {
        
        _collapsePinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handleCollapsePinchGesture:)];
        _collapsePinchGestureRecognizer.delegate = self;
    }
    
    return _collapsePinchGestureRecognizer;
}

- (void)setExposedItemIndexPath:(nullable NSIndexPath *)exposedItemIndexPath {
    
    [self setExposedItemIndexPath:exposedItemIndexPath animated:YES completion:nil];
}

- (void)setExposedItemIndexPath:(nullable NSIndexPath *)exposedItemIndexPath animated:(BOOL)animated {
    
    [self setExposedItemIndexPath:exposedItemIndexPath animated:animated completion:nil];
}

- (void)setExposedItemIndexPath:(nullable NSIndexPath *)exposedItemIndexPath animated:(BOOL)animated completion:(void (^)(void))completion {

    if (self.exposedItemIndexPath == nil && exposedItemIndexPath) {
        
        // Exposed item while none is exposed yet
        //
        self.stackedLayout.contentOffset = self.collectionView.contentOffset;
        
        TGLExposedLayout *exposedLayout = [[[self.class exposedLayoutClass] alloc] initWithExposedItemIndex:exposedItemIndexPath.item];
        
        exposedLayout.layoutMargin = self.exposedLayoutMargin;
        exposedLayout.itemSize = self.exposedItemSize;
        exposedLayout.topOverlap = self.exposedTopOverlap;
        exposedLayout.bottomOverlap = self.exposedBottomOverlap;
        exposedLayout.bottomOverlapCount = self.exposedBottomOverlapCount;
        
        exposedLayout.pinningMode = self.exposedPinningMode;
        exposedLayout.topPinningCount = self.exposedTopPinningCount;
        exposedLayout.bottomPinningCount = self.exposedBottomPinningCount;
        
        void (^layoutcompletion) (BOOL) = ^ (BOOL finished) {

            // NOTE: We can use strong self references here since
            //       the cycle is broken as soon as local variable
            //       `layoutcompletion` goes out of scope.
            self.stackedLayout.overwriteContentOffset = YES;
            self.exposedLayout = exposedLayout;

            self->_exposedItemIndexPath = exposedItemIndexPath;

            UICollectionViewCell *exposedCell = [self.collectionView cellForItemAtIndexPath:self.exposedItemIndexPath];

            [self addCollapseGestureRecognizerToView:exposedCell];

            [[UIApplication sharedApplication] endIgnoringInteractionEvents];

            if (completion) completion();
        };
        
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];

        if (animated) {
            
            [self.collectionView setCollectionViewLayout:exposedLayout animated:YES completion:layoutcompletion];
            
        } else {
            
            self.collectionView.collectionViewLayout = exposedLayout;
            
            layoutcompletion(YES);
        }
        
    } else if (self.exposedItemIndexPath && exposedItemIndexPath && (exposedItemIndexPath.item != self.exposedItemIndexPath.item || self.unexposedItemsAreSelectable)) {
        
        // We have another exposed item and we expose the new one instead
        //
        UICollectionViewCell *exposedCell = [self.collectionView cellForItemAtIndexPath:self.exposedItemIndexPath];
        
        [self removeCollapseGestureRecognizersFromView:exposedCell];
        
        TGLExposedLayout *exposedLayout = [[TGLExposedLayout alloc] initWithExposedItemIndex:exposedItemIndexPath.item];
        
        exposedLayout.layoutMargin = self.exposedLayout.layoutMargin;
        exposedLayout.itemSize = self.exposedLayout.itemSize;
        exposedLayout.topOverlap = self.exposedLayout.topOverlap;
        exposedLayout.bottomOverlap = self.exposedLayout.bottomOverlap;
        exposedLayout.bottomOverlapCount = self.exposedLayout.bottomOverlapCount;
        
        exposedLayout.pinningMode = self.exposedLayout.pinningMode;
        exposedLayout.topPinningCount = self.exposedLayout.topPinningCount;
        exposedLayout.bottomPinningCount = self.exposedLayout.bottomPinningCount;
        
        void (^layoutcompletion) (BOOL) = ^ (BOOL finished) {

            // NOTE: We can use strong self references here since
            //       the cycle is broken as soon as local variable
            //       `layoutcompletion` goes out of scope.
            self.exposedLayout = exposedLayout;

            // Mention self explicitly here to get rid of compiler warning
            self->_exposedItemIndexPath = exposedItemIndexPath;
            
            UICollectionViewCell *exposedCell = [self.collectionView cellForItemAtIndexPath:self.exposedItemIndexPath];
            
            [self addCollapseGestureRecognizerToView:exposedCell];
            
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            
            if (completion) completion();
        };
        
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];

        if (animated) {
            
            [self.collectionView setCollectionViewLayout:exposedLayout animated:YES completion:layoutcompletion];
            
        } else {
            
            self.collectionView.collectionViewLayout = exposedLayout;
            
            layoutcompletion(YES);
        }
        
    } else if (self.exposedItemIndexPath) {
        
        // We collapse the currently exposed item because
        //
        // 1. -exposedItemIndexPath has been set to nil or
        // 2. we're not allowed to collapse by selecting a new item
        //
        [self.collectionView deselectItemAtIndexPath:self.exposedItemIndexPath animated:YES];
        
        UICollectionViewCell *exposedCell = [self.collectionView cellForItemAtIndexPath:self.exposedItemIndexPath];
        
        [self removeCollapseGestureRecognizersFromView:exposedCell];
        
        self.exposedLayout = nil;
        
        _exposedItemIndexPath = nil;
        
        void (^layoutcompletion) (BOOL) = ^ (BOOL finished) {
            
            // NOTE: We can use strong self references here since
            //       the cycle is broken as soon as local variable
            //       `layoutcompletion` goes out of scope.
            self.stackedLayout.overwriteContentOffset = NO;
            
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            
            if (completion) completion();
        };
        
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];

        if (animated) {
            
            [self.collectionView setCollectionViewLayout:self.stackedLayout animated:YES completion:layoutcompletion];
            
        } else {
            
            self.collectionView.collectionViewLayout = self.stackedLayout;
            
            layoutcompletion(YES);
        }
    } else {
        if (completion) completion();
    }
}

- (void)resetExposedItemIndexPath {

    // Set -exposedItemIndexPath to `nil` w/o triggering
    // any layout updates as in the setters above
    //
    _exposedItemIndexPath = nil;
}

#pragma mark - Actions

- (IBAction)handleMovePressGesture:(UILongPressGestureRecognizer *)recognizer {
    
    static CGPoint startLocation;
    static CGPoint targetPosition;
    
    switch (recognizer.state) {
            
        case UIGestureRecognizerStateBegan: {
            
            startLocation = [recognizer locationInView:self.collectionView];

            NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:startLocation];

            self.stackedLayout.movingItemScaleFactor = self.movingItemScaleFactor;
            self.stackedLayout.movingItemOnTop = self.movingItemOnTop;

            if (indexPath && [self.collectionView beginInteractiveMovementForItemAtIndexPath:indexPath]) {

                UICollectionViewCell *movingCell = [self.collectionView cellForItemAtIndexPath:indexPath];
                
                targetPosition = movingCell.center;

                [self.collectionView updateInteractiveMovementTargetPosition:targetPosition];
                
                self.movingIndexPath = indexPath;
            }

            break;
        }

        case UIGestureRecognizerStateChanged: {

            if (self.movingIndexPath) {

                CGPoint currentLocation = [recognizer locationInView:self.collectionView];
                CGPoint newTargetPosition = targetPosition;
                
                newTargetPosition.y += (currentLocation.y - startLocation.y);

                [self.collectionView updateInteractiveMovementTargetPosition:newTargetPosition];
            }

            break;
        }

        case UIGestureRecognizerStateEnded: {

            if (self.movingIndexPath) {

                [self.collectionView endInteractiveMovement];
                [self.stackedLayout invalidateLayout];
                
                self.movingIndexPath = nil;
            }
            
            break;
        }
            
        case UIGestureRecognizerStateCancelled: {

            if (self.movingIndexPath) {

                [self.collectionView cancelInteractiveMovement];
                [self.stackedLayout invalidateLayout];
                
                self.movingIndexPath = nil;
            }
            
            break;
        }
            
        default:
            
            break;
    }
}

- (IBAction)handleCollapsePanGesture:(UIPanGestureRecognizer *)recognizer {
    
    static CGFloat transitionMaxThreshold;
    static CGFloat transitionMinThreshold;
    
    switch (recognizer.state) {
            
        case UIGestureRecognizerStateBegan: {
            
            if (self.transitionLayout == nil) {
                
                UICollectionViewCell *exposedCell = [self.collectionView cellForItemAtIndexPath:self.exposedItemIndexPath];
                
                __weak typeof(self) weakSelf = self;
                
                self.transitionLayout = [self.collectionView startInteractiveTransitionToCollectionViewLayout:self.stackedLayout completion:^ (BOOL completed, BOOL finish) {
                    
                    if (finish) {
                        
                        // We have a properly installed stacked layout here
                        
                        [weakSelf removeCollapseGestureRecognizersFromView:exposedCell];
                        
                        weakSelf.stackedLayout.overwriteContentOffset = NO;
                        weakSelf.exposedLayout = nil;
                        
                        // Issue #37: Do not trigger layout update, since
                        //            everthing is fine when interactive
                        //            transition finished
                        //
                        [weakSelf resetExposedItemIndexPath];
                    }
                    
                    // Issue #37: Re-allow item interaction when
                    //            interactive transition is done
                    //
                    weakSelf.transitionLayout = nil;
                    weakSelf.finishingInteractiveTransition = NO;
                }];
                
                transitionMaxThreshold = (self.collapsePanMaximumThreshold > 0.0) ? self.collapsePanMaximumThreshold : CGRectGetHeight(exposedCell.bounds);
                transitionMinThreshold = MAX(self.collapsePanMinimumThreshold, 0.0);
            }

            break;
        }
            
        case UIGestureRecognizerStateChanged: {
            
            if (self.transitionLayout && self.collectionView.collectionViewLayout == self.transitionLayout && !self.isFinishingInteractiveTransition) {
            
                CGPoint currentOffset = [recognizer translationInView:self.collectionView];

                if (currentOffset.y >= 0.0) {
                    
                    self.transitionLayout.transitionProgress = MIN(currentOffset.y, transitionMaxThreshold) / transitionMaxThreshold;
                }
            }

            break;
        }
            
        case UIGestureRecognizerStateEnded: {
            
            if (self.transitionLayout && self.collectionView.collectionViewLayout == self.transitionLayout && !self.isFinishingInteractiveTransition) {
                
                // Issue #37: Prevent item interaction while
                //            interactive transition is finishing
                //
                self.finishingInteractiveTransition = YES;
                
                CGPoint currentOffset = [recognizer translationInView:self.collectionView];
                CGPoint currentSpeed = [recognizer velocityInView:self.collectionView];
                
                if (currentOffset.y >= transitionMinThreshold && currentSpeed.y >= 0.0) {
                    
                    [self.collectionView deselectItemAtIndexPath:self.exposedItemIndexPath animated:YES];
                    [self.collectionView finishInteractiveTransition];
                    
                } else {
                    
                    [self.collectionView cancelInteractiveTransition];
                }
            }
            
            break;
        }
            
        case UIGestureRecognizerStateCancelled: {
            
            if (self.transitionLayout && self.collectionView.collectionViewLayout == self.transitionLayout && !self.isFinishingInteractiveTransition) {
                
                // Issue #37: Prevent item interaction while
                //            interactive transition is finishing
                //
                self.finishingInteractiveTransition = YES;

                [self.collectionView cancelInteractiveTransition];
            }
            
            break;
        }
            
        default:
            
            break;
    }
}

- (IBAction)handleCollapsePinchGesture:(UIPinchGestureRecognizer *)recognizer {
    
    static CGFloat transitionMinThreshold;

    switch (recognizer.state) {
            
        case UIGestureRecognizerStateBegan: {
            
            if (self.transitionLayout == nil) {

                __weak typeof(self) weakSelf = self;
            
                self.transitionLayout = [self.collectionView startInteractiveTransitionToCollectionViewLayout:self.stackedLayout completion:^ (BOOL completed, BOOL finish) {

                    if (finish) {
                        
                        // We have a properly installed stacked layout here

                        UICollectionViewCell *exposedCell = [self.collectionView cellForItemAtIndexPath:weakSelf.exposedItemIndexPath];
                        
                        [weakSelf removeCollapseGestureRecognizersFromView:exposedCell];
                        
                        weakSelf.stackedLayout.overwriteContentOffset = NO;
                        weakSelf.exposedLayout = nil;

                        // Issue #37: Do not trigger layout update, since
                        //            everthing is fine when interactive
                        //            transition finished
                        //
                        [weakSelf resetExposedItemIndexPath];
                    }
                    
                    // Issue #37: Re-allow item selection when
                    //            interactive transition is done
                    //
                    weakSelf.transitionLayout = nil;
                    weakSelf.finishingInteractiveTransition = NO;
                }];
                
                transitionMinThreshold = weakSelf.collapsePinchMinimumThreshold;
                
                if (transitionMinThreshold < 0.0) transitionMinThreshold = 0.0; else if (transitionMinThreshold > 1.0) transitionMinThreshold = 1.0;

                transitionMinThreshold = 1.0 - transitionMinThreshold;
            }

            break;
        }
            
        case UIGestureRecognizerStateChanged: {
            
            if (self.transitionLayout && self.collectionView.collectionViewLayout == self.transitionLayout && !self.isFinishingInteractiveTransition) {
                
                CGFloat currentScale = recognizer.scale;

                if (currentScale >= 0.0 && currentScale <= 1.0) {
                    
                    self.transitionLayout.transitionProgress = 1.0 - currentScale;
                }
            }
            
            break;
        }
            
        case UIGestureRecognizerStateEnded: {
            
            if (self.transitionLayout && self.collectionView.collectionViewLayout == self.transitionLayout && !self.isFinishingInteractiveTransition) {
                
                // Issue #37: Prevent item interaction while
                //            interactive transition is finishing
                //
                self.finishingInteractiveTransition = YES;

                CGFloat currentScale = recognizer.scale;
                CGFloat currentSpeed = recognizer.velocity;

                if (currentScale <= transitionMinThreshold && currentSpeed <= 0.0) {
                
                    [self.collectionView deselectItemAtIndexPath:self.exposedItemIndexPath animated:YES];
                    [self.collectionView finishInteractiveTransition];
                    
                } else {
                    
                    [self.collectionView cancelInteractiveTransition];
                }
            }
            
            break;
        }
            
        case UIGestureRecognizerStateCancelled: {
            
            if (self.transitionLayout && self.collectionView.collectionViewLayout == self.transitionLayout && !self.isFinishingInteractiveTransition) {
                
                // Issue #37: Prevent item interaction while
                //            interactive transition is finishing
                //
                self.finishingInteractiveTransition = YES;

                [self.collectionView cancelInteractiveTransition];
            }

            break;
        }
            
        default:
            
            break;
    }
}

#pragma mark - UICollectionViewDelegate protocol

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {

    // When selecting unexposed items is not allowed,
    // prevent them from being highlighted and thus
    // selected by the collection view
    //
    // Issue #37: Prevent selection, too, while interactive transition is still in progress.
    //
    //      NOTE: Prevent selection while drag is in progress, too.
    //
    return (self.exposedItemIndexPath == nil || indexPath.item == self.exposedItemIndexPath.item || self.unexposedItemsAreSelectable) && self.transitionLayout == nil && !self.isDragging;
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // When selecting unexposed items is not allowed
    // make sure the currently exposed item remains
    // selected
    //
    if (self.exposedItemIndexPath && indexPath.item == self.exposedItemIndexPath.item) {
        
        [collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.exposedItemIndexPath && indexPath.item == self.exposedItemIndexPath.item) {

        self.exposedItemIndexPath = nil;

    } else {
        
        self.exposedItemIndexPath = indexPath;
    }
}

#pragma mark - UICollectionViewDataSource protocol

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    // Currently, only one single section is
    // supported, therefore MUST NOT be != 1
    //
    return 1;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {

    return (self.exposedLayout == nil && [self collectionView:self.collectionView numberOfItemsInSection:0] > 1);
}

#pragma mark - UICollectionViewDragDelegate protocol

- (NSArray<UIDragItem *> *)collectionView:(UICollectionView *)collectionView itemsForBeginningDragSession:(id<UIDragSession>)session atIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(11) {

    if (self.exposedLayout == nil && [self collectionView:self.collectionView numberOfItemsInSection:0] > 1) {

        self.dragSourceIndexPath = indexPath;

        NSItemProvider *provider = [NSItemProvider new];
        UIDragItem *item = [[UIDragItem alloc] initWithItemProvider:provider];

        return @[item];

    } else {

        return @[];
    }
}

- (void)collectionView:(UICollectionView *)collectionView dragSessionWillBegin:(id<UIDragSession>)session NS_AVAILABLE_IOS(11) {

    self.dragging = YES;
}

- (void)collectionView:(UICollectionView *)collectionView dragSessionDidEnd:(id<UIDragSession>)session NS_AVAILABLE_IOS(11) {

    self.dragging = NO;
}

#pragma mark - UICollectionViewDropDelegate protocol

- (UICollectionViewDropProposal *)collectionView:(UICollectionView *)collectionView dropSessionDidUpdate:(id<UIDropSession>)session withDestinationIndexPath:(NSIndexPath *)destinationIndexPath NS_AVAILABLE_IOS(11) {

    UIDropOperation operation = session.localDragSession ? UIDropOperationMove : UIDropOperationCopy;

    return [[UICollectionViewDropProposal alloc] initWithDropOperation:operation intent:UICollectionViewDropIntentInsertAtDestinationIndexPath];
}

- (void)collectionView:(UICollectionView *)collectionView performDropWithCoordinator:(id<UICollectionViewDropCoordinator>)coordinator NS_AVAILABLE_IOS(11) {

    // NOTE: We handle only move interactions within
    //       this collection view here.
    //
    // Any other drop interactions, e.g. from other view
    // within same app or from other app, must be handled
    // in a subclass since they's require customized data
    // source updates.
    //
    id<UICollectionViewDropItem> item = coordinator.items.firstObject;

    if (item.sourceIndexPath) {

        // KLUDGE: On the very first drag when dropping
        //         item at last position `destinationIndexPath`
        //         is (0, count) instead of (0, count -1)
        //
        NSIndexPath *destinationIndexPath = coordinator.destinationIndexPath;

        if (destinationIndexPath.item >= [collectionView numberOfItemsInSection:destinationIndexPath.section]) {

            destinationIndexPath = [NSIndexPath indexPathForItem:([collectionView numberOfItemsInSection:destinationIndexPath.section] - 1) inSection:destinationIndexPath.section];
        }

        [collectionView performBatchUpdates:^() {

            [collectionView deleteItemsAtIndexPaths:@[item.sourceIndexPath]];
            [self collectionView:collectionView moveItemAtIndexPath:item.sourceIndexPath toIndexPath:destinationIndexPath];
            [collectionView insertItemsAtIndexPaths:@[destinationIndexPath]];

            self.dragSourceIndexPath = nil;

        } completion:^ (BOOL finished) {

            [coordinator dropItem:item.dragItem toItemAtIndexPath:destinationIndexPath];
        }];
    }
}

- (void)collectionView:(UICollectionView *)collectionView dropSessionDidEnd:(id<UIDropSession>)session NS_AVAILABLE_IOS(11) {

    // When drop is at original index path, method
    // `-collectionView:performDropWithCoordinator:`
    // is not called.
    //
    if (self.dragSourceIndexPath != nil) {

        // KLUDGE: Reload item to force correct layout
        //         -- esp. regarding zIndex
        //
        [self.collectionView reloadItemsAtIndexPaths:@[self.dragSourceIndexPath]];
        self.dragSourceIndexPath = nil;
    }
}

#pragma mark - Helpers

- (void)addCollapseGestureRecognizerToView:(UIView *)view {
    
    UIGestureRecognizer *recognizer = self.collapseGestureRecognizer;
    
    if (recognizer) [view addGestureRecognizer:recognizer];
}

- (void)removeCollapseGestureRecognizersFromView:(UIView *)view {

    // Make sure the gesture recognizers are not created lazily
    // when removing them. Therefore use ivar to test for presence
    // before removing
    //
    if (_collapsePanGestureRecognizer) [view removeGestureRecognizer:self.collapsePanGestureRecognizer];
    if (_collapsePinchGestureRecognizer) [view removeGestureRecognizer:self.collapsePinchGestureRecognizer];
}

@end
