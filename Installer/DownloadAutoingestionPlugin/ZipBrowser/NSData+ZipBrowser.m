#import "NSData+ZipBrowser.h"


@implementation NSData (ZipBrowser)


- (NSData *)dataAtOffset:(unsigned long long)offset
                  length:(NSUInteger)length;
{
  return [self subdataWithRange:NSMakeRange(offset, length)];
}


- (uint16_t)littleUnsignedShortAtOffset:(unsigned long long)offset;
{
  uint16_t const *unsignedShort = [self bytes] + offset;
  return NSSwapLittleShortToHost(*unsignedShort);
}


- (uint32_t)littleUnsignedIntAtOffset:(unsigned long long)offset;
{
  uint32_t const *unsignedInt = [self bytes] + offset;
  return NSSwapLittleIntToHost(*unsignedInt);
}


@end
