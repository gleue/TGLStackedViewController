//
//  TGLSettingOptionsViewController.h
//  TGLStackedViewExample
//
//  Created by Tim Gleue on 12.06.16.
//  Copyright © 2016-2019 Tim Gleue • interactive software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TGLSettingOptionsViewController;

@protocol TGLSettingOptionsViewControllerDelegate <NSObject>

@optional

- (void)optionsViewController:(nonnull TGLSettingOptionsViewController *)controller didSelectValue:(nonnull NSValue *)value;

@end

@interface TGLSettingOptionsViewController : UITableViewController

@property (nonatomic, weak, nullable) id<TGLSettingOptionsViewControllerDelegate> delegate;

@property (nonatomic, strong, nullable) NSArray<NSString*> *names;
@property (nonatomic, strong, nullable) NSArray<NSValue*> *values;

@property (nonatomic, strong, nullable) NSValue *selectedValue;
@property (nonatomic, strong, nullable) NSIndexPath *optionIndexPath;

@end
