//
//  Completion.m
//  TeXtended
//
//  Created by Tobias Mende on 18.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "Completion.h"
#import "Constants.h"
#import "EditorPlaceholder.h"
#import "CompletionManager.h"
#import <TMTHelperCollection/TMTLog.h>

LOGGING_DEFAULT_DYNAMIC

static const NSRegularExpression *PLACEHOLDER_REGEX;

@implementation Completion

    + (void)initialize
    {
        LOGGING_LOAD
        NSError *error;
        PLACEHOLDER_REGEX = [NSRegularExpression regularExpressionWithPattern:@"@@[^@@]*@@" options:NSRegularExpressionCaseInsensitive error:&error];
        if (error) {
            DDLogError(@"Regex Error");
        }

    }


    - (id)initWithInsertion:(NSString *)insertion
    {
        return [self initWithInsertion:insertion andExtension:@""];
    }

    - (id)initWithInsertion:(NSString *)insertion andExtension:(NSString *)extension
    {
        self = [super init];
        if (self) {
            _insertion = insertion;
            _extension = extension;
        }
        return self;
    }

    - (id)init
    {
        return [self initWithInsertion:@"" andExtension:@""];
    }


    - (id)initWithDictionary:(NSDictionary *)dict
    {
        NSString *insertion = dict[TMTCompletionInsertionKey];
        NSString *extension = dict[TMTCompletionExtensionKey];
        NSString *counter = dict[TMTCompletionCounterKey];
        if (extension) {
            self = [self initWithInsertion:insertion andExtension:extension];
        } else {
            self = [self initWithInsertion:insertion];
        }
        if (self && counter) {
            self.counter = (NSUInteger)[counter integerValue];
        }
        return self;
    }


    - (NSString *)description
    {
        return [NSString stringWithFormat:@"Completion: %@ hasPlaceholders: %@", self.insertion, @(self.hasPlaceholders)];
    }


#pragma mark -
#pragma mark Getter & Setter

    - (BOOL)hasExtension
    {
        return self.extension && self.extension.length > 0;
    }

    - (BOOL)hasPlaceholders
    {
        return [self stringContainsPlaceholders:self.extension];
    }

    - (BOOL)stringContainsPlaceholders:(NSString *)string
    {
        NSArray *matches = [PLACEHOLDER_REGEX matchesInString:string options:0 range:NSMakeRange(0, string.length)];
        return matches.count > 0;
    }


    - (NSString *)key
    {
        return [NSString stringWithFormat:@"%@%@", self.insertion, self.extension];
    }


    + (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key
    {
        NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
        if ([key isEqualToString:@"key"]) {
            keyPaths = [keyPaths setByAddingObjectsFromSet:[NSSet setWithObjects:@"insertion", @"extension", nil]];
        }
        return keyPaths;
    }

    - (NSAttributedString *)substitutePlaceholdersInString:(NSString *)string
    {
        NSMutableAttributedString *extension = [[NSMutableAttributedString alloc] initWithString:string];
        if (self.hasPlaceholders) {
            NSArray *matches = [PLACEHOLDER_REGEX matchesInString:string options:0 range:NSMakeRange(0, string.length)];
            NSInteger offset = 0;
            for (NSTextCheckingResult *match in matches) {
                NSRange range = [match range];
                NSRange final = NSMakeRange(range.location + 2, range.length - 4);
                NSString *title = [string substringWithRange:final];
                NSAttributedString *placeholder = [EditorPlaceholder placeholderAsAttributedStringWithName:title];
                NSRange newRange = NSMakeRange(range.location + offset, range.length);
                [extension replaceCharactersInRange:newRange withAttributedString:placeholder];
                offset += placeholder.length - range.length;


            }
        }
        return extension;
    }


    + (NSString *)substitutePlaceholdersInString:(NSString *)string withString:(NSString *)substitution
    {
        NSMutableString *result = string.mutableCopy;
        NSArray *matches = [PLACEHOLDER_REGEX matchesInString:result options:0 range:NSMakeRange(0, result.length)];
        NSInteger offset = 0;
        for (NSTextCheckingResult *match in matches.reverseObjectEnumerator) {
            NSRange range = [match range];
            NSRange final = NSMakeRange(range.location + 2, range.length - 4);
            NSString *title = [string substringWithRange:final];
            NSAttributedString *placeholder = [EditorPlaceholder placeholderAsAttributedStringWithName:title];
            NSRange newRange = NSMakeRange(range.location + offset, range.length);
            [result replaceCharactersInRange:newRange withString:substitution];
            offset += placeholder.length - range.length;


        }
        return result;
    }


    - (NSAttributedString *)substitutedExtension
    {

        return [self substitutePlaceholdersInString:self.extension];
    }

    - (NSString *)prefix
    {
        NSTextCheckingResult *match = [PLACEHOLDER_REGEX firstMatchInString:self.key options:0 range:NSMakeRange(0, self.key.length)];
        if (!match || match.range.location == NSNotFound) {
            return self.key;
        } else {
            NSUInteger location = match.range.location;
            if (location > 0 && [[CompletionManager specialSymbols] containsObject:[self.key substringWithRange:NSMakeRange(location - 1, 1)]]) {
                location--;
            }
            return [self.key substringToIndex:location];
        }
    }

    - (NSComparisonResult)compare:(Completion *)other
    {
        if (self.counter > other.counter) {
            return NSOrderedAscending;
        } else if (self.counter < other.counter) {
            return NSOrderedDescending;
        }
        return [self.insertion caseInsensitiveCompare:other.insertion];
    }


#pragma mark -
#pragma mark NSCoding Protocol
    - (id)initWithCoder:(NSCoder *)aDecoder
    {
        self = [super init];
        if (self) {
            _insertion = [aDecoder decodeObjectForKey:TMTCompletionInsertionKey];
            _extension = [aDecoder decodeObjectForKey:TMTCompletionExtensionKey];
            _counter = (NSUInteger)[aDecoder decodeIntegerForKey:TMTCompletionCounterKey];
        }
        return self;
    }


    - (void)encodeWithCoder:(NSCoder *)aCoder
    {
        [aCoder encodeObject:self.insertion forKey:TMTCompletionInsertionKey];
        [aCoder encodeObject:self.extension forKey:TMTCompletionExtensionKey];
        [aCoder encodeInteger:(NSInteger)self.counter forKey:TMTCompletionCounterKey];
    }


    - (NSMutableDictionary *)dictionaryRepresentation
    {
        return [NSMutableDictionary dictionaryWithObjectsAndKeys:self.insertion, TMTCompletionInsertionKey, self.extension, TMTCompletionExtensionKey, [NSNumber numberWithUnsignedInteger:self.counter], TMTCompletionCounterKey, nil];

    }


    - (NSUInteger)hash
    {
        return [[self key] hash];
    }

    - (BOOL)isEqual:(id)object
    {
        if ([object isKindOfClass:[Completion class]]) {
            Completion *other = (Completion *) object;

            return [self.key isEqualToString:[other key]];
        }
        return false;
    }

    - (NSString *)autoCompletionWord
    {
        return self.insertion;
    }


@end
