#import <InstallerPlugins/InstallerPlugins.h>
#import "AutoingestionToolDelegate.h"


enum DownloadAutoingestionState {
  DownloadAutoingestionStateUnknown = 0,
  DownloadAutoingestionStateNotDownloaded,
  DownloadAutoingestionStateDownloadInProgress,
  DownloadAutoingestionStateDownloadComplete,
  DownloadAutoingestionStateDownloadedPreviously,
  DownloadAutoingestionStateDownloadFailed,
};


@interface DownloadAutoingestionPluginPane : InstallerPane <AutoingestionToolDelegate>

@property (readonly) AutoingestionTool *autoingestionTool;
@property (strong) IBOutlet NSTextField *errorMessage;
@property (strong) IBOutlet NSButton *errorSkipButton;
@property (strong) IBOutlet NSButton *errorTryAgainButton;
@property (strong) IBOutlet NSImageView *javaClassIconView;
@property (strong) IBOutlet NSProgressIndicator *progressIndicator;
@property (readonly) enum DownloadAutoingestionState state;
@property (strong) IBOutlet NSTextField *statusLabel;

- (void)beginStateDownloadComplete;

- (void)beginStateDownloadFailedWithMessage:(NSString *)message;

- (void)beginStateDownloadInProgress;

- (void)beginStateDownloadedPreviously;

- (void)beginStateNotDownloaded;

- (IBAction)errorSkipClicked:(id)sender;

- (IBAction)errorTryAgainClicked:(id)sender;

- (void)loadResources;

- (void)showJavaClassIcon;

@end
