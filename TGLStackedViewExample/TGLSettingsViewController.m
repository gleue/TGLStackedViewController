//
//  TGLSettingsViewController.m
//  TGLStackedViewExample
//
//  Created by Tim Gleue on 10.06.16.
//  Copyright © 2016 Tim Gleue • interactive software. All rights reserved.
//

#import "TGLSettingsViewController.h"
#import "TGLViewController.h"

#pragma mark - TGLSettingsTableViewCell interfaces

@interface TGLSettingsTableViewCell : UITableViewCell

@property (nonatomic, copy) NSString *keyPath;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, strong) NSMutableDictionary *valuesDict;

@end

@interface TGLSwitchTableViewCell : TGLSettingsTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *switchLabel;
@property (weak, nonatomic) IBOutlet UISwitch *switchControl;

- (void)setSwitchValue:(BOOL)value;

@end

@interface TGLStepperTableViewCell : TGLSettingsTableViewCell

@property (nonatomic, copy) NSString *labelFormat;
@property (nonatomic, assign) NSNumberFormatterStyle numberStyle;

@property (weak, nonatomic) IBOutlet UILabel *stepperLabel;
@property (weak, nonatomic) IBOutlet UIStepper *stepperControl;

- (void)setStepperValue:(double)value;

@end

#pragma mark - TGLSettingsViewController

@interface TGLSettingsViewController ()

@property (nonatomic, strong) NSArray<NSDictionary*> *sections;
@property (nonatomic, strong) NSMutableDictionary *values;

@end

@implementation TGLSettingsViewController

#pragma mark - View life cycle

