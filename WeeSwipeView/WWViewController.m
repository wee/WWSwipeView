//
//  WWViewController.m
//  WeeSwipeView
//
//  Created by Wee Witthawaskul on 2/23/13.
//  Copyright (c) 2013 Wee Witthawaskul. All rights reserved.
//

#import "WWViewController.h"
#import "WWSwipeViewController.h"

@interface WWViewController () <WWSwipViewDataSource>

@property (nonatomic) WWSwipeViewController *swipeViewController;
@end

@implementation WWViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.swipeViewController = [[WWSwipeViewController alloc] init];
    self.swipeViewController.delegate = self;
    self.swipeViewController.view.frame = CGRectMake(0, 0, 768, 300);
    [self.view addSubview:self.swipeViewController.view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark - WWScrollViewDataSource
- (NSUInteger)numberOfItems
{
    return 100;
}

- (UIImageView *)viewAtIndex:(NSInteger)index
{
    if (index < 0 || index >= [self numberOfItems]) {
        return nil;
    }
    index = index % 3;
    NSString *fileName = [NSString stringWithFormat:@"%d.jpg", (index+1)];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:fileName] ];
    imageView.userInteractionEnabled = NO;
    return imageView;
}


@end
