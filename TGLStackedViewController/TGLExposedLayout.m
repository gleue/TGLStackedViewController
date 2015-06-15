//
//  TGLExposedLayout.m
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

#import "TGLExposedLayout.h"

@interface TGLExposedLayout ()

@property (assign, nonatomic) NSInteger exposedItemIndex;

@property (nonatomic, strong) NSDictionary *layoutAttributes;

@end

@implementation TGLExposedLayout

- (instancetype)initWithExposedItemIndex:(NSInteger)exposedItemIndex {
    
    self = [super init];
    
    if (self) {
        
        self.layoutMargin = UIEdgeInsetsMake(40.0, 0.0, 0.0, 0.0);
        self.topOverlap = 20.0;
        self.bottomOverlap = 20.0;
        self.bottomOverlapCount = 1;
        self.exposedCardFloating = NO;

        self.exposedItemIndex = exposedItemIndex;
    }
    
    return self;
}

#pragma mark - Accessors

- (void)setLayoutMargin:(UIEdgeInsets)margins {
    
    if (!UIEdgeInsetsEqualToEdgeInsets(margins, self.layoutMargin)) {
        
        _layoutMargin = margins;
        
        [self invalidateLayout];
    }
}

- (void)setItemSize:(CGSize)itemSize {
    
    if (!CGSizeEqualToSize(itemSize, self.itemSize)) {
        
        _itemSize = itemSize;
        
        [self invalidateLayout];
    }
}

- (void)setTopOverlap:(CGFloat)topOverlap {
    
    if (topOverlap != self.topOverlap) {
        
        _topOverlap = topOverlap;
        
        [self invalidateLayout];
    }
}

- (void)setBottomOverlap:(CGFloat)bottomOverlap {
    
    if (bottomOverlap != self.bottomOverlap) {
        
        _bottomOverlap = bottomOverlap;
        
        [self invalidateLayout];
    }
}

- (void)setBottomOverlapCount:(NSUInteger)bottomOverlapCount {
    
    if (bottomOverlapCount != self.bottomOverlapCount) {
        
        _bottomOverlapCount = bottomOverlapCount;
        
        [self invalidateLayout];
    }
}

- (void)setExposedCardFloating:(BOOL)exposedCardFloating {
    
    if (exposedCardFloating != self.exposedCardFloating) {
        
        _exposedCardFloating = exposedCardFloating;
        
        [self invalidateLayout];
    }
}


#pragma mark - Layout computation

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset {
    
    // See http://stackoverflow.com/a/25416243
    //
    return CGPointZero;
}

- (CGSize)collectionViewContentSize {

    CGSize contentSize = self.collectionView.bounds.size;
    
    contentSize.height -= self.collectionView.contentInset.top + self.collectionView.contentInset.bottom;
    
    return contentSize;
}

- (void)prepareLayout {

    CGSize itemSize = self.itemSize;
    CGFloat floatingMargin = self.exposedCardFloating ? self.bottomOverlapCount*self.bottomOverlap + self.topOverlap : 0;
    
    if (CGSizeEqualToSize(itemSize, CGSizeZero)) {
        // To do: count * self.bottomOverlap 와 조합하야함.
        itemSize = CGSizeMake(CGRectGetWidth(self.collectionView.bounds) - self.layoutMargin.left - self.layoutMargin.right, CGRectGetHeight(self.collectionView.bounds) - self.layoutMargin.top - self.layoutMargin.bottom - self.collectionView.contentInset.top - self.collectionView.contentInset.bottom - floatingMargin);
    }

    NSMutableDictionary *layoutAttributes = [NSMutableDictionary dictionary];
    NSInteger itemCount = [self.collectionView numberOfItemsInSection:0];
    NSInteger bottomOverlapCount = self.bottomOverlapCount;
    
    for (NSInteger item = 0; item < itemCount; item++) {

        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:0];
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];

        if (item < self.exposedItemIndex) {
            
            // Items before exposed item
            // are aligned above top with
            // amount -topOverlap
            //
            attributes.frame = CGRectMake(self.layoutMargin.left, self.layoutMargin.top - self.topOverlap, itemSize.width, itemSize.height);

            // Items below first unexposed
            // are hidden to improve
            // performance
            //
            if (item < self.exposedItemIndex - 1) attributes.hidden = YES;

        } else if (item == self.exposedItemIndex) {
            
            // Exposed item
            //
            attributes.frame = CGRectMake(self.layoutMargin.left, self.layoutMargin.top, itemSize.width, itemSize.height);

        } else if (item > self.exposedItemIndex + bottomOverlapCount) {
            
            // Items following overlapping
            // items at bottom are hidden
            // to improve performance
            //
            attributes.frame = CGRectMake(self.layoutMargin.left, self.collectionViewContentSize.height, itemSize.width, itemSize.height);
            attributes.hidden = YES;

        } else {
        
            // At max -bottomOverlapCount
            // overlapping item(s) at the
            // botton right below the
            // exposed item
            //
            NSInteger count = MIN(self.bottomOverlapCount + 1, itemCount - self.exposedItemIndex) - (item - self.exposedItemIndex);
            
            attributes.frame = CGRectMake(self.layoutMargin.left, floatingMargin + self.layoutMargin.top + itemSize.height - count * self.bottomOverlap, itemSize.width, itemSize.height);
 
            // Issue #21
            //
            // Make sure overlapping cards
            // reach to the bottom before
            // being hidden
            //
            if (item == self.exposedItemIndex + bottomOverlapCount && attributes.frame.origin.y < self.collectionView.bounds.size.height - self.layoutMargin.bottom) {

                ++bottomOverlapCount;
            }
        }

        attributes.zIndex = item;

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

@end
