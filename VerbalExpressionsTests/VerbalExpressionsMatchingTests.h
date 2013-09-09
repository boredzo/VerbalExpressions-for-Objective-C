#import <SenTestingKit/SenTestingKit.h>

@interface VerbalExpressionsMatchingTests: SenTestCase

//- (void) testMatchEmptyString;
- (void) testMatchEntireString;
- (void) testMatchSubstring;
- (void) testMatchRequiredPrefix;
- (void) testMatchRequiredSuffix;
- (void) testMatchMultipleLines;

- (void) testMatchGroup;
- (void) testMatchNonCapturingGroup;

- (void) testMatchGroupContainingOr;

@end
