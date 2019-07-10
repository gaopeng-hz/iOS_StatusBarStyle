# iOS之状态栏样式

### 项目设置
iOS新建工程后可以在`General`标签页对APP进行基本的配置，在`Deployment Info`下的`Status Bar Style`中可以进行状态栏的样式设置。
![状态栏样式设置](https://upload-images.jianshu.io/upload_images/788630-471af29f021624a3.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

这里有三个样式可以设置：
1. 第一个是整体样式，默认是Default，是黑色的样式，还有一种是Light，是白色的样式。
2. 第二个是`Hide status bar`，勾上之后启动的时候自动隐藏状态栏，后面可以在UIApplication或者UIViewController中设置显示状态栏。
3. 第三个是`Require full screen`，网上查资料，这个是针对分屏任务的，勾上这个后就表示这个App需要全屏运行，不支持分屏任务了。

三个样式修改后也可以在`Info.plist`中找到相应的设置
![Info.plist](https://upload-images.jianshu.io/upload_images/788630-104fad65872f1f04.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

###程序控制

####UIApplication

在UIApplication中可以通过一些方法和属性设置状态栏样式。

```objc

@interface UIApplication(UIApplicationDeprecated)

@property(nonatomic,getter=isProximitySensingEnabled) BOOL proximitySensingEnabled NS_DEPRECATED_IOS(2_0, 3_0) __TVOS_PROHIBITED; // default is NO. see UIDevice for replacement
- (void)setStatusBarHidden:(BOOL)hidden animated:(BOOL)animated NS_DEPRECATED_IOS(2_0, 3_2) __TVOS_PROHIBITED; // use -setStatusBarHidden:withAnimation:

// Explicit setting of the status bar orientation is more limited in iOS 6.0 and later.
@property(readwrite, nonatomic) UIInterfaceOrientation statusBarOrientation NS_DEPRECATED_IOS(2_0, 9_0, "Explicit setting of the status bar orientation is more limited in iOS 6.0 and later") __TVOS_PROHIBITED;
- (void)setStatusBarOrientation:(UIInterfaceOrientation)interfaceOrientation animated:(BOOL)animated NS_DEPRECATED_IOS(2_0, 9_0, "Explicit setting of the status bar orientation is more limited in iOS 6.0 and later") __TVOS_PROHIBITED;

// Setting the statusBarStyle does nothing if your application is using the default UIViewController-based status bar system.
@property(readwrite, nonatomic) UIStatusBarStyle statusBarStyle NS_DEPRECATED_IOS(2_0, 9_0, "Use -[UIViewController preferredStatusBarStyle]") __TVOS_PROHIBITED;
- (void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle animated:(BOOL)animated NS_DEPRECATED_IOS(2_0, 9_0, "Use -[UIViewController preferredStatusBarStyle]") __TVOS_PROHIBITED;

// Setting statusBarHidden does nothing if your application is using the default UIViewController-based status bar system.
@property(readwrite, nonatomic,getter=isStatusBarHidden) BOOL statusBarHidden NS_DEPRECATED_IOS(2_0, 9_0, "Use -[UIViewController prefersStatusBarHidden]") __TVOS_PROHIBITED;
- (void)setStatusBarHidden:(BOOL)hidden withAnimation:(UIStatusBarAnimation)animation NS_DEPRECATED_IOS(3_2, 9_0, "Use -[UIViewController prefersStatusBarHidden]") __TVOS_PROHIBITED;

- (BOOL)setKeepAliveTimeout:(NSTimeInterval)timeout handler:(void(^ __nullable)(void))keepAliveHandler NS_DEPRECATED_IOS(4_0, 9_0, "Please use PushKit for VoIP applications instead of calling this method") __TVOS_PROHIBITED;
- (void)clearKeepAliveTimeout NS_DEPRECATED_IOS(4_0, 9_0, "Please use PushKit for VoIP applications instead of calling this method") __TVOS_PROHIBITED;

@end
```
可以设置status bar hidden和status bar style，并且支持动画。`不过从这个Category的名字就可以看到，这些方法已经被标识Deprecated，不建议使用了。`

#### View controller-based status bar appearance

可能你通过上面的UIApplication进行设置并没有什么效果，这是因为还有一个Info.plist中的属性需要配置，`View controller-based status bar appearance`，这个属性需要一个Boolean的值，默认是YES，表示状态栏的样式由每个ViewController控制，所以你针对UIApplication进行的设置就没有作用了。也因为UIApplication针对状态栏的样式设置被标识成Deprecated，所以这个属性默认是YES，开发者可以在每个页面自行控制状态栏的样式。

#### UIViewController

一个新的工程里默认会创建一个ViewController，可以覆盖一些方法控制状态栏样式。

```objc
- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}
```

这三个方法的命名也很好理解，可以修改返回值观察变化。

#### setNeedsStatusBarAppearanceUpdate

我有几个按钮，需要动态修改状态栏样式，比如有一个按钮是控制style，一个是控制hidden，在按钮的事件处理中修改一个成员变量，在上面的返回函数中使用这个成员变量。还需要调用setNeedsStatusBarAppearanceUpdate更新状态栏样式。

```objc
- (IBAction)toggleStatusHidden:(id)sender {
    _statusBarHidden = !_statusBarHidden;
    // 直接调用setNeedsStatusBarAppearanceUpdate没有动画效果，所以用UIView的动画包了一下
    [UIView animateWithDuration:0.25 animations:^{
        [self setNeedsStatusBarAppearanceUpdate];
    }];
}

- (IBAction)toggleStatusBarStyle:(id)sender {
    // UIStatusBarStyle 枚举对应的两个style正好是 0 和 1，这里可以直接取反操作
    _style = !_style;
    // preferredStatusBarUpdateAnimation 只会影响hidden属性，style没有animation
    [self setNeedsStatusBarAppearanceUpdate];
}
```

这里为了支持动画效果，使用了UIView的animation动画，可以把duration设置的长一点，观察Slide和Fade两种动画的区别。但是`只影响prefersStatusBarHidden`，这点在`preferredStatusBarUpdateAnimation`方法的注释中可以看到。

```objc
// Override to return the type of animation that should be used for status bar changes for this view controller. This currently only affects changes to prefersStatusBarHidden.
- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation NS_AVAILABLE_IOS(7_0) __TVOS_PROHIBITED; // Defaults to UIStatusBarAnimationFade
```

> 使用UIViewController还没找到style切换动画的方法，如果有同学知道怎么实现，还望在评论中告诉一下。

#### UINavigationController

上面的例子全部都在一个新建的空工程中实践的，只有一个ViewController，然而我们大多数情况都需要UINavigationController，我们在Storyboard中选中ViewController，选择菜单中的Editor->Embed In->Navigation Controller，加入一个导航控制器，再运行，我们发现style的修改不起作用了，hidden和animation还是有效果的。猜测是因为UINavigationController的preferesStatusBarStyle方法没有转发给当前ViewController。于是自定义一个MyNavigationController，在Storyboard中设置Class，重写MyNavigationController的`preferesStatusBarStyle`方法：

```objc
- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.topViewController.preferredStatusBarStyle;
}
```

再运行，切换Style也可以了。

### 总结

1. 从iOS9开始，UIApplication对statusbarstyle的修改方法已经废弃，建议使用UIViewController中相关是设置方法，同时View controller-based status bar appearance默认为YES。
2. preferredStatusBarUpdateAnimation默认值是Fade，只对显示/隐藏状态栏起作用。
3. 当嵌入在一个UINavigationController中时需要重写preferredStatusBarStyle。
4. Genaral中三个设置项的意义。


