#import <SenTestingKit/SenTestingKit.h>

@interface VerbalExpressionsNonMatchingTests : SenTestCase

- (void) testMatchNonEmptyPatternAgainstEmptyString;
- (void) testMatchEmptyPatternAgainstEmptyString;
- (void) testMatchSubstringThatIsRequiredAsPrefix;
- (void) testMatchSubstringThatIsRequiredAsSuffix;
// pattern: foo.*bar where .* is \n
- (void) testMatchSubstringBrokenAcrossMultipleLines;

@end
