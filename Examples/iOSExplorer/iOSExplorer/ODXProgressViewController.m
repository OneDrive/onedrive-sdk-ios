//
//  ODXProgressViewController.m
//  iOSExplorer
//
//  Created by Ace Levenberg on 9/4/15.
//  Copyright (c) 2015 Microsoft. All rights reserved.
//

#import "ODXProgressViewController.h"

@interface ODXProgressViewController()

@property UIViewController *parentViewController;

@property NSProgress *progress;

@property UIAlertController *progressController;

@property UIProgressView *progressView;

@end

static void *ProgressObserverContext = &ProgressObserverContext;

@implementation ODXProgressViewController

- (instancetype)initWithParentViewController:(UIViewController *)parentViewController
{
    self = [super init];
    if (self){
        _parentViewController = parentViewController;
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context
{
    if (context == ProgressObserverContext){
        dispatch_async(dispatch_get_main_queue(), ^{
            NSProgress *progress = object;
            [self.progressView setProgress:progress.fractionCompleted animated:YES];
        });    
    }
    else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
    
}


- (void)showProgressWithTitle:(NSString*)title progress:(NSProgress *)progress
{
    self.progress = progress;
    self.progressController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    self.progressView.progressTintColor = [UIColor blueColor];
    [self.progressView setProgress:0.25 animated:YES];
    [self.progressController.view addSubview:self.progressView];
    [self.parentViewController presentViewController:self.progressController animated:YES completion:nil];
    [progress addObserver:self forKeyPath:NSStringFromSelector(@selector(fractionCompleted)) options:0 context:ProgressObserverContext];
}

- (void)hideProgress
{
    if (self.progress){
        [self.progress removeObserver:self
                          forKeyPath:NSStringFromSelector(@selector(fractionCompleted))
                             context:ProgressObserverContext];
        self.progress = nil;
    }
    if (self.progressController){
        dispatch_async(dispatch_get_main_queue(), ^{
            self.progressView = nil;
            [self.progressController dismissViewControllerAnimated:YES completion:nil];
            self.progressController = nil;
        });
    }
}



@end
