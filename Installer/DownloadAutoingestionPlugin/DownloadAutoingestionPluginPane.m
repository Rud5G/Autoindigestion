#import "DownloadAutoingestionPluginPane.h"

#import <syslog.h>
#import "AutoingestionTool.h"


#define LocalizedString(STRING) \
    [[NSBundle bundleForClass:[self class]] localizedStringForKey:(STRING) value:nil table:nil]


@implementation DownloadAutoingestionPluginPane


- (void)autoingestionToolDidFinishDownloading:(AutoingestionTool *)autoingestionTool;
{
  switch (_state) {
    case DownloadAutoingestionStateDownloadInProgress:
      [self beginStateDownloadComplete];
      break;
    default:
      syslog(LOG_ERR, "Unexpected state %i for %s", _state, __FUNCTION__);
      break;
  }
}


- (void)autoingestionTool:(AutoingestionTool *)autoingestionTool
downloadFailedWithMessage:(NSString *)message;
{
  switch (_state) {
    case DownloadAutoingestionStateDownloadInProgress:
      [self beginStateDownloadFailedWithMessage:message];
      break;
    default:
      syslog(LOG_ERR, "Unexpected state %i for %s", _state, __FUNCTION__);
      break;
  }
}


- (void)autoingestionTool:(AutoingestionTool *)autoingestionTool
        didUpdateProgress:(double)progress;
{
  switch (_state) {
    case DownloadAutoingestionStateDownloadInProgress:
      [_progressIndicator setDoubleValue:progress];
      break;
    default:
      syslog(LOG_ERR, "Unexpected state %i for %s", _state, __FUNCTION__);
      break;
  }
}


- (void)beginStateDownloadInProgress;
{
  _state = DownloadAutoingestionStateDownloadInProgress;
  [_autoingestionTool performSelector:@selector(download)
                           withObject:nil
                           afterDelay:1.0];
}


- (void)didEnterPane:(InstallerSectionDirection)dir;
{
  switch (_state) {
    case DownloadAutoingestionStateNotDownloaded:
      [self beginStateDownloadInProgress];
      break;
    case DownloadAutoingestionStateDownloadedPreviously:
      break;
    default:
      syslog(LOG_ERR, "Unexpected state %i for %s", _state, __FUNCTION__);
      break;
  }
}


- (IBAction)errorSkipClicked:(id)sender;
{
  switch (_state) {
    case DownloadAutoingestionStateDownloadFailed:
      _state = DownloadAutoingestionStateNotDownloaded;
      [self gotoNextPane];
      break;
    default:
      syslog(LOG_ERR, "Unexpected state %i for %s", _state, __FUNCTION__);
      break;
  }
}


- (IBAction)errorTryAgainClicked:(id)sender;
{
  switch (_state) {
    case DownloadAutoingestionStateDownloadFailed:
      [self beginStateNotDownloaded];
      [self beginStateDownloadInProgress];
      break;
    default:
      syslog(LOG_ERR, "Unexpected state %i for %s", _state, __FUNCTION__);
      break;
  }
}


- (id)init;
{
  self = [super init];
  if ( ! self) return nil;
  
  _autoingestionTool = [[AutoingestionTool alloc] init];
  [_autoingestionTool setDelegate:self];
  
  _state = DownloadAutoingestionStateNotDownloaded;
  
  return self;
}


- (void)beginStateDownloadComplete;
{
  _state = DownloadAutoingestionStateDownloadComplete;
  [_errorMessage setHidden:YES];
  [_errorSkipButton setHidden:YES];
  [_errorTryAgainButton setHidden:YES];
  [_javaClassIconView setAlphaValue:0.0f];
  [_javaClassIconView setHidden:NO];
  [_progressIndicator setDoubleValue:1.0];
  [_statusLabel setStringValue:LocalizedString(@"Auto-ingest tool downloaded.")];
  [self setNextEnabled:NO];
  
  [self performSelector:@selector(showJavaClassIcon)
             withObject:nil
             afterDelay:1.0];
}


