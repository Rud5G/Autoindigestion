#import "DataBuffer.h"


@implementation DataBuffer


- (NSData *)dataAtOffset:(unsigned long long)offset
                  length:(NSUInteger)length;
{
  return [_data subdataWithRange:NSMakeRange(offset, length)];
}


- (unsigned long long)fileLength;
{
  return [_data length];
}


- (id)initWithData:(NSData *)data;
{
  self = [super init];
  if ( ! self) return nil;
  
  _data = [data copy];
  
  return self;
}


- (uint16_t)littleUnsignedShortAtOffset:(unsigned long long)offset;
{
  uint16_t const *unsignedShort = [_data bytes] + offset;
  return NSSwapLittleShortToHost(*unsignedShort);
}


- (uint32_t)littleUnsignedIntAtOffset:(unsigned long long)offset;
{
  uint32_t const *unsignedInt = [_data bytes] + offset;
  return NSSwapLittleIntToHost(*unsignedInt);
}


@end
