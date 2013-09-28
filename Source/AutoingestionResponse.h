#import <Foundation/Foundation.h>


enum AutoingestionResponseCode {
  AutoingestionResponseCodeNone = 0,
  AutoingestionResponseCodeSuccess,
  AutoingestionResponseCodeNotAvailable,
  AutoingestionResponseCodeNoReportsAvailable,
  AutoingestionResponseCodeTryAgainLater,
  AutoingestionResponseCodeDailyReportDateOutOfRange,
  AutoingestionResponseCodeWeeklyReportDateOutOfRange,
  AutoingestionResponseCodeMonthlyReportDateOutOfRange,
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
@property (readonly, copy) NSString *filename;
@property (readonly, getter=isNetworkUnavailable) BOOL networkUnavailable;
@property (readonly, getter=isSuccess) BOOL success;
@property (readonly, copy) NSString *summary;
@property (readonly, copy) NSString *text;
@property (readonly, getter=isTryAgainLater) BOOL tryAgainLater;

- (id)initWithOutput:(NSData *)output;

@end
