//
//  WCDetailTransitionController.m
//  WorldCup
//
//  Created by Ryan Nystrom on 6/24/14.
//  Copyright (c) 2014 Ryan Nystrom. All rights reserved.
//

#import "WCDetailTransitionController.h"
#import "WCDetailController.h"
#import "WCMatchesController.h"
#import "UIImage+Blurring.h"
#import <POP.h>

@interface WCDetailTransition: NSObject
<UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) BOOL isPresenting;

@property (nonatomic, weak) UIView *homeView;
@property (nonatomic, weak) UIView *awayView;

@end

@implementation WCDetailTransition

-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.25;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)ctx {
    id fromController = [ctx viewControllerForKey:UITransitionContextFromViewControllerKey];
    id toController = [ctx viewControllerForKey:UITransitionContextToViewControllerKey];
    
    if (self.isPresenting) {
        [self showDetailController:toController fromMatchesController:fromController context:ctx];
    }
    else {
        [self hideDetailController:fromController toMatchesController:toController context:ctx];
    }
}

- (UIImage *)blurryScreenshot {
    UIView *screenshotView = [UIApplication sharedApplication].keyWindow;
    
    UIGraphicsBeginImageContextWithOptions(screenshotView.bounds.size, NO, 0);
    [screenshotView drawViewHierarchyInRect:screenshotView.bounds afterScreenUpdates:NO];
    UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    screenshot = [screenshot applyBlurWithRadius:5 tintColor:[UIColor colorWithWhite:0.1 alpha:0.6] saturationDeltaFactor:1.8 maskImage:nil];
    
    return screenshot;
}

- (void)showDetailController:(WCDetailController *)detail fromMatchesController:(UIViewController *)matches context:(id<UIViewControllerContextTransitioning>)ctx {
    UIView *containerView = [ctx containerView];
    
    UIView *screenshotView = [UIApplication sharedApplication].keyWindow;
    
    UIGraphicsBeginImageContextWithOptions(screenshotView.bounds.size, NO, 0);
    [screenshotView drawViewHierarchyInRect:screenshotView.bounds afterScreenUpdates:NO];
    UIImage *appsnap = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        UIImage *blur = [appsnap applyBlurWithRadius:5 tintColor:[UIColor colorWithWhite:0.1 alpha:0.6] saturationDeltaFactor:1.8 maskImage:nil];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            detail.backgroundFadeView.image = blur;
            
            // blurview is used for alpha animation
            UIImageView *blurView = [[UIImageView alloc] initWithImage:blur];
            blurView.alpha = 0;
            // make sure index 0 since its an async op
            [containerView insertSubview:blurView aboveSubview:matches.view];
            
            [UIView animateWithDuration:0.5 animations:^{
                blurView.alpha = 1;
            } completion:^(BOOL finished) {
                detail.view.alpha = 0;
                [containerView addSubview:detail.view];
                [UIView animateWithDuration:0.15 animations:^{
                    detail.view.alpha = 1;
                } completion:^(BOOL finished) {
                    [ctx completeTransition:YES];
                }];
            }];
        });
    });
    
//    UIImage *screenshot = [self blurryScreenshot];
    
