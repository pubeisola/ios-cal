//
//  RBCustomDatePickerView.m
//  RBCustomDateTimePicker
//  Created by 高峰 on 15-1-9.
//  Copyright (c) 2015年 高峰. All rights reserved.
//

#import "RBCustomDatePickerView.h"
#import "common.h"

@interface RBCustomDatePickerView()
{
    UIView                      *timeBroadcastView; //定时播放显示视图
    MXSCycleScrollView          *yearScrollView;    //年份滚动视图
    MXSCycleScrollView          *monthScrollView;   //月份滚动视图
    MXSCycleScrollView          *dayScrollView;     //日滚动视图
    MXSCycleScrollView          *hourScrollView;    //时滚动视图
    MXSCycleScrollView          *minuteScrollView;  //分滚动视图
    MXSCycleScrollView          *secondScrollView;  //秒滚动视图
    UILabel                     *nowPickerShowTimeLabel;    //当前picker显示的时间
    UILabel                     *selectTimeIsNotLegalLabel; //所选时间是否合法
    UIButton                    *OkBtn;                     //自定义picker上的确认按钮
}

@end

@implementation RBCustomDatePickerView
@synthesize  delegate = _delegate;
@synthesize  is_limit_to_today = _is_limit_to_today;

- (id)initWithFrame:(CGRect)frame  delegate:(id<caldelegate>) delegate
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        // Initialization code
        _delegate = delegate;
        [self setTimeBroadcastView];
        _is_limit_to_today = 0;    //默认 不进行时间限制
    }
    
    return self;
}

#pragma mark -custompicker
//设置自定义datepicker界面
- (void)setTimeBroadcastView
{
    nowPickerShowTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 10.0, 190, 18)];
    [nowPickerShowTimeLabel setBackgroundColor:[UIColor whiteColor]];
    [nowPickerShowTimeLabel setFont:[UIFont systemFontOfSize:18.0]];
    [nowPickerShowTimeLabel setTextColor:RGBA(51, 51, 51, 1)];
    [nowPickerShowTimeLabel setTextAlignment:NSTextAlignmentCenter];
    
    NSDate *now = [NSDate date];
    
    //获取当前文本框日期
    NSMutableString *cur_date_str = [[NSMutableString alloc] init];
    //回调控制器函数 获取日期
    if ([_delegate respondsToSelector:@selector(fetchCalDate)])
    {
        [cur_date_str appendFormat:@"%@", [_delegate fetchCalDate] ];
    }
    
    if ([cur_date_str isKindOfClass:[NSMutableString class]])
    {
        if ([cur_date_str length] > 0)
        {
            NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
            [inputFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
            [inputFormatter setDateFormat:@"yyyy-MM-dd"];
            
            NSDate* inputDate = [inputFormatter dateFromString:cur_date_str];
            if (inputDate)
            {
                now = inputDate;
            }
        }
    }
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    
    NSString *dateString = [dateFormatter stringFromDate:now];
    NSString *weekString = [self fromDateToWeek:dateString];
    NSInteger monthInt   = [dateString substringWithRange:NSMakeRange(4, 2)].integerValue;
    NSInteger dayInt     = [dateString substringWithRange:NSMakeRange(6, 2)].integerValue;
    
    nowPickerShowTimeLabel.text = [NSString stringWithFormat:@"%@年%ld月%ld日 %@",[dateString substringWithRange:NSMakeRange(0, 4)],monthInt,dayInt, weekString];
    
    [self addSubview:nowPickerShowTimeLabel];
    
    timeBroadcastView = [[UIView alloc] initWithFrame:CGRectMake(8, 33, 278.5, 190.0)];
    timeBroadcastView.layer.cornerRadius = 8;//设置视图圆角
    timeBroadcastView.layer.masksToBounds = YES;
    
    CGColorRef cgColor = [UIColor colorWithRed:221.0/255.0 green:221.0/255.0 blue:221.0/255.0 alpha:1.0].CGColor;
    timeBroadcastView.layer.borderColor = cgColor;
    timeBroadcastView.layer.borderWidth = 2.0;
    [self addSubview:timeBroadcastView];
    
    UIView *beforeSepLine = [[UIView alloc] initWithFrame:CGRectMake(0, 39, 278.5, 1.5)];
    [beforeSepLine setBackgroundColor:RGBA(237.0, 237.0, 237.0, 1.0)];
    [timeBroadcastView addSubview:beforeSepLine];
    
    UIView *middleSepView = [[UIView alloc] initWithFrame:CGRectMake(0, 75, 278.5, 38)];
    [middleSepView setBackgroundColor:RGBA(249.0, 138.0, 20.0, 1.0)];
    [timeBroadcastView addSubview:middleSepView];
    
    UIView *bottomSepLine = [[UIView alloc] initWithFrame:CGRectMake(0, 150.5, 278.5, 1.5)];
    [bottomSepLine setBackgroundColor:RGBA(237.0, 237.0, 237.0, 1.0)];
    [timeBroadcastView addSubview:bottomSepLine];
    
    [self setYearScrollView];
    [self setMonthScrollView];
    [self setDayScrollView];
    [self setHourScrollView];
    [self setMinuteScrollView];
    [self setSecondScrollView];
    
    selectTimeIsNotLegalLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 339.5, 278.5, 15)];
    [selectTimeIsNotLegalLabel setBackgroundColor:[UIColor clearColor]];
    [selectTimeIsNotLegalLabel setFont:[UIFont systemFontOfSize:15.0]];
    [selectTimeIsNotLegalLabel setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:selectTimeIsNotLegalLabel];
}

