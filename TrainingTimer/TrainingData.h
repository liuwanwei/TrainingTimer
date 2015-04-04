//
//  DataCenter.h
//  TrainingTimer
//
//  Created by sungeo on 15/3/21.
//  Copyright (c) 2015年 buddysoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TrainingUnit.h"
#import "TrainingRecord.h"

extern NSString * const TrainingProcessChangedNote;
extern NSString * const TrainingRecordsChangedNote;

@class TrainingProcess;

@interface TrainingData : NSObject

@property (nonatomic, strong, readonly) NSMutableArray * trainingProcesses;// TODO: NSMutableArray不合适
@property (nonatomic, strong, readonly) NSArray * records;

+ (instancetype)defaultInstance;

- (void)loadDataes;
- (void)saveTrainingProcess:(TrainingProcess *)process;

/**
 *  添加一条练习记录
 *  添加成功后，会广播TrainingRecordsChangedNote消息
 *
 *  @param aRecord      练习记录对象
 *
 *  @return void
 */
- (void)addRecord:(TrainingRecord *)aRecord;

@end
