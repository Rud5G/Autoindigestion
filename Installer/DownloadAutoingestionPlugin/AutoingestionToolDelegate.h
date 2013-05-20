#import <Foundation/Foundation.h>


@class AutoingestionTool;


@protocol AutoingestionToolDelegate <NSObject>

- (void)autoingestionToolDidFinishDownloading:(AutoingestionTool *)autoingestionTool;

- (void)autoingestionTool:(AutoingestionTool *)autoingestionTool
  downloadFailedWithError:(NSError *)error;

- (void)autoingestionTool:(AutoingestionTool *)autoingestionTool
        didUpdateProgress:(double)progress;

@end
