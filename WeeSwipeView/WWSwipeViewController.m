//
//  WWSwipeViewController.m
//  WeeSwipeView
//
//  Created by Wee Witthawaskul on 2/23/13.
//  Copyright (c) 2013 Wee Witthawaskul. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "WWSwipeViewController.h"
#import "WWScrollView.h"

@interface WWSwipeViewController () <UIScrollViewDelegate>

@property (nonatomic) WWScrollView *scrollView;
@property (nonatomic, assign) CGSize imageSize;
@property (nonatomic, assign) NSInteger currentImageIndex;
@property (nonatomic, assign) CGFloat currentOffsetX;

@end

@implementation WWSwipeViewController

- (void)viewDidLoad
{
    self.scrollView = [[WWScrollView alloc] init];
    self.scrollView.delegate = self;
    [self.view addSubview:self.scrollView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.scrollView.frame = self.view.bounds;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width * 3, self.scrollView.bounds.size.height);
    self.scrollView.contentOffset = CGPointMake(self.scrollView.bounds.size.width, 0);
    self.currentOffsetX = self.scrollView.contentOffset.x;
    [self setUpScrollView:0.0];
}

- (void)setUpScrollView:(CGFloat)radiusOffset
{
    NSLog(@"before: radius offest %f, currentImageIndex %d", radiusOffset * 180 / M_PI, self.currentImageIndex);
    if (radiusOffset > M_PI_4) {
        self.currentImageIndex--;
        radiusOffset -= M_PI_4;
        self.currentOffsetX = self.scrollView.contentOffset.x;
    } else if (radiusOffset < -M_PI_4) {
        self.currentImageIndex++;
        radiusOffset += M_PI_4;
        self.currentOffsetX = self.scrollView.contentOffset.x;
    }
    CGFloat thumbnailWidth = self.scrollView.bounds.size.width / 2;
    CGFloat thumbnailHeight = [self imageSize].height * thumbnailWidth / [self imageSize].width;
    
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSMutableArray *views = [@[] mutableCopy];
    for (int index = -2; index <= 2; index++) {
        UIImageView *view = [self.delegate viewAtIndex:index + self.currentImageIndex];
        if (view) {
            CGFloat radius = [self radiusFromPosition:index] + radiusOffset;
            CGFloat centerX = self.scrollView.bounds.size.width + (self.scrollView.bounds.size.width * (1 + sin(radius)) / 2.0);
            CGFloat scale = 0.5 + 0.5 * cos(radius);
            CGFloat x = centerX - (thumbnailWidth * scale) / 2.0;
            CGFloat centerY = self.scrollView.bounds.size.height / 2.0;
            CGFloat y = centerY - (thumbnailHeight * scale) / 2.0;
            view.frame = CGRectMake(x, y, thumbnailWidth * scale, thumbnailHeight * scale);
//            NSLog(@"radiusOffset = %f, scale = %f, frame = %@, cx = %f, cy = %f", radiusOffset * 180/M_PI, scale, NSStringFromCGRect(view.frame), centerX, centerY);
            [views addObject:view];
        }
    }
    for (UIView *view in [self sortViewByWidth:views]) {
        [self.scrollView addSubview:view];
    }
//    NSLog(@"self.scrollView.contentSize %@ self.scrollView.contentOffset %@", NSStringFromCGSize(self.scrollView.contentSize), NSStringFromCGPoint(self.scrollView.contentOffset));
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

- (CGFloat)radiusFromPosition:(NSInteger)index
{
    return index * M_PI / 4;
}

- (CGSize)imageSize
{
    if (_imageSize.width == 0) {
        self.imageSize = [self.delegate viewAtIndex:0].image.size;
    }
    return _imageSize;
}

 - (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat deltaX = self.currentOffsetX - scrollView.contentOffset.x;
    CGFloat radiusOffset = ((deltaX * M_PI * 4) / self.scrollView.bounds.size.width);
    NSLog(@"scroll to %@ from %f radius %f delta %f bounds width = %f self.currentOffsetX %f", NSStringFromCGPoint(scrollView.contentOffset), self.currentOffsetX, radiusOffset * 180/M_PI, deltaX, self.scrollView.bounds.size.width, self.currentOffsetX);
    [self setUpScrollView:radiusOffset];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSLog(@"sroll end %@", NSStringFromCGPoint(scrollView.contentOffset));
}


@end
