#import <SenTestingKit/SenTestingKit.h>
#import "AutoingestionResponse.h"


@interface AutoingestionResponseTest : SenTestCase
@end


@implementation AutoingestionResponseTest


- (void)testSuccessfulResponse;
{
  char const bytes[] = "S_D_80123456_20120812.txt.gz\n"
                       "File Downloaded Successfully ";
  NSData *output = [NSData dataWithBytes:bytes length:sizeof bytes - 1];
  AutoingestionResponse *response = [[AutoingestionResponse alloc] initWithOutput:output];

  STAssertTrue([response isSuccess], nil);
  STAssertFalse([response isNetworkUnavailable], nil);
  STAssertFalse([response isTryAgainLater], nil);
  STAssertEquals(AutoingestionResponseCodeSuccess, [response code], nil);

  NSString *expectedText = [NSString stringWithCString:bytes
                                              encoding:NSUTF8StringEncoding];
  STAssertEqualObjects(expectedText, [response text], nil);
  
  NSString *expectedSummary = @"S_D_80123456_20120812.txt.gz\n"
                               "\tFile Downloaded Successfully";
  STAssertEqualObjects(expectedSummary, [response summary], nil);

  NSString *expectedFilename = @"S_D_80123456_20120812.txt.gz";
  STAssertEqualObjects(expectedFilename, [response filename], nil);
}


- (void)testUnknownHostResponse;
{
  char const bytes[] =
      "java.net.UnknownHostException: reportingitc.apple.com\n"
      "\tat java.net.PlainSocketImpl.connect(PlainSocketImpl.java:195)\n"
      "\tat java.net.SocksSocketImpl.connect(SocksSocketImpl.java:432)\n"
      "\tat java.net.Socket.connect(Socket.java:529)\n"
      "\tat com.sun.net.ssl.internal.ssl.SSLSocketImpl.connect(SSLSocketImpl.java:564)\n"
      "\tat com.sun.net.ssl.internal.ssl.BaseSSLSocketImpl.connect(BaseSSLSocketImpl.java:141)\n"
      "\tat sun.net.NetworkClient.doConnect(NetworkClient.java:163)\n"
      "\tat sun.net.www.http.HttpClient.openServer(HttpClient.java:388)\n"
      "\tat sun.net.www.http.HttpClient.openServer(HttpClient.java:523)\n"
      "\tat sun.net.www.protocol.https.HttpsClient.<init>(HttpsClient.java:272)\n"
      "\tat sun.net.www.protocol.https.HttpsClient.New(HttpsClient.java:329)\n"
      "\tat sun.net.www.protocol.https.AbstractDelegateHttpsURLConnection.getNewHttpClient(AbstractDelegateHttpsURLConnection.java:172)\n"
      "\tat sun.net.www.protocol.http.HttpURLConnection.plainConnect(HttpURLConnection.java:911)\n"
      "\tat sun.net.www.protocol.https.AbstractDelegateHttpsURLConnection.connect(AbstractDelegateHttpsURLConnection.java:158)\n"
      "\tat sun.net.www.protocol.http.HttpURLConnection.getOutputStream(HttpURLConnection.java:1014)\n"
      "\tat sun.net.www.protocol.https.HttpsURLConnectionImpl.getOutputStream(HttpsURLConnectionImpl.java:230)\n"
      "\tat Autoingestion.main(Autoingestion.java:61)\n"
      "The report you requested is not available at this time.  Please try again in a few minutes.\n";
  NSData *output = [NSData dataWithBytes:bytes length:sizeof bytes - 1];
  AutoingestionResponse *response = [[AutoingestionResponse alloc] initWithOutput:output];

  STAssertFalse([response isSuccess], nil);
  STAssertTrue([response isNetworkUnavailable], nil);
  STAssertFalse([response isTryAgainLater], nil);
  STAssertEquals(AutoingestionResponseCodeUnknownHostException, [response code], nil);
  NSString *expectedText = [NSString stringWithCString:bytes
                                              encoding:NSUTF8StringEncoding];
  STAssertEqualObjects(expectedText, [response text], nil);

  NSString *expectedSummary = @"java.net.UnknownHostException: reportingitc.apple.com\n"
      "\tThe report you requested is not available at this time.  Please try again in a few minutes.";
  STAssertEqualObjects(expectedSummary, [response summary], nil);

  STAssertNil([response filename], nil);
}


