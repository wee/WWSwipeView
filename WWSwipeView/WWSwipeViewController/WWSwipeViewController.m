//
//  WWSwipeViewController.m
//  WeeSwipeView
//
//  Created by Wee Witthawaskul on 2/23/13.
//  Copyright (c) 2013 Wee Witthawaskul. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "WWSwipeViewController.h"

@interface WWSwipeViewController () <UIScrollViewDelegate>

@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic, assign) CGSize imageSize;
@property (nonatomic, assign) NSInteger currentImageIndex;
@property (nonatomic, assign) NSInteger previousImageIndex;
@property (nonatomic, assign) CGFloat currentOffsetX;
@property (nonatomic, assign) BOOL beingSnapped;

@end

@implementation WWSwipeViewController

- (id)init
{
    if ((self = [super init]) != nil) {
        self.previousImageIndex = -1;
        self.currentImageIndex = 0;
        self.snapToCenter = NO;
        self.bounce = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.delegate = self;
    self.scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    [self.view addSubview:self.scrollView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.scrollView.frame = self.view.bounds;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width * 3, self.scrollView.bounds.size.height);
    self.scrollView.contentOffset = CGPointMake(self.scrollView.bounds.size.width, 0);
    self.currentOffsetX = self.scrollView.contentOffset.x;
    [self setUpScrollView:0.0 delta:0.0];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSLog(@"scrollViewDidScroll %f self.currentOffsetX %f", scrollView.contentOffset.x, self.currentOffsetX);
    CGFloat maxBounceOffset = self.bounce ? [self thumbnailWidth] / 2 : 0;
    if (self.currentOffsetX == 0)
        return;
    if ([self isFirstItemAndBounceBeyondLimit:maxBounceOffset]) {
        scrollView.contentOffset = CGPointMake(scrollView.bounds.size.width - maxBounceOffset, scrollView.contentOffset.y);
    } else if ([self isLastItemAndBounceBeyondLimit:maxBounceOffset]) {
        scrollView.contentOffset = CGPointMake(scrollView.bounds.size.width + maxBounceOffset, scrollView.contentOffset.y);
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    CGFloat deltaX = self.currentOffsetX - scrollView.contentOffset.x;
    CGFloat radianOffset = ((deltaX * M_PI) / scrollView.bounds.size.width);
    [self setUpScrollView:radianOffset delta:deltaX];
}

- (BOOL)isFirstItemAndBounceBeyondLimit:(CGFloat)maxBounceOffset
{
    return self.currentImageIndex == 0 && self.scrollView.contentOffset.x < self.scrollView.bounds.size.width - maxBounceOffset;
}

- (BOOL)isLastItemAndBounceBeyondLimit:(CGFloat)maxBounceOffset
{
    return self.currentImageIndex == [self.datasource numberOfItems]-1 && self.scrollView.contentOffset.x > self.scrollView.bounds.size.width + maxBounceOffset;
}

- (CGFloat)thumbnailWidth
{
    return self.scrollView.bounds.size.width / 2.5;
}

- (void)setUpScrollView:(CGFloat)radianOffset delta:(CGFloat)deltaX
{
    NSLog(@"Radian offset %f, delta %f, currentImageIndex %d scroll offset %f current offset %f", radianOffset * 180 / M_PI, deltaX, self.currentImageIndex, self.scrollView.contentOffset.x, self.currentOffsetX);
    
    CGFloat thumbnailWidth = [self thumbnailWidth];
    CGFloat thumbnailHeight = [self imageSize].height * thumbnailWidth / [self imageSize].width;
    
    NSMutableArray *views = [@[] mutableCopy];
    for (int index = -2; index <= 2; index++) {
        UIImageView *view = [self buildImageView:index
                                    radianOffset:radianOffset
                                           width:thumbnailWidth
                                          height:thumbnailHeight];
        if (view)
            [views addObject:view];
    }
    [self addToScrollViewByWidth:views];
    [self adjustScrollViewOffset:radianOffset deltaX:deltaX];

}

- (UIImageView *)buildImageView:(NSUInteger)index radianOffset:(CGFloat)radianOffset width:(CGFloat)width height:(CGFloat)height
{
    UIImageView *view = [self.datasource viewAtIndex:index + self.currentImageIndex];
    if (view) {
        CGFloat radian = [self radianFromPosition:index] + radianOffset;
        CGFloat centerX = self.scrollView.contentOffset.x + (self.scrollView.bounds.size.width * (1 + sin(radian)) / 2.0);
        CGFloat scale = 0.5 + 0.5 * cos(radian);
        CGFloat x = centerX - (width * scale) / 2.0;
        CGFloat centerY = self.scrollView.bounds.size.height / 2.0;
        CGFloat y = centerY - (height * scale) / 2.0;
        view.frame = CGRectMake(x, y, width * scale, height * scale);
    }
    return view;
}

- (CGFloat)radianFromPosition:(NSInteger)index
{
    return index * M_PI_4;
}

- (void)addToScrollViewByWidth:(NSArray *)views
{
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    for (UIView *view in [self sortViewByWidth:views]) {
        [self.scrollView addSubview:view];
    }
}

- (void)adjustScrollViewOffset:(CGFloat)radianOffset deltaX:(CGFloat)deltaX
{
    if (radianOffset < -M_PI_4 && self.currentImageIndex < [self.datasource numberOfItems] - 1) {
        radianOffset += M_PI_4;
        self.currentImageIndex++;
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x + deltaX, self.scrollView.contentOffset.y) animated:NO];
    } else if (radianOffset > M_PI_4 && self.currentImageIndex > 0) {
        radianOffset -= M_PI_4;
        self.currentImageIndex--;
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x + deltaX, self.scrollView.contentOffset.y) animated:NO];
    } else if (self.currentImageIndex <= 0 && self.scrollView.contentOffset.x < self.scrollView.bounds.size.width) {
        if (!self.beingSnapped) {
            [self willSnapInSeconds:0.1];
        }
    } else if (self.currentImageIndex >= [self.datasource numberOfItems] - 1 &&
               self.scrollView.contentOffset.x > self.scrollView.bounds.size.width) {
//        self.scrollView.contentOffset = CGPointMake(self.scrollView.bounds.size.width, self.scrollView.contentOffset.y);
        if (!self.beingSnapped) {
            [self willSnapInSeconds:0.1];
        }
    } else {
        if (self.snapToCenter && !self.beingSnapped) {
            [self willSnapInSeconds:0.2];
        }
    }
}

