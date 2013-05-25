#import <Foundation/Foundation.h>


@interface NSData (ZipBrowser)

- (uint32_t)littleUnsignedIntAtOffset:(unsigned long long)offset;

- (uint16_t)littleUnsignedShortAtOffset:(unsigned long long)offset;

@end
