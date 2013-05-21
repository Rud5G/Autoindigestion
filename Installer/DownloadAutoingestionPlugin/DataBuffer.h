#import "ZipBrowser/FileBuffer.h"


@interface DataBuffer : FileBuffer

@property (readonly) NSData *data;

- (id)initWithData:(NSData *)data;

@end
