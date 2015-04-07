#import <UIKit/UIKit.h>


@interface UIFont(Adapter)

+ (UIFont *)findAdaptiveFontWithName:(NSString *)fontName forUILabelSize:(CGSize)labelSize withMinimumSize:(NSInteger)minSize;

+ (UIFont *)adaptiveFontWithHeight:(CGFloat)height;
+ (UIFont *)adaptiveFontForString:(NSString *)string withWidth:(CGFloat)width;

//+ (UIFont *)adaptiveFontForHeight:(BOOL)isHeight withLength:(CGFloat)length;

@end