//
//  RBCustomDatePickerView.h
//  RBCustomDateTimePicker
//  Created by 高峰 on 15-1-9.
//  Copyright (c) 2015年 高峰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MXSCycleScrollView.h"
#import "UIView+Toast.h"

@protocol caldelegate <NSObject>

@optional
- (void)calDidChangeDate:(NSString *) date;
- (NSString *)fetchCalDate;    //获取 要显示的当前日期
-(void)closeCal;  //关闭日历
@end

@interface RBCustomDatePickerView : UIView <MXSCycleScrollViewDatasource,MXSCycleScrollViewDelegate>
{
    
}

@property (nonatomic, weak)   id<caldelegate>  delegate;
@property (nonatomic, assign) NSInteger is_limit_to_today;   //限制时间到今天

- (id)initWithFrame:(CGRect)frame  delegate:(id<caldelegate>) delegate;

- (void)selectSetBroadcastTime;
@end
