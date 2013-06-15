//
//  BracketHighlighter.m
//  SimpleSyntaxHighlightingTest
//
//  Created by Tobias Mende on 10.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "BracketHighlighter.h"
#import "NSString+LatexExtension.h"
#import "HighlightingTextView.h"
#import "Constants.h"
#import "UndoSupport.h"
static const NSDictionary *BRACKETS_TO_HIGHLIGHT;
static const NSArray *VALID_PRE_CHARS;
static const NSSet *KEYS_TO_UNBIND;
typedef enum {
    TMTOpeningBracketType,
    TMTClosingBracketType,
    TMTNoBracketType
} TMTBracketType;

@interface BracketHighlighter ()
- (void) unbindAll;
@end

@implementation BracketHighlighter


-(id)initWithTextView:(HighlightingTextView *)tv {
    self = [super initWithTextView:tv];
    if(self) {
        NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
        self.shouldHighlightMatchingBrackets = [[[defaults values] valueForKey:TMT_SHOULD_HIGHLIGHT_MATCHING_BRACKETS] boolValue];
        [self bind:@"shouldHighlightMatchingBrackets" toObject:defaults withKeyPath:[@"values." stringByAppendingString:TMT_SHOULD_HIGHLIGHT_MATCHING_BRACKETS] options:NULL];
        
        self.shouldAutoInsertClosingBrackets = [[[defaults values] valueForKey:TMT_SHOULD_AUTO_INSERT_CLOSING_BRACKETS] boolValue];
        [self bind:@"shouldAutoInsertClosingBrackets" toObject:defaults withKeyPath:[@"values." stringByAppendingString:TMT_SHOULD_AUTO_INSERT_CLOSING_BRACKETS] options:NULL];
    }
    return self;
}


+ (void)initialize {
    BRACKETS_TO_HIGHLIGHT = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"}",@"{",
                             @")",@"(",
                             @"]",@"[",
                             nil];
    VALID_PRE_CHARS = [NSArray arrayWithObject:@"\\"];
    KEYS_TO_UNBIND = [NSSet setWithObjects:@"shouldHighlightMatchingBrackets", @"shouldAutoInsertClosingBrackets" , nil];
    
}

- (void)highlightOnMoveLeft {
    NSUInteger insertionPoint = [view selectedRange].location;
    if (view.string.length == 0) {
        return;
    }
    NSString* last = [NSString stringWithFormat:@"%C",[[[view textStorage] string] characterAtIndex:insertionPoint]];
    // Needed for correct bracket detection.
    [self highlightBracketWithInsertion:last andPosition:insertionPoint+1];
}

- (void)highlightOnMoveRight {
    NSUInteger insertionPoint = [view selectedRange].location;
    if (view.string.length == 0) {
        return;
    }
    NSString* last = [NSString stringWithFormat:@"%C",[[[view textStorage] string] characterAtIndex:insertionPoint-1]];
    [self highlightOnInsertWithInsertion:last];
}

- (NSArray*)highlightOnInsertWithInsertion:(NSString *)str {
        NSUInteger insertionPoint = [view selectedRange].location;
    if (str.length>1) {
        str = [str substringFromIndex:str.length-1];
    }
        return [self highlightBracketWithInsertion:str andPosition:insertionPoint];
}


- (void)handleBracketsOnInsertWithInsertion:(NSString *)str{
    // Call the highlighting algorithm to find matching brackets
    NSArray *ranges =[self highlightOnInsertWithInsertion:str];
    //If no matching brackets where found: insert pendant
    if(!ranges) {
        lastAutoinsert = [NSDate new];
        [self autoInsertMatchingBracket:str];
    }

}

-(BOOL)shouldInsert:(NSString *)str {
    if (![self stringIsBracket:str]) {
        return YES;
    }
    if(lastAutoinsert && lastAutoinsert.timeIntervalSinceNow > -0.5 && [self bracketTypeForString:str] == TMTClosingBracketType ) {
        [self highlightOnInsertWithInsertion:[view.string substringWithRange:NSMakeRange(view.selectedRange.location-1, 1)]];
        return NO;
    }
    lastAutoinsert = nil;
    return YES;
}


