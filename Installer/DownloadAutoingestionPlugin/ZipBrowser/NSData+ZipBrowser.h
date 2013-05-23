#import <Foundation/Foundation.h>


@interface NSData (ZipBrowser)

- (NSData *)dataAtOffset:(unsigned long long)offset length:(NSUInteger)length;

- (uint32_t)littleUnsignedIntAtOffset:(unsigned long long)offset;

- (uint16_t)littleUnsignedShortAtOffset:(unsigned long long)offset;

@end
