#import "VerbalExpressionsNonMatchingTests.h"
#import "PRHVerbalExpression.h"

@implementation VerbalExpressionsNonMatchingTests

- (void) testMatchNonEmptyPatternAgainstEmptyString {
	PRHVerbalExpression *verbalExpression = [[PRHVerbalExpression new] find:@"foo"];

	STAssertFalse([verbalExpression matchesString:@""], @"Non-empty pattern with required atom(s) should not match empty string");
}

- (void) testMatchEmptyPatternAgainstEmptyString {
	PRHVerbalExpression *verbalExpression = [PRHVerbalExpression new];

	STAssertFalse([verbalExpression matchesString:@"foo"], @"Empty pattern should not match non-empty string");
}

- (void) testMatchSubstringThatIsRequiredAsPrefix {
	PRHVerbalExpression *verbalExpression = [[[PRHVerbalExpression new]
		startOfLine]
		find:@"Earth"];

	STAssertFalse([verbalExpression matchesString:@"People of Earth!"], @"Pattern that requires a prefix should not match the prefix anywhere else in the string");
}

- (void) testMatchSubstringThatIsRequiredAsSuffix {
	PRHVerbalExpression *verbalExpression = [[[PRHVerbalExpression new]
		endOfLine]
		find:@"Earth"];

	STAssertFalse([verbalExpression matchesString:@"People of Earth!"], @"Pattern that requires a suffix should not match the suffix anywhere else in the string");
}

- (void) testMatchSubstringBrokenAcrossMultipleLines {
	NSString *patternPart1 = @"Earth!";
	NSString *patternPart2 = @"Your attention";
	PRHVerbalExpression *verbalExpression = [[[
		[PRHVerbalExpression new]
		find:patternPart1]
		anything]
		then:patternPart2];

	NSString *line1 = [@"People of " stringByAppendingString:patternPart1];
	NSString *line2 = [patternPart2 stringByAppendingString:@" please!"];
	NSString *entireString = [NSString stringWithFormat:@"%@\n%@", line1, line2];

	STAssertFalse([verbalExpression matchesString:entireString], @"Pattern that spans a line-break in the string should not match when search multiple lines is off");
}

@end
