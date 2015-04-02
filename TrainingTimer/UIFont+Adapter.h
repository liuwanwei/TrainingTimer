#import <UIKit/UIKit.h>


@interface UIFont(Adapter)

+ (UIFont *)findAdaptiveFontWithName:(NSString *)fontName forUILabelSize:(CGSize)labelSize withMinimumSize:(NSInteger)minSize;


@end