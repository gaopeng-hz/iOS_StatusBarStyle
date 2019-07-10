//
//  ViewController.m
//  statusbar
//
//  Created by gaopeng on 2019/4/12.
//  Copyright © 2019 gaopeng. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, assign) BOOL statusBarHidden;

@property (nonatomic, assign) UIStatusBarStyle style;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (BOOL)prefersStatusBarHidden {
    return _statusBarHidden;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return _style;
}

- (IBAction)testStatusBarHidden:(id)sender {
    _statusBarHidden = !_statusBarHidden;
    // 直接调用setNeedsStatusBarAppearanceUpdate没有动画效果，所以用UIView的动画包了一下
    [UIView animateWithDuration:1 animations:^{
        [self setNeedsStatusBarAppearanceUpdate];
    }];
}

- (IBAction)toggleStatusBarStyle:(id)sender {
    // UIStatusBarStyle 枚举对应的两个style正好是 0 和 1，这里可以直接取反操作
    _style = !_style;
    // preferredStatusBarUpdateAnimation 只会影响hidden属性，style的动画不受影响
    [UIView animateWithDuration:0.25 animations:^{
        [self setNeedsStatusBarAppearanceUpdate];
    }];
}

- (void)dealloc {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

@end
