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

- (void)setTopOverlap:(CGFloat)cardOverlapTop {
    
    if (cardOverlapTop != self.topOverlap) {
        
        _topOverlap = cardOverlapTop;
        
        [self invalidateLayout];
    }
}

- (void)setBottomOverlap:(CGFloat)cardOverlapBottom {
    
    if (cardOverlapBottom != self.bottomOverlap) {
        
        _bottomOverlap = cardOverlapBottom;
        
        [self invalidateLayout];
    }
}

#pragma mark - Layout computation

- (CGSize)collectionViewContentSize {

    CGSize contentSize = self.collectionView.bounds.size;
    
    contentSize.height -= self.collectionView.contentInset.top + self.collectionView.contentInset.bottom;
    
    return contentSize;
}

- (void)prepareLayout {

    CGSize cardSize = CGSizeMake(CGRectGetWidth(self.collectionView.bounds) - self.layoutMargin.left - self.layoutMargin.right, CGRectGetHeight(self.collectionView.bounds) - self.layoutMargin.top - self.layoutMargin.bottom - self.collectionView.contentInset.top - self.collectionView.contentInset.bottom);

    NSMutableDictionary *layoutAttributes = [NSMutableDictionary dictionary];
    
    for (NSInteger item = 0; item < [self.collectionView numberOfItemsInSection:0]; item++) {

        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:0];
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];

        if (item < self.exposedItemIndex) {
            
            // Items before exposed item
            // are aligned above top with
            // cardTopOverlap
            //
            attributes.frame = CGRectMake(self.layoutMargin.left, self.layoutMargin.top - self.topOverlap, cardSize.width, cardSize.height);
            
        } else if (item == self.exposedItemIndex) {
            
            // Exposed item
            //
            attributes.frame = CGRectMake(self.layoutMargin.left, self.layoutMargin.top, cardSize.width, cardSize.height);

        } else if (item > self.exposedItemIndex + 1) {
            
            attributes.frame = CGRectMake(self.layoutMargin.left, self.collectionViewContentSize.height, cardSize.width, cardSize.height);
        
        } else {
        
            NSInteger delta = MIN(item - self.exposedItemIndex - 1, 0);
    
            attributes.frame = CGRectMake(self.layoutMargin.left, self.layoutMargin.top + cardSize.height - (1 - delta) * self.bottomOverlap, cardSize.width, cardSize.height);
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