//设置年月日时分的滚动视图
- (void)setYearScrollView
{
    yearScrollView    = [[MXSCycleScrollView alloc] initWithFrame:CGRectMake(0, 0, 76, 190.0)];
    NSInteger yearint = [self setNowTimeShow:0];

    [yearScrollView setCurrentSelectPage:(yearint - 1982)];
    
    yearScrollView.delegate   = self;
    yearScrollView.datasource = self;

    [self setAfterScrollShowView:yearScrollView andCurrentPage:1];
    [timeBroadcastView addSubview:yearScrollView];
}

//设置年月日时分的滚动视图
- (void)setMonthScrollView
{
    monthScrollView    = [[MXSCycleScrollView alloc] initWithFrame:CGRectMake(76, 0, 84, 190.0)];
    NSInteger monthint = [self setNowTimeShow:1];
    
    [monthScrollView setCurrentSelectPage:(monthint-3)];
    monthScrollView.delegate   = self;
    monthScrollView.datasource = self;
    
    [self setAfterScrollShowView:monthScrollView andCurrentPage:1];
    [timeBroadcastView addSubview:monthScrollView];
}

//设置年月日时分的滚动视图
- (void)setDayScrollView
{
    dayScrollView    = [[MXSCycleScrollView alloc] initWithFrame:CGRectMake(160, 0, 110, 190.0)];
    NSInteger dayint = [self setNowTimeShow:2];
    [dayScrollView setCurrentSelectPage:(dayint-3)];
    
    dayScrollView.delegate   = self;
    dayScrollView.datasource = self;

    [self setAfterScrollShowView:dayScrollView andCurrentPage:1];
    [timeBroadcastView addSubview:dayScrollView];
}

//设置年月日时分的滚动视图
- (void)setHourScrollView
{
    hourScrollView    = [[MXSCycleScrollView alloc] initWithFrame:CGRectMake(159.5, 0, 39.0, 190.0)];
    NSInteger hourint = [self setNowTimeShow:3];
    
    [hourScrollView setCurrentSelectPage:(hourint-2)];
    hourScrollView.delegate   = self;
    hourScrollView.datasource = self;
    hourScrollView.hidden     = YES;
    [self setAfterScrollShowView:hourScrollView andCurrentPage:1];
    [timeBroadcastView addSubview:hourScrollView];
}

//设置年月日时分的滚动视图
- (void)setMinuteScrollView
{
    minuteScrollView    = [[MXSCycleScrollView alloc] initWithFrame:CGRectMake(198.5, 0, 37.0, 190.0)];
    NSInteger minuteint = [self setNowTimeShow:4];
    
    [minuteScrollView setCurrentSelectPage:(minuteint-2)];
    minuteScrollView.delegate   = self;
    minuteScrollView.datasource = self;
    minuteScrollView.hidden     = YES;
    [self setAfterScrollShowView:minuteScrollView andCurrentPage:1];
    [timeBroadcastView addSubview:minuteScrollView];
}

//设置年月日时分的滚动视图
- (void)setSecondScrollView
{
    secondScrollView    = [[MXSCycleScrollView alloc] initWithFrame:CGRectMake(235.5, 0, 43.0, 190.0)];
    NSInteger secondint = [self setNowTimeShow:5];
    
    [secondScrollView setCurrentSelectPage:(secondint-2)];
    secondScrollView.delegate   = self;
    secondScrollView.datasource = self;
    secondScrollView.hidden     = YES;
    [self setAfterScrollShowView:secondScrollView andCurrentPage:1];
    [timeBroadcastView addSubview:secondScrollView];
}