- (void)viewDidLoad {

    [super viewDidLoad];
    
    NSArray *navigationRows = @[ @{ @"type": @"switch", @"title": @"Hides Navigation Bar", @"defaultValue": @(YES), @"keyPath": @"%N.navigationBarHidden" },
                                 @{ @"type": @"switch", @"title": @"Hides Toolbar", @"defaultValue": @(YES), @"keyPath": @"%N.toolbarHidden" } ];
    
    NSDictionary *navigationSection = @{ @"headerTitle": @"Navigation Controller", @"rows": navigationRows };
    
    NSArray *controllerRows = @[ @{ @"type": @"switch",  @"title": @"Adjust Scroll View Insets", @"defaultValue": @(NO), @"keyPath": @"%S.automaticallyAdjustsScrollViewInsets" },
                                 @{ @"type": @"stepper", @"titleFormat": @"%@ Cards", @"numberStyle": @(kCFNumberFormatterDecimalStyle), @"defaultValue": @(20), @"minValue": @(0), @"maxValue": @(100), @"keyPath": @"%S.cardCount" },
                                 @{ @"type": @"stepper", @"titleFormat": @"%@ Card Width", @"numberStyle": @(kCFNumberFormatterDecimalStyle), @"defaultValue": @(0), @"minValue": @(0), @"maxValue": @(500), @"keyPath": @"%S.cardSize.width" },
                                 @{ @"type": @"stepper", @"titleFormat": @"%@ Card Height", @"numberStyle": @(kCFNumberFormatterDecimalStyle), @"defaultValue": @(320), @"minValue": @(0), @"maxValue": @(1000), @"keyPath": @"%S.cardSize.height" } ];
    
    NSDictionary *controllerSection = @{ @"headerTitle": @"Stacked View Controller", @"rows": controllerRows };
    
    NSArray *stackedRows = @[ @{ @"type": @"stepper", @"titleFormat": @"%@ Top Reveal", @"numberStyle": @(NSNumberFormatterDecimalStyle), @"defaultValue": @(120), @"minValue": @(1), @"maxValue": @(500), @"keyPath": @"%S.stackedTopReveal" },
                              @{ @"type": @"switch",  @"title": @"Fill Height", @"defaultValue": @(YES), @"keyPath": @"%S.stackedFillHeight" },
                              @{ @"type": @"switch",  @"title": @"Always Bounce", @"defaultValue": @(YES), @"keyPath": @"%S.stackedAlwaysBounce" },
                              @{ @"type": @"stepper", @"titleFormat": @"%@ Bounce Factor", @"numberStyle": @(NSNumberFormatterPercentStyle), @"defaultValue": @(20), @"minValue": @(0), @"maxValue": @(200), @"valueFactor": @(0.01), @"keyPath": @"%S.stackedBounceFactor" },
                              @{ @"type": @"stepper", @"titleFormat": @"%@ Moving Scale", @"numberStyle": @(NSNumberFormatterPercentStyle), @"defaultValue": @(95), @"minValue": @(0), @"maxValue": @(200), @"valueFactor": @(0.01), @"keyPath": @"%S.movingItemScaleFactor" } ];
    
    NSDictionary *stackedSection = @{ @"headerTitle": @"Stacked Layout", @"rows": stackedRows };

    NSArray *exposedRows = @[ @{ @"type": @"switch",  @"title": @"Collapsible Exposed Item", @"defaultValue": @(YES), @"keyPath": @"%S.exposedItemsAreCollapsible" },
                              @{ @"type": @"switch",  @"title": @"Selectable Unexposed Items", @"defaultValue": @(NO), @"keyPath": @"%S.unexposedItemsAreSelectable" },
                              @{ @"type": @"stepper", @"titleFormat": @"%@ Top Pinning Count", @"numberStyle": @(NSNumberFormatterDecimalStyle), @"defaultValue": @(-1), @"minValue": @(-1), @"maxValue": @(10), @"keyPath": @"%S.exposedTopPinningCount" },
                              @{ @"type": @"stepper", @"titleFormat": @"%@ Bottom Pinning Count", @"numberStyle": @(NSNumberFormatterDecimalStyle), @"defaultValue": @(-1), @"minValue": @(-1), @"maxValue": @(10), @"keyPath": @"%S.exposedBottomPinningCount" },
                              @{ @"type": @"stepper", @"titleFormat": @"%@ Top Overlap", @"numberStyle": @(NSNumberFormatterDecimalStyle), @"defaultValue": @(20), @"minValue": @(0), @"maxValue": @(100), @"keyPath": @"%S.exposedTopOverlap" },
                              @{ @"type": @"stepper", @"titleFormat": @"%@ Bottom Overlap", @"numberStyle": @(NSNumberFormatterDecimalStyle), @"defaultValue": @(20), @"minValue": @(0), @"maxValue": @(100), @"keyPath": @"%S.exposedBottomOverlap" },
                              @{ @"type": @"stepper", @"titleFormat": @"%@ Bottom Overlap Count", @"numberStyle": @(NSNumberFormatterDecimalStyle), @"defaultValue": @(1), @"minValue": @(0), @"maxValue": @(10), @"keyPath": @"%S.exposedBottomOverlapCount" } ];
    
    NSDictionary *exposedSection = @{ @"headerTitle": @"Exposed Layout", @"rows": exposedRows };
    
    self.sections = @[ navigationSection, controllerSection, stackedSection, exposedSection ];
    
    [self resetSettings:nil];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"ShowExample"]) {
        
        [self applyValues:self.values forSections:self.sections ToSegue:segue];

        UINavigationController *navigationController = segue.destinationViewController;
        TGLViewController *stackedController = (TGLViewController *)navigationController.topViewController;
        
        stackedController.doubleTapToClose = navigationController.navigationBarHidden;
        
        if (!stackedController.doubleTapToClose) {
            
            stackedController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(closeStackedController:)];
        }
    }
}

#pragma mark - Actions

- (IBAction)resetSettings:(id)sender {
    
    self.values = [self dictionaryOfDefaultValuesFromSections:self.sections];

    [self.tableView reloadData];
}

