#import "DownloadAutoingestionPluginPane.h"

#import "AutoingestionTool.h"


#define LocalizedString(STRING) \
    [[NSBundle bundleForClass:[self class]] localizedStringForKey:(STRING) value:nil table:nil]


@implementation DownloadAutoingestionPluginPane


- (void)autoingestionToolDidFinishDownloading:(AutoingestionTool *)autoingestionTool;
{
  [self setStateDownloadComplete];
}


- (void)autoingestionTool:(AutoingestionTool *)autoingestionTool
  downloadFailedWithError:(NSError *)error;
{
  [self setStatedownloadFailed:error];
}


- (void)autoingestionTool:(AutoingestionTool *)autoingestionTool
        didUpdateProgress:(double)progress;
{
  [_progressIndicator setDoubleValue:progress];
}


- (void)didEnterPane:(InstallerSectionDirection)dir;
{
  if ( ! [_autoingestionTool isDownloaded]) [_autoingestionTool download];
}


- (id)init;
{
  self = [super init];
  if ( ! self) return nil;
  
  _autoingestionTool = [[AutoingestionTool alloc] init];
  [_autoingestionTool setDelegate:self];
  
  return self;
}


- (void)setStateDownloadComplete;
{
  [_statusLabel setStringValue:LocalizedString(@"Auto-Ingest tool downloaded.")];
  [_progressIndicator setDoubleValue:1.0];
  [self setNextEnabled:YES];
}


- (void)setStatedownloadFailed:(NSError *)error;
{
  [_statusLabel setStringValue:LocalizedString(@"Error downloading Auto-Ingest tool.")];
  // TODO: display error info, retry and skip buttons
}


- (void)setStateDownloadedPreviously;
{
  [_statusLabel setStringValue:LocalizedString(@"Auto-Ingest tool downloaded.")];
  [_progressIndicator setHidden:YES];
  [self setNextEnabled:YES];
}


- (void)setStateNotDownloaded;
{
  [_statusLabel setStringValue:LocalizedString(@"Downloading Auto-Ingest tool.")];
  [_progressIndicator setDoubleValue:0.0];
  [_progressIndicator setHidden:NO];
  [self setNextEnabled:NO];
}


- (NSString *)title;
{
	return LocalizedString(@"Download Auto-Ingest Tool");
}


- (void)willEnterPane:(InstallerSectionDirection)dir;
{
  if ([_autoingestionTool isDownloaded]) {
    [self setStateDownloadedPreviously];
  } else {
    [self setStateNotDownloaded];
  }
}


@end
