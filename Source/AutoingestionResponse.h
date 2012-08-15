#import <Foundation/Foundation.h>


enum AutoingestionResponseCode {
  AutoingestionResponseCodeNone = 0,
  AutoingestionResponseCodeSuccess,
  AutoingestionResponseCodeNotAvailable,
  AutoingestionResponseCodeNoReportsAvailable,
  AutoingestionResponseCodeTryAgain,
  AutoingestionResponseCodeDailyReportDateOutOfRange,
  AutoingestionResponseCodeWeeklyReportDateOutOfRange,
  AutoingestionResponseCodeUnknownHostException,
  AutoingestionResponseCodeSocketException,
  AutoingestionResponseCodeNoRouteToHostException,
  AutoingestionResponseCodeConnectException,
  AutoingestionResponseCodeUnrecognized,
};


@interface AutoingestionResponse : NSObject

@property (readonly) enum AutoingestionResponseCode code;
@property (readonly, copy) NSString *filename;
@property (readonly, getter=isNetworkUnavailable) BOOL networkUnavailable;
@property (readonly, getter=isSuccess) BOOL success;
@property (readonly, copy) NSString *summary;
@property (readonly, copy) NSString *text;

- (id)initWithOutput:(NSData *)output;

@end