//    detail.backgroundFadeView.image = screenshot;
    
    UIView *eventSnapshot = [detail.eventsContainer snapshotViewAfterScreenUpdates:YES];
    
    // resting frame for events container
    CGRect originalEventFrame = detail.eventsContainer.frame;
    
    // position event frame at the "bottom" of the screen
    CGRect eventFrame = originalEventFrame;
    eventFrame.origin.y = detail.view.bounds.size.height;
    eventSnapshot.frame = eventFrame;
    [containerView addSubview:eventSnapshot];
    
    // hide flag borders for screenshots
    CGFloat originalHomeBorder = self.homeView.layer.borderWidth;
    CGFloat originalAwayBorder = self.awayView.layer.borderWidth;
    self.homeView.layer.borderWidth = 0;
    self.awayView.layer.borderWidth = 0;
    
    // add snapshots of flag views to animation container
    UIView *homeView = [self.homeView snapshotViewAfterScreenUpdates:YES];
    UIView *awayView = [self.awayView snapshotViewAfterScreenUpdates:YES];
    [containerView addSubview:homeView];
    [containerView addSubview:awayView];
    
    // restore original view borders
    self.homeView.layer.borderWidth = originalHomeBorder;
    self.awayView.layer.borderWidth = originalAwayBorder;
    
    // position flags in animation container relative to screen
    CGRect homeOriginFrame = [self.homeView.superview convertRect:self.homeView.frame toView:containerView];
    CGRect awayOriginFrame = [self.awayView.superview convertRect:self.awayView.frame toView:containerView];
    homeView.frame = homeOriginFrame;
    awayView.frame = awayOriginFrame;
    
    // create resting positions relative to larger flags
    CGRect homeToFrame = [detail.homeFlagImageView.superview convertRect:detail.homeFlagImageView.frame toView:detail.view];
    CGRect awayToFrame = [detail.awayFlagImageView.superview convertRect:detail.awayFlagImageView.frame toView:detail.view];
    
    POPSpringAnimation *homeSpring = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
    // trial & error on these #s
    homeSpring.springSpeed = 20;
    homeSpring.springBounciness = 10;
    homeSpring.toValue = [NSValue valueWithCGRect:homeToFrame];
    [homeView pop_addAnimation:homeSpring forKey:nil];
    
    POPSpringAnimation *awaySpring = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
    awaySpring.springSpeed = 20;
    awaySpring.springBounciness = 10;
    awaySpring.beginTime = CACurrentMediaTime() + 0.1;
    awaySpring.toValue = [NSValue valueWithCGRect:awayToFrame];
    [awayView pop_addAnimation:awaySpring forKey:nil];
    
    POPSpringAnimation *eventSpring = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
    eventSpring.springSpeed = 20;
    eventSpring.springBounciness = 10;
    eventSpring.beginTime = CACurrentMediaTime();
    eventSpring.toValue = [NSValue valueWithCGRect:originalEventFrame];
    [eventSnapshot pop_addAnimation:eventSpring forKey:nil];
}

- (void)hideDetailController:(WCDetailController *)detail toMatchesController:(UIViewController *)matches context:(id<UIViewControllerContextTransitioning>)ctx {
    UIView *containerView = [ctx containerView];
    
    // create snapshot of view that will be underneath
    UIView *matchSnapshot = [matches.view snapshotViewAfterScreenUpdates:YES];
    [containerView insertSubview:matchSnapshot atIndex:0];
    
    // snap blur as separate view since it will use a different animation
    UIView *blurSnapshot = [detail.backgroundFadeView snapshotViewAfterScreenUpdates:YES];
    [containerView addSubview:blurSnapshot];
    
    // hide blur and take a snapshot of the content inside the detail view
    detail.backgroundFadeView.hidden = YES;
    UIView *detailSnapshot = [detail.view snapshotViewAfterScreenUpdates:YES];
    [containerView addSubview:detailSnapshot];
    
    // the final frame is beneath the screen
    CGRect detailFrame = detailSnapshot.frame;
    detailFrame.origin.y = matches.view.bounds.size.height;
    
    // remove the actual view, use snapshots for animations
    [detail.view removeFromSuperview];
    
    [UIView animateWithDuration:0.25 animations:^{
        detailSnapshot.frame = detailFrame;
        blurSnapshot.alpha = 0;
    } completion:^(BOOL finished) {
        [ctx completeTransition:YES];
    }];
}

@end

@implementation WCDetailTransitionController

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    WCDetailTransition *controller = [[WCDetailTransition alloc] init];
    controller.isPresenting = YES;
    controller.homeView = self.homeView;
    controller.awayView = self.awayView;
    return controller;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    WCDetailTransition *controller = [[WCDetailTransition alloc] init];
    controller.isPresenting = NO;
    controller.homeView = self.homeView;
    controller.awayView = self.awayView;
    return controller;
}

@end
