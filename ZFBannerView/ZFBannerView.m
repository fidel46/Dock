//
//  ZFBannerView.m
//
//
//  Created by BiBiMan on 2021/4/23.
//  Copyright © 2021 BiBiMan. All rights reserved.
//

#import "ZFBannerView.h"

#define PlaceHolderImage @"jiazaitupian"


@interface ZFBannerView ()<UIScrollViewDelegate>
@property (nonatomic, weak) IBOutlet UIScrollView *mainScrollView;/**< 滚动视图*/
@property (nonatomic, weak) IBOutlet UIPageControl *mainPageControl;/**< 分页指示器*/

//MARK: - 自动布局约束部分
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *itemTopLayout;/**< 上边距*/
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *itemLeftLayout;/**< 左边距*/
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *itemBottomLayout;/**< 下边距*/
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *itemRightLayout;/**< 右边距*/

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *leftItemLeadingLayout;/**< 左item视图左边距*/
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *rightItemLeadingLayout;/**< 右item视图左边距*/

//MARK: - 视图类属性
@property (nonatomic, weak) IBOutlet UIImageView *leftItem;/**< 左item视图*/
@property (nonatomic, weak) IBOutlet UIImageView *middleItem;/**< 中间item视图*/
@property (nonatomic, weak) IBOutlet UIImageView *rightItem;/**< 右item视图*/

//MARK: - 行为属性
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, weak) IBOutlet UITapGestureRecognizer *mainTapGesture;

//MARK: - 计时属性
@property (nonatomic, strong) NSTimer *playTimer;

@end
@implementation ZFBannerView
+ (instancetype )nib {
    Class objCls = [ZFBannerView class];
    NSString *nibName = NSStringFromClass(objCls);
    return [[[NSBundle bundleForClass:objCls] loadNibNamed:nibName owner:nil options:nil] firstObject];
}
- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = UIColor.whiteColor;
    //初始化设置
    self.duration = 2;
    self.itemEdgeInsets = UIEdgeInsetsZero;
    self.itemCornerRadius = 0;
    self.currentIndex = 0;
    self.itemContentModel = UIViewContentModeScaleAspectFill;
    
    self.mainPageControl.numberOfPages = 0;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    if (@available(iOS 11.0, *)) {
        self.mainScrollView.contentSize = self.mainScrollView.contentLayoutGuide.layoutFrame.size;
    } else {
        CGFloat itemWidth = CGRectGetWidth(self.frame);
        CGFloat itemHeight = CGRectGetWidth(self.frame);
        self.mainScrollView.contentSize = CGSizeMake(itemWidth*3, itemHeight);
    }
}
- (void)setItemEdgeInsets:(UIEdgeInsets)itemEdgeInsets {
    _itemEdgeInsets = itemEdgeInsets;
    self.itemTopLayout.constant = itemEdgeInsets.top;
    self.itemLeftLayout.constant = itemEdgeInsets.left;
    self.itemBottomLayout.constant = itemEdgeInsets.bottom;
    self.itemRightLayout.constant = itemEdgeInsets.right;
    
    self.leftItemLeadingLayout.constant = itemEdgeInsets.left;
    self.rightItemLeadingLayout.constant = itemEdgeInsets.left;
}
- (void)setItemCornerRadius:(CGFloat)itemCornerRadius {
    _itemCornerRadius = itemCornerRadius;
    self.leftItem.layer.cornerRadius = itemCornerRadius;
    self.middleItem.layer.cornerRadius = itemCornerRadius;
    self.rightItem.layer.cornerRadius = itemCornerRadius;
}
- (void)setIndicatorNormalColor:(UIColor *)indicatorNormalColor {
    _indicatorNormalColor = indicatorNormalColor;
    self.mainPageControl.pageIndicatorTintColor = indicatorNormalColor;
}
- (void)setIndicatorSelectedColor:(UIColor *)indicatorSelectedColor {
    _indicatorSelectedColor = indicatorSelectedColor;
    self.mainPageControl.currentPageIndicatorTintColor = indicatorSelectedColor;
}
- (void)setItemContentModel:(UIViewContentMode)itemContentModel {
    _itemContentModel = itemContentModel;
    self.leftItem.contentMode = itemContentModel;
    self.middleItem.contentMode = itemContentModel;
    self.rightItem.contentMode = itemContentModel;
}
- (void)setImages:(NSArray<id> *)images {
    if (!images.count) {
        self.userInteractionEnabled = NO;
        self.mainPageControl.numberOfPages = 0;
        [self rollBackToOriginPositon];
        return;
    }
    _images = images;
    self.mainPageControl.numberOfPages = images.count;
    [self rollBackToOriginPositon];
    [self refreshItemImage];
}
//MARK: - ScrollViewDelegate
#pragma mark - UIScrollViewDelegate <-滚动代理*****
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    //即将拖拽
    [self stopPlay];
}
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    //结束拖拽，即将滚动减速
    if (!decelerate) {
        //拖拽位置未变化-无减速
        [self startPlay];
    }
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    //已经结束滚动减速-进行无缝切换
    CGFloat x = scrollView.contentOffset.x;
    CGFloat index = x / CGRectGetWidth(scrollView.frame);
    if (index > 1) {
        self.currentIndex = [self nextIndex];
    }else if (index < 1) {
        self.currentIndex = [self lastIndex];
    }
    self.mainPageControl.currentPage = self.currentIndex;
    [self switchToMiddleItem];
    if (!self.playTimer.valid) {
        //防止重复创建计时器
        [self startPlay];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self scrollViewDidEndDecelerating:scrollView];
}
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
////    NSLog(@"%s",__PRETTY_FUNCTION__);
//}
#pragma mark - *****滚动代理->
//MARK: - 回滚到初始位置
- (void)rollBackToOriginPositon {
    [self layoutIfNeeded];
    self.currentIndex = 0;
    self.mainPageControl.currentPage = 0;
    CGFloat itemWidth = self.mainScrollView.contentSize.width/3.0f;
    CGPoint offset = CGPointMake(itemWidth, 0);
    [self.mainScrollView setContentOffset:offset animated:NO];
    [self startPlay];
}
//MARK: - 滚动到右侧图片
- (void)scrollToNextItemWithanimated:(BOOL)animated {
    CGFloat itemWidth = self.mainScrollView.contentSize.width/3.0;
    CGPoint offset = CGPointMake(itemWidth * 2, 0);
    [self.mainScrollView setContentOffset:offset animated:animated];
}
//MARK: - 无缝切换到中间图片
- (void)switchToMiddleItem {
    [self refreshItemImage];
    CGFloat itemWidth = self.mainScrollView.contentSize.width/3.0;
    CGPoint offset = CGPointMake(itemWidth * 1, 0);
    [self.mainScrollView setContentOffset:offset animated:NO];
}
//MARK: - 防止数据溢出nextIndex
- (NSInteger)nextIndex {
    NSInteger index = self.currentIndex+1;
    if (index >= self.images.count) {
        index = 0;
    }
    return index;
}
//MARK: - 防止数据溢出lastIndex
- (NSInteger)lastIndex {
    
    NSInteger index = self.currentIndex-1;
    if (index < 0) {
        index = self.images.count-1;
    }
    if (!self.images.count) {
        index = 0;
    }
    return index;
}

