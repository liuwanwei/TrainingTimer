#import "NSDictionary+QueryStringBuilder.h"

static NSString * escapeString(NSString *unencodedString)
{
    NSString *s = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
        (CFStringRef)unencodedString,
        NULL,
        (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
        kCFStringEncodingUTF8));
    return s;
}


@implementation NSDictionary (QueryStringBuilder)

- (NSString *)queryString
{
    NSMutableString *queryString = nil;
    NSArray *keys = [self allKeys];
    
    if ([keys count] > 0) {
        for (id key in keys) {
            id value = [self objectForKey:key];
            if (nil == queryString) {
                queryString = [[NSMutableString alloc] init];
                [queryString appendFormat:@"?"];
            } else {
                [queryString appendFormat:@"&"];
            }
            
            if (nil != key && nil != value) {
                [queryString appendFormat:@"%@=%@", escapeString(key), escapeString(value)];
            } else if (nil != key) {
                [queryString appendFormat:@"%@", escapeString(key)];
            }
        }
    }
    
    return queryString;
}

- (NSString *)jsonString{
    NSError * error;
    NSData * data = [NSJSONSerialization dataWithJSONObject:self options:0 error:&error];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end
