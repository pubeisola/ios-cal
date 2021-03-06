//
//  MXSCycleScrollView.m
// 
//  Created by 高峰 on 15-1-9.
//  Copyright (c) 2015年 高峰. All rights reserved.
//

#import "MXSCycleScrollView.h"

@implementation MXSCycleScrollView

@synthesize scrollView  = _scrollView;
@synthesize currentPage = _curPage;
@synthesize datasource  = _datasource;
@synthesize delegate    = _delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        // Initialization code
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.delegate    = self;
        _scrollView.contentSize = CGSizeMake(self.bounds.size.width, (self.bounds.size.height/5)*7);
        
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator   = NO;
        _scrollView.contentOffset                  = CGPointMake(0, (self.bounds.size.height/5));
        
        [self addSubview:_scrollView];
    }
    
    return self;
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([_delegate respondsToSelector:@selector(selectSetBroadcastTime)])
    {
        [_delegate selectSetBroadcastTime];
    }
    
}

//设置初始化页数
- (void)setCurrentSelectPage:(NSInteger)selectPage
{
    _curPage = selectPage;
}

- (void)setDataource:(id<MXSCycleScrollViewDatasource>)datasource
{
    _datasource = datasource;
    [self reloadData];
}

- (void)reloadData
{
    _totalPages = [_datasource numberOfPages:self];
    
    if (_totalPages == 0)
    {
        return;
    }
    
    [self loadData];
    [_scrollView setContentOffset:CGPointMake(0, (self.bounds.size.height/5)) animated:YES];
    [self setAfterScrollShowView:_scrollView andCurrentPage:1];
}

- (void)loadData
{
    //从scrollView上移除所有的subview
    NSArray *subViews = [_scrollView subviews];
    if([subViews count] != 0)
    {
        [subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    [self getDisplayImagesWithCurpage:(int)_curPage];
    
    for (int i = 0; i < 7; i++)
    {
        UIView *v = [_curViews objectAtIndex:i];
         v.userInteractionEnabled = YES;
         UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
         action:@selector(handleTap:)];
         [v addGestureRecognizer:singleTap];
        
        v.frame = CGRectOffset(v.frame, 0, v.frame.size.height * i );
        [_scrollView addSubview:v];
    }
    
    [_scrollView setContentOffset:CGPointMake( 0, (self.bounds.size.height/5) )];
}

- (void)getDisplayImagesWithCurpage:(int)page
{
    int pre1 = [self validPageValue:_curPage-1];
    int pre2 = [self validPageValue:_curPage];
    int pre3 = [self validPageValue:_curPage+1];
    int pre4 = [self validPageValue:_curPage+2];
    int pre5 = [self validPageValue:_curPage+3];
    int pre  = [self validPageValue:_curPage+4];
    int last = [self validPageValue:_curPage+5];
    
    if (pre1 < 0)
    {
    
    }
    
    if (!_curViews)
    {
        _curViews = [[NSMutableArray alloc] init];
    }
    
    [_curViews removeAllObjects];

    [_curViews addObject:[_datasource pageAtIndex:pre1 andScrollView:self]];
    [_curViews addObject:[_datasource pageAtIndex:pre2 andScrollView:self]];
    [_curViews addObject:[_datasource pageAtIndex:pre3 andScrollView:self]];
    [_curViews addObject:[_datasource pageAtIndex:pre4 andScrollView:self]];
    [_curViews addObject:[_datasource pageAtIndex:pre5 andScrollView:self]];
    [_curViews addObject:[_datasource pageAtIndex:pre andScrollView:self]];
    [_curViews addObject:[_datasource pageAtIndex:last andScrollView:self]];
}

- (int)validPageValue:(NSInteger)value
{
    if(value <= -1 )
    {   //坑爹的判断  以前这里是等号  会有问题 很小的数
        value = _totalPages - 1;
    }
    
    if(value == _totalPages+1)
    {
        value = 1;
    }
    
    if (value == _totalPages+2)
    {
        value = 2;
    }
    
    if(value == _totalPages+3)
    {
        value = 3;
    }
    
    if (value >= _totalPages+4)
    { //坑爹的判断  以前这里是等号    会有问题  很大的数
        value = 4;
    }
    
    if(value == _totalPages)
    {
        value = 0;
    }
    
    
    return (int)value;
    
}

- (void)handleTap:(UITapGestureRecognizer *)tap
{
    
    if ([_delegate respondsToSelector:@selector(didClickPage:atIndex:)])
    {
        [_delegate didClickPage:self atIndex:_curPage];
    }

    if ([_delegate respondsToSelector:@selector(selectSetBroadcastTime)])
    {    
        [_delegate selectSetBroadcastTime];
    }
    
}

- (void)setViewContent:(UIView *)view atIndex:(NSInteger)index
{
    if (index == _curPage)
    {
        [_curViews replaceObjectAtIndex:1 withObject:view];
        for (int i = 0; i < 7; i++)
        {
            UIView *v = [_curViews objectAtIndex:i];
            v.userInteractionEnabled = YES;
                        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                                    action:@selector(handleTap:)];
                        [v addGestureRecognizer:singleTap];
            v.frame = CGRectOffset(v.frame, 0, v.frame.size.height * i);
            [_scrollView addSubview:v];
        }
    }
}