- (void)setAfterScrollShowView:(MXSCycleScrollView*)scrollview  andCurrentPage:(NSInteger)pageNumber
{
    UILabel *oneLabel = [[(UILabel*)[[scrollview subviews] objectAtIndex:0] subviews] objectAtIndex:pageNumber];
    [oneLabel setFont:[UIFont systemFontOfSize:14]];
    [oneLabel setTextColor:RGBA(186.0, 186.0, 186.0, 1.0)];
    
    UILabel *twoLabel = [[(UILabel*)[[scrollview subviews] objectAtIndex:0] subviews] objectAtIndex:pageNumber+1];
    [twoLabel setFont:[UIFont systemFontOfSize:16]];
    [twoLabel setTextColor:RGBA(113.0, 113.0, 113.0, 1.0)];
    
    UILabel *currentLabel = [[(UILabel*)[[scrollview subviews] objectAtIndex:0] subviews] objectAtIndex:pageNumber+2];
    [currentLabel setFont:[UIFont systemFontOfSize:18]];
    [currentLabel setTextColor:[UIColor whiteColor]];
    
    UILabel *threeLabel = [[(UILabel*)[[scrollview subviews] objectAtIndex:0] subviews] objectAtIndex:pageNumber+3];
    [threeLabel setFont:[UIFont systemFontOfSize:16]];
    [threeLabel setTextColor:RGBA(113.0, 113.0, 113.0, 1.0)];
    
    UILabel *fourLabel = [[(UILabel*)[[scrollview subviews] objectAtIndex:0] subviews] objectAtIndex:pageNumber+4];
    [fourLabel setFont:[UIFont systemFontOfSize:14]];
    [fourLabel setTextColor:RGBA(186.0, 186.0, 186.0, 1.0)];
}

#pragma mark mxccyclescrollview delegate
#pragma mark mxccyclescrollview databasesource
- (NSInteger)numberOfPages:(MXSCycleScrollView*)scrollView
{
    if (scrollView == yearScrollView)
    {
        return 119;
    }
    else if (scrollView == monthScrollView)
    {
        return 12;
    }
    else if (scrollView == dayScrollView)
    {
        UILabel *yearLabel   = [[(UILabel*)[[yearScrollView subviews] objectAtIndex:0] subviews] objectAtIndex:3];
        UILabel *monthLabel  = [[(UILabel*)[[monthScrollView subviews] objectAtIndex:0] subviews] objectAtIndex:3];
        
        NSInteger yearInt   = yearLabel.tag;
        NSInteger monthInt  = monthLabel.tag;

        return [common howManyDaysInThisMonth:(int)yearInt month:(int)monthInt];
    }
    else if (scrollView == hourScrollView)
    {
        return 24;
    }
    else if (scrollView == minuteScrollView)
    {
        return 60;
    }
    
    return 60;
}

- (UIView *)pageAtIndex:(NSInteger)index andScrollView:(MXSCycleScrollView *)scrollView
{
    UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, scrollView.bounds.size.width, scrollView.bounds.size.height/5)];
    l.tag  = index + 1;

    if (scrollView == yearScrollView)
    {
        l.text = [NSString stringWithFormat:@"%d年",(int)fabs((int)(1980+index))];
        l.tag  = 1980+index;
    }
    else if (scrollView == monthScrollView)
    {
        l.text = [NSString stringWithFormat:@"%d月",(int)fabs((int)(1+index))];
        l.tag  = index + 1;
    }
    else if (scrollView == dayScrollView)
    {
        l.text = [NSString stringWithFormat:@"%d日",(int)fabs((int)(1+index))];
        l.tag  = index + 1;
    }
    else if (scrollView == hourScrollView)
    {
        if (index < 10)
        {
            l.text = [NSString stringWithFormat:@"0%ld",index];
        }
        else
        {
            l.text = [NSString stringWithFormat:@"%ld",index];
        }
    }
    else if (scrollView == minuteScrollView)
    {
        if (index < 10)
        {
            l.text = [NSString stringWithFormat:@"0%ld",index];
        }
        else
        {
            l.text = [NSString stringWithFormat:@"%ld",index];
        }
    }
    else
    {
        if (index < 10)
        {
            l.text = [NSString stringWithFormat:@"0%ld",index];
        }
        else
        {
            l.text = [NSString stringWithFormat:@"%ld",index];
        }
    }
    
    l.font            = [UIFont systemFontOfSize:12];
    l.textAlignment   = NSTextAlignmentCenter;
    l.backgroundColor = [UIColor clearColor];
    
    return l;
}

