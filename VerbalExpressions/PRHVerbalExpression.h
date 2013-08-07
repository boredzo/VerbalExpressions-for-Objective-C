#import <Foundation/Foundation.h>

@interface PRHVerbalExpression : NSObject

//Default: Off (case-sensitive)
@property(getter=isCaseInsensitive) bool caseInsensitive;
//Default: On (matches line separators)
@property bool matchesLineSeparators;

@property(nonatomic, readonly) NSString *source;
- (NSRegularExpression *) regularExpression;

- (bool) matchesString:(NSString *)str;
- (NSArray *) allMatchesInString:(NSString *)str;
//Equivalent to the full enumerateMatches…:::: method with options:0.
- (void) enumerateMatchesInString:(NSString *)str usingBlock:(void (^)(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop))block;
- (void) enumerateMatchesInString:(NSString *)str options:(NSMatchingOptions)options range:(NSRange)range usingBlock:(void (^)(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop))block;

@end

@interface PRHVerbalExpression (RegularExpressionComponents)

//All of these methods return self.
//Any method that takes a string takes a *literal* string. There are no special characters here—that would defeat the point.

// ^
- (instancetype) startOfLine;
// $
- (instancetype) endOfLine;

//Appends a sequence of characters to be matched.
- (instancetype) then:(NSString *)literalString;
//Synonym for then:
- (instancetype) find:(NSString *)literalString;

// …?
- (instancetype) maybe:(id)literalStringOrVerbalExpression;
// …*
- (instancetype) zeroOrMoreOf:(id)literalStringOrVerbalExpression;
// …+
- (instancetype) oneOrMoreOf:(id)literalStringOrVerbalExpression;
// …{min,max}
- (instancetype) atLeast:(NSUInteger)min
		   butNoMoreThan:(NSUInteger)max
			ofExpression:(id)literalStringOrVerbalExpression;

// (…)
- (instancetype) group:(id)literalStringOrVerbalExpression;
// (?:…)
- (instancetype) nonCapturingGroup:(id)literalStringOrVerbalExpression;

// zero or more of any character
- (instancetype) anything;
// zero or more of any atom that is not any of these characters (frustratingly, I cannot use NSCharacterSet here)
- (instancetype) anythingBut:(NSString *)literalStringOfCharacters;

// one or more of any character
- (instancetype) something;
// one or more of any atom that is not any of these characters (frustratingly, I cannot use NSCharacterSet here)
- (instancetype) somethingBut:(NSString *)literalStringOfCharacters;

// exactly one of any of the characters in this string
- (instancetype) anyOf:(NSString *)literalStringOfCharacters;
//Synonym for anyOf:
- (instancetype) any:(NSString *)literalStringOfCharacters;

//Matches any single line-break (e.g., \n or \r\n).
- (instancetype) lineBreak;
//Synonym for lineBreak
- (instancetype) br;

// Character class range (can be stacked: e.g., rangeFrom:to:from:to:from:to:)
//Corresponds to .range() in original VerbalExpressions
- (instancetype) characterClassWithRangeFrom:(unichar)from to:(unichar)to;
// Extend preceding character class with another range
- (instancetype) extendCharacterClassWithRangeFrom:(unichar)from to:(unichar)to;
- (instancetype) characterClassWithCharacter:(unichar)ch;
- (instancetype) extendCharacterClassWithCharacter:(unichar)ch;

// one tab character (\t)
- (instancetype) tab;
// one of any in-word character (\w)
//Corresponds to .word() in original VerbalExpressions
- (instancetype) wordCharacter;

//Turns on NSRegularExpressionCaseInsensitive (off by default)
- (instancetype) withAnyCase;
//Turns off NSRegularExpressionDotMatchesLineSeparators (on by default)
- (instancetype) searchOneLine;
//Turns on NSRegularExpressionDotMatchesLineSeparators
- (instancetype) searchMultipleLines;

//Append any regex substring to the expression being built.
- (instancetype) add:(NSString *)regexString;
// | (start a new alternative sub-expression)
- (instancetype) or;

@end

