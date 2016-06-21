//
//  TGLCollectionViewCell.m
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

#import <QuartzCore/QuartzCore.h>

#import "TGLCollectionViewCell.h"

@interface TGLCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

@implementation TGLCollectionViewCell

- (void)awakeFromNib {
    
    [super awakeFromNib];

    self.imageView.tintColor = self.color;
    self.imageView.layer.borderColor = self.nameLabel.highlightedTextColor.CGColor;

    self.nameLabel.text = self.title;
}

#pragma mark - Accessors

- (void)setTitle:(NSString *)title {

    _title = [title copy];
    
    self.nameLabel.text = self.title;
}

- (void)setColor:(UIColor *)color {

    _color = [color copy];
    
    self.imageView.tintColor = self.color;
}

- (void)setSelected:(BOOL)selected {

    [super setSelected:selected];
    
    self.imageView.layer.borderWidth = self.isSelected ? 2.0 : 0.0;
    self.imageView.layer.cornerRadius = self.isSelected ? 8.0 : 0.0;
}

@end