//设置现在时间
- (NSInteger)genNowTimeShow:(NSInteger)timeType
{
    
    NSDate *now = [NSDate date];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *dateString = [dateFormatter stringFromDate:now];
    
    switch (timeType)
    {
        case 0:
        {
            NSRange range = NSMakeRange(0, 4);
            NSString *yearString = [dateString substringWithRange:range];
            return yearString.integerValue;
        }
            break;
            
        case 1:
        {
            NSRange range = NSMakeRange(4, 2);
            NSString *yearString = [dateString substringWithRange:range];
            return yearString.integerValue;
        }
            break;
            
        case 2:
        {
            NSRange range = NSMakeRange(6, 2);
            NSString *yearString = [dateString substringWithRange:range];
            return yearString.integerValue;
        }
            break;
            
        case 3:
        {
            NSRange range = NSMakeRange(8, 2);
            NSString *yearString = [dateString substringWithRange:range];
            return yearString.integerValue;
        }
            break;
            
        case 4:
        {
            NSRange range = NSMakeRange(10, 2);
            NSString *yearString = [dateString substringWithRange:range];
            return yearString.integerValue;
        }
            break;
            
        case 5:
        {
            NSRange range = NSMakeRange(12, 2);
            NSString *yearString = [dateString substringWithRange:range];
            return yearString.integerValue;
        }
            break;
            
        default:
            break;
            
    }
    
    return 0;
}


