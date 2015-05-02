//
//  BlurMenu.m
//  BlurMenu
//
//  Created by Ali Yılmaz on 06/02/14.
//  Copyright (c) 2014 Ali Yılmaz. All rights reserved.
//

#import "BlurMenu.h"
#import <Masonry.h>
#import <EXTScope.h>
#import <NSObject+GLPubSub.h>

#define COLLECTION_VIEW_PADDING 64

#define ITEM_HEIGHT 50
#define ITEM_LINE_SPACING 10

@implementation BlurMenu
@synthesize parent, delegate, menuItems, _collectionView, _closeButton;

+ (BOOL)requiresConstraintBasedLayout{
    return YES;
}

- (id)initWithItems:(NSArray*)items parentView:(UIView *)p delegate:(id<BlurMenuDelegate>)d {
    self = [super init];
    if (self) {
        self.parent = p;
        self.delegate = d;
        self.menuItems = items;

        self.alpha = 0.0f;
        self.frame = p.frame;
        self.itemHeight = ITEM_HEIGHT;
        self.itemFont = [UIFont systemFontOfSize:17.0f];
        self.itemTextColor = [UIColor whiteColor];
        
        [self subscribe:UIApplicationWillChangeStatusBarOrientationNotification handler:^(GLEvent * event){
            [self setNeedsUpdateConstraints];
        }];
    }
    
    return self;
}

- (void)updateConstraints{
    
    [self remakeConstrainits];
    
    [super updateConstraints];
}

- (void)remakeConstrainits{
    CGFloat height = [self calculateCollectionViewHeight];
    
    @weakify(self);
    
    [_collectionView mas_remakeConstraints:^(MASConstraintMaker * maker){
        @strongify(self);
        maker.leading.equalTo(self.mas_leading);
        maker.top.equalTo(self.mas_top).offset((self.frame.size.height - height) / 2);
        maker.width.equalTo(self.mas_width);
        maker.bottom.equalTo(self.mas_bottom).offset((self.frame.size.height - height) / 2);
    }];
    
    [_closeButton mas_remakeConstraints:^(MASConstraintMaker * maker){
        @strongify(self);
        maker.leading.equalTo(self.mas_leading);
        maker.bottom.equalTo(self.mas_bottom).offset(-COLLECTION_VIEW_PADDING);
        maker.width.equalTo(self.mas_width);
        maker.height.equalTo(@(COLLECTION_VIEW_PADDING));
    }];
    
//    [_collectionView setNeedsLayout];
//    [_collectionView layoutIfNeeded];
}

- (void)initSubViews{
    UIImage *background = [self blurredSnapshot];
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:background];
    [self addSubview:backgroundView];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    [layout setMinimumLineSpacing:ITEM_LINE_SPACING];
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    [_collectionView setDataSource:self];
    [_collectionView setDelegate:self];
    [_collectionView registerClass:[BlurMenuItemCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    [_collectionView setBackgroundColor:[UIColor clearColor]];
    [self addSubview:_collectionView];
    
    _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _closeButton.backgroundColor = [UIColor clearColor];
    [_closeButton setTitle:@"Close" forState:UIControlStateNormal];
    [_closeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _closeButton.titleLabel.font = [UIFont fontWithName:@"GillSans-Light" size:26.0f];
    [_closeButton addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchDown];
    [self addSubview:_closeButton];
    
    [self remakeConstrainits];
}


- (void)show {
    [self initSubViews];
    
//    [self.parent addSubview:self];
    [UIView animateWithDuration:0.1 animations:^{
        self.alpha = 1.0f;
    } completion:^(BOOL finished) {
        if ([self.delegate respondsToSelector:@selector(menuDidShow)]) {
            [self.delegate menuDidShow];
        }
    }];
}

- (void)hide {
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        if ([self.delegate respondsToSelector:@selector(menuDidHide)]) {
            [self.delegate menuDidHide];
        }
    }];
}

#pragma mark - CollectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.menuItems count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BlurMenuItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    cell.title.text = [menuItems objectAtIndex:indexPath.row];
    cell.title.font = _itemFont;
    cell.title.textColor = _itemTextColor;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    const NSInteger ScreenWidth = ([UIScreen mainScreen].bounds.size.width);
    return CGSizeMake(ScreenWidth, _itemHeight);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(selectedItemAtIndex:)]) {
        [self.delegate selectedItemAtIndex:indexPath.row];
    }
}

#pragma mark - Calculations
- (CGFloat)currentScreenHeight {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    return screenRect.size.height;
}

- (CGFloat)maxPossibleHeight {
    CGFloat current = [self currentScreenHeight];
    return current - (COLLECTION_VIEW_PADDING*2);
}

- (CGFloat)calculateCollectionViewHeight {
    NSInteger totalItem = [self.menuItems count];
    CGFloat totalHeight = (totalItem * _itemHeight) + (totalItem * ITEM_LINE_SPACING);
    CGFloat maxPossible = [self maxPossibleHeight];
    if (totalHeight > maxPossible) {
        return maxPossible;
    }
    return totalHeight;
}

#pragma mark - Snapshot
- (UIImage *)blurredSnapshot {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(CGRectGetWidth(self.parent.frame), CGRectGetHeight(self.parent.frame)), NO, 1.0f);
    [self.parent drawViewHierarchyInRect:CGRectMake(0, 0, CGRectGetWidth(self.parent.frame), CGRectGetHeight(self.parent.frame)) afterScreenUpdates:NO];
    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // Now apply the blur effect using Apple's UIImageEffect category
    UIImage *blurredSnapshotImage = [snapshotImage applyLightEffect];
    // Or apply any other effects available in "UIImage+ImageEffects.h"
    // UIImage *blurredSnapshotImage = [snapshotImage applyDarkEffect];
    // UIImage *blurredSnapshotImage = [snapshotImage applyExtraLightEffect];
    
    UIGraphicsEndImageContext();
    
    return blurredSnapshotImage;
}

@end
