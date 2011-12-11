//http://madebymany.com/blog/url-encoding-an-nsstring-on-ios

#import <Foundation/Foundation.h>
@interface NSString (URLEncoding)
-(NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding;
@end
