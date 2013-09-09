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

- (void) testMatchGroup {
	NSString *patternPart1 = @"Hello ";
	NSString *patternPart2 = @"*\n one two three yes \n*";
	NSString *patternPart3 = @" Goodbye";

	PRHVerbalExpression *innerExpression = [PRHVerbalExpression new];
	[innerExpression find:patternPart2];

	PRHVerbalExpression *verbalExpression = [[[[
		[PRHVerbalExpression new]
		searchMultipleLines]
		find:patternPart1]
		group:innerExpression]
		then:patternPart3];

	NSMutableString *entireString = [NSMutableString stringWithCapacity:patternPart1.length + patternPart2.length + patternPart3.length];
	[entireString appendString:patternPart1];
	[entireString appendString:patternPart2];
	[entireString appendString:patternPart3];

	STAssertTrue([verbalExpression matchesString:entireString], @"Pattern %@ that contains a group %@ should match all parts of the string", verbalExpression, innerExpression);
	__block NSUInteger numMatches = 0;
	[verbalExpression enumerateMatchesInString:entireString usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		++numMatches;
		NSRange groupRange = [result rangeAtIndex:1];
		NSString *groupMatchString = [entireString substringWithRange:groupRange];
		STAssertEqualObjects(groupMatchString, patternPart2, @"Capturing group did not capture the correct text");
	}];
	STAssertEquals(numMatches, (NSUInteger)1UL, @"enumerateMatchesInString:: enumerated a strange number of matches");
}
- (void) testMatchNonCapturingGroup {
	NSString *patternPart1 = @"Hello ";
	NSString *patternPart2 = @"*\n one two three yes \n*";
	NSString *patternPart3 = @" Goodbye";

	PRHVerbalExpression *innerExpression = [PRHVerbalExpression new];
	[innerExpression find:patternPart2];

	PRHVerbalExpression *verbalExpression = [[[[
		[PRHVerbalExpression new]
		searchMultipleLines]
		find:patternPart1]
		nonCapturingGroup:innerExpression]
		then:patternPart3];

	NSMutableString *entireString = [NSMutableString stringWithCapacity:patternPart1.length + patternPart2.length + patternPart3.length];
	[entireString appendString:patternPart1];
	[entireString appendString:patternPart2];
	[entireString appendString:patternPart3];

	STAssertTrue([verbalExpression matchesString:entireString], @"Pattern %@ that contains a non-capturing group should match all parts of the string", verbalExpression);
}

@end