- (IBAction)closeStackedController:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource protocol

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    NSDictionary *sectionDict = self.sections[section];
    NSArray *sectionRows = sectionDict[@"rows"];

    return sectionRows.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSDictionary *sectionDict = self.sections[section];
    
    return NSLocalizedString(sectionDict[@"headerTitle"], nil);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *sectionDict = self.sections[indexPath.section];
    NSArray *sectionRows = sectionDict[@"rows"];
    NSDictionary *rowDict = sectionRows[indexPath.row];

    NSString *rowType = rowDict[@"type"];
    
    if ([rowType isEqualToString:@"switch"]) {
        
        TGLSwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SwitchCell" forIndexPath:indexPath];
        
        cell.switchLabel.text = rowDict[@"title"];
        
        [cell setSwitchValue:[self.values[indexPath] boolValue]];

        cell.keyPath = rowDict[@"keyPath"];
        cell.indexPath = indexPath;
        cell.valuesDict = self.values;
        
        return cell;
        
    } else if ([rowType isEqualToString:@"stepper"]) {
        
        TGLStepperTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StepperCell" forIndexPath:indexPath];

        cell.labelFormat = rowDict[@"titleFormat"];
        cell.numberStyle = (NSNumberFormatterStyle)rowDict[@"numberStyle"];

        cell.stepperControl.minimumValue = [rowDict[@"minValue"] doubleValue];
        cell.stepperControl.maximumValue = [rowDict[@"maxValue"] doubleValue];
        
        [cell setStepperValue:[self.values[indexPath] doubleValue]];
        
        cell.keyPath = rowDict[@"keyPath"];
        cell.indexPath = indexPath;
        cell.valuesDict = self.values;

        return cell;
        
    } else {
        
        return nil;
    }
}

#pragma mark - Helpers

- (NSMutableDictionary *)dictionaryOfDefaultValuesFromSections:(NSArray<NSDictionary*> *)sections {
    
    NSMutableDictionary *valuesDict = [NSMutableDictionary dictionary];
    
    NSInteger section = 0;
    
    for (NSDictionary *sectionDict in sections) {
        
        NSInteger row = 0;
        
        for (NSDictionary *rowDict in sectionDict[@"rows"]) {
            
            NSIndexPath *rowIndexPath = [NSIndexPath indexPathForRow:row inSection:section];
            
            valuesDict[rowIndexPath] = rowDict[@"defaultValue"];

            row += 1;
        }
        
        section += 1;
    }
    
    return valuesDict;
}

- (void)applyValues:(NSDictionary *)values forSections:(NSArray<NSDictionary*> *)sections ToSegue:(UIStoryboardSegue *)segue {
    
    NSInteger section = 0;
    
    for (NSDictionary *sectionDict in sections) {
        
        NSInteger row = 0;
        
        for (NSDictionary *rowDict in sectionDict[@"rows"]) {
            
            NSString *rowType = rowDict[@"type"];
            NSString *rowKeyPath = rowDict[@"keyPath"];
            
            rowKeyPath = [rowKeyPath stringByReplacingOccurrencesOfString:@"%N" withString:@"destinationViewController"];
            rowKeyPath = [rowKeyPath stringByReplacingOccurrencesOfString:@"%S" withString:@"destinationViewController.topViewController"];
            
            NSIndexPath *rowIndexPath = [NSIndexPath indexPathForRow:row inSection:section];
            
            if ([rowType isEqualToString:@"switch"]) {
                
                [segue setValue:@([values[rowIndexPath] boolValue]) forKeyPath:rowKeyPath];
                
            } else if ([rowType isEqualToString:@"stepper"]) {
                
                double value = [values[rowIndexPath] doubleValue];
                
                if (rowDict[@"valueFactor"]) {
                    
                    value *= [rowDict[@"valueFactor"] doubleValue];
                }

                [segue setValue:@(value) forKeyPath:rowKeyPath];
            }
            
            row += 1;
        }
        
        section += 1;
    }
}

@end

#pragma mark - TGLSettingsTableViewCell implementations

@implementation TGLSettingsTableViewCell
@end

@implementation TGLSwitchTableViewCell

- (void)setSwitchValue:(BOOL)value {
    
    self.switchControl.on = value;
}

- (IBAction)switchValueChanged:(id)sender {
    
    self.valuesDict[self.indexPath] = @(self.switchControl.on);
}

@end

@implementation TGLStepperTableViewCell

- (void)setStepperValue:(double)value {

    self.stepperControl.value = value;
    
    [self updateLabel];
}

- (IBAction)stepperValueChanged:(id)sender {
    
    self.valuesDict[self.indexPath] = @(self.stepperControl.value);

    [self updateLabel];
}

- (void)updateLabel {
    
    double value = self.stepperControl.value;
    
    if (self.numberStyle == NSNumberFormatterPercentStyle) value /= 100.0;
    
    NSString *localizedFormat = NSLocalizedString(self.labelFormat, nil);
    
    self.stepperLabel.text = [NSString stringWithFormat:localizedFormat, [NSNumberFormatter localizedStringFromNumber:@(value) numberStyle:self.numberStyle]];
}

@end
