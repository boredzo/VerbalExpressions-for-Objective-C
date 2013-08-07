#import "VerbalExpressionsMatchingTests.h"

#import "PRHVerbalExpression.h"

@implementation VerbalExpressionsMatchingTests


- (void) setUp {
	[super setUp];

	// Set-up code here.
}

- (void) tearDown {
	// Tear-down code here.

	[super tearDown];
}

/*Fails because NSRegularExpression says this isn't a match. TODO: Uncomment this when NSRegularExpression can actually match an empty pattern to an empty string
- (void) testMatchEmptyString {
	PRHVerbalExpression *verbalExpression = [PRHVerbalExpression new];
	STAssertTrue([verbalExpression matchesString:@""], @"Empty pattern should match empty string");
}
*/

- (void) testMatchEntireString {
	NSString *entireString = @"hello";
	PRHVerbalExpression *verbalExpression = [
		[PRHVerbalExpression new]
		find:entireString];
	STAssertTrue([verbalExpression matchesString:entireString], @"Pattern created from string should match the same string");
}

- (void) testMatchSubstring {
	NSString *substring = @"hello";
	NSString *entireString = [NSString stringWithFormat:@"Why, %@ there!", substring];
	PRHVerbalExpression *verbalExpression = [
		[PRHVerbalExpression new]
		find:substring];
	STAssertTrue([verbalExpression matchesString:entireString], @"Pattern that incorporates a substring should match that substring");
}

- (void) testMatchRequiredPrefix {
	NSString *prefix = @"Hello";
	NSString *entireString = [prefix stringByAppendingString:@", people of Earth!"];
	PRHVerbalExpression *verbalExpression = [[
		[PRHVerbalExpression new]
		startOfLine]
		then:prefix];
	STAssertTrue([verbalExpression matchesString:entireString], @"Pattern that requires a prefix should match a string that begins with that prefix");
}

- (void) testMatchRequiredSuffix {
	NSString *suffix = @"Your attention please!";
	NSString *entireString = [@"People of Earth! " stringByAppendingString:suffix];
	PRHVerbalExpression *verbalExpression = [[
		[PRHVerbalExpression new]
		then:suffix]
		endOfLine];
	STAssertTrue([verbalExpression matchesString:entireString], @"Pattern that requires a suffix should match a string that begins with that suffix");
}

- (void) testMatchMultipleLines {
	NSString *patternPart1 = @"Earth!";
	NSString *patternPart2 = @"Your attention";
	PRHVerbalExpression *verbalExpression = [[[[
		[PRHVerbalExpression new]
		searchMultipleLines]
		find:patternPart1]
		anything]
		then:patternPart2];

	NSString *line1 = [@"People of " stringByAppendingString:patternPart1];
	NSString *line2 = [patternPart2 stringByAppendingString:@" please!"];
	NSString *entireString = [NSString stringWithFormat:@"%@\n%@", line1, line2];

	STAssertTrue([verbalExpression matchesString:entireString], @"Pattern that spans a line-break in the string should match when search multiple lines is on");
}

@end
