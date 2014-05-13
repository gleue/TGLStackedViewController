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
    
    if ([segue.identifier isEqualToString:@"Show stand-alone"]) {
        
        TGLViewController *controller = segue.destinationViewController;
        
        controller.doubleTapToClose = YES;
        
    } else if ([segue.identifier isEqualToString:@"Show in NavigationController"]) {
        
        TGLViewController *controller = segue.destinationViewController;
        
        controller.stackedLayout.layoutMargin = UIEdgeInsetsZero;
        controller.exposedLayoutMargin = UIEdgeInsetsMake(20.0, 0.0, 0.0, 0.0);

    } else if ([segue.identifier isEqualToString:@"Show with Toolbar"]) {
        
        self.navigationController.toolbarHidden = NO;
        
        TGLViewController *controller = segue.destinationViewController;
        
        controller.stackedLayout.layoutMargin = UIEdgeInsetsZero;
        controller.exposedLayoutMargin = UIEdgeInsetsMake(20.0, 0.0, 0.0, 0.0);

    } else if ([segue.identifier isEqualToString:@"Show without ExtendedEdges"]) {
        
        TGLViewController *controller = segue.destinationViewController;
        
        controller.stackedLayout.layoutMargin = UIEdgeInsetsZero;
        controller.exposedLayoutMargin = UIEdgeInsetsMake(20.0, 0.0, 0.0, 0.0);
        controller.edgesForExtendedLayout = UIRectEdgeNone;
    }
}

@end