//设置现在时间
- (NSInteger)setNowTimeShow:(NSInteger)timeType
{
    //获取当前文本框日期
    NSMutableString *cur_date_str = [[NSMutableString alloc] init];
    //回调控制器函数 获取日期
    if ([_delegate respondsToSelector:@selector(fetchCalDate)])
    {
        [cur_date_str appendFormat:@"%@", [_delegate fetchCalDate] ];
    }
    
    NSDate *now = [NSDate date];

    if ([cur_date_str isKindOfClass:[NSMutableString class]])
    {
        if ([cur_date_str length] > 0)
        {
            NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
            [inputFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
            [inputFormatter setDateFormat:@"yyyy-MM-dd"];
            
            NSDate* inputDate = [inputFormatter dateFromString:cur_date_str];
            if (inputDate)
            {
                now = inputDate;
            }
        }
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *dateString = [dateFormatter stringFromDate:now];
    
    switch (timeType)
    {
        case 0:
        {
            NSRange range = NSMakeRange(0, 4);
            NSString *yearString = [dateString substringWithRange:range];
            return yearString.integerValue;
        }
            break;
            
        case 1:
        {
            NSRange range = NSMakeRange(4, 2);
            NSString *yearString = [dateString substringWithRange:range];
            return yearString.integerValue;
        }
            break;
            
        case 2:
        {
            NSRange range = NSMakeRange(6, 2);
            NSString *yearString = [dateString substringWithRange:range];
            return yearString.integerValue;
        }
            break;
            
        case 3:
        {
            NSRange range = NSMakeRange(8, 2);
            NSString *yearString = [dateString substringWithRange:range];
            return yearString.integerValue;
        }
            break;
            
        case 4:
        {
            NSRange range = NSMakeRange(10, 2);
            NSString *yearString = [dateString substringWithRange:range];
            return yearString.integerValue;
        }
            break;
            
        case 5:
        {
            NSRange range = NSMakeRange(12, 2);
            NSString *yearString = [dateString substringWithRange:range];
            return yearString.integerValue;
        }
            break;
            
        default:
            break;
            
    }
    
    return 0;
}

//选择设置的播报时间
- (void)selectSetBroadcastTime
{
    UILabel *yearLabel   = [[(UILabel*)[[yearScrollView subviews] objectAtIndex:0] subviews] objectAtIndex:3];
    UILabel *monthLabel  = [[(UILabel*)[[monthScrollView subviews] objectAtIndex:0] subviews] objectAtIndex:3];
    UILabel *dayLabel    = [[(UILabel*)[[dayScrollView subviews] objectAtIndex:0] subviews] objectAtIndex:3];
    UILabel *hourLabel   = [[(UILabel*)[[hourScrollView subviews] objectAtIndex:0] subviews] objectAtIndex:3];
    UILabel *minuteLabel = [[(UILabel*)[[minuteScrollView subviews] objectAtIndex:0] subviews] objectAtIndex:3];
    UILabel *secondLabel = [[(UILabel*)[[secondScrollView subviews] objectAtIndex:0] subviews] objectAtIndex:3];
    
    NSInteger yearInt   = yearLabel.tag;
    NSInteger monthInt  = monthLabel.tag;
    NSInteger dayInt    = dayLabel.tag;

    //回调控制器函数 设置日期
    if ([_delegate respondsToSelector:@selector(calDidChangeDate:)])
    {
        if ((monthInt < 10) && (dayInt < 10))
        {
            [_delegate calDidChangeDate: [NSString stringWithFormat:@"%ld-0%ld-0%ld",yearInt,monthInt,dayInt]];
        }
        else if ((monthInt < 10) && (dayInt > 10))
        {
            [_delegate calDidChangeDate: [NSString stringWithFormat:@"%ld-0%ld-%ld",yearInt,monthInt,dayInt]];
        }
        else if ((monthInt > 10) && (dayInt < 10))
        {
            [_delegate calDidChangeDate: [NSString stringWithFormat:@"%ld-%ld-0%ld",yearInt,monthInt,dayInt]];
        }
        else
        {
            [_delegate calDidChangeDate: [NSString stringWithFormat:@"%ld-%ld-%ld",yearInt,monthInt,dayInt]];
        }
    }
    
    //单机确认后  关闭日历视图
    if ([_delegate respondsToSelector:@selector(closeCal)])
    {
        [_delegate closeCal];
    }
}

//滚动时上下标签显示(当前时间和是否为有效时间)
- (void)scrollviewDidChangeNumber:(MXSCycleScrollView *) csView
{
    UILabel *yearLabel   = [[(UILabel*)[[yearScrollView subviews] objectAtIndex:0] subviews] objectAtIndex:3];
    UILabel *monthLabel  = [[(UILabel*)[[monthScrollView subviews] objectAtIndex:0] subviews] objectAtIndex:3];
    UILabel *dayLabel    = [[(UILabel*)[[dayScrollView subviews] objectAtIndex:0] subviews] objectAtIndex:3];
    UILabel *hourLabel   = [[(UILabel*)[[hourScrollView subviews] objectAtIndex:0] subviews] objectAtIndex:3];
    UILabel *minuteLabel = [[(UILabel*)[[minuteScrollView subviews] objectAtIndex:0] subviews] objectAtIndex:3];
    UILabel *secondLabel = [[(UILabel*)[[secondScrollView subviews] objectAtIndex:0] subviews] objectAtIndex:3];
    
    NSInteger yearInt   = yearLabel.tag;
    NSInteger monthInt  = monthLabel.tag;
    NSInteger dayInt    = dayLabel.tag;
    NSInteger hourInt   = hourLabel.tag - 1;
    NSInteger minuteInt = minuteLabel.tag - 1;
    NSInteger secondInt = secondLabel.tag - 1;
    
    //{{限制 日期滚动范围
    
    NSDateFormatter *dateFormatter_limit = [[NSDateFormatter alloc] init];
    [dateFormatter_limit setDateFormat:@"yyyy-MM-dd"];
    NSDate *  senddate=[NSDate date];
    
    //当前时间
    NSDate *senderDate = [dateFormatter_limit dateFromString:[dateFormatter_limit stringFromDate:senddate]];
    unsigned units     = NSMonthCalendarUnit|NSDayCalendarUnit|NSYearCalendarUnit;
    NSCalendar *myCal  = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    //当前日期
    NSDateComponents *comp1 = [myCal components:units fromDate:senderDate];
    NSInteger cur_month     = [comp1 month];
    NSInteger cur_year      = [comp1 year];
    NSInteger cur_day       = [comp1 day];
    
    //如果等于 1: _is_limit_to_today == 1  表示时间要限制到今天 以后  否则不限制
    if (_is_limit_to_today == 1)
    {
        if (yearInt < cur_year)
        {
            NSInteger year = [self genNowTimeShow:0];
            [yearScrollView setCurrentSelectPage:(year - 1982)];
            [yearScrollView reloadData];
            
            [self makeToast:@"预约日期不能是过去的日期"
                        duration:TIMEEXIST
                        position:CSToastPositionBottom];
            return ;
        }
        else if(yearInt == cur_year)
        {
            if (monthInt < cur_month)
            {
                NSInteger month = [self genNowTimeShow:1];
                [monthScrollView setCurrentSelectPage:(month - 3)];
                [monthScrollView reloadData];
                
                [self makeToast:@"预约日期不能是过去的日期"
                       duration:TIMEEXIST
                       position:CSToastPositionBottom];
                return;
            }
            else if (monthInt == cur_month)
            {
                if (dayInt < cur_day)
                {
                    NSInteger day = [self genNowTimeShow:2];
                    [dayScrollView setCurrentSelectPage:(day - 3)];
                    [dayScrollView reloadData];
                    
                    [self makeToast:@"预约日期不能是过去的日期"
                           duration:TIMEEXIST
                           position:CSToastPositionBottom];
                    return;
                }
            
            }
            

        }
        
    }
    
    //}}限制 日期滚动范围
    
    NSString *dateString = [NSString stringWithFormat:@"%ld%02ld%02ld%02ld%02ld%02ld",yearInt,monthInt,dayInt,hourInt,minuteInt,secondInt];
    NSString *weekString = [self fromDateToWeek:dateString];
    nowPickerShowTimeLabel.text = [NSString stringWithFormat:@"%ld年%ld月%ld日 %@",yearInt,monthInt,dayInt, weekString];
    
    //回调控制器函数 设置日期
    if ([_delegate respondsToSelector:@selector(calDidChangeDate:)])
    {
        if ((monthInt < 10) && (dayInt < 10))
        {
            [_delegate calDidChangeDate: [NSString stringWithFormat:@"%ld-0%ld-0%ld",yearInt,monthInt,dayInt]];
        }
        else if ((monthInt < 10) && (dayInt > 10))
        {
            [_delegate calDidChangeDate: [NSString stringWithFormat:@"%ld-0%ld-%ld",yearInt,monthInt,dayInt]];
        }
        else if ((monthInt > 10) && (dayInt < 10))
        {
            [_delegate calDidChangeDate: [NSString stringWithFormat:@"%ld-%ld-0%ld",yearInt,monthInt,dayInt]];
        }
        else
        {
            [_delegate calDidChangeDate: [NSString stringWithFormat:@"%ld-%ld-%ld",yearInt,monthInt,dayInt]];
        }
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *selectTimeString = [NSString stringWithFormat:@"%ld-%02ld-%02ld %02ld:%02ld:%02ld",yearInt,monthInt,dayInt,hourInt,minuteInt,secondInt];
    
    NSDate *selectDate  = [dateFormatter dateFromString:selectTimeString];
    NSDate *nowDate     = [NSDate date];
    NSString *nowString = [dateFormatter stringFromDate:nowDate];
    NSDate *nowStrDate  = [dateFormatter dateFromString:nowString];
    
    if (NSOrderedAscending == [selectDate compare:nowStrDate])
    {//选择的时间与当前系统时间做比较
        [selectTimeIsNotLegalLabel setTextColor:RGBA(155, 155, 155, 1)];
        selectTimeIsNotLegalLabel.text = @"";
        [OkBtn setEnabled:NO];
    }
    else
    {
        selectTimeIsNotLegalLabel.text = @"";
        [OkBtn setEnabled:YES];
    }
    
    if (csView == yearScrollView)
    {
        [dayScrollView reloadData];
    }
    else if (csView == monthScrollView)
    {
        [dayScrollView reloadData];
    }
    
}

//通过日期求星期
- (NSString*)fromDateToWeek:(NSString*)selectDate
{
    NSInteger yearInt  = [selectDate substringWithRange:NSMakeRange(0, 4)].integerValue;
    NSInteger monthInt = [selectDate substringWithRange:NSMakeRange(4, 2)].integerValue;
    NSInteger dayInt   = [selectDate substringWithRange:NSMakeRange(6, 2)].integerValue;
    
    int c = 20;//世纪
    int y = (int)(yearInt -1);//年
    int d = (int)dayInt;
    int m = (int)monthInt;
    int w =(y+(y/4)+(c/4)-2*c+(26*(m+1)/10)+d-1)%7;
    NSString *weekDay = @"";
    
    switch (w)
    {
        case 0:
            weekDay = @"周日";
            break;
        case 1:
            weekDay = @"周一";
            break;
        case 2:
            weekDay = @"周二";
            break;
        case 3:
            weekDay = @"周三";
            break;
        case 4:
            weekDay = @"周四";
            break;
        case 5:
            weekDay = @"周五";
            break;
        case 6:
            weekDay = @"周六";
            break;
        default:
            break;
    }
    
    return weekDay;
}

@end