- (void)willSnapInSeconds:(CGFloat)seconds
{
    @synchronized(self) {
        [NSTimer scheduledTimerWithTimeInterval:seconds target:self selector:@selector(snap:) userInfo:[NSNumber numberWithFloat:self.scrollView.bounds.size.width] repeats:NO];
        self.beingSnapped = YES;
    }
}

- (void)snap:(NSTimer *)timer
{
    @synchronized(self) {
        self.beingSnapped = YES;
        NSNumber *snapToX = timer.userInfo;
        [self.scrollView setContentOffset:CGPointMake([snapToX floatValue], self.scrollView.contentOffset.y) animated:YES];
        self.beingSnapped = NO;
    }
}

- (NSArray *)sortViewByWidth:(NSArray *)views
{
    return [views sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        CGFloat firstWidth = ((UIImageView *)obj1).frame.size.width;
        CGFloat secondWidth = ((UIImageView *)obj2).frame.size.width;
        if (firstWidth == secondWidth) {
            return NSOrderedSame;
        } else if (firstWidth < secondWidth) {
            return NSOrderedAscending;
        } else {
            return NSOrderedDescending;
        }
    }];
}

- (CGSize)imageSize
{
    if (_imageSize.width == 0) {
        self.imageSize = [self.datasource numberOfItems] > 0 ? [self.datasource viewAtIndex:0].image.size : CGSizeZero;
    }
    return _imageSize;
}

- (void)setCurrentImageIndex:(NSInteger)currentImageIndex
{
    _currentImageIndex = currentImageIndex;
    if (currentImageIndex != self.previousImageIndex) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectItem:)]) {
            [self.delegate didSelectItem:currentImageIndex];
        }
        self.previousImageIndex = currentImageIndex;
    }
}

@end
