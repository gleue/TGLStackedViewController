//
//  TGLSettingOptionsViewController.m
//  TGLStackedViewExample
//
//  Created by Tim Gleue on 12.06.16.
//  Copyright © 2016-2019 Tim Gleue • interactive software. All rights reserved.
//

#import "TGLSettingOptionsViewController.h"
#import "TGLViewController.h"

#pragma mark - TGLSettingsTableViewCell interfaces

@interface TGLOptionValueTableViewCell : UITableViewCell

@end

#pragma mark - TGLSettingOptionsViewController

@interface TGLSettingOptionsViewController ()

@end

@implementation TGLSettingOptionsViewController

#pragma mark - View life cycle

- (void)viewDidLoad {

    [super viewDidLoad];
}

#pragma mark - UITableViewDataSource protocol

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return MIN(self.names.count, self.values.count);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TGLOptionValueTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OptionCell" forIndexPath:indexPath];

    cell.textLabel.text = NSLocalizedString(self.names[indexPath.row], nil);
    cell.accessoryType = ([self.values[indexPath.row] isEqualToValue:self.selectedValue]) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    return cell;
}

#pragma mark - UITableViewDelegate protocol

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    for (NSInteger row = 0; row < [tableView numberOfRowsInSection:indexPath.section]; row++) {

        UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:indexPath.section]];
        
        if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
            
            cell.accessoryType = UITableViewCellAccessoryNone;
            break;
        }
    }
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]];
    
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    self.selectedValue = self.values[indexPath.row];
    
    if ([self.delegate respondsToSelector:@selector(optionsViewController:didSelectValue:)]) {
        
        [self.delegate optionsViewController:self didSelectValue:self.selectedValue];
    }
}

@end

#pragma mark - TGLOptionValueTableViewCell implementations

@implementation TGLOptionValueTableViewCell
@end
