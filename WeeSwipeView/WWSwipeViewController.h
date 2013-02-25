//
//  WWSwipeViewController.h
//  WeeSwipeView
//
//  Created by Wee Witthawaskul on 2/23/13.
//  Copyright (c) 2013 Wee Witthawaskul. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WWSwipeViewDataSource <NSObject>

@required
- (NSUInteger)numberOfItems;
- (UIImageView *)viewAtIndex:(NSInteger)index;

@end

@protocol WWSwipeViewDelegate <NSObject>

@optional
- (void)didSelectItem:(NSInteger)index;

@end

@interface WWSwipeViewController : UIViewController

@property (nonatomic, weak) id<WWSwipeViewDataSource> datasource;
@property (nonatomic, weak) id<WWSwipeViewDelegate> delegate;

@end
