#import "PRHVerbalExpression.h"

@implementation PRHVerbalExpression
{
	NSMutableString *_regexString;
}

- (id) init {
	if ((self = [super init])) {
		_regexString = [[NSMutableString alloc] init];
	}
	return self;
}

- (NSString *) description {
	return [NSString stringWithFormat:@"<%@ %p /%@/%@>",
		NSStringFromClass(self.class), (__bridge void *)self,
		_regexString,
		[self regularExpressionOptionsDescription]
	];
}

- (NSString *) regularExpressionOptionsDescription {
	NSMutableString *mutableString = [NSMutableString stringWithCapacity:2U];
	if (self.caseInsensitive)
		[mutableString appendString:@"i"];
	if (self.matchesLineSeparators)
		[mutableString appendString:@"m"];
	return [mutableString copy];
}

- (NSString *) source {
	return [_regexString copy];
}

+ (NSSet *) keyPathsForValuesAffectingRegularExpression {
	return [[self keyPathsForValuesAffectingRegularExpressionOptions] setByAddingObject:@"regularExpressionOptions"];
}
- (NSRegularExpression *) regularExpression {
	return [NSRegularExpression regularExpressionWithPattern:_regexString
	                                                 options:[self regularExpressionOptions]
		                                               error:NULL];
}

+ (NSSet *) keyPathsForValuesAffectingRegularExpressionOptions {
	return [NSSet setWithArray:@[ @"matchesLineSeparators", @"caseInsensitive" ]];
}
- (NSRegularExpressionOptions) regularExpressionOptions {
	return (NSRegularExpressionOptions)(
		self.matchesLineSeparators ? NSRegularExpressionDotMatchesLineSeparators : 0
		| self.caseInsensitive ? NSRegularExpressionCaseInsensitive : 0
	);
}

- (bool) matchesString:(NSString *)str {
	__block bool matched = false;
	[self enumerateMatchesInString:str
		usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop)
		{
			matched = true;
			*stop = YES;
		}
	];
	return matched;
}

- (NSArray *) allMatchesInString:(NSString *)str {
	NSMutableArray *allMatches = [[NSMutableArray alloc] init];
	[self enumerateMatchesInString:str
		usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop)
		{
			[allMatches addObject:result];
		}
	];
	return [allMatches copy];
}

- (void) enumerateMatchesInString:(NSString *)str
                       usingBlock:(void (^)(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop))block {
	return [self enumerateMatchesInString:str
		options:0
		range:(NSRange){ 0, str.length }
		usingBlock:block];
}

- (void) enumerateMatchesInString:(NSString *)str
	options:(NSMatchingOptions)options
	range:(NSRange)range
	usingBlock:(void (^)(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop))block
{
	return [self.regularExpression enumerateMatchesInString:str
		options:options
		range:range
		usingBlock:block];
}

@end

@implementation PRHVerbalExpression (RegularExpressionComponents)

- (NSString *) patternStringFromSubpattern:(id)stringOrVerbalExpression {
	return [stringOrVerbalExpression respondsToSelector:@selector(source)]
		? [stringOrVerbalExpression source]
		: stringOrVerbalExpression;
}

- (instancetype) startOfLine {
	if ( ! [_regexString hasPrefix:@"^"])
		[_regexString insertString:@"^" atIndex:0];
	return self;
}

- (instancetype) endOfLine {
	if ( ! [_regexString hasSuffix:@"$"])
		[_regexString appendString:@"$"];
	return self;
}

- (instancetype) then:(NSString *)literalString {
	[_regexString appendString:[NSRegularExpression escapedPatternForString:literalString]];
	return self;
}

- (instancetype) find:(NSString *)literalString {
	return [self then:literalString];
}

- (void) appendNonCapturingGroupWithSubpattern:(id)literalStringOrVerbalExpression repeatString:(NSString *)repeatString {
	NSString *literalString = [self patternStringFromSubpattern:literalStringOrVerbalExpression];
	[_regexString appendFormat:@"(?:%@)%@", literalString, repeatString];
}