- (void)testConnectExceptionResponse;
{
  char const bytes[] =
      "java.net.ConnectException: Operation timed out\n"
      "\tat java.net.PlainSocketImpl.socketConnect(Native Method)\n"
      "\tat java.net.PlainSocketImpl.doConnect(PlainSocketImpl.java:351)\n"
      "\tat java.net.PlainSocketImpl.connectToAddress(PlainSocketImpl.java:213)\n"
      "\tat java.net.PlainSocketImpl.connect(PlainSocketImpl.java:200)\n"
      "\tat java.net.SocksSocketImpl.connect(SocksSocketImpl.java:432)\n"
      "\tat java.net.Socket.connect(Socket.java:529)\n"
      "\tat com.sun.net.ssl.internal.ssl.SSLSocketImpl.connect(SSLSocketImpl.java:564)\n"
      "\tat com.sun.net.ssl.internal.ssl.BaseSSLSocketImpl.connect(BaseSSLSocketImpl.java:141)\n"
      "\tat sun.net.NetworkClient.doConnect(NetworkClient.java:163)\n"
      "\tat sun.net.www.http.HttpClient.openServer(HttpClient.java:388)\n"
      "\tat sun.net.www.http.HttpClient.openServer(HttpClient.java:523)\n"
      "\tat sun.net.www.protocol.https.HttpsClient.<init>(HttpsClient.java:272)\n"
      "\tat sun.net.www.protocol.https.HttpsClient.New(HttpsClient.java:329)\n"
      "\tat sun.net.www.protocol.https.AbstractDelegateHttpsURLConnection.getNewHttpClient(AbstractDelegateHttpsURLConnection.java:172)\n"
      "\tat sun.net.www.protocol.http.HttpURLConnection.plainConnect(HttpURLConnection.java:911)\n"
      "\tat sun.net.www.protocol.https.AbstractDelegateHttpsURLConnection.connect(AbstractDelegateHttpsURLConnection.java:158)\n"
      "\tat sun.net.www.protocol.http.HttpURLConnection.getOutputStream(HttpURLConnection.java:1014)\n"
      "\tat sun.net.www.protocol.https.HttpsURLConnectionImpl.getOutputStream(HttpsURLConnectionImpl.java:230)\n"
      "\tat Autoingestion.main(Autoingestion.java:61)\n"
      "The report you requested is not available at this time.  Please try again in a few minutes.\n";
  NSData *output = [NSData dataWithBytes:bytes length:sizeof bytes - 1];
  AutoingestionResponse *response = [[AutoingestionResponse alloc] initWithOutput:output];

  STAssertFalse([response isSuccess], nil);
  STAssertTrue([response isNetworkUnavailable], nil);
  STAssertFalse([response isTryAgainLater], nil);
  STAssertEquals(AutoingestionResponseCodeConnectException, [response code], nil);
  NSString *expectedText = [NSString stringWithCString:bytes
                                              encoding:NSUTF8StringEncoding];
  STAssertEqualObjects(expectedText, [response text], nil);

  NSString *expectedSummary = @"java.net.ConnectException: Operation timed out\n"
      "\tThe report you requested is not available at this time.  Please try again in a few minutes.";
  STAssertEqualObjects(expectedSummary, [response summary], nil);

  STAssertNil([response filename], nil);
}


- (void)testNoReportsAvailableResponse;
{
  char const bytes[] =
      "There are no reports available to download for this selection.";
  NSData *output = [NSData dataWithBytes:bytes length:sizeof bytes - 1];
  AutoingestionResponse *response = [[AutoingestionResponse alloc] initWithOutput:output];

  STAssertFalse([response isSuccess], nil);
  STAssertFalse([response isNetworkUnavailable], nil);
  STAssertFalse([response isTryAgainLater], nil);
  STAssertEquals(AutoingestionResponseCodeNoReportsAvailable, [response code], nil);
  NSString *expectedText = [NSString stringWithCString:bytes
                                              encoding:NSUTF8StringEncoding];
  STAssertEqualObjects(expectedText, [response text], nil);
  STAssertEqualObjects(expectedText, [response summary], nil);

  STAssertNil([response filename], nil);
}


