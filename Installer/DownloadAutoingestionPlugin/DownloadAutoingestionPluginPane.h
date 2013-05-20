#import <InstallerPlugins/InstallerPlugins.h>
#import "AutoingestionToolDelegate.h"


@interface DownloadAutoingestionPluginPane : InstallerPane <AutoingestionToolDelegate>

@property (readonly) AutoingestionTool *autoingestionTool;
@property (strong) IBOutlet NSProgressIndicator *progressIndicator;
@property (strong) IBOutlet NSTextField *statusLabel;

- (void)setStateDownloadComplete;

- (void)setStatedownloadFailed:(NSError *)error;

- (void)setStateDownloadedPreviously;

- (void)setStateNotDownloaded;

@end
