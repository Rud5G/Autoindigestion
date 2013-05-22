#import <Foundation/Foundation.h>


@interface DataBuffer : NSObject

@property (readonly, copy) NSData *data;

- (void)close;

- (NSData *)dataAtOffset:(unsigned long long)offset length:(NSUInteger)length;

- (unsigned long long)fileLength;

- (id)initWithData:(NSData *)data;

- (uint32_t)littleUnsignedIntAtOffset:(unsigned long long)offset;

- (uint16_t)littleUnsignedShortAtOffset:(unsigned long long)offset;

@end
