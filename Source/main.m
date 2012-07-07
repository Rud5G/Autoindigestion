#import "ConfigurationFile.h"
#import "Defaults.h"
#import "Options.h"
#import "StandardMonitor.h"
#import "Tool.h"


int main(int argc, char *argv[])
{
  @autoreleasepool {
    StandardMonitor *standardMonitor = [[StandardMonitor alloc] initWithArgumentList:argv];
    Defaults *defaults = [[Defaults alloc] initWithMonitor:standardMonitor];
    Options *options = [[Options alloc] initWithMonitor:standardMonitor 
                                               defaults:defaults
                                          argumentCount:argc
                                        andArgumentList:argv];
    ConfigurationFile *configurationFile = [[ConfigurationFile alloc] initWithMonitor:standardMonitor
                                                                             defaults:defaults
                                                                           andOptions:options];
    Tool *tool = [[Tool alloc] initWithMonitor:standardMonitor
                                      defaults:defaults
                             configurationFile:configurationFile
                                    andOptions:options];
    [tool prepare];
    [tool downloadReports];
  }
  return 0;
}
