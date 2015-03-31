//
//  TrainingProcess.h
//  TrainingTimer
//
//  Created by sungeo on 15/3/21.
//  Copyright (c) 2015年 buddysoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BDFoundation.h"

@class TrainingUnit;

@interface TrainingProcess : BaseModel

@property (nonatomic, copy) NSString * title;
@property (nonatomic, strong, readonly) NSMutableArray * units;

- (instancetype)initWithTitle:(NSString *)title;

- (void)addUnit:(TrainingUnit *)unit;
- (void)deleteUnit:(TrainingUnit *)unit;

@end