- (void)testTryAgainResponse;
{
  char const bytes[] =
      "The report you requested is not available at this time.  "
      "Please try again in a few minutes.";
  NSData *output = [NSData dataWithBytes:bytes length:sizeof bytes - 1];
  AutoingestionResponse *response = [[AutoingestionResponse alloc] initWithOutput:output];
  
  STAssertFalse([response isSuccess], nil);
  STAssertFalse([response isNetworkUnavailable], nil);
  STAssertTrue([response isTryAgainLater], nil);
  STAssertEquals(AutoingestionResponseCodeTryAgainLater, [response code], nil);
  NSString *expectedText = [NSString stringWithCString:bytes
                                              encoding:NSUTF8StringEncoding];
  STAssertEqualObjects(expectedText, [response text], nil);
  STAssertEqualObjects(expectedText, [response summary], nil);
  
  STAssertNil([response filename], nil);
}


- (void)testNoRouteToHostExceptionResponse;
{
  char const bytes[] =
      "java.net.NoRouteToHostException: No route to host\n"
      "\tat java.net.PlainSocketImpl.socketConnect(Native Method)\n"
      "\tat java.net.PlainSocketImpl.doConnect(PlainSocketImpl.java:351)\n"
      "\tat java.net.PlainSocketImpl.connectToAddress(PlainSocketImpl.java:213)\n"
      "\tat java.net.PlainSocketImpl.connect(PlainSocketImpl.java:200)\n"
      "\tat java.net.SocksSocketImpl.connect(SocksSocketImpl.java:432)\n"
      "\tat java.net.Socket.connect(Socket.java:529)\n"
      "\tat com.sun.net.ssl.internal.ssl.SSLSocketImpl.connect(SSLSocketImpl.java:564)\n"
      "\tat com.sun.net.ssl.internal.ssl.BaseSSLSocketImpl.connect(BaseSSLSocketImpl.java:141)\n"
      "\tat sun.net.NetworkClient.doConnect(NetworkClient.java:163)\n"
      "\tat sun.net.www.http.HttpClient.openServer(HttpClient.java:388)\n"
      "\tat sun.net.www.http.HttpClient.openServer(HttpClient.java:523)\n"
      "\tat sun.net.www.protocol.https.HttpsClient.<init>(HttpsClient.java:272)\n"
      "\tat sun.net.www.protocol.https.HttpsClient.New(HttpsClient.java:329)\n"
      "\tat sun.net.www.protocol.https.AbstractDelegateHttpsURLConnection.getNewHttpClient(AbstractDelegateHttpsURLConnection.java:172)\n"
      "\tat sun.net.www.protocol.http.HttpURLConnection.plainConnect(HttpURLConnection.java:911)\n"
      "\tat sun.net.www.protocol.https.AbstractDelegateHttpsURLConnection.connect(AbstractDelegateHttpsURLConnection.java:158)\n"
      "\tat sun.net.www.protocol.http.HttpURLConnection.getOutputStream(HttpURLConnection.java:1014)\n"
      "\tat sun.net.www.protocol.https.HttpsURLConnectionImpl.getOutputStream(HttpsURLConnectionImpl.java:230)\n"
      "\tat Autoingestion.main(Autoingestion.java:61)\n"
      "The report you requested is not available at this time.  Please try again in a few minutes.\n";
  NSData *output = [NSData dataWithBytes:bytes length:sizeof bytes - 1];
  AutoingestionResponse *response = [[AutoingestionResponse alloc] initWithOutput:output];

  STAssertFalse([response isSuccess], nil);
  STAssertTrue([response isNetworkUnavailable], nil);
  STAssertFalse([response isTryAgainLater], nil);
  STAssertEquals(AutoingestionResponseCodeNoRouteToHostException, [response code], nil);
  NSString *expectedText = [NSString stringWithCString:bytes
                                              encoding:NSUTF8StringEncoding];
  STAssertEqualObjects(expectedText, [response text], nil);

  NSString *expectedSummary = @"java.net.NoRouteToHostException: No route to host\n"
      "\tThe report you requested is not available at this time.  Please try again in a few minutes.";
  STAssertEqualObjects(expectedSummary, [response summary], nil);

  STAssertNil([response filename], nil);
}


