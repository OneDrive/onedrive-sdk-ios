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
    [self.progressView setProgress:0 animated:YES];
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
