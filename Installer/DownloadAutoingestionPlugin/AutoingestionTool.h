#import <Foundation/Foundation.h>


@protocol AutoingestionToolDelegate;


@interface AutoingestionTool : NSObject <NSURLConnectionDelegate>

@property (readonly) NSURLConnection *connection;
@property (readonly) NSUInteger contentLength;
@property (weak) id<AutoingestionToolDelegate> delegate;
@property (readonly, getter=isDownloaded) BOOL downloaded;
@property (readonly) NSMutableData *zipData;

- (void)download;

@end
