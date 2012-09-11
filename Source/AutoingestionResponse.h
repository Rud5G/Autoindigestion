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

- (id)initWithOutput:(NSData *)output;

@end
