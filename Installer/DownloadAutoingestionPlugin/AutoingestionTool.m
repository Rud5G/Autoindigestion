#import "AutoingestionTool.h"

#import <syslog.h>
#import "AutoingestionToolDelegate.h"


static NSString *const kAutoingestionPath = @"/Library/Autoindigestion/Autoingestion.class";
static NSString *const kAutoingestionURL = @"http://www.apple.com/itunesnews/docs/Autoingestion.class.zip";


@implementation AutoingestionTool


- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error;
{
  syslog(LOG_ERR, "ERROR: failed to download %s: (%li) %s",
         [kAutoingestionURL UTF8String], [error code], [[error localizedDescription] UTF8String]);
  [_delegate autoingestionTool:self downloadFailedWithError:error];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
{
  syslog(LOG_INFO, "Downloaded %s", [kAutoingestionURL UTF8String]);
  [_delegate autoingestionToolDidFinishDownloading:self];
  // TODO: extract from zip
  _downloaded = YES;
}


- (void)connection:(NSURLConnection *)connection
    didReceiveData:(NSData *)data;
{
  [_zipData appendData:data];
  
  if (_contentLength) {
    double progress = (double) [_zipData length] / (double) _contentLength;
    [_delegate autoingestionTool:self didUpdateProgress:progress];
  } else {
    [_delegate autoingestionTool:self didUpdateProgress:0.75];
  }
}


- (void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response;
{
  if (NSURLResponseUnknownLength == [response expectedContentLength]) {
    [_delegate autoingestionTool:self didUpdateProgress:0.25];
  } else {
    _contentLength = (NSUInteger) [response expectedContentLength];
  }
}


- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse *)cachedResponse;
{
  return nil;
}


- (void)download;
{
  _contentLength = 0;
  _downloaded = NO;
  _zipData = [NSMutableData data];
  
  syslog(LOG_INFO, "Downloading %s", [kAutoingestionURL UTF8String]);
  NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:kAutoingestionURL]];
  _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}


- (id)init;
{
  self = [super init];
  if ( ! self) return nil;
  
  _downloaded = [[NSFileManager defaultManager] fileExistsAtPath:kAutoingestionPath];

  return self;
}


@end
