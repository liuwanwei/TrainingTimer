//
//  HiitSettingViewController.m
//  TrainingTimer
//
//  Created by sungeo on 15/3/30.
//  Copyright (c) 2015年 buddysoft. All rights reserved.
//

#import "HiitSettingViewController.h"
#import "HeartRateViewController.h"
#import "TrainingViewController.h"
#import "TrainingProcess.h"
#import "TrainingUnit.h"
#import <XLForm.h>

static NSString * const kFormRowPrepareTime = @"prepareTime";
static NSString * const kFormRowTrainingTime = @"trainingTime";
static NSString * const kFormRowRestTime = @"restTime";
static NSString * const kFormRowGroupCount = @"groupCount";
static NSString * const kFormRowStart = @"start";

@implementation HiitSettingViewController

- (instancetype)init{
    if (self = [super init]) {
        [self initializeForm];
        [self initializeBarButtonItem];
    }
    
    return self;
}

- (void)initializeForm{
    XLFormRowDescriptor * row;
    XLFormSectionDescriptor * section;
    XLFormDescriptor * form = [[XLFormDescriptor alloc] initWithTitle:@"HIIT训练方案"];
    self.form = form;
    
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"热身设定:"];
    [form addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kFormRowPrepareTime rowType:XLFormRowDescriptorTypeSelectorPush title:@"低强度热身时间"];
    row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(60) displayText:@"1分钟"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(120) displayText:@"2分钟"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(180) displayText:@"3分钟"]];
    row.value = [XLFormOptionsObject formOptionsObjectWithValue:@(120) displayText:@"2分钟"];
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"每组包括："];
    [form addFormSection:section];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kFormRowTrainingTime
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"高强度运动时间"];
    row.value = @"60秒";
    [section addFormRow:row];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kFormRowRestTime
                                                rowType:XLFormRowDescriptorTypeInfo
                                                  title:@"中强度运动时间"];
    row.value = @"20秒";
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"循环设定："];
    [form addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kFormRowGroupCount
                                                rowType:XLFormRowDescriptorTypeSelectorPush
                                                  title:@"循环几组"];
    row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"3组"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(4) displayText:@"4组"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(5) displayText:@"5组"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(6) displayText:@"6组"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(7) displayText:@"7组"]];
    row.value = [XLFormOptionsObject formOptionsObjectWithValue:@(4) displayText:@"4组"];
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kFormRowStart
                                                rowType:XLFormRowDescriptorTypeButton
                                                  title:@"开始"];
    row.action.formSelector = @selector(startTouched:);
    [section addFormRow:row];
}

- (void)startTouched:(id)sender{
    TrainingProcess * process = [[TrainingProcess alloc] initWithTitle:@""];
    
    XLFormOptionsObject * option = [self.form formRowWithTag:kFormRowPrepareTime].value;
    NSNumber * interval = option.valueData;
    
    // 准备时间单元
    TrainingUnit * unit = [TrainingUnit trainingUnitWithType:TrainingUnitTypePreprae interval:interval.integerValue];
    [process addUnit:unit];
    
    // 训练时间单元
    option = [self.form formRowWithTag:kFormRowGroupCount].value;
    NSNumber * count = option.valueData;
    for (NSInteger i = 0; i < count.integerValue; i++) {
        unit = [TrainingUnit trainingUnitWithType:TrainingUnitTypeJump interval:60];
        [process addUnit:unit];
        
        unit = [TrainingUnit trainingUnitWithType:TrainingUnitTypeRest interval:20];
        unit.index = @(i);
        [process addUnit:unit];
    }
    
    TrainingViewController * trainingVc = [[TrainingViewController alloc] init];
    trainingVc.process = process;
    [self.navigationController pushViewController:trainingVc animated:YES];
}

- (void)initializeBarButtonItem{
    UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithTitle:@"心率" style:UIBarButtonItemStylePlain target:self action:@selector(showHeartRateSetting:)];
    self.navigationItem.rightBarButtonItem = item;
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:nil];
}

- (void)showHeartRateSetting:(id)sender{
    HeartRateViewController * vc = [[HeartRateViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
