//
//  TGLTableViewController.m
//  TGLStackedViewExample
//
//  Created by Tim Gleue on 13.05.14.
//  Copyright (c) 2014 Tim Gleue • interactive software. All rights reserved.
//

#import "TGLTableViewController.h"
#import "TGLViewController.h"

@implementation TGLTableViewController

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    self.navigationController.toolbarHidden = YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    TGLViewController *controller = segue.destinationViewController;
    
    controller.exposedBottomOverlapCount = 4;
    
    controller.exposedTopPinningCount = 2;
    controller.exposedBottomPinningCount = 5;
    
    if ([segue.identifier rangeOfString:@"LowerPinned"].location != NSNotFound) {
        
        controller.exposedItemSize = controller.stackedLayout.itemSize = CGSizeMake(0.0, 240.0);
        controller.exposedPinningMode = TGLExposedLayoutPinningModeBelow;
        controller.exposedTopOverlap = 5.0;
        controller.exposedBottomOverlap = 5.0;
        
    } else if ([segue.identifier rangeOfString:@"AllPinned"].location != NSNotFound) {
        
        controller.exposedItemSize = controller.stackedLayout.itemSize = CGSizeMake(0.0, 240.0);
        controller.exposedPinningMode = TGLExposedLayoutPinningModeAll;
        controller.exposedBottomOverlap = 5.0;

    } else {
        
        controller.exposedTopOverlap = 20.0;
        controller.exposedBottomOverlap = 20.0;
    }
    
    if ([segue.identifier hasPrefix:@"Modal"]) {
        
        controller.doubleTapToClose = YES;
        controller.exposedLayoutMargin = UIEdgeInsetsMake(40.0, 0.0, 0.0, 0.0);
        
    } else {
        
        controller.stackedLayout.layoutMargin = UIEdgeInsetsZero;
        controller.exposedLayoutMargin = controller.exposedPinningMode ? UIEdgeInsetsMake(40.0, 0.0, 0.0, 0.0) : UIEdgeInsetsMake(20.0, 0.0, 0.0, 0.0);
    }

    if ([segue.identifier hasSuffix:@"WithToolbar"]) {
        
        self.navigationController.toolbarHidden = NO;
    }
    
    if ([segue.identifier hasSuffix:@"WithoutExtendedEdges"]) {
        
        controller.edgesForExtendedLayout = UIRectEdgeNone;
    }
}

@end
