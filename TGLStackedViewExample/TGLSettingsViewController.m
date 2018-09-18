//
//  TGLSettingsViewController.m
//  TGLStackedViewExample
//
//  Created by Tim Gleue on 10.06.16.
//  Copyright © 2016 Tim Gleue • interactive software. All rights reserved.
//

#import "TGLSettingsViewController.h"
#import "TGLSettingOptionsViewController.h"
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

@interface TGLOptionsTableViewCell : TGLSettingsTableViewCell

@end

#pragma mark - TGLSettingsViewController

@interface TGLSettingsViewController () <TGLSettingOptionsViewControllerDelegate>

@property (nonatomic, strong) NSArray<NSDictionary*> *sections;
@property (nonatomic, strong) NSMutableDictionary *values;

@end

static NSString * const TGLSettingsSectionHeaderTitleKey = @"headerTitle";
static NSString * const TGLSettingsSectionRowArrayKey = @"sectionRows";

static NSString * const TGLSettingsRowTypeKey = @"rowType";
static NSString * const TGLSettingsRowTypeSwitch = @"switch";
static NSString * const TGLSettingsRowTypeStepper = @"stepper";
static NSString * const TGLSettingsRowTypeOptions = @"options";
static NSString * const TGLSettingsRowDefaultValueKey = @"defaultValue";
static NSString * const TGLSettingsRowKeyPathKey = @"keyPath";

static NSString * const TGLSettingsSwitchRowTitleKey = @"title";

static NSString * const TGLSettingsStepperRowTitleFormatKey = @"titleFormat";
static NSString * const TGLSettingsStepperRowNumberStyleKey = @"numberStyle";
static NSString * const TGLSettingsStepperRowMinValueKey = @"minValue";
static NSString * const TGLSettingsStepperRowMaxValueKey = @"maxValue";
static NSString * const TGLSettingsStepperRowValueFactorKey = @"valueFactor";

static NSString * const TGLSettingsOptionsRowTitleKey = @"title";
static NSString * const TGLSettingsOptionsRowValuesArrayKey = @"optionValues";
static NSString * const TGLSettingsOptionsRowOptionNameKey = @"name";
static NSString * const TGLSettingsOptionsRowOptionValueKey = @"value";

@implementation TGLSettingsViewController

#pragma mark - View life cycle

