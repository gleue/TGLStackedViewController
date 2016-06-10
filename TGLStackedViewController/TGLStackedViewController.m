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

@interface TGLStackedViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate>

@property (nonatomic, strong) TGLStackedLayout *stackedLayout;
@property (nonatomic, strong) TGLExposedLayout *exposedLayout;

@property (nonatomic, assign) CGPoint stackedContentOffset;

@property (nonatomic, strong) UILongPressGestureRecognizer *moveGestureRecognizer;
@property (nonatomic, strong) NSIndexPath *movingIndexPath;


@end

@implementation TGLStackedViewController

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
    _exposedTopOverlap = 20.0;
    _exposedBottomOverlap = 20.0;
    _exposedBottomOverlapCount = 1;
    
    _exposedPinningMode = TGLExposedLayoutPinningModeAll;
    _exposedTopPinningCount = -1;
    _exposedBottomPinningCount = -1;
    
    _movingItemScaleFactor = 0.95;
}

#pragma mark - View life cycle

- (void)viewDidLoad {

    [super viewDidLoad];
    
    NSAssert([self.collectionViewLayout isKindOfClass:TGLStackedLayout.class], @"TGLStackedViewController collection view layout is not a TGLStackedLayout");
    
    self.stackedLayout = (TGLStackedLayout *)self.collectionViewLayout;

    self.moveGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    self.moveGestureRecognizer.delegate = self;

    [self.collectionView addGestureRecognizer:self.moveGestureRecognizer];
    
}

#pragma mark - Actions

- (IBAction)handleLongPress:(UILongPressGestureRecognizer *)recognizer {
    
    static CGPoint startLocation;
    static CGPoint targetPosition;
    
    switch (recognizer.state) {
            
        case UIGestureRecognizerStateBegan: {
            
            startLocation = [recognizer locationInView:self.collectionView];

            NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:startLocation];

            if (indexPath && [self.collectionView beginInteractiveMovementForItemAtIndexPath:indexPath]) {
                
                UICollectionViewCell *movingCell = [self.collectionView cellForItemAtIndexPath:indexPath];
                
                targetPosition = movingCell.center;
                
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

    
    





    }
}

#pragma mark - UICollectionViewDelegate protocol

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // When selecting unexposed items is not allowed,
    // prevent them from being highlighted and thus
    // selected by the collection view
    //
    return (self.exposedLayout == nil || self.unexposedItemsAreSelectable || indexPath.item == self.exposedItemIndexPath.item);
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // When selecting unexposed items is not allowed
    // make sure the currently exposed item remains
    // selected
    //
    if (indexPath.item == self.exposedItemIndexPath.item) {
        
        [collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.exposedLayout == nil) {
        
        TGLExposedLayout *exposedLayout = [[[self.class exposedLayoutClass] alloc] initWithExposedItemIndex:indexPath.item];
        
        exposedLayout.layoutMargin = self.exposedLayoutMargin;
        exposedLayout.itemSize = self.exposedItemSize;
        exposedLayout.topOverlap = self.exposedTopOverlap;
        exposedLayout.bottomOverlap = self.exposedBottomOverlap;
        exposedLayout.bottomOverlapCount = self.exposedBottomOverlapCount;
        
        exposedLayout.pinningMode = self.exposedPinningMode;
        exposedLayout.topPinningCount = self.exposedTopPinningCount;
        exposedLayout.bottomPinningCount = self.exposedBottomPinningCount;

        self.stackedLayout.contentOffset = self.collectionView.contentOffset;

        __weak typeof(self) weakSelf = self;

        [self.collectionView setCollectionViewLayout:exposedLayout animated:YES completion:^ (BOOL finished) {
            
            weakSelf.stackedLayout.overwriteContentOffset = YES;
            weakSelf.exposedItemIndexPath = indexPath;
            weakSelf.exposedLayout = exposedLayout;
            
            UICollectionViewCell *exposedCell = [weakSelf.collectionView cellForItemAtIndexPath:weakSelf.exposedItemIndexPath];
            
            [exposedCell addGestureRecognizer:weakSelf.unexposeGestureRecognizer];
        }];
        
    } else if (self.exposedItemIndexPath) {
        
        if (indexPath.item == self.exposedItemIndexPath.item || !self.unexposedItemsAreSelectable) {
            
            [self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
            
            UICollectionViewCell *exposedCell = [self.collectionView cellForItemAtIndexPath:self.exposedItemIndexPath];
            
            [exposedCell removeGestureRecognizer:self.unexposeGestureRecognizer];
            
            self.exposedItemIndexPath = nil;
            self.exposedLayout = nil;

            __weak typeof(self) weakSelf = self;

            [self.collectionView setCollectionViewLayout:self.stackedLayout animated:YES completion:^ (BOOL finished) {
                
                weakSelf.stackedLayout.overwriteContentOffset = NO;
            }];
            
        } else {
            
            if (self.exposedItemIndexPath) {

                UICollectionViewCell *exposedCell = [self.collectionView cellForItemAtIndexPath:self.exposedItemIndexPath];
                
                [exposedCell removeGestureRecognizer:self.unexposeGestureRecognizer];
            }

            TGLExposedLayout *exposedLayout = [[TGLExposedLayout alloc] initWithExposedItemIndex:indexPath.item];
            
            exposedLayout.layoutMargin = self.exposedLayout.layoutMargin;
            exposedLayout.itemSize = self.exposedLayout.itemSize;
            exposedLayout.topOverlap = self.exposedLayout.topOverlap;
            exposedLayout.bottomOverlap = self.exposedLayout.bottomOverlap;
            exposedLayout.bottomOverlapCount = self.exposedLayout.bottomOverlapCount;
            
            exposedLayout.pinningMode = self.exposedLayout.pinningMode;
            exposedLayout.topPinningCount = self.exposedLayout.topPinningCount;
            exposedLayout.bottomPinningCount = self.exposedLayout.bottomPinningCount;
            
            __weak typeof(self) weakSelf = self;
            
            [self.collectionView setCollectionViewLayout:exposedLayout animated:YES completion:^ (BOOL finished) {

                weakSelf.exposedItemIndexPath = indexPath;
                weakSelf.exposedLayout = exposedLayout;
                
                UICollectionViewCell *exposedCell = [weakSelf.collectionView cellForItemAtIndexPath:weakSelf.exposedItemIndexPath];
                
                [exposedCell addGestureRecognizer:weakSelf.unexposeGestureRecognizer];
            }];
        }
    }
}

- (CGPoint)collectionView:(UICollectionView *)collectionView targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset {
    
    // Force original contentOffset when unexposing
    //
    return self.exposedLayout == nil ? proposedContentOffset : self.stackedContentOffset;
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

@end
