#import <Foundation/Foundation.h>


enum AutoingestionResponseCode {
  AutoingestionResponseCodeNone = 0,
  AutoingestionResponseCodeSuccess,
  AutoingestionResponseCodeNotAvailable,
  AutoingestionResponseCodeNoReportsAvailable,
  AutoingestionResponseCodeTryAgainLater,
  AutoingestionResponseCodeDailyReportDateOutOfRange,
  AutoingestionResponseCodeWeeklyReportDateOutOfRange,
  AutoingestionResponseCodeYearlyReportDateOutOfRange,
  AutoingestionResponseCodeUnknownHostException,
  AutoingestionResponseCodeSocketException,
  AutoingestionResponseCodeNoRouteToHostException,
  AutoingestionResponseCodeConnectException,
  AutoingestionResponseCodeSSLHandshakeException,
  AutoingestionResponseCodeUnrecognized,
};


@interface AutoingestionResponse : NSObject

@property (readonly) enum AutoingestionResponseCode code;
@property (readonly) NSString *filename;
@property (readonly, getter=isNetworkUnavailable) BOOL networkUnavailable;
@property (readonly, getter=isSuccess) BOOL success;
@property (readonly) NSString *summary;
@property (readonly) NSString *text;
@property (readonly, getter=isTryAgainLater) BOOL tryAgainLater;

- (id)initWithOutput:(NSData *)output;

@end
