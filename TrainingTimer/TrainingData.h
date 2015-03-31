//
//  DataCenter.h
//  TrainingTimer
//
//  Created by sungeo on 15/3/21.
//  Copyright (c) 2015年 buddysoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TrainingUnit.h"

extern NSString * const TrainingProcessChangedNote;

@class TrainingProcess;

@interface TrainingData : NSObject

@property (nonatomic, strong, readonly) NSMutableArray * trainingProcesses;

+ (instancetype)defaultInstance;

- (void)loadDataes;
- (void)saveTrainingProcess:(TrainingProcess *)process;

@end
