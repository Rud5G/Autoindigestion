#import "Options.h"

#import <getopt.h>
#import "Defaults.h"
#import "Monitor.h"


@implementation Options


@synthesize autoingestionClass;
@synthesize configurationFile;
@synthesize defaults;
@synthesize monitor;
@synthesize vendorsDir;


- (id)init;
{
  [NSException raise:@"Not Implemented" format:@"%s", __FUNCTION__];
  return nil;
}


- (id)initWithMonitor:(id <Monitor>)theMonitor
             defaults:(Defaults *)theDefaults
        argumentCount:(int)argc
      andArgumentList:(char *[])argv;
{
  self = [super init];
  if ( ! self) return nil;

  defaults = theDefaults;
  monitor = theMonitor;

  struct option longOptions[] = {
      {
        .name = "help",
        .has_arg = no_argument,
        .flag = NULL,
        .val = 'h',
      },
      {
        .name = "autoingestion-class",
        .has_arg = required_argument,
        .flag = NULL,
        .val = 'a',
      },
      {
        .name = "configuration-file",
        .has_arg = required_argument,
        .flag = NULL,
        .val = 'c',
      },
      {
        .name = "vendors-dir",
        .has_arg = required_argument,
        .flag = NULL,
        .val = 'd',
      },
      {
        .name = NULL,
        .has_arg = no_argument,
        .flag = NULL,
        .val = FALSE,
      },
  };

  int longOptionIndex;
  int ch;
  while (-1 != (ch = getopt_long(argc, argv, "ha:c:v:", longOptions, &longOptionIndex))) {
    switch (ch) {
      case 'h':
        [self printUsageAndExit];
        break;
      case 'a':
        autoingestionClass = [NSString stringWithCString:optarg
                                                encoding:NSUTF8StringEncoding];
        break;
      case 'c':
        configurationFile = [NSString stringWithCString:optarg
                                               encoding:NSUTF8StringEncoding];
        break;
      case 'v':
        vendorsDir = [NSString stringWithCString:optarg
                                              encoding:NSUTF8StringEncoding];
        break;
      case '?':
        [self printUsageAndExit];
        break;
      default:
        [self printUsageAndExit];
        break;
    }
  }

  return self;
}


- (void)printUsageAndExit
{
  [monitor exitWithUsage:
      @"USAGE: %@ [options]...\n"
      @"  -h, --help                       display this help message\n"
      @"  -a, --autoingestion-class=PATH   path to Autoingestion.class\n"
      @"                                   (default: %@)\n"
      @"  -c, --configuration-file=PATH    path to configuration file\n"
      @"                                   (default: %@)\n"
      @"  -v, --vendors-dir=PATH           path to vendors directory\n"
      @"                                   (default: %@)\n"
      ,
      [monitor command],
      [defaults autoingestionClass],
      [defaults configurationFile],
      [defaults vendorsDir]
  ];
}


@end