//MARK: - 更新item的图片
- (void)refreshItemImage {
    if (!self.images.count) {
        [self setImage:PlaceHolderImage forItem:self.leftItem];
        [self setImage:PlaceHolderImage forItem:self.middleItem];
        [self setImage:PlaceHolderImage forItem:self.rightItem];
    }else {
        [self setImage:self.images[[self lastIndex]] forItem:self.leftItem];
        [self setImage:self.images[self.currentIndex] forItem:self.middleItem];
        [self setImage:self.images[[self nextIndex]] forItem:self.rightItem];
    }
    
}
//MARK: - 根据数组图片类型做兼容展示
- (void)setImage:(id)image forItem:(UIImageView *)item {
    if ([image isKindOfClass:[UIImage class]]) {
        [item setImage:image];
    }else if ([image isKindOfClass:[NSString class]]) {
        NSString *imageStr = (NSString *)image;
        if ([imageStr hasPrefix:@"http"]) {
            //网络图片
            [item yy_setImageWithURL:[NSURL URLWithString:imageStr] placeholder:[UIImage imageNamed:PlaceHolderImage]];
        }else {
            UIImage *imgObj = [UIImage imageNamed:image];
            if (!imgObj) {
                imgObj = [UIImage imageNamed:PlaceHolderImage];
            }
            [item setImage:imgObj];
        }
    }else {
        [item setImage:[UIImage imageNamed:PlaceHolderImage]];
    }
}
- (void)startPlay {
    //销毁计时器
    [self stopPlay];
    if (self.images.count) {
        //初始化计时器
        self.playTimer = [NSTimer timerWithTimeInterval:self.duration target:self selector:@selector(playing) userInfo:nil repeats:YES];
        //启动计时器
        [[NSRunLoop currentRunLoop] addTimer:self.playTimer forMode:NSRunLoopCommonModes];
    }
}
//MARK: - 销毁计时器
- (void)stopPlay {
    [_playTimer invalidate];
    _playTimer = nil;
}
//MARK: - 轮播
- (void)playing {
    [self scrollToNextItemWithanimated:YES];
}
- (UIView *)superview {
    UIView *view = [super superview];
    if (!view) {
        [self stopPlay];
    }
    return view;
}
//点击了banner
- (IBAction)didSelectItem:(UITapGestureRecognizer *)tap {
    NSLog(@"%d-%@",(int)self.currentIndex,self.images[self.currentIndex]);
    
    //执行代理回调
    if ([self.delegate respondsToSelector:@selector(didSelectItemForIndex:)]) {
        [self.delegate didSelectItemForIndex:self.currentIndex];
    }
    //执行block回调
    if (self.handleBlock) {
        self.handleBlock(self.currentIndex);
    }
    
}
- (UIScrollView *)scrollView {
    return self.mainScrollView;
}
- (UITapGestureRecognizer *)tapGesture {
    return self.mainTapGesture;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
