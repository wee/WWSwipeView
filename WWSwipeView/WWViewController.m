//
//  WWViewController.m
//  WeeSwipeView
//
//  Created by Wee Witthawaskul on 2/23/13.
//  Copyright (c) 2013 Wee Witthawaskul. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "WWViewController.h"
#import "WWSwipeViewController.h"

@interface WWViewController () <WWSwipeViewDataSource, WWSwipeViewDelegate>

@property (nonatomic) WWSwipeViewController *swipeViewController;
@property (nonatomic) WWSwipeViewController *swipeViewControllerWithoutSnap;
@property (nonatomic) UILabel *selectedLabel;

@end

@implementation WWViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.selectedLabel = [[UILabel alloc] init];
    self.selectedLabel.textColor = [UIColor blackColor];
    self.selectedLabel.font = [UIFont systemFontOfSize:14];
    self.selectedLabel.frame = CGRectMake(0, 305, [UIScreen mainScreen].bounds.size.width, 20);
    [self.view addSubview:self.selectedLabel];
    self.view.backgroundColor = [UIColor whiteColor];

    // sample 1 with snap
    self.swipeViewController = [[WWSwipeViewController alloc] init];
    self.swipeViewController.datasource = self;
    self.swipeViewController.delegate = self;
    self.swipeViewController.snapToCenter = YES;
    self.swipeViewController.bounce = YES;
    [self.view addSubview:self.swipeViewController.view];

    // sample 2 without snap
    self.swipeViewControllerWithoutSnap = [[WWSwipeViewController alloc] init];
    self.swipeViewControllerWithoutSnap.datasource = self;
    self.swipeViewControllerWithoutSnap.delegate = self;
    self.swipeViewControllerWithoutSnap.snapToCenter = NO;
    self.swipeViewController.bounce = NO;
    [self.view addSubview:self.swipeViewControllerWithoutSnap.view];

    [self setUpFrames];
}

- (void)setUpFrames
{
    self.swipeViewController.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, 300);
    self.swipeViewControllerWithoutSnap.view.frame = CGRectMake(0, 350, self.view.bounds.size.width, 300);
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self setUpFrames];
}

// iOS 5 support
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

#pragma mark - WWSwipeViewDataSource
- (NSUInteger)numberOfItems
{
    return 3;
}

- (UIImageView *)viewAtIndex:(NSInteger)index
{
    if (index < 0 || index >= [self numberOfItems]) {
        return nil;
    }
    index = index % 3;
    NSString *fileName = [self imageFileName:index];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:fileName] ];
    imageView.userInteractionEnabled = NO;
    imageView.layer.masksToBounds = NO;
    imageView.layer.cornerRadius = 8;
    imageView.layer.shadowRadius = 5;
    imageView.layer.shadowOpacity = 0.5;
    return imageView;
}

- (NSString *)imageFileName:(NSInteger)index
{
    return [NSString stringWithFormat:@"%d.jpg", (index+1)];
}

#pragma mark - WWSwipeViewDelegate
- (void)didSelectItem:(NSInteger)index
{
    self.selectedLabel.text = [NSString stringWithFormat:@"Image selected: %@", [self imageFileName:index]];
}
@end
