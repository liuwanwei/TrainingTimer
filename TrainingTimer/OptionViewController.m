//
//  OptionViewController.m
//  TrainingTimer
//
//  Created by sungeo on 15/5/3.
//  Copyright (c) 2015年 buddysoft. All rights reserved.
//

#import "OptionViewController.h"

@implementation OptionViewController{
        BlurMenu * _menu;
}

#pragma mark - Blue menu delegate
- (void)selectedItemAtIndex:(NSInteger)index{
    XLFormOptionsObject * object = (XLFormOptionsObject *)_options[index];
    _currentValue =  [object.formValue integerValue];
    
    [self updateProgressView];
    
    // 通知更新
    if (_delegate && [_delegate respondsToSelector:@selector(bigLineView:didChangeWithNewValue:)]) {
        [_delegate performSelector:@selector(bigLineView:didChangeWithNewValue:) withObject:self withObject:@(_currentValue)];
    }
    
    [_menu hide];
}



- (void)showTappedMenu{
    
    NSArray * items = nil;
    if (items == nil) {
        NSMutableArray * mutableArray = [@[] mutableCopy];
        NSEnumerator * enumerator = [_options objectEnumerator];
        XLFormOptionsObject * option;
        while ((option = [enumerator nextObject])) {
            [mutableArray addObject:option.displayText];
        }
        
        items = mutableArray;
    }
    
    _menu = [[BlurMenu alloc] initWithItems:items parentView:self.parentViewController.view delegate:self];
    [self.parentViewController.view addSubview:_menu];
    _menu.itemHeight = 80;
    _menu.itemFont = [UIFont systemFontOfSize:30.0f];
    _menu.itemTextColor = [UIColor mainColor];
    @weakify(self);
    [_menu mas_makeConstraints:^(MASConstraintMaker * maker){
        @strongify(self);
        maker.edges.equalTo(self.parentViewController.view);
    }];
    
    [_menu show];
}


@end