- (void)autoInsertMatchingBracket:(NSString*) bracket {
    if ([self bracketTypeForString:bracket] != TMTOpeningBracketType || !self.shouldAutoInsertClosingBrackets   ) {
        //should not auto insert or the string is not an opening bracket.
        return;
    }
    NSUInteger insertionPoint = [view selectedRange].location;
    //Get the prechared bracket:
    NSString* extOpeningBracket = [self extendedBracketForBracket:bracket atPosition:insertionPoint];
    NSString* closingBracket = [self pendantForBracket:bracket ofType:TMTOpeningBracketType];
    NSString* extClosingBracket = [NSString stringWithString:closingBracket];
    if(extOpeningBracket.length > bracket.length) {
        //if the opening bracket has been extended, also extend the closing one.
        NSString *preChar = [self charBeforeCurrentBracketWithPosition:insertionPoint];
        extClosingBracket = [preChar stringByAppendingString:closingBracket];
    }
    
    //insert the closing bracket and reset cursor to current insertion point
    [view.undoSupport insertString:extClosingBracket atIndex:insertionPoint withActionName:NSLocalizedString(@"Autoinsert Matching Bracket", "Autoinsert Matching Bracket")];
    [view setSelectedRange:NSMakeRange(insertionPoint, 0)];
}

- (NSArray*)highlightBracketWithInsertion:(NSString *)str andPosition:(NSUInteger) pos{
    NSLayoutManager *lm = [view layoutManager];
    NSRect visibleArea = [view visibleRect];
    NSRange visibleGlyphRange = [lm glyphRangeForBoundingRect:visibleArea inTextContainer:view.textContainer];
    NSRange range = [lm characterRangeForGlyphRange:visibleGlyphRange actualGlyphRange:NULL];
    NSArray *rangesToHighlight = [self findMatchingBracketFor:str withStart:pos inRange:range];
    if (rangesToHighlight && self.shouldHighlightMatchingBrackets) {
        for(NSValue *rv in rangesToHighlight) {
            [view showFindIndicatorForRange:[rv rangeValue]];
        }
    }
    return rangesToHighlight;
    
}

- (NSArray *)findMatchingBracketFor:(NSString *)bracket
                          withStart:(NSUInteger)position inRange:(NSRange)range {
    if (position > view.string.length) {
        NSLog(@"invalid position");
        return nil;
    }
    TMTBracketType type = [self bracketTypeForString:bracket];
    if(type == TMTNoBracketType) {
        return nil;
    }
    return [self findMatchingBracketFor:bracket withType:type withPosition:position inRange:range];
}

#pragma mark -
#pragma mark Private Methods

- (NSString*) charBeforeCurrentBracketWithPosition:(NSUInteger)pos {
    if(pos > 1 && pos <= view.string.length) {
        return [NSString stringWithFormat:@"%C",[[[view textStorage] string] characterAtIndex:pos-2]];
    } else {
        return @"";
    }
}


- (NSString*) extendedBracketForBracket:(NSString*) bracket atPosition:(NSUInteger) pos{
    NSString *preChar = [self charBeforeCurrentBracketWithPosition:pos];
    if([VALID_PRE_CHARS containsObject:preChar] && (![view.string numberOfBackslashesBeforePositionIsEven:pos-1])) {
        // Extend the bracket if length is longer than one.
        return [NSString stringWithFormat:@"%@%@",preChar,bracket];
    }
    return bracket;
}