- (void)testSocketExceptionResponse;
{
  char const bytes[] =
      "java.net.SocketException: Network is down\n"
      "\tat java.net.SocketInputStream.socketRead0(Native Method)\n"
      "\tat java.net.SocketInputStream.read(SocketInputStream.java:129)\n"
      "\tat com.sun.net.ssl.internal.ssl.InputRecord.readFully(InputRecord.java:293)\n"
      "\tat com.sun.net.ssl.internal.ssl.InputRecord.read(InputRecord.java:331)\n"
      "\tat com.sun.net.ssl.internal.ssl.SSLSocketImpl.readRecord(SSLSocketImpl.java:830)\n"
      "\tat com.sun.net.ssl.internal.ssl.SSLSocketImpl.performInitialHandshake(SSLSocketImpl.java:1170)\n"
      "\tat com.sun.net.ssl.internal.ssl.SSLSocketImpl.startHandshake(SSLSocketImpl.java:1197)\n"
      "\tat com.sun.net.ssl.internal.ssl.SSLSocketImpl.startHandshake(SSLSocketImpl.java:1181)\n"
      "\tat sun.net.www.protocol.https.HttpsClient.afterConnect(HttpsClient.java:434)\n"
      "\tat sun.net.www.protocol.https.AbstractDelegateHttpsURLConnection.connect(AbstractDelegateHttpsURLConnection.java:166)\n"
      "\tat sun.net.www.protocol.http.HttpURLConnection.getOutputStream(HttpURLConnection.java:1014)\n"
      "\tat sun.net.www.protocol.https.HttpsURLConnectionImpl.getOutputStream(HttpsURLConnectionImpl.java:230)\n"
      "\tat Autoingestion.main(Autoingestion.java:61)\n"
      "The report you requested is not available at this time.  Please try again in a few minutes.\n";
  NSData *output = [NSData dataWithBytes:bytes length:sizeof bytes - 1];
  AutoingestionResponse *response = [[AutoingestionResponse alloc] initWithOutput:output];
  
  STAssertFalse([response isSuccess], nil);
  STAssertTrue([response isNetworkUnavailable], nil);
  STAssertFalse([response isTryAgainLater], nil);
  STAssertEquals(AutoingestionResponseCodeSocketException, [response code], nil);
  NSString *expectedText = [NSString stringWithCString:bytes
                                              encoding:NSUTF8StringEncoding];
  STAssertEqualObjects(expectedText, [response text], nil);
  
  NSString *expectedSummary = @"java.net.SocketException: Network is down\n"
      "\tThe report you requested is not available at this time.  Please try again in a few minutes.";
  STAssertEqualObjects(expectedSummary, [response summary], nil);
  
  STAssertNil([response filename], nil);
}


- (void)testNotAvailableResponse;
{
  char const bytes[] = "Auto ingestion is not available for this selection.";
  NSData *output = [NSData dataWithBytes:bytes length:sizeof bytes - 1];
  AutoingestionResponse *response = [[AutoingestionResponse alloc] initWithOutput:output];

  STAssertFalse([response isSuccess], nil);
  STAssertFalse([response isNetworkUnavailable], nil);
  STAssertFalse([response isTryAgainLater], nil);
  STAssertEquals(AutoingestionResponseCodeNotAvailable, [response code], nil);
  NSString *expectedText = [NSString stringWithCString:bytes
                                              encoding:NSUTF8StringEncoding];
  STAssertEqualObjects(expectedText, [response text], nil);
  STAssertEqualObjects(expectedText, [response summary], nil);

  STAssertNil([response filename], nil);
}