- (instancetype) maybe:(id)literalStringOrVerbalExpression {
	[self appendNonCapturingGroupWithSubpattern:literalStringOrVerbalExpression repeatString:@"?"];
	return self;
}

- (instancetype) zeroOrMoreOf:(id)literalStringOrVerbalExpression {
	[self appendNonCapturingGroupWithSubpattern:literalStringOrVerbalExpression repeatString:@"*"];
	return self;
}

- (instancetype) oneOrMoreOf:(id)literalStringOrVerbalExpression {
	[self appendNonCapturingGroupWithSubpattern:literalStringOrVerbalExpression repeatString:@"+"];
	return self;
}

- (instancetype) atLeast:(NSUInteger)min
           butNoMoreThan:(NSUInteger)max
            ofExpression:(id)literalStringOrVerbalExpression
{
	NSString *repeatString = [NSString stringWithFormat:@"{%lu,%lu}", min, max];
	[self appendNonCapturingGroupWithSubpattern:literalStringOrVerbalExpression repeatString:repeatString];
	return self;
}

- (instancetype) group:(id)literalStringOrVerbalExpression {
	[_regexString appendFormat:@"(%@)", [self patternStringFromSubpattern:literalStringOrVerbalExpression]];
	return self;
}

- (instancetype) nonCapturingGroup:(id)literalStringOrVerbalExpression {
	[_regexString appendFormat:@"(?:%@)", [self patternStringFromSubpattern:literalStringOrVerbalExpression]];
	return self;
}

- (instancetype) anything {
	[_regexString appendFormat:@"(?:.*)"];
	return self;
}

- (instancetype) anythingBut:(NSString *)literalStringOfCharacters {
	[_regexString appendFormat:@"(?:[^%@]*)", [self patternStringFromSubpattern:literalStringOfCharacters]];
	return self;
}

- (instancetype) something {
	[_regexString appendFormat:@"(?:.+)"];
	return self;
}

- (instancetype) somethingBut:(NSString *)literalStringOfCharacters {
	[_regexString appendFormat:@"(?:[^%@]+)", [self patternStringFromSubpattern:literalStringOfCharacters]];
	return self;
}

- (instancetype) anyOf:(NSString *)literalStringOfCharacters {
	[_regexString appendFormat:@"(?:[%@])", [self patternStringFromSubpattern:literalStringOfCharacters]];
	return self;
}

- (instancetype) any:(NSString *)literalStringOfCharacters {
	return [self anyOf:literalStringOfCharacters];
}

- (instancetype) lineBreak {
	return self;
}

- (instancetype) br {
	return [self lineBreak];
}

- (instancetype) characterClassWithRangeFrom:(unichar)from to:(unichar)to {
	NSString *fromString = [self stringForClassFromCharacter:from];
	NSString *toString = [self stringForClassFromCharacter:to];
	[_regexString appendFormat:@"[%@-%@]", fromString, toString];
	return self;
}

- (instancetype) extendCharacterClassWithRangeFrom:(unichar)from to:(unichar)to {
	return self;
}

- (instancetype) characterClassWithCharacter:(unichar)ch {
	return self;
}

- (instancetype) extendCharacterClassWithCharacter:(unichar)ch {
	return self;
}

- (NSString *) stringForClassFromCharacter:(unichar)ch {
	return [NSRegularExpression escapedPatternForString:[NSString stringWithFormat:@"%C", ch]];
}

- (instancetype) tab {
	[_regexString appendString:@"\\t"];
	return self;
}

- (instancetype) wordCharacter {
	[_regexString appendString:@"\\w"];
	return self;
}

- (instancetype) withAnyCase {
	self.caseInsensitive = true;
	return self;
}

- (instancetype) searchOneLine {
	self.matchesLineSeparators = false;
	return self;
}
- (instancetype) searchMultipleLines {
	self.matchesLineSeparators = true;
	return self;
}

- (instancetype) add:(NSString *)regexString {
	[self willChangeValueForKey:@"regularExpression"];
	[_regexString appendString:regexString];
	[self didChangeValueForKey:@"regularExpression"];
	return self;
}

- (instancetype) or {
	return [self add:@"|"];
}

@end
