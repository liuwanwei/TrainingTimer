//
//  HeartRateViewController.m
//  TrainingTimer
//
//  Created by sungeo on 15/3/30.
//  Copyright (c) 2015年 buddysoft. All rights reserved.
//

#import "HeartRateViewController.h"

static NSString * const kRowAge = @"rowAge";
static NSString * const kRowMaxHeartRate = @"maxHeartRate";
static NSString * const kRowHighHeartRate = @"highHeartRate";
static NSString * const kRowMediumHeartRate = @"mediumHeartRate";
static NSString * const kRowLowHeartRate = @"lowHeartRate";

static NSString * const kAgeStorageKey = @"age";

@implementation HeartRateViewController

- (instancetype)init{
    if (self = [super init]) {
        [self initializeForm];
    }
    
    return self;
}

- (void)initializeForm{
    XLFormDescriptor * form = [XLFormDescriptor formDescriptorWithTitle:@"心率计算"];
    self.form = form;
    
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kRowAge rowType:XLFormRowDescriptorTypeText title:@"您的年龄:"];
    [row.cellConfig setObject:@"请输入您的真实年龄" forKey:@"textField.placeholder"];
    [section addFormRow:row];
    
    // 心率数据
    section = [XLFormSectionDescriptor formSectionWithTitle:@"心率单位：心跳次数/分钟"];
    [form addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kRowMaxHeartRate
                                                rowType:XLFormRowDescriptorTypeInfo title:@"最大心率:"];
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kRowHighHeartRate
                                                rowType:XLFormRowDescriptorTypeInfo title:@"高强度运动心率:"];
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kRowMediumHeartRate
                                                rowType:XLFormRowDescriptorTypeInfo title:@"中强度运动心率:"];
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kRowLowHeartRate
                                                rowType:XLFormRowDescriptorTypeInfo title:@"低强度运动心率:"];
    [section addFormRow:row];
    NSString * notes = @"运动时，请根据相应的运动强度要求，来保持自己的心率在对应的范围内。遇到心脏不适时请立刻停止运动。\n\n\
热身期：保持低强度运动心率\n\
训练期：不要超过高强度运动心率\n\n\
切记：永远不要超过最大心率！";
    section.footerTitle = notes;
    
    [self initAge];
}

#pragma mark - XL form descriptor delegate
- (void)formRowDescriptorValueHasChanged:(XLFormRowDescriptor *)formRow oldValue:(id)oldValue newValue:(id)newValue{
    [super formRowDescriptorValueHasChanged:formRow oldValue:oldValue newValue:newValue];
    if ([formRow.tag isEqualToString:kRowAge]) {
        NSInteger age = [formRow.value integerValue];
        if (age > 80 || age < 12) {
            return;
        }
        
        [self saveAge:age];
        
        [self updateRowsWithAge:age];
    }
}

- (void)updateRowsWithAge:(NSInteger)age{
    // 最大心率
    NSInteger max = 220 - age;
    XLFormRowDescriptor * row = [self.form formRowWithTag:kRowMaxHeartRate];
    row.value = @(max);
    
    // 高强度心率
    row = [self.form formRowWithTag:kRowHighHeartRate];
    row.value = [NSString stringWithFormat:@"%@ ~ %@", @((NSInteger)(max * 0.7)), @((NSInteger)(max * 0.85))];
    
    // 中强度心率
    row = [self.form formRowWithTag:kRowMediumHeartRate];
    row.value = [NSString stringWithFormat:@"%@ ~ %@", @((NSInteger)(max * 0.5)), @((NSInteger)(max * 0.7))];
    
    // 低强度心率
    row = [self.form formRowWithTag:kRowLowHeartRate];
    row.value = [NSString stringWithFormat:@"< %@", @((NSInteger)(max * 0.5))];
    
    [self.tableView reloadData];
}

- (void)initAge{
    NSInteger age = [self getAge];
    if (age > 0) {
        XLFormRowDescriptor * row = [self.form formRowWithTag:kRowAge];
        row.value = @(age);
        [self updateRowsWithAge:age];
    }
}

- (void)saveAge:(NSInteger)age{
    NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:@(age) forKey:kAgeStorageKey];
}

- (NSInteger)getAge{
    NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
    NSNumber * age = [ud objectForKey:kAgeStorageKey];
    return [age integerValue];
}

@end
