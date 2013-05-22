#import "AutoingestionTool.h"

#import <syslog.h>
#import "AutoingestionToolDelegate.h"
#import "DataBuffer.h"
#import "ZipBrowser/ZipDocument.h"
#import "ZipBrowser/ZipEntry.h"


static NSString *const kAutoingestionFilename = @"Autoingestion.class";
static NSString *const kAutoindigestionPath = @"/Library/Autoindigestion";
static NSString *const kAutoingestionTempPath = @"/tmp/com.ablepear.autoindigestion.installer";
static NSString *const kAutoingestionURL = @"http://www.apple.com/itunesnews/docs/Autoingestion.class.zip";


static void collectZipEntries(ZipEntry *zipEntry, NSMutableArray *zipEntries);


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
  
  DataBuffer *dataBuffer = [[DataBuffer alloc] initWithData:_zipData];
  ZipDocument *zipDocument = [[ZipDocument alloc] init];

  NSError *error;
  BOOL didRead = [zipDocument readFromFileBuffer:dataBuffer error:&error];
  if ( ! didRead) {
    syslog(LOG_ERR, "Unable to decompress %s: (%li) %s",
           [kAutoingestionURL UTF8String], [error code], [[error localizedDescription] UTF8String]);
    return;
  }
  
  NSMutableArray *zipEntries = [NSMutableArray array];
  collectZipEntries([zipDocument rootEntry], zipEntries);
  for (ZipEntry *zipEntry in zipEntries) {
    syslog(LOG_INFO, "Found zip entry: %s", [[zipEntry name] UTF8String]);
    if ([kAutoingestionFilename isEqualToString:[zipEntry name]]) {
      syslog(LOG_INFO, "Unzipping %s", [kAutoingestionFilename UTF8String]);
      NSData *autoingestionClass = [zipDocument unzipEntry:zipEntry];
      if ( ! autoingestionClass) {
        syslog(LOG_ERR, "Unable to unzip %s", [kAutoingestionFilename UTF8String]);
        return;
      }

      if ([[NSFileManager defaultManager] fileExistsAtPath:kAutoingestionTempPath]) {
        syslog(LOG_INFO, "Removing old %s directory", [kAutoingestionTempPath UTF8String]);
        BOOL removed = [[NSFileManager defaultManager] removeItemAtPath:kAutoingestionTempPath
                                                                  error:&error];
        if ( ! removed) {
          syslog(LOG_ERR, "Unable to remove directory %s: (%li) %s",
                 [kAutoingestionTempPath UTF8String], [error code], [[error localizedDescription] UTF8String]);
          return;
        }
      }
      
      BOOL created = [[NSFileManager defaultManager] createDirectoryAtPath:kAutoingestionTempPath
                                               withIntermediateDirectories:YES
                                                                attributes:nil
                                                                     error:&error];
      if ( ! created) {
        syslog(LOG_ERR, "Unable to create directory %s: (%li) %s",
               [kAutoingestionTempPath UTF8String], [error code], [[error localizedDescription] UTF8String]);
        return;
      }

      NSString *path = [kAutoingestionTempPath stringByAppendingPathComponent:kAutoingestionFilename];
      BOOL didWrite = [autoingestionClass writeToFile:path
                                              options:NSAtomicWrite
                                                error:&error];
      if ( ! didWrite) {
        syslog(LOG_ERR, "Unable to write %s: (%li) %s",
            [path UTF8String], [error code], [[error localizedDescription] UTF8String]);
        return;
      }
      break;
    }
  }
  
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
  NSURLRequest *request = [NSURLRequest requestWithURL:_url];
  _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}


- (id)init;
{
  self = [super init];
  if ( ! self) return nil;
  
  NSString *path = [kAutoindigestionPath stringByAppendingPathComponent:kAutoingestionFilename];
  
  _downloaded = [[NSFileManager defaultManager] fileExistsAtPath:path];
  _url = [NSURL URLWithString:kAutoingestionURL];
  
  return self;
}


@end


static void collectZipEntries(ZipEntry *zipEntry, NSMutableArray *zipEntries)
{
  [zipEntries addObject:zipEntry];
  for (ZipEntry *childEntry in [zipEntry childEntries]) {
    collectZipEntries(childEntry, zipEntries);
  }
}