- (void)testDailyReportDataOutOfRangeResponse;
{
  char const bytes[] =
      "Daily reports are available only for past 14 days, please enter a date within past 14 days.\n";
  NSData *output = [NSData dataWithBytes:bytes length:sizeof bytes - 1];
  AutoingestionResponse *response = [[AutoingestionResponse alloc] initWithOutput:output];

  STAssertFalse([response isSuccess], nil);
  STAssertFalse([response isNetworkUnavailable], nil);
  STAssertFalse([response isTryAgainLater], nil);
  STAssertEquals(AutoingestionResponseCodeDailyReportDateOutOfRange, [response code], nil);
  NSString *expectedText = [NSString stringWithCString:bytes
                                              encoding:NSUTF8StringEncoding];
  STAssertEqualObjects(expectedText, [response text], nil);
  
  NSString *expectedSummary =
      @"Daily reports are available only for past 14 days, please enter a date within past 14 days.";
  STAssertEqualObjects(expectedSummary, [response summary], nil);

  STAssertNil([response filename], nil);
}


- (void)testWeeklyReportDataOutOfRangeResponse;
{
  char const bytes[] =
      "Weekly reports are available only for past 13 weeks, please enter a weekend date within past 13 weeks.\n";
  NSData *output = [NSData dataWithBytes:bytes length:sizeof bytes - 1];
  AutoingestionResponse *response = [[AutoingestionResponse alloc] initWithOutput:output];

  STAssertFalse([response isSuccess], nil);
  STAssertFalse([response isNetworkUnavailable], nil);
  STAssertFalse([response isTryAgainLater], nil);
  STAssertEquals(AutoingestionResponseCodeWeeklyReportDateOutOfRange, [response code], nil);
  NSString *expectedText = [NSString stringWithCString:bytes
                                              encoding:NSUTF8StringEncoding];
  STAssertEqualObjects(expectedText, [response text], nil);
  
  NSString *expectedSummary =
      @"Weekly reports are available only for past 13 weeks, please enter a weekend date within past 13 weeks.";
  STAssertEqualObjects(expectedSummary, [response summary], nil);
}


- (void)testMonthlyReportDataOutOfRangeResponse;
{
  char const bytes[] =
      "Monthly reports are available only for past 12 months, please enter a month within past 12 months.\n";
  NSData *output = [NSData dataWithBytes:bytes length:sizeof bytes - 1];
  AutoingestionResponse *response = [[AutoingestionResponse alloc] initWithOutput:output];
  
  STAssertFalse([response isSuccess], nil);
  STAssertFalse([response isNetworkUnavailable], nil);
  STAssertFalse([response isTryAgainLater], nil);
  STAssertEquals(AutoingestionResponseCodeMonthlyReportDateOutOfRange, [response code], nil);
  NSString *expectedText = [NSString stringWithCString:bytes
                                              encoding:NSUTF8StringEncoding];
  STAssertEqualObjects(expectedText, [response text], nil);
  
  NSString *expectedSummary =
      @"Monthly reports are available only for past 12 months, please enter a month within past 12 months.";
  STAssertEqualObjects(expectedSummary, [response summary], nil);
}


- (void)testYearlyReportDataOutOfRangeResponse;
{
  char const bytes[] = "Please enter a valid year.\n";
  NSData *output = [NSData dataWithBytes:bytes length:sizeof bytes - 1];
  AutoingestionResponse *response = [[AutoingestionResponse alloc] initWithOutput:output];
  
  STAssertFalse([response isSuccess], nil);
  STAssertFalse([response isNetworkUnavailable], nil);
  STAssertFalse([response isTryAgainLater], nil);
  STAssertEquals(AutoingestionResponseCodeYearlyReportDateOutOfRange, [response code], nil);
  NSString *expectedText = [NSString stringWithCString:bytes
                                              encoding:NSUTF8StringEncoding];
  STAssertEqualObjects(expectedText, [response text], nil);
  
  NSString *expectedSummary = @"Please enter a valid year.";
  STAssertEqualObjects(expectedSummary, [response summary], nil);
}


@end
