//
//  ODXProgressViewController.h
//  iOSExplorer
//
//  Created by Ace Levenberg on 9/4/15.
//  Copyright (c) 2015 Microsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ODXProgressViewController : NSObject

- (instancetype)initWithParentViewController:(UIViewController *)parentViewController;

- (void)showProgressWithTitle:(NSString*)title progress:(NSProgress *)progress;

- (void)hideProgress;

@end
