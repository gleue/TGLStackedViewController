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
@property (nonatomic, strong) NSIndexPath *movingIndexPath;

// Set to YES when layout is currently arranging
// items so that they evenly fill entire height
//
@property (nonatomic, assign) BOOL filling;

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
    self.movingItemScaleFactor = 0.95;
}

#pragma mark - Accessors

- (void)setLayoutMargin:(UIEdgeInsets)margins {

    if (!UIEdgeInsetsEqualToEdgeInsets(margins, self.layoutMargin)) {
        
        _layoutMargin = margins;
        
        [self invalidateLayout];
    }
}

- (void)setTopReveal:(CGFloat)topReveal {
    
    if (topReveal != self.topReveal) {
        
        _topReveal = topReveal;
        
        [self invalidateLayout];
    }
}

- (void)setItemSize:(CGSize)itemSize {
    
    if (!CGSizeEqualToSize(itemSize, self.itemSize)) {
        
        _itemSize = itemSize;
        
        [self invalidateLayout];
    }
}

- (void)setBounceFactor:(CGFloat)bounceFactor {

    if (bounceFactor != self.bounceFactor) {

        _bounceFactor = bounceFactor;
        
        [self invalidateLayout];
    }
}

- (void)setFillHeight:(BOOL)fillHeight {

    if (fillHeight != self.isFillingHeight) {
        
        _fillHeight = fillHeight;
        
        [self invalidateLayout];
    }
}

- (void)setAlwaysBounce:(BOOL)alwaysBounce {
    
    if (alwaysBounce != self.alwaysBounce) {
        
        _alwaysBounce = alwaysBounce;
        
        [self invalidateLayout];
    }
}

#pragma mark - Layout computation

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset {
    
    // Honor overwritten contentOffset
    //
    // See http://stackoverflow.com/a/25416243
    //
    return self.overwriteContentOffset ? self.contentOffset : proposedContentOffset;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    
    return YES;
}

- (CGSize)collectionViewContentSize {
    
    CGSize contentSize = CGSizeMake(CGRectGetWidth(self.collectionView.bounds), self.layoutMargin.top + self.topReveal * [self.collectionView numberOfItemsInSection:0] + self.layoutMargin.bottom);
    
    if (contentSize.height < CGRectGetHeight(self.collectionView.bounds)) {

        contentSize.height = CGRectGetHeight(self.collectionView.bounds);

        // Adding an extra point of content height
        // enables scrolling/bouncing
        //
        if (self.isAlwaysBouncing) contentSize.height += 1.0;
        
        self.filling = self.isFillingHeight;
        
    } else {
        
        self.filling = NO;
    }
    
    return contentSize;
}

- (void)prepareLayout {

    // Force update of property -filling
    // used to decide whether to arrange
    // items evenly in collection view's
    // full height
    //
    [self collectionViewContentSize];
    
    CGSize layoutSize = CGSizeMake(CGRectGetWidth(self.collectionView.bounds) - self.layoutMargin.left - self.layoutMargin.right,
                                   CGRectGetHeight(self.collectionView.bounds) - self.layoutMargin.top - self.layoutMargin.bottom);

    CGFloat itemReveal = self.topReveal;
    
    if (self.filling) {
        
        itemReveal = floor(layoutSize.height / [self.collectionView numberOfItemsInSection:0]);
    }

    CGSize itemSize = self.itemSize;
    
    if (itemSize.width == 0.0) itemSize.width = layoutSize.width;
    if (itemSize.height == 0.0) itemSize.height = layoutSize.height;
    
    CGFloat itemHorizontalOffset = 0.5 * (layoutSize.width - itemSize.width);
    CGPoint itemOrigin = CGPointMake(self.layoutMargin.left + floor(itemHorizontalOffset), 0.0);

    // Honor overwritten contentOffset
    //
    CGPoint contentOffset = self.overwriteContentOffset ? self.contentOffset : self.collectionView.contentOffset;

    NSMutableDictionary *layoutAttributes = [NSMutableDictionary dictionary];
    UICollectionViewLayoutAttributes *previousTopOverlappingAttributes[2] = { nil, nil };
    NSInteger itemCount = [self.collectionView numberOfItemsInSection:0];

    static NSInteger firstCompressingItem = -1;
    
    for (NSInteger item = 0; item < itemCount; item++) {
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:0];
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];

        // Cards overlap each other
        // via z depth
        //
        attributes.zIndex = item;
        
        // The moving items are scaled
        //
        if (self.movingIndexPath && attributes.indexPath.item == self.movingIndexPath.item) {
            
            attributes.transform = CGAffineTransformMakeScale(self.movingItemScaleFactor, self.movingItemScaleFactor);
        }

        // By default all items are layed
        // out evenly with each revealing
        // only top part ...
        //
        attributes.frame = CGRectMake(itemOrigin.x, self.layoutMargin.top + itemReveal * item, itemSize.width, itemSize.height);

        if (itemCount == 1 && self.isCenteringSingleItem) {
            
            // Center single item if necessary
            //
            CGRect frame = attributes.frame;

            frame.origin.y = self.layoutMargin.top + 0.5 * (layoutSize.height - itemSize.height);

            attributes.frame = frame;
            
        } else if (contentOffset.y + self.collectionView.contentInset.top < 0.0) {

            // Expand cells when reaching top
            // and user scrolls further down,
            // i.e. when bouncing
            //
            CGRect frame = attributes.frame;
            
            frame.origin.y -= self.bounceFactor * (contentOffset.y + self.collectionView.contentInset.top) * item;
            
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

            // Keep queue of last two items'
            // attributes and hide any item
            // below top overlapping item to
            // improve performance
            //
            if (previousTopOverlappingAttributes[1]) previousTopOverlappingAttributes[1].hidden = YES;
            
            previousTopOverlappingAttributes[1] = previousTopOverlappingAttributes[0];
            previousTopOverlappingAttributes[0] = attributes;

        } else if (self.collectionViewContentSize.height > CGRectGetHeight(self.collectionView.bounds) && contentOffset.y > self.collectionViewContentSize.height - CGRectGetHeight(self.collectionView.bounds)) {

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

- (void)invalidateLayoutWithContext:(UICollectionViewLayoutInvalidationContext *)context {
    
    [super invalidateLayoutWithContext:context];
    
    self.movingIndexPath = context.targetIndexPathsForInteractivelyMovingItems.firstObject;
}

@end
