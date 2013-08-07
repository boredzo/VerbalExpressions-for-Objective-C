# Verbal Expressions for Objective-C
## Regular expression syntax and Objective-C verbosity, together at last

This is an Objective-C implementation of @jehna's [VerbalExpressions](https://github.com/jehna/VerbalExpressions) project. This is an original implementation; I have copied only the method names, nothing more.

### Usage

Create a PRHVerbalExpression, then send messages to it to set options and build up the search pattern. Each option or pattern message returns `self`, so you can stack up a chain of such messages that describe the pattern.

Each PRHVerbalExpression responds to a small suite of matching methods that you can use to apply the pattern to a string.

For example:

    NSString *prefix = @"Hello";
    NSString *suffix = @"Your attention please!";
    NSString *entireString = [NSString stringWithFormat:@"%@, people of Earth!\n%@", prefix, suffix];
    PRHVerbalExpression *expression = [[[[[[[
    	[PRHVerbalExpression new]
    	searchMultipleLines]
    	startOfLine]
    	then:prefix]
    	anything]
    	then:suffix]
    	endOfLine];
    bool match = [expression matchesString:entireString];

Within the header and this documentation, a “literal string” is a string that is not examined for regular expression metacharacters (or, if it is, it is in order to escape them). So, for example, a literal string like `@"[^0-9]"` will match exactly six characters (or not at all): an opening square bracket, a caret, a zero, a hyphen-minus, a nine, and a closing square bracket. It will not match a single character that is not within the range of '0'–'9'.

### Differences

#### Character classes

For character classes, the original JavaScript implementation has a method named `range`, taking two arguments.

This version replaces this with four different methods:

- `characterClassWithRangeFrom:(unichar)from to:(unichar)to`
- `extendCharacterClassWithRangeFrom:(unichar)from to:(unichar)to`
- `characterClassWithCharacter:(unichar)ch`
- `extendCharacterClassWithCharacter:(unichar)ch`

So, for example, a simple expression for formatted numbers might look like:

    [[[
    	[PRHVerbalExpression new]
    	characterClassWithRangeFrom:'0' to:'9']
    	extendCharacterClassWithCharacter:',']
    	extendCharacterClassWithCharacter:'.'];

(This produces the regular expression `[0-9,.]`.)

#### Groups

I've added methods for creating groups:

- `group:(id)literalStringOrVerbalExpression`
- `nonCapturingGroup:(id)literalStringOrVerbalExpression`

Each one takes either a literal string or a PRHVerbalExpression.

#### Multipliers

I've added methods for specifying the minimum and maximum number of times a subexpression must appear consecutively:

- `maybe:(id)literalStringOrVerbalExpression` (`?`)
- `zeroOrMoreOf:(id)literalStringOrVerbalExpression` (`*`)
- `oneOrMoreOf:(id)literalStringOrVerbalExpression` (`+`)
- `atLeast:(NSUInteger)min butNoMoreThan:(NSUInteger)max ofExpression:(id)literalStringOrVerbalExpression` (`{min,max}`)

### Room for improvement

Some of this isn't implemented yet, and most of it is not yet tested. Any method in PRHVerbalExpression that simply returns `self` is not yet implemented.

Additionally, there's room for some of the method names to be made *even more* verbose to conform to typical Objective-C naming conventions.

My original vision for the project was to implement some runtime hackery so that you wouldn't need to nest method calls. I still want to give that a try, although I'm not sure how to handle the no-argument methods (like `startOfLine`/`endOfLine`).

Certain things could be made more robust. For example, if you add anything (except another sub-expression) to the expression after `endOfLine`, you're going to have a bad time. Ideally, most of the methods should replace and re-append the `$` if there is one.

Contributions are very welcome.
