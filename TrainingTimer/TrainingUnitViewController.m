//
//  TrainingUnitViewController.m
//  TrainingTimer
//
//  Created by sungeo on 15/3/23.
//  Copyright (c) 2015年 buddysoft. All rights reserved.
//

#import "TrainingUnitViewController.h"
#import "TrainingUnit.h"
#import <XLForm.h>

static NSString * const kTrainingUnitTypeRow = @"trainingUnitTypeRow";

@interface TrainingUnitViewController ()

@end

@implementation TrainingUnitViewController{
    __weak TrainingUnit * _unit;
}

- (instancetype)initWithTrainingUnit:(TrainingUnit *)unit{
    if (self = [super init]) {
        _unit = unit;
        [self createForm];
    }
    
    return self;
}

- (void)createForm{
    XLFormDescriptor * form = [XLFormDescriptor formDescriptor];
    self.form = form;
    
    XLFormSectionDescriptor * section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    
    XLFormRowDescriptor * row = [XLFormRowDescriptor formRowDescriptorWithTag:kTrainingUnitTypeRow rowType:XLFormRowDescriptorTypeSelectorActionSheet title:@"训练类型"];
    row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(TrainingUnitTypePreprae) displayText:[TrainingUnit descriptionForType:TrainingUnitTypePreprae]],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(TrainingUnitTypeJump) displayText:[TrainingUnit descriptionForType:TrainingUnitTypeJump]],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(TrainingUnitTypeRest) displayText:[TrainingUnit descriptionForType:TrainingUnitTypeRest]]];
    [section addFormRow:row];
    
    if (_unit) {
        row.value = [XLFormOptionsObject formOptionsObjectWithValue:_unit.type displayText:_unit.description];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save:)];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Supporting functions

- (void)save:(id)sender{
    
}

@end