- (void)viewDidLoad {

    [super viewDidLoad];
    
    NSArray *navigationRows = @[ @{ TGLSettingsRowTypeKey: TGLSettingsRowTypeSwitch, TGLSettingsSwitchRowTitleKey: @"Hides Navigation Bar", TGLSettingsRowDefaultValueKey: @(YES), TGLSettingsRowKeyPathKey: @"%N.navigationBarHidden" },
                                 @{ TGLSettingsRowTypeKey: TGLSettingsRowTypeSwitch, TGLSettingsSwitchRowTitleKey: @"Hides Toolbar", TGLSettingsRowDefaultValueKey: @(YES), TGLSettingsRowKeyPathKey: @"%N.toolbarHidden" } ];
    
    NSDictionary *navigationSection = @{ TGLSettingsSectionHeaderTitleKey: @"Navigation Controller", TGLSettingsSectionRowArrayKey: navigationRows };
    
    NSArray *controllerRows = @[ @{ TGLSettingsRowTypeKey: TGLSettingsRowTypeSwitch,  TGLSettingsSwitchRowTitleKey: @"Adjust Scroll View Insets", TGLSettingsRowDefaultValueKey: @(NO), TGLSettingsRowKeyPathKey: @"%S.automaticallyAdjustsScrollViewInsets" },
                                 @{ TGLSettingsRowTypeKey: TGLSettingsRowTypeSwitch, TGLSettingsSwitchRowTitleKey: @"Shows Scroll Indicators", TGLSettingsRowDefaultValueKey: @(NO), TGLSettingsRowKeyPathKey: @"%S.showsVerticalScrollIndicator" },
                                 @{ TGLSettingsRowTypeKey: TGLSettingsRowTypeSwitch, TGLSettingsSwitchRowTitleKey: @"Shows Background View", TGLSettingsRowDefaultValueKey: @(NO), TGLSettingsRowKeyPathKey: @"%S.showsBackgroundView" },
                                 @{ TGLSettingsRowTypeKey: TGLSettingsRowTypeStepper, TGLSettingsStepperRowTitleFormatKey: @"%@ Cards", TGLSettingsStepperRowNumberStyleKey: @(NSNumberFormatterDecimalStyle), TGLSettingsRowDefaultValueKey: @(20), TGLSettingsStepperRowMinValueKey: @(0), TGLSettingsStepperRowMaxValueKey: @(100), TGLSettingsRowKeyPathKey: @"%S.cardCount" },
                                 @{ TGLSettingsRowTypeKey: TGLSettingsRowTypeStepper, TGLSettingsStepperRowTitleFormatKey: @"%@ Card Height", TGLSettingsStepperRowNumberStyleKey: @(NSNumberFormatterDecimalStyle), TGLSettingsRowDefaultValueKey: @(320), TGLSettingsStepperRowMinValueKey: @(0), TGLSettingsStepperRowMaxValueKey: @(1000), TGLSettingsRowKeyPathKey: @"%S.cardSize.height" } ];
    
    NSDictionary *controllerSection = @{ TGLSettingsSectionHeaderTitleKey: @"Stacked View Controller", TGLSettingsSectionRowArrayKey: controllerRows };

    CGRect statusFrame = [[UIApplication sharedApplication] statusBarFrame];

    NSArray *stackedRows = @[ @{ TGLSettingsRowTypeKey: TGLSettingsRowTypeStepper, TGLSettingsStepperRowTitleFormatKey: @"%@ Top Margin", TGLSettingsStepperRowNumberStyleKey: @(NSNumberFormatterDecimalStyle), TGLSettingsRowDefaultValueKey: @(statusFrame.size.height), TGLSettingsStepperRowMinValueKey: @(0), TGLSettingsStepperRowMaxValueKey: @(200), TGLSettingsRowKeyPathKey: @"%S.stackedLayoutMargin.top" },
                              @{ TGLSettingsRowTypeKey: TGLSettingsRowTypeStepper, TGLSettingsStepperRowTitleFormatKey: @"%@ Left Margin", TGLSettingsStepperRowNumberStyleKey: @(NSNumberFormatterDecimalStyle), TGLSettingsRowDefaultValueKey: @(0), TGLSettingsStepperRowMinValueKey: @(0), TGLSettingsStepperRowMaxValueKey: @(100), TGLSettingsRowKeyPathKey: @"%S.stackedLayoutMargin.left" },
                              @{ TGLSettingsRowTypeKey: TGLSettingsRowTypeStepper, TGLSettingsStepperRowTitleFormatKey: @"%@ Right Margin", TGLSettingsStepperRowNumberStyleKey: @(NSNumberFormatterDecimalStyle), TGLSettingsRowDefaultValueKey: @(0), TGLSettingsStepperRowMinValueKey: @(0), TGLSettingsStepperRowMaxValueKey: @(100), TGLSettingsRowKeyPathKey: @"%S.stackedLayoutMargin.right" },
                              @{ TGLSettingsRowTypeKey: TGLSettingsRowTypeStepper, TGLSettingsStepperRowTitleFormatKey: @"%@ Top Reveal", TGLSettingsStepperRowNumberStyleKey: @(NSNumberFormatterDecimalStyle), TGLSettingsRowDefaultValueKey: @(120), TGLSettingsStepperRowMinValueKey: @(1), TGLSettingsStepperRowMaxValueKey: @(500), TGLSettingsRowKeyPathKey: @"%S.stackedTopReveal" },
                              @{ TGLSettingsRowTypeKey: TGLSettingsRowTypeSwitch,  TGLSettingsSwitchRowTitleKey: @"Fill Height", TGLSettingsRowDefaultValueKey: @(YES), TGLSettingsRowKeyPathKey: @"%S.stackedFillHeight" },
                              @{ TGLSettingsRowTypeKey: TGLSettingsRowTypeSwitch,  TGLSettingsSwitchRowTitleKey: @"Center Single Item", TGLSettingsRowDefaultValueKey: @(NO), TGLSettingsRowKeyPathKey: @"%S.stackedCenterSingleItem" },
                              @{ TGLSettingsRowTypeKey: TGLSettingsRowTypeSwitch,  TGLSettingsSwitchRowTitleKey: @"Always Bounce", TGLSettingsRowDefaultValueKey: @(YES), TGLSettingsRowKeyPathKey: @"%S.stackedAlwaysBounce" },
                              @{ TGLSettingsRowTypeKey: TGLSettingsRowTypeStepper, TGLSettingsStepperRowTitleFormatKey: @"%@ Bounce Factor", TGLSettingsStepperRowNumberStyleKey: @(NSNumberFormatterPercentStyle), TGLSettingsRowDefaultValueKey: @(20), TGLSettingsStepperRowMinValueKey: @(0), TGLSettingsStepperRowMaxValueKey: @(200), TGLSettingsStepperRowValueFactorKey: @(0.01), TGLSettingsRowKeyPathKey: @"%S.stackedBounceFactor" },
                              @{ TGLSettingsRowTypeKey: TGLSettingsRowTypeStepper, TGLSettingsStepperRowTitleFormatKey: @"%@ Moving Scale", TGLSettingsStepperRowNumberStyleKey: @(NSNumberFormatterPercentStyle), TGLSettingsRowDefaultValueKey: @(95), TGLSettingsStepperRowMinValueKey: @(0), TGLSettingsStepperRowMaxValueKey: @(200), TGLSettingsStepperRowValueFactorKey: @(0.01), TGLSettingsRowKeyPathKey: @"%S.movingItemScaleFactor" },
                              @{ TGLSettingsRowTypeKey: TGLSettingsRowTypeSwitch,  TGLSettingsSwitchRowTitleKey: @"Moving Item on Top", TGLSettingsRowDefaultValueKey: @(YES), TGLSettingsRowKeyPathKey: @"%S.movingItemOnTop" } ];
    
    NSDictionary *stackedSection = @{ TGLSettingsSectionHeaderTitleKey: @"Stacked Layout", TGLSettingsSectionRowArrayKey: stackedRows };

    NSArray *exposedPinningOptions = @[ @{ TGLSettingsOptionsRowOptionNameKey: @"Pin All", TGLSettingsOptionsRowOptionValueKey: @(2) }, @{ TGLSettingsOptionsRowOptionNameKey: @"Pin Below", TGLSettingsOptionsRowOptionValueKey: @(1) }, @{ TGLSettingsOptionsRowOptionNameKey: @"Pin None", TGLSettingsOptionsRowOptionValueKey: @(0) } ];
    
    NSArray *exposedRows = @[ @{ TGLSettingsRowTypeKey: TGLSettingsRowTypeStepper, TGLSettingsStepperRowTitleFormatKey: @"%@ Top Margin", TGLSettingsStepperRowNumberStyleKey: @(NSNumberFormatterDecimalStyle), TGLSettingsRowDefaultValueKey: @(statusFrame.size.height + 20), TGLSettingsStepperRowMinValueKey: @(0), TGLSettingsStepperRowMaxValueKey: @(200), TGLSettingsRowKeyPathKey: @"%S.exposedLayoutMargin.top" },
                              @{ TGLSettingsRowTypeKey: TGLSettingsRowTypeStepper, TGLSettingsStepperRowTitleFormatKey: @"%@ Left Margin", TGLSettingsStepperRowNumberStyleKey: @(NSNumberFormatterDecimalStyle), TGLSettingsRowDefaultValueKey: @(0), TGLSettingsStepperRowMinValueKey: @(0), TGLSettingsStepperRowMaxValueKey: @(100), TGLSettingsRowKeyPathKey: @"%S.exposedLayoutMargin.left" },
                              @{ TGLSettingsRowTypeKey: TGLSettingsRowTypeStepper, TGLSettingsStepperRowTitleFormatKey: @"%@ Right Margin", TGLSettingsStepperRowNumberStyleKey: @(NSNumberFormatterDecimalStyle), TGLSettingsRowDefaultValueKey: @(0), TGLSettingsStepperRowMinValueKey: @(0), TGLSettingsStepperRowMaxValueKey: @(100), TGLSettingsRowKeyPathKey: @"%S.exposedLayoutMargin.right" },
                              @{ TGLSettingsRowTypeKey: TGLSettingsRowTypeOptions, TGLSettingsOptionsRowTitleKey: @"Pinning Mode", TGLSettingsRowDefaultValueKey: @(2), TGLSettingsRowKeyPathKey: @"%S.exposedPinningMode", TGLSettingsOptionsRowValuesArrayKey: exposedPinningOptions },
                              @{ TGLSettingsRowTypeKey: TGLSettingsRowTypeStepper, TGLSettingsStepperRowTitleFormatKey: @"%@ Top Pinning Count", TGLSettingsStepperRowNumberStyleKey: @(NSNumberFormatterDecimalStyle), TGLSettingsRowDefaultValueKey: @(-1), TGLSettingsStepperRowMinValueKey: @(-1), TGLSettingsStepperRowMaxValueKey: @(10), TGLSettingsRowKeyPathKey: @"%S.exposedTopPinningCount" },
                              @{ TGLSettingsRowTypeKey: TGLSettingsRowTypeStepper, TGLSettingsStepperRowTitleFormatKey: @"%@ Bottom Pinning Count", TGLSettingsStepperRowNumberStyleKey: @(NSNumberFormatterDecimalStyle), TGLSettingsRowDefaultValueKey: @(-1), TGLSettingsStepperRowMinValueKey: @(-1), TGLSettingsStepperRowMaxValueKey: @(10), TGLSettingsRowKeyPathKey: @"%S.exposedBottomPinningCount" },
                              @{ TGLSettingsRowTypeKey: TGLSettingsRowTypeStepper, TGLSettingsStepperRowTitleFormatKey: @"%@ Top Overlap", TGLSettingsStepperRowNumberStyleKey: @(NSNumberFormatterDecimalStyle), TGLSettingsRowDefaultValueKey: @(10), TGLSettingsStepperRowMinValueKey: @(0), TGLSettingsStepperRowMaxValueKey: @(100), TGLSettingsRowKeyPathKey: @"%S.exposedTopOverlap" },
                              @{ TGLSettingsRowTypeKey: TGLSettingsRowTypeStepper, TGLSettingsStepperRowTitleFormatKey: @"%@ Bottom Overlap", TGLSettingsStepperRowNumberStyleKey: @(NSNumberFormatterDecimalStyle), TGLSettingsRowDefaultValueKey: @(10), TGLSettingsStepperRowMinValueKey: @(0), TGLSettingsStepperRowMaxValueKey: @(100), TGLSettingsRowKeyPathKey: @"%S.exposedBottomOverlap" },
                              @{ TGLSettingsRowTypeKey: TGLSettingsRowTypeStepper, TGLSettingsStepperRowTitleFormatKey: @"%@ Bottom Overlap Count", TGLSettingsStepperRowNumberStyleKey: @(NSNumberFormatterDecimalStyle), TGLSettingsRowDefaultValueKey: @(1), TGLSettingsStepperRowMinValueKey: @(0), TGLSettingsStepperRowMaxValueKey: @(10), TGLSettingsRowKeyPathKey: @"%S.exposedBottomOverlapCount" },
                              @{ TGLSettingsRowTypeKey: TGLSettingsRowTypeSwitch,  TGLSettingsSwitchRowTitleKey: @"Collapsible Exposed Item", TGLSettingsRowDefaultValueKey: @(YES), TGLSettingsRowKeyPathKey: @"%S.exposedItemsAreCollapsible" },
                              @{ TGLSettingsRowTypeKey: TGLSettingsRowTypeSwitch,  TGLSettingsSwitchRowTitleKey: @"Selectable Unexposed Items", TGLSettingsRowDefaultValueKey: @(NO), TGLSettingsRowKeyPathKey: @"%S.unexposedItemsAreSelectable" } ];

    NSDictionary *exposedSection = @{ TGLSettingsSectionHeaderTitleKey: @"Exposed Layout", TGLSettingsSectionRowArrayKey: exposedRows };
    
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
        
    } else if ([segue.identifier isEqualToString:@"ShowOptions"]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        NSDictionary *rowDict = [self rowDictionaryForIndexPath:indexPath fromSections:self.sections];
        NSArray<NSDictionary*> *optionValues = rowDict[TGLSettingsOptionsRowValuesArrayKey];
        
        NSMutableArray<NSString*> *names = [NSMutableArray array];
        NSMutableArray<NSValue*> *values = [NSMutableArray array];
        
        for (NSDictionary *optionDict in optionValues) {

            NSString *optionName = optionDict[TGLSettingsOptionsRowOptionNameKey];
            
            [names addObject:optionName];
            
            NSValue *optionValue = optionDict[TGLSettingsOptionsRowOptionValueKey];

            [values addObject:optionValue];
        }
        
        TGLSettingOptionsViewController *optionsController = segue.destinationViewController;
        
        optionsController.names = names;
        optionsController.values = values;
        optionsController.selectedValue = self.values[indexPath];
        optionsController.optionIndexPath = indexPath;

        optionsController.delegate = self;
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
    NSArray *sectionRows = sectionDict[TGLSettingsSectionRowArrayKey];

    return sectionRows.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSDictionary *sectionDict = self.sections[section];
    
    return NSLocalizedString(sectionDict[TGLSettingsSectionHeaderTitleKey], nil);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *rowDict = [self rowDictionaryForIndexPath:indexPath fromSections:self.sections];

    NSString *rowType = rowDict[TGLSettingsRowTypeKey];
    
    if ([rowType isEqualToString:TGLSettingsRowTypeSwitch]) {
        
        TGLSwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SwitchCell" forIndexPath:indexPath];
        NSString *title = rowDict[TGLSettingsSwitchRowTitleKey];
        
        cell.switchLabel.text = NSLocalizedString(title, nil);
        
        [cell setSwitchValue:[self.values[indexPath] boolValue]];

        cell.keyPath = rowDict[TGLSettingsRowKeyPathKey];
        cell.indexPath = indexPath;
        cell.valuesDict = self.values;
        
        return cell;
        
    } else if ([rowType isEqualToString:TGLSettingsRowTypeStepper]) {
        
        TGLStepperTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StepperCell" forIndexPath:indexPath];

        cell.labelFormat = rowDict[TGLSettingsStepperRowTitleFormatKey];
        cell.numberStyle = (NSNumberFormatterStyle)[rowDict[TGLSettingsStepperRowNumberStyleKey] integerValue];

        cell.stepperControl.minimumValue = [rowDict[TGLSettingsStepperRowMinValueKey] doubleValue];
        cell.stepperControl.maximumValue = [rowDict[TGLSettingsStepperRowMaxValueKey] doubleValue];
        
        [cell setStepperValue:[self.values[indexPath] doubleValue]];
        
        cell.keyPath = rowDict[TGLSettingsRowKeyPathKey];
        cell.indexPath = indexPath;
        cell.valuesDict = self.values;

        return cell;
        
    } else if ([rowType isEqualToString:TGLSettingsRowTypeOptions]) {
        
        TGLOptionsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OptionsCell" forIndexPath:indexPath];
        NSString *title = rowDict[TGLSettingsSwitchRowTitleKey];
        NSString *name = [self nameForOptionWithValue:self.values[indexPath] inOptionValuesArray:rowDict[TGLSettingsOptionsRowValuesArrayKey]];

        cell.textLabel.text = NSLocalizedString(title, nil);
        cell.detailTextLabel.text = NSLocalizedString(name, nil);
        
        cell.keyPath = rowDict[TGLSettingsRowKeyPathKey];
        cell.indexPath = indexPath;
        cell.valuesDict = self.values;
        
        return cell;
        
    } else {
        
        return nil;
    }
}

