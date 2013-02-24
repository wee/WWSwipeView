//
//  WWSwipeViewController.h
//  WeeSwipeView
//
//  Created by Wee Witthawaskul on 2/23/13.
//  Copyright (c) 2013 Wee Witthawaskul. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WWSwipViewDataSource <NSObject>

@required
- (NSUInteger)numberOfItems;
- (UIImageView *)viewAtIndex:(NSInteger)index;

@end

@interface WWSwipeViewController : UIViewController

@property (nonatomic, weak) id<WWSwipViewDataSource> delegate;

@end
