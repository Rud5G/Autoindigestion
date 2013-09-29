#import "AutoingestionTool.h"

#import <syslog.h>
#import "AutoingestionToolDelegate.h"
#import "ZipBrowser/ZipDocument.h"
#import "ZipBrowser/ZipEntry.h"


static NSString *const kAutoingestionFilename = @"Autoingestion.class";
static NSString *const kAutoingestionTempPath = @"/tmp/com.ablepear.autoindigestion.installer";
static NSString *const kAutoingestionURL = @"http://www.apple.com/itunesnews/docs/Autoingestion.class.zip";


@implementation AutoingestionTool


- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error;
{
  NSString *message = [NSString stringWithFormat:@"Failed to download %@: (%li) %@",
                       kAutoingestionURL, [error code], [error localizedDescription]];
  [_delegate autoingestionTool:self downloadFailedWithMessage:message];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
{
  syslog(LOG_INFO, "Downloaded %s", [kAutoingestionURL UTF8String]);
  
  ZipDocument *zipDocument = [[ZipDocument alloc] init];

  NSError *error;
  BOOL didRead = [zipDocument readFromData:_zipData error:&error];
  if ( ! didRead) {
    NSString *message = [NSString stringWithFormat:@"Unable to decompress %@: (%li) %@",
                         kAutoingestionURL, [error code], [error localizedDescription]];
    syslog(LOG_ERR, "%s", [message UTF8String]);
    [_delegate autoingestionTool:self downloadFailedWithMessage:message];
    return;
  }
  
  ZipEntry *zipEntry = [zipDocument entryWithName:kAutoingestionFilename];
  if ( ! zipEntry) {
    NSString *message = [NSString stringWithFormat:@"No entry named \"%@\" found in %@",
                         kAutoingestionFilename, kAutoingestionURL];
    syslog(LOG_ERR, "%s", [message UTF8String]);
    [_delegate autoingestionTool:self downloadFailedWithMessage:message];
    return;
  }
  
  syslog(LOG_INFO, "Extracting %s", [kAutoingestionFilename UTF8String]);
  NSData *autoingestionClass = [zipDocument unzipEntry:zipEntry];
  if ( ! autoingestionClass) {
    NSString *message = [NSString stringWithFormat:@"Unable to unzip %@",
                         kAutoingestionFilename];
    syslog(LOG_ERR, "%s", [message UTF8String]);
    [_delegate autoingestionTool:self downloadFailedWithMessage:message];
    return;
  }

  if ([[NSFileManager defaultManager] fileExistsAtPath:kAutoingestionTempPath]) {
    syslog(LOG_INFO, "Removing old %s directory", [kAutoingestionTempPath UTF8String]);
    BOOL removed = [[NSFileManager defaultManager] removeItemAtPath:kAutoingestionTempPath
                                                              error:&error];
    if ( ! removed) {
      NSString *message = [NSString stringWithFormat:@"Unable to remove directory %@: (%li) %@",
                           kAutoingestionTempPath, [error code], [error localizedDescription]];
      syslog(LOG_ERR, "%s", [message UTF8String]);
      [_delegate autoingestionTool:self downloadFailedWithMessage:message];
      return;
    }
  }
  
  BOOL created = [[NSFileManager defaultManager] createDirectoryAtPath:kAutoingestionTempPath
                                           withIntermediateDirectories:YES
                                                            attributes:nil
                                                                 error:&error];
  if ( ! created) {
    NSString *message = [NSString stringWithFormat:@"Unable to create directory %@: (%li) %@",
                         kAutoingestionTempPath, [error code], [error localizedDescription]];
    syslog(LOG_ERR, "%s", [message UTF8String]);
    [_delegate autoingestionTool:self downloadFailedWithMessage:message];
    return;
  }

  NSString *path = [kAutoingestionTempPath stringByAppendingPathComponent:kAutoingestionFilename];
  BOOL didWrite = [autoingestionClass writeToFile:path
                                          options:NSAtomicWrite
                                            error:&error];
  if ( ! didWrite) {
    NSString *message = [NSString stringWithFormat:@"Unable to write %@: (%li) %@",
                         path, [error code], [error localizedDescription]];
    syslog(LOG_ERR, "%s", [message UTF8String]);
    [_delegate autoingestionTool:self downloadFailedWithMessage:message];
    return;
  }
  
  _downloaded = YES;
  [_delegate autoingestionToolDidFinishDownloading:self];
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
  NSURLRequest *request = [NSURLRequest requestWithURL:_url];
  _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}


- (id)init;
{
  self = [super init];
  if ( ! self) return nil;
  
  _url = [NSURL URLWithString:kAutoingestionURL];
  
  return self;
}


@end
