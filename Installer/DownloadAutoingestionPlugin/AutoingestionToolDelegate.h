#import <Foundation/Foundation.h>


@class AutoingestionTool;


@protocol AutoingestionToolDelegate <NSObject>

- (void)autoingestionToolDidFinishDownloading:(AutoingestionTool *)autoingestionTool;

- (void)autoingestionTool:(AutoingestionTool *)autoingestionTool
downloadFailedWithMessage:(NSString *)message;

- (void)autoingestionTool:(AutoingestionTool *)autoingestionTool
        didUpdateProgress:(double)progress;

@end
