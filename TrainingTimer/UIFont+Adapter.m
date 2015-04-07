#import "UIFont+Adapter.h"

@implementation UIFont(Adapter)

+ (UIFont *)findAdaptiveFontWithName:(NSString *)fontName forUILabelSize:(CGSize)labelSize withMinimumSize:(NSInteger)minSize
{
    if (fontName == nil) {
        fontName = @"Times New Roman";
    }
    
    if (minSize <= 0) {
        minSize = 5;
    }
    
    UIFont *tempFont = nil;
    NSString *testString = @"9";
    
    NSInteger tempMin = minSize;
    NSInteger tempMax = 256;
    NSInteger mid = 0;
    NSInteger difference = 0;
    
    while (tempMin <= tempMax) {
        @autoreleasepool {
            mid = tempMin + (tempMax - tempMin) / 2;
            tempFont = [UIFont fontWithName:fontName size:mid];
            
            //            CGSize tempFontSize = [testString sizeWithFont:tempFont];]
            CGSize tempFontSize = [testString sizeWithAttributes:@{NSFontAttributeName:tempFont}];
            difference = labelSize.height - tempFontSize.height;
            
            if (mid == tempMin || mid == tempMax) {
                if (difference < 0) {
                    return [UIFont fontWithName:fontName size:(mid - 1)];
                }
                
                return [UIFont fontWithName:fontName size:mid];
            }
            
            if (difference < 0) {
                tempMax = mid - 1;
            } else if (difference > 0) {
                tempMin = mid + 1;
            } else {
                return [UIFont fontWithName:fontName size:mid];
            }
        }
    }
    
    return [UIFont fontWithName:fontName size:mid];
}

+ (UIFont *)adaptiveFontForString:(NSString *)string withWidth:(CGFloat)width{
    return [[self class] adaptiveFontForString:string forHeight:NO withLength:width];
}

+ (UIFont *)adaptiveFontWithHeight:(CGFloat)height{
    return [[self class] adaptiveFontForString:@"9" forHeight:YES withLength:height];
}

+ (UIFont *)adaptiveFontForString:(NSString *)string forHeight:(BOOL)isHeight withLength:(CGFloat)length{
    NSString * fontName = @"Times New Roman";
    CGFloat minSize = 5;
    
    UIFont *tempFont = nil;
    
    // 测试字符串，模拟得出该串的高度，作比较看是否符合条件
    NSString *testString = string;
    
    NSInteger tempMin = minSize;
    NSInteger tempMax = 256;
    NSInteger mid = 0;
    NSInteger difference = 0;
    
    while (tempMin <= tempMax) {
        @autoreleasepool {
            mid = tempMin + (tempMax - tempMin) / 2;
            tempFont = [UIFont fontWithName:fontName size:mid];
            
            CGSize tempFontSize = [testString sizeWithAttributes:@{NSFontAttributeName:tempFont}];
            NSInteger tempFontLength = isHeight ? tempFontSize.height : tempFontSize.width;
            difference = length - tempFontLength;
            
            if (mid == tempMin || mid == tempMax) {
                if (difference < 0) {
                    return [UIFont fontWithName:fontName size:(mid - 1)];
                }
                
                return [UIFont fontWithName:fontName size:mid];
            }
            
            if (difference < 0) {
                tempMax = mid - 1;
            } else if (difference > 0) {
                tempMin = mid + 1;
            } else {
                return [UIFont fontWithName:fontName size:mid];
            }
        }
    }
    
    return [UIFont fontWithName:fontName size:mid];
    
}

@end
