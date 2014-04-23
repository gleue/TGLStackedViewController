//
//  TGLStackedLayout.m
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

#import "TGLStackedLayout.h"

@interface TGLStackedLayout ()

@property (nonatomic, strong) NSDictionary *layoutAttributes;

@end

@implementation TGLStackedLayout

- (instancetype)init {
    
    self = [super init];

    if (self) [self initLayout];
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    if (self) [self initLayout];
    
    return self;
}

- (void)initLayout {
    
    self.layoutMargin = UIEdgeInsetsMake(20.0, 0.0, 0.0, 0.0);
    self.topReveal = 120.0;
    self.bounceFactor = 0.2;
}

#pragma mark - Accessors

- (void)setLayoutMargin:(UIEdgeInsets)margins {

    if (!UIEdgeInsetsEqualToEdgeInsets(margins, self.layoutMargin)) {
        
        _layoutMargin = margins;
        
        [self invalidateLayout];
    }
}

- (void)setTopReveal:(CGFloat)cardReveal {
    
    if (cardReveal != self.topReveal) {
        
        _topReveal = cardReveal;
        
        [self invalidateLayout];
    }
}

- (void)setBounceFactor:(CGFloat)bounceFactor {

    if (bounceFactor != self.bounceFactor) {

        _bounceFactor = bounceFactor;
        
        [self invalidateLayout];
    }
}

#pragma mark - Layout computation

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    
    return YES;
}

- (CGSize)collectionViewContentSize {
    
    return CGSizeMake(CGRectGetWidth(self.collectionView.bounds), self.layoutMargin.top + self.topReveal * [self.collectionView numberOfItemsInSection:0] + self.layoutMargin.bottom);
}

- (void)prepareLayout {

    CGPoint contentOffset = self.overwriteContentOffset ? self.contentOffset : self.collectionView.contentOffset;

    self.overwriteContentOffset = NO;

    NSMutableDictionary *layoutAttributes = [NSMutableDictionary dictionary];
    
    NSInteger itemCount = [self.collectionView numberOfItemsInSection:0];
    NSInteger overlappingCount = 0;

    static NSInteger firstCompressingItem = -1;

    for (NSInteger item = 0; item < itemCount; item++) {
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:0];
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];

        // Cards overlap each other
        // via z depth
        //
        attributes.zIndex = item;
        
        // The moving item is hidden
        //
        attributes.hidden = [attributes.indexPath isEqual:self.movingIndexPath];

        // By default all items are layed
        // out evenly with each revealing
        // only top part ...
        //
        attributes.frame = CGRectMake(self.layoutMargin.left, self.layoutMargin.top + self.topReveal * item, CGRectGetWidth(self.collectionView.bounds) - self.layoutMargin.left - self.layoutMargin.right, CGRectGetHeight(self.collectionView.bounds) - self.layoutMargin.top - self.layoutMargin.bottom);

        if (contentOffset.y < 0) {
            
            // Expand cells when reaching top
            // and user scrolls further down,
            // i.e. when bouncing
            //
            CGRect frame = attributes.frame;
            
            frame.origin.y -= self.bounceFactor * contentOffset.y * item;
            
            attributes.frame = frame;

        } else if (CGRectGetMinY(attributes.frame) < contentOffset.y + self.layoutMargin.top) {

            // Topmost cells overlap stack, but
            // are placed directly above each
            // other such that only one cell
            // is visible
            //
            CGRect frame = attributes.frame;
            
            frame.origin.y = contentOffset.y + self.layoutMargin.top;
            
            attributes.frame = frame;
            
            ++overlappingCount;

        } else if (contentOffset.y + CGRectGetHeight(self.collectionView.bounds) > self.collectionViewContentSize.height) {

            // Compress cells when reaching bottom
            // and user scrolls further up,
            // i.e. when bouncing
            //
            if (firstCompressingItem < 0) {
                
                firstCompressingItem = item;

            } else {

                CGRect frame = attributes.frame;
                CGFloat delta = contentOffset.y + CGRectGetHeight(self.collectionView.bounds) - self.collectionViewContentSize.height;
                
                frame.origin.y += self.bounceFactor * delta * (firstCompressingItem - item);
                frame.origin.y = MAX(frame.origin.y, contentOffset.y + self.layoutMargin.top);

                attributes.frame = frame;
            }

        } else {
            
            firstCompressingItem = -1;
        }
        
        layoutAttributes[indexPath] = attributes;
    }

    self.layoutAttributes = layoutAttributes;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {

    NSMutableArray *layoutAttributes = [NSMutableArray array];
    
    [self.layoutAttributes enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *indexPath, UICollectionViewLayoutAttributes *attributes, BOOL *stop) {
        
        if (CGRectIntersectsRect(rect, attributes.frame)) {
            
            [layoutAttributes addObject:attributes];
        }
    }];
    
    return layoutAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return self.layoutAttributes[indexPath];
}

#pragma mark - Methods

- (void)invalidateLayoutIfNecessaryWithMovingLocation:(CGPoint)movingLocation updateBlock:(void (^) (NSIndexPath *fromIndexPath, NSIndexPath *toIndexPath))updateBlock {

    NSIndexPath *oldMovingIndexPath = self.movingIndexPath;
    NSIndexPath *newMovingIndexPath = [self.collectionView indexPathForItemAtPoint:movingLocation];

    if (newMovingIndexPath != nil && ![newMovingIndexPath isEqual:oldMovingIndexPath]) {
        
        __weak typeof(self) weakSelf = self;
        
        [self.collectionView performBatchUpdates:^ (void) {

                                            [weakSelf.collectionView deleteItemsAtIndexPaths:@[ oldMovingIndexPath ]];
            
                                            self.movingIndexPath = newMovingIndexPath;
                                            updateBlock(oldMovingIndexPath, newMovingIndexPath);
            
                                            [weakSelf.collectionView insertItemsAtIndexPaths:@[ newMovingIndexPath ]];
                                        }
                                      completion:nil];
    }
}

@end