- (void)setAfterScrollShowView:(UIScrollView*)scrollview  andCurrentPage:(NSInteger)pageNumber
{
    UILabel *oneLabel = (UILabel*)[[scrollview subviews] objectAtIndex:pageNumber];
    [oneLabel setFont:[UIFont systemFontOfSize:14]];
    [oneLabel setTextColor:RGBA(186.0, 186.0, 186.0, 1.0)];
    
    UILabel *twoLabel = (UILabel*)[[scrollview subviews] objectAtIndex:pageNumber+1];
    [twoLabel setFont:[UIFont systemFontOfSize:16]];
    [twoLabel setTextColor:RGBA(113.0, 113.0, 113.0, 1.0)];
    
    UILabel *currentLabel = (UILabel*)[[scrollview subviews] objectAtIndex:pageNumber+2];
    [currentLabel setFont:[UIFont systemFontOfSize:18]];
    [currentLabel setTextColor:[UIColor whiteColor]];
    
    UILabel *threeLabel = (UILabel*)[[scrollview subviews] objectAtIndex:pageNumber+3];
    [threeLabel setFont:[UIFont systemFontOfSize:16]];
    [threeLabel setTextColor:RGBA(113.0, 113.0, 113.0, 1.0)];
    
    UILabel *fourLabel = (UILabel*)[[scrollview subviews] objectAtIndex:pageNumber+4];
    [fourLabel setFont:[UIFont systemFontOfSize:14]];
    [fourLabel setTextColor:RGBA(186.0, 186.0, 186.0, 1.0)];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)aScrollView
{
    
    int y = aScrollView.contentOffset.y;
    NSInteger page = aScrollView.contentOffset.y/((self.bounds.size.height/5));

    if (y>2*(self.bounds.size.height/5))
    {
        _curPage = [self validPageValue:_curPage+1];
        
        [self loadData];
    }
    
    if (y<=0)
    {
        _curPage = [self validPageValue:_curPage-1];
        [self loadData];
    }
    //    //往下翻一张
    //    if(x >= (4*self.frame.size.width)) {
    //        _curPage = [self validPageValue:_curPage+1];
    //        [self loadData];
    //    }
    //
    //    //往上翻
    //    if(x <= 0) {
    //        
    //    }
    
    if (page>1 || page <=0)
    {
        [self setAfterScrollShowView:aScrollView andCurrentPage:1];
    }
    
    if ([_delegate respondsToSelector:@selector(scrollviewDidChangeNumber:)])
    {
        [_delegate scrollviewDidChangeNumber:self];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self setAfterScrollShowView:scrollView andCurrentPage:1];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_scrollView setContentOffset:CGPointMake(0, (self.bounds.size.height/5)) animated:YES];
    [self setAfterScrollShowView:scrollView andCurrentPage:1];
    
    if ([_delegate respondsToSelector:@selector(scrollviewDidChangeNumber:)])
    {
        [_delegate scrollviewDidChangeNumber:self];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    [self setAfterScrollShowView:scrollView andCurrentPage:1];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [_scrollView setContentOffset:CGPointMake(0, (self.bounds.size.height/5)) animated:YES];
    [self setAfterScrollShowView:scrollView andCurrentPage:1];
    
    if ([_delegate respondsToSelector:@selector(scrollviewDidChangeNumber:)])
    {
        [_delegate scrollviewDidChangeNumber:self];
    }
}

@end