- (void)beginStateDownloadFailedWithMessage:(NSString *)message;
{
  _state = DownloadAutoingestionStateDownloadFailed;
  [_errorMessage setHidden:NO];
  [_errorMessage setStringValue:message];
  [_errorSkipButton setHidden:NO];
  [_errorTryAgainButton setHidden:NO];
  [_javaClassIconView setHidden:YES];
  [_progressIndicator setHidden:YES];
  [_statusLabel setStringValue:LocalizedString(@"Error downloading auto-ingest tool.")];
  [self setNextEnabled:YES];
}


- (void)beginStateDownloadedPreviously;
{
  _state = DownloadAutoingestionStateDownloadedPreviously;
  [_errorMessage setHidden:YES];
  [_errorSkipButton setHidden:YES];
  [_errorTryAgainButton setHidden:YES];
  [_javaClassIconView setAlphaValue:1.0];
  [_javaClassIconView setHidden:NO];
  [_progressIndicator setHidden:YES];
  [_statusLabel setStringValue:LocalizedString(@"Auto-ingest tool downloaded.")];
  [self setNextEnabled:YES];
}


- (void)beginStateNotDownloaded;
{
  _state = DownloadAutoingestionStateNotDownloaded;
  [_errorMessage setHidden:YES];
  [_errorSkipButton setHidden:YES];
  [_errorTryAgainButton setHidden:YES];
  [_javaClassIconView setAlphaValue:0.0];
  [_javaClassIconView setHidden:YES];
  [_progressIndicator setAlphaValue:1.0];
  [_progressIndicator setDoubleValue:0.0];
  [_progressIndicator setHidden:NO];
  [_statusLabel setStringValue:LocalizedString(@"Downloading auto-ingest tool.")];
  [self setNextEnabled:NO];
}


- (void)loadResources;
{
  NSBundle *bundle = [NSBundle bundleForClass:[self class]];
  NSImage *javaClassIcon = [bundle imageForResource:@"JavaClass"];
  [_javaClassIconView setImage:javaClassIcon];
}


- (BOOL)shouldExitPane:(InstallerSectionDirection)dir;
{
  switch (_state) {
    case DownloadAutoingestionStateNotDownloaded: return YES;
    case DownloadAutoingestionStateDownloadInProgress: return NO;
    case DownloadAutoingestionStateDownloadComplete: return NO;
    case DownloadAutoingestionStateDownloadedPreviously: return YES;
    case DownloadAutoingestionStateDownloadFailed: return YES;
    default:
      syslog(LOG_ERR, "Unexpected state %i for %s", _state, __FUNCTION__);
      return YES;
  }
}


- (void)showJavaClassIcon;
{
  [NSAnimationContext beginGrouping];
  [[NSAnimationContext currentContext] setDuration:1.0];
  
  [[_javaClassIconView animator] setAlphaValue:1.0f];
  [[_progressIndicator animator] setAlphaValue:0.0f];
  
  [[NSAnimationContext currentContext] setCompletionHandler:^{
    [[_progressIndicator animator] setHidden:YES];
    [self performSelector:@selector(beginStateDownloadedPreviously)
               withObject:nil
               afterDelay:0.1];
  }];
  [NSAnimationContext endGrouping];
}


- (NSString *)title;
{
	return LocalizedString(@"Download Auto-Ingest Tool");
}


- (void)willEnterPane:(InstallerSectionDirection)dir;
{
  switch (_state) {
    case DownloadAutoingestionStateNotDownloaded:
      [self loadResources];
      [self beginStateNotDownloaded];
      break;
    case DownloadAutoingestionStateDownloadedPreviously:
      break;
    default:
      syslog(LOG_ERR, "Unexpected state %i for %s", _state, __FUNCTION__);
      break;
  }
}


@end
