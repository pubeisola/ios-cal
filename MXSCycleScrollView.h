//
//  MXSCycleScrollView.h
// 
//  Created by 高峰 on 15-1-9.
//  Copyright (c) 2015年 高峰. All rights reserved.
//
//颜色和透明度设置
#define RGBA(r,g,b,a)  [UIColor colorWithRed:(float)r/255.0f green:(float)g/255.0f blue:(float)b/255.0f alpha:a]

#import <UIKit/UIKit.h>

@protocol MXSCycleScrollViewDelegate;
@protocol MXSCycleScrollViewDatasource;

@interface MXSCycleScrollView : UIView<UIScrollViewDelegate>
{
    UIScrollView *_scrollView;
    
    NSInteger _totalPages;
    NSInteger _curPage;
    
    NSMutableArray *_curViews;
}

@property (nonatomic,readonly) UIScrollView *scrollView;
@property (nonatomic,assign) NSInteger currentPage;
@property (nonatomic,assign,setter = setDataource:) id<MXSCycleScrollViewDatasource> datasource;
@property (nonatomic,assign,setter = setDelegate:)  id<MXSCycleScrollViewDelegate> delegate;

- (void)setCurrentSelectPage:(NSInteger)selectPage; //设置初始化页数
- (void)reloadData;
- (void)setViewContent:(UIView *)view atIndex:(NSInteger)index;

@end

@protocol MXSCycleScrollViewDelegate <NSObject>

@optional

- (void)didClickPage:(MXSCycleScrollView *)csView atIndex:(NSInteger)index;
- (void)scrollviewDidChangeNumber:(MXSCycleScrollView *)csView;
- (void)selectSetBroadcastTime;

@end

@protocol MXSCycleScrollViewDatasource <NSObject>

@required

- (NSInteger)numberOfPages:(MXSCycleScrollView*)scrollView;
- (UIView *)pageAtIndex:(NSInteger)index andScrollView:(MXSCycleScrollView*)scrollView;

@end
