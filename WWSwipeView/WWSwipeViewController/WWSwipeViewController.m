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
@property (nonatomic, assign) CGFloat previousDeltaX;

@end

@implementation WWSwipeViewController

- (void)viewDidLoad
{
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.delegate = self;
    self.scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    [self.view addSubview:self.scrollView];
    self.previousImageIndex = -1;
    self.currentImageIndex = 0;
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
    if (self.currentOffsetX == 0)//|| [scrollView isDecelerating])
        return;
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    CGFloat deltaX = self.currentOffsetX - scrollView.contentOffset.x;
    CGFloat radianOffset = ((deltaX * M_PI) / self.scrollView.bounds.size.width);
    [self setUpScrollView:radianOffset delta:deltaX];
    self.previousDeltaX = deltaX;
}

- (void)setUpScrollView:(CGFloat)radianOffset delta:(CGFloat)deltaX
{
    NSLog(@"Radian offset %f, delta %f, currentImageIndex %d scroll offset %f current offset %f", radianOffset * 180 / M_PI, deltaX, self.currentImageIndex, self.scrollView.contentOffset.x, self.currentOffsetX);
    
    CGFloat thumbnailWidth = self.scrollView.bounds.size.width / 2;
    CGFloat thumbnailHeight = [self imageSize].height * thumbnailWidth / [self imageSize].width;
    
    NSMutableArray *views = [@[] mutableCopy];
    for (int index = -2; index <= 2; index++) {
        UIImageView *view = [self.datasource viewAtIndex:index + self.currentImageIndex];
        if (view) {
            CGFloat radian = [self radianFromPosition:index] + radianOffset;
            CGFloat centerX = self.scrollView.contentOffset.x + (self.scrollView.bounds.size.width * (1 + sin(radian)) / 2.0);
            CGFloat scale = 0.5 + 0.5 * cos(radian);
            CGFloat x = centerX - (thumbnailWidth * scale) / 2.0;
            CGFloat centerY = self.scrollView.bounds.size.height / 2.0;
            CGFloat y = centerY - (thumbnailHeight * scale) / 2.0;
            view.frame = CGRectMake(x, y, thumbnailWidth * scale, thumbnailHeight * scale);
            [views addObject:view];
        }
    }
    [self addToScrollViewByWidth:views];
    [self adjustScrollViewOffset:radianOffset deltaX:deltaX];

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
        self.imageSize = [self.datasource viewAtIndex:0].image.size;
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
