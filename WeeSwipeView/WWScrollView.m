//
//  WWScrollView.m
//  WeeSwipeView
//
//  Created by Wee Witthawaskul on 2/24/13.
//  Copyright (c) 2013 Wee Witthawaskul. All rights reserved.
//

#import "WWScrollView.h"

@implementation WWScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setContentOffset:(CGPoint)contentOffset
{
    [super setContentOffset:contentOffset];
    NSLog(@"offset %@", NSStringFromCGPoint(contentOffset));
}
@end
