//
//  BlurMenu.h
//  BlurMenu
//
//  Created by Ali Yılmaz on 06/02/14.
//  Copyright (c) 2014 Ali Yılmaz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImage+ImageEffects.h"
#import "BlurMenuItemCell.h"

@class BlurMenu;

@protocol BlurMenuDelegate <NSObject>
@optional
- (void)menuDidShow;
- (void)menuDidHide;
- (void)selectedItemAtIndex:(NSInteger)index;
@end

@interface BlurMenu : UIView <UICollectionViewDataSource,UICollectionViewDelegateFlowLayout> {
    id<BlurMenuDelegate> delegate;
    UIView *parent;
    NSArray *menuItems;
    UICollectionView *_collectionView;
    UIButton * _closeButton;
}

@property(nonatomic, retain) id <BlurMenuDelegate> delegate;
@property(nonatomic, retain) UIView *parent;
@property(nonatomic, retain) NSArray *menuItems;
@property(nonatomic, retain) UICollectionView *_collectionView;
@property (nonatomic, retain) UIButton * _closeButton;
@property(nonatomic) NSInteger itemHeight;
@property(nonatomic, strong) UIFont * itemFont;
@property(nonatomic, strong) UIColor * itemTextColor;
@property(nonatomic, copy) NSString * title;

- (id)initWithItems:(NSArray*)items parentView:(UIView *)p delegate:(id<BlurMenuDelegate>)d;

- (void)show;
- (void)hide;

- (void)remakeConstrainits;

@end