#pragma mark - TGLSettingOptionsViewControllerDelegate protocol

- (void)optionsViewController:(TGLSettingOptionsViewController *)controller didSelectValue:(NSValue *)value {
    
    NSIndexPath *indexPath = controller.optionIndexPath;

    self.values[indexPath] = value;
    
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - Helpers

- (NSMutableDictionary *)dictionaryOfDefaultValuesFromSections:(NSArray<NSDictionary*> *)sections {
    
    NSMutableDictionary *valuesDict = [NSMutableDictionary dictionary];
    
    NSInteger section = 0;
    
    for (NSDictionary *sectionDict in sections) {
        
        NSInteger row = 0;
        
        for (NSDictionary *rowDict in sectionDict[TGLSettingsSectionRowArrayKey]) {
            
            NSIndexPath *rowIndexPath = [NSIndexPath indexPathForRow:row inSection:section];
            
            valuesDict[rowIndexPath] = rowDict[TGLSettingsRowDefaultValueKey];

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
        
        for (NSDictionary *rowDict in sectionDict[TGLSettingsSectionRowArrayKey]) {
            
            NSString *rowType = rowDict[TGLSettingsRowTypeKey];
            NSString *rowKeyPath = rowDict[TGLSettingsRowKeyPathKey];
            
            rowKeyPath = [rowKeyPath stringByReplacingOccurrencesOfString:@"%N" withString:@"destinationViewController"];
            rowKeyPath = [rowKeyPath stringByReplacingOccurrencesOfString:@"%S" withString:@"destinationViewController.topViewController"];
            
            NSIndexPath *rowIndexPath = [NSIndexPath indexPathForRow:row inSection:section];
            
            if ([rowType isEqualToString:TGLSettingsRowTypeSwitch]) {
                
                [segue setValue:@([values[rowIndexPath] boolValue]) forKeyPath:rowKeyPath];
                
            } else if ([rowType isEqualToString:TGLSettingsRowTypeStepper]) {
                
                double value = [values[rowIndexPath] doubleValue];
                
                if (rowDict[TGLSettingsStepperRowValueFactorKey]) {
                    
                    value *= [rowDict[TGLSettingsStepperRowValueFactorKey] doubleValue];
                }

                [segue setValue:@(value) forKeyPath:rowKeyPath];
                
            } else if ([rowType isEqualToString:TGLSettingsRowTypeOptions]) {
                
                [segue setValue:values[rowIndexPath] forKeyPath:rowKeyPath];
            }
            
            row += 1;
        }
        
        section += 1;
    }
}

- (NSDictionary *)rowDictionaryForIndexPath:(NSIndexPath *)indexPath fromSections:(NSArray<NSDictionary*> *)sections {
    
    NSDictionary *sectionDict = sections[indexPath.section];
    NSArray *sectionRows = sectionDict[TGLSettingsSectionRowArrayKey];
    
    return sectionRows[indexPath.row];
}

- (NSString *)nameForOptionWithValue:(NSValue *)value inOptionValuesArray:(NSArray<NSDictionary*> *)options {
    
    for (NSDictionary *optionDict in options) {
        
        NSValue *optionValue = optionDict[TGLSettingsOptionsRowOptionValueKey];
        
        if ([optionValue isEqualToValue:value]) return optionDict[TGLSettingsOptionsRowOptionNameKey];
    }
    
    return nil;
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

@implementation TGLOptionsTableViewCell
@end
