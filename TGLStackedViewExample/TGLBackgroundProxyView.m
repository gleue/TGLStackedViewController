//
//  TGLBackgroundProxyView.m
//  TGLStackedViewExample
//
//  Created by Tim Gleue on 21.06.16.
//  Copyright © 2016-2019 Tim Gleue • interactive software. All rights reserved.
//

#import "TGLBackgroundProxyView.h"

@implementation TGLBackgroundProxyView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {

    // Return target view subview during hit testing,
    // thus making unreachable target interactable
    //
    return [self.targetView hitTest:point withEvent:event];
}

@end
