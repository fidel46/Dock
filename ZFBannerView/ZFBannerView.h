//
//  ZFBannerView.h
//  
//
//  Created by BiBiMan on 2021/4/23.
//  Copyright © 2021 BiBiMan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TAYProtocolDock.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^SelectBlock)(NSInteger index);

@interface ZFBannerView : UIView
+ (instancetype)nib;
@property (nonatomic, assign) CGFloat itemCornerRadius;/**< item视图圆角半径*/
@property (nonatomic, assign) UIEdgeInsets itemEdgeInsets;/**< item视图内边距-控制item的位置*/
@property (nonatomic, assign) NSTimeInterval duration;/**< 轮播间隔时间:默认2s*/
@property (nonatomic, strong) UIColor *indicatorNormalColor;/**< 分页指示器默认颜色*/
@property (nonatomic, strong) UIColor *indicatorSelectedColor;/**< 分页指示器当前（选中）颜色*/
@property (nonatomic, assign) UIViewContentMode itemContentModel;/**< 图片填充模式*/
@property (nonatomic, strong) NSArray<id> * _Nullable images;/**< 图片数组*/

@property (nonatomic, weak) id<ZFBannerViewDelegate> delegate;/**< 选择代理回调*/
@property (nonatomic, copy) SelectBlock handleBlock;/**< 选择block回调*/

//MARK: - 解决Cell容器手势问题
@property (nonatomic, readonly) UIScrollView *scrollView;
@property (nonatomic, readonly) UITapGestureRecognizer *tapGesture;
@end

NS_ASSUME_NONNULL_END
