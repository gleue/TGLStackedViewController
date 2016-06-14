//
//  TGLViewController.m
//  TGLStackedViewExample
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

#import "TGLViewController.h"
#import "TGLCollectionViewCell.h"

@interface UIColor (randomColor)

+ (UIColor *)randomColor;

@end

@implementation UIColor (randomColor)

+ (UIColor *)randomColor {
    
    CGFloat comps[3];
    
    for (int i = 0; i < 3; i++) {
        
        NSUInteger r = arc4random_uniform(256);
        comps[i] = (CGFloat)r/255.f;
    }
    
    return [UIColor colorWithRed:comps[0] green:comps[1] blue:comps[2] alpha:1.0];
}

@end

@interface TGLViewController ()

@property (nonatomic, weak) IBOutlet UIBarButtonItem *deselectItem;

@property (nonatomic, strong, readonly) NSMutableArray *cards;

@property (nonatomic, strong) NSTimer *dismissTimer;

@end

@implementation TGLViewController

@synthesize cards = _cards;

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        
        _cardCount = 20;
        _cardSize = CGSizeZero;
        
        _stackedLayoutMargin = UIEdgeInsetsMake(20.0, 0.0, 0.0, 0.0);
        _stackedTopReveal = 120.0;
        _stackedBounceFactor = 0.2;
        _stackedFillHeight = NO;
        _stackedAlwaysBounce = NO;
    }
    
    return self;
}

- (void)dealloc {

    [self stopDismissTimer];
}

#pragma mark - View life cycle

- (void)viewDidLoad {

    [super viewDidLoad];
    
    self.exposedItemSize = self.cardSize;

    self.stackedLayout.itemSize = self.exposedItemSize;
    self.stackedLayout.layoutMargin = self.stackedLayoutMargin;
    self.stackedLayout.topReveal = self.stackedTopReveal;
    self.stackedLayout.bounceFactor = self.stackedBounceFactor;
    self.stackedLayout.fillHeight = self.stackedFillHeight;
    self.stackedLayout.alwaysBounce = self.stackedAlwaysBounce;

    if (self.doubleTapToClose) {
        
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        
        recognizer.delaysTouchesBegan = YES;
        recognizer.numberOfTapsRequired = 2;
        
        [self.collectionView addGestureRecognizer:recognizer];
    }
}

- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];
    
    if (self.doubleTapToClose) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Double Tap to Close", nil)
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleAlert];

        __weak typeof(self) weakSelf = self;
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                         style:UIAlertActionStyleDefault
                                                       handler:^ (UIAlertAction *action) {
                                                           
                                                           [weakSelf.dismissTimer invalidate];
                                                           weakSelf.dismissTimer = nil;
                                                       }];
        
        [alert addAction:action];
        
        [self presentViewController:alert animated:YES completion:^ (void) {
            
            self.dismissTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(dismissTimerFired:) userInfo:nil repeats:NO];
        }];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {

    return UIStatusBarStyleLightContent;
}

#pragma mark - Accessors

- (void)setCardCount:(NSInteger)cardCount {

    if (cardCount != _cardCount) {
        
        _cardCount = cardCount;
        
        _cards = nil;
        
        if (self.isViewLoaded) [self.collectionView reloadData];
    }
}

- (NSMutableArray *)cards {

    if (_cards == nil) {
        
        _cards = [NSMutableArray array];
        
        // Adjust the number of cards here
        //
        for (NSInteger i = 1; i <= self.cardCount; i++) {
            
            NSDictionary *card = @{ @"name" : [NSString stringWithFormat:@"Card #%d", (int)i], @"color" : [UIColor randomColor] };
            
            [_cards addObject:card];
        }
        
    }
    
    return _cards;
}

#pragma mark - Key-Value Coding

- (void)setValue:(id)value forKeyPath:(nonnull NSString *)keyPath {
    
    // Add key-value coding capabilities for some extra properties
    //
    if ([keyPath hasPrefix:@"cardSize."]) {
        
        CGSize cardSize = self.cardSize;
        
        if ([keyPath hasSuffix:@".width"]) {
            
            cardSize.width = [value doubleValue];
            
        } else if ([keyPath hasSuffix:@".height"]) {
            
            cardSize.height = [value doubleValue];
        }
        
        self.cardSize = cardSize;
        
    } else if ([keyPath containsString:@"edLayoutMargin."]) {
        
        NSString *layoutKey = [keyPath componentsSeparatedByString:@"."].firstObject;
        UIEdgeInsets layoutMargin = [layoutKey isEqualToString:@"stackedLayoutMargin"] ? self.stackedLayoutMargin : self.exposedLayoutMargin;
        
        if ([keyPath hasSuffix:@".top"]) {
            
            layoutMargin.top = [value doubleValue];
            
        } else if ([keyPath hasSuffix:@".left"]) {
            
            layoutMargin.left = [value doubleValue];
            
        } else if ([keyPath hasSuffix:@".right"]) {
            
            layoutMargin.right = [value doubleValue];
        }
        
        [self setValue:[NSValue valueWithUIEdgeInsets:layoutMargin] forKey:layoutKey];
        
    } else {
        
        [super setValue:value forKeyPath:keyPath];
    }
}

#pragma mark - Actions

- (IBAction)handleDoubleTap:(UITapGestureRecognizer *)recognizer {
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)dismissTimerFired:(NSTimer *)timer {
    
    if (timer == self.dismissTimer && self.presentedViewController) {

        [self dismissViewControllerAnimated:YES completion:^ (void) {
            
            [self stopDismissTimer];
        }];
    }
}

- (IBAction)collapseExposedItem:(id)sender {
    
    self.exposedItemIndexPath = nil;
}

#pragma mark - UICollectionViewDataSource protocol

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.cards.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    TGLCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CardCell" forIndexPath:indexPath];
    NSDictionary *card = self.cards[indexPath.item];
    
    cell.title = card[@"name"];
    cell.color = card[@"color"];

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    
    // Update data source when moving cards around
    //
    NSDictionary *card = self.cards[sourceIndexPath.item];
    
    [self.cards removeObjectAtIndex:sourceIndexPath.item];
    [self.cards insertObject:card atIndex:destinationIndexPath.item];
}

#pragma mark - Helpers

- (void)stopDismissTimer {
    
    [self.dismissTimer invalidate];
    self.dismissTimer = nil;
}

@end
