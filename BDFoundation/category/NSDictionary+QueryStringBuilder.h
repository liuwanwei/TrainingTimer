#import <Foundation/Foundation.h>


@interface NSDictionary (QueryStringBuilder)

- (NSString *)queryString;
- (NSString *)jsonString;

@end