- (NSArray *) findMatchingBracketFor:(NSString *) str
                            withType:(TMTBracketType) type
                        withPosition:(NSUInteger) pos
                             inRange:(NSRange) range {

    NSString *pendant = [self pendantForBracket:str ofType:type];
    NSString *preChar = [self charBeforeCurrentBracketWithPosition:pos];
    NSString *first, *second;
    BOOL searchWithPrechar = NO;
    // Are we looking for a special bracket longer than a single sign?
    if([VALID_PRE_CHARS containsObject:preChar] && (![view.string numberOfBackslashesBeforePositionIsEven:pos-1])) {
        // Extend the bracket if length is longer than one.
        first = [NSString stringWithFormat:@"%@%@",preChar,str];
        second = [NSString stringWithFormat:@"%@%@",preChar,pendant];
        searchWithPrechar = YES;
    } else {
        first = [NSString stringWithString:str];
        second = [NSString stringWithString:pendant];
    }
    NSRange firstRange = NSMakeRange(pos-first.length, first.length);
    NSUInteger firstCounter=0;
    NSUInteger currentPosition = pos;
    if(type == TMTClosingBracketType) {
        // If we search backward the starting point must be before the input bracket to prevent wrong unbalancing.
        if(currentPosition >= 2*first.length) {
            currentPosition -= 2*first.length;
        } else {
            currentPosition = 0;
        }
    }
    NSRange compareWindow;
    //NSRange matchingRange;
    while ((type == TMTClosingBracketType && currentPosition >= range.location)
           || (type == TMTOpeningBracketType && currentPosition <= range.location+range.length-first.length)) {
        // As long as there is more text ahead in the current position, move compare window.
        compareWindow = NSMakeRange(currentPosition, first.length);
        NSString *compareString = [view.textStorage.string substringWithRange:compareWindow];
        if (!searchWithPrechar) {
            // In this case, prechared brackets must be ignored. Therefore: Jump over.
            NSString *charBefore = [self charBeforeCurrentBracketWithPosition:currentPosition+1];
            if([VALID_PRE_CHARS containsObject:charBefore] && ![view.string numberOfBackslashesBeforePositionIsEven:currentPosition]) {
                //The Jumping:
                
                
                if(type == TMTClosingBracketType) {
                    if(currentPosition < charBefore.length+1) {
                        break;
                    } else {
                        currentPosition -= charBefore.length+1;
                    }
                } else {
                    currentPosition += charBefore.length;
                }
                continue;
            }
        }
        if ([compareString isEqualToString:first]) {
            // If we have a bracket of the given type: Increment counter.
            firstCounter++;
        } else if(firstCounter > 0 && [compareString isEqualToString:second]) {
            // Matching bracket found: Decrement
            firstCounter--;
        } else if(firstCounter == 0 && [compareString isEqualToString:second]) {
            // Matching bracket found and no unclosed brackets of given type: MATCH
           
            return [NSArray arrayWithObjects:[NSValue valueWithRange:firstRange], [NSValue valueWithRange:compareWindow], nil];
        }
        // Move position pointer:
        if(type == TMTClosingBracketType) {
            if(currentPosition == 0) {
                break;
            } else {
                currentPosition--;
            }
        } else {
            currentPosition++;
        }
    }
    return nil;
    
}




- (NSString *) pendantForBracket:(NSString *) str
                          ofType:(TMTBracketType) type {
    switch (type) {
        case TMTOpeningBracketType:
            return [BRACKETS_TO_HIGHLIGHT valueForKey:str];
            break;
        case TMTClosingBracketType:
            return [[BRACKETS_TO_HIGHLIGHT allKeys]
                    objectAtIndex:[[BRACKETS_TO_HIGHLIGHT allValues]
                                   indexOfObject:str]];
            break;
        default:
            break;
    }
    return nil;
}


- (BOOL) stringIsBracket:(NSString* ) string {
    return [self bracketTypeForString:string] != TMTNoBracketType;
}


- (TMTBracketType) bracketTypeForString:(NSString*) str {
    NSArray *openingBrackets = [BRACKETS_TO_HIGHLIGHT allKeys];
    if([openingBrackets containsObject:str]) {
        return TMTOpeningBracketType;
    }
    NSArray *closingBrackets = [BRACKETS_TO_HIGHLIGHT allValues];
    if ([closingBrackets containsObject:str]) {
        return TMTClosingBracketType;
    }
    return TMTNoBracketType;
}


- (void)dealloc {
#ifdef DEBUG
    NSLog(@"BracketHighlighter dealloc");
#endif
    [self unbindAll];
}

- (void)unbindAll {
    for(NSString *key in KEYS_TO_UNBIND) {
        [self unbind:key];
    }
}
@end
