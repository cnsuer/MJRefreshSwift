

# MJRefreshSwift

最近的一个项目是用swift写的,虽然都写的是oc式的swift,不过总算走出了学习swift的第一步,刚好,最近一段时间闲来无事,打算把项目中用到的oc框架,都替换成纯swift的,然后找了好久,都没有找到一个像MJRefresh这样方便的swift版下拉刷新框架,借着这个机会,就自己学习下,把它转为swift的吧....

网上有很多源码解析的文章,我就不再多此一举的写了......

## 框架结构
框架的结构设计得很清晰，使用一个基类MJRefreshComponent来做一些基本的设定，然后通过继承的方式，让MJRefreshHeader和MJRefreshFooter分别具备下拉刷新和上拉加载的功能。从继承机构来看可以分为三层，具体如图
![结构设计](https://upload-images.jianshu.io/upload_images/2752872-497cac68d52bed2d.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1000/format/webp)

## 一切的开始 MJRefreshComponent
首先写的就是MJRefreshComponent.swift这个文件

这里有一点疑问MJ定一个,三个Block,类型都是一样的,只是名字不同,估计只是为了观看方便

```obj-c
    /** 进入刷新状态的回调 */
    typedef void (^MJRefreshComponentRefreshingBlock)(void);
    /** 开始刷新后的回调(进入刷新状态后的回调) */
    typedef void (^MJRefreshComponentbeginRefreshingCompletionBlock)(void);
    /** 结束刷新后的回调 */
    typedef void (^MJRefreshComponentEndRefreshingCompletionBlock)(void);
```
我就比较懒了,直接写一个...

```swift
    public typealias MJRefreshCallBack = () -> ()
```

这里需要处理下

```obj-c
    - (void)setState:(MJRefreshState)state
    {
        _state = state;
        
        // 加入主队列的目的是等setState:方法调用完毕、设置完文字后再去布局子控件
        MJRefreshDispatchAsyncOnMainQueue([self setNeedsLayout];)
    }
```

因为swift不能重写setter方法,不过还好,swift中有一套新方法，willSet和didSet,所以修改如下

```swift
    didSet{
        //状态改变
        mj_setState(oldValue)
    }
```
这里为什么要额外用`didSet`呢(也可以用`willSet`)?因为MJRefreshHeader子类重写state的setter方法,做了一次状态检查

```obj-c
    - (void)setState:(MJRefreshState)state
    {
        MJRefreshCheckState

        // 根据状态做事情
        if (state == MJRefreshStateIdle) {
            
        }
    }
```

MJRefreshCheckState的定义为

```obj-c
    // 状态检查
    #define MJRefreshCheckState \
    MJRefreshState oldState = self.state; \
    if (state == oldState) return; \
    [super setState:state];
```

只有当值变化了,才继续下一步的操作,MJRefreshHeaderSwift写为

```swift
    override func mj_setState(_ oldState: MJRefreshState) {
        //状态未改变的话直接返回
        if state == oldState { return }
        //调用父类方法
        super.mj_setState(oldState)
        // 根据状态做事情
        if state == .idle {
        
        }
    }
```
