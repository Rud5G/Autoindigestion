#import "NSData+ZipBrowser.h"


@implementation NSData (ZipBrowser)


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
