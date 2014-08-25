//
//  TGLTableViewController.m
//  TGLStackedViewExample
//
//  Created by Tim Gleue on 13.05.14.
//  Copyright (c) 2014 Tim Gleue • interactive software. All rights reserved.
//

#import "TGLTableViewController.h"
#import "TGLViewController.h"

@interface TGLTableViewController ()

@property (nonatomic, retain) NSArray *segues;

@end

@implementation TGLTableViewController

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    self.navigationController.toolbarHidden = YES;
}

#pragma mark - Accessors

- (NSArray *)segues {
    
    if (_segues == nil) {
        
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
            
            _segues = @[ @"Stand-alone (double tap to close)", @"Show in NavigationController", @"Show with Toolbar" ];
            
        } else {
            
            _segues = @[ @"Stand-alone (double tap to close)", @"Show in NavigationController", @"Show with Toolbar", @"Show without ExtendedEdges" ];
        }
    }
    
    return _segues;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.segues.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //obviously not efficient but we're not doing anything special.
    UITableViewCell* cell = [[UITableViewCell alloc] init];
    [cell.textLabel setText:self.segues[indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [self performSegueWithIdentifier:self.segues[indexPath.row] sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"Stand-alone (double tap to close)"]) {
        
        TGLViewController *controller = segue.destinationViewController;
        controller.stackedLayout.topVisibleOverlappingHeight = 2.f;
        controller.stackedLayout.maxTopVisibleOverlappingCards = 3;
        
        controller.exposedMaxTopVisibleItems = 0;
        controller.exposedMaxBottomVisibleItems = 3;
        controller.exposedBottomOverlap = 40;
        
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
