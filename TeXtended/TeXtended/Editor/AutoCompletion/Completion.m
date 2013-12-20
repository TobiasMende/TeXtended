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
static const NSRegularExpression *PLACEHOLDER_REGEX;
@implementation Completion

+ (void)initialize {
    NSError *error;
    PLACEHOLDER_REGEX = [NSRegularExpression regularExpressionWithPattern:@"@@[^@@]*@@" options:NSRegularExpressionCaseInsensitive error:&error];
    if (error) {
        DDLogError(@"Regex Error");
    }
    
}

- (id)initWithInsertion:(NSString *)insertion {
    return [self initWithInsertion:insertion containingPlaceholders:NO];
}

- (id)initWithInsertion:(NSString *)insertion containingPlaceholders:(BOOL)flag {
    return [self initWithInsertion:insertion containingPlaceholders:flag andExtension:@""];
}

- (id)initWithInsertion:(NSString *) insertion containingPlaceholders :(BOOL)flag andExtension:(NSString *)extension {
    self = [super init];
    if (self) {
        _insertion = insertion;
        _hasPlaceholders = flag;
        _extension = extension;
    }
return self;
}

- (id)init {
    return [self initWithInsertion:@"" containingPlaceholders:YES andExtension:@""];
}


- (id)initWithDictionary:(NSDictionary *)dict {
    NSString *insertion = dict[TMTCompletionInsertionKey];
    BOOL hasPlaceholders = [dict[TMTCompletionHasPlaceholdersKey] boolValue];
    NSString *extension = dict[TMTCompletionExtensionKey];
    NSString *counter = dict[TMTCompletionCounterKey];
    if (extension) {
        self = [self initWithInsertion:insertion containingPlaceholders:hasPlaceholders andExtension:extension];
    } else {
        self = [self initWithInsertion:insertion containingPlaceholders:hasPlaceholders];
    }
    if (self && counter) {
        self.counter = [counter integerValue];
    }
    return self;
}



- (NSString *)description {
    return [NSString stringWithFormat:@"Completion: %@ hasPlaceholders: %@", self.insertion, @(self.hasPlaceholders)];
}


#pragma mark -
#pragma mark Getter & Setter

- (BOOL)hasExtension {
    return self.extension && self.extension.length > 0;
}


-(NSString *)key {
    return [NSString stringWithFormat:@"%@%@", self.insertion, self.extension];
}


+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
    NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
    if ([key isEqualToString:@"key"]) {
        keyPaths = [keyPaths setByAddingObjectsFromSet:[NSSet setWithObjects:@"insertion",@"extension", nil]];
    }
    return keyPaths;
}

- (NSAttributedString *)substitutePlaceholdersInString:(NSString *)string {
    NSMutableAttributedString *extension = [[NSMutableAttributedString alloc] initWithString:string];
    if (self.hasPlaceholders) {
        NSArray *matches = [PLACEHOLDER_REGEX matchesInString:string options:0 range:NSMakeRange(0, string.length)];
        NSInteger offset = 0;
        for (NSTextCheckingResult *match in matches) {
            NSRange range = [match range];
            NSRange final = NSMakeRange(range.location+2, range.length-4);
            NSString *title = [string substringWithRange:final];
            NSAttributedString *placeholder = [EditorPlaceholder placeholderAsAttributedStringWithName:title];
            NSRange newRange = NSMakeRange(range.location+offset, range.length);
            [extension replaceCharactersInRange:newRange withAttributedString:placeholder];
            offset += placeholder.length - range.length;
            
            
        }
    }
    return extension;
}

- (NSAttributedString *)substitutedExtension {
    
    return [self substitutePlaceholdersInString:self.extension];
}

- (NSString *)prefix {
    NSTextCheckingResult *match = [PLACEHOLDER_REGEX firstMatchInString:self.key options:0 range:NSMakeRange(0, self.key.length)];
    if (!match || match.range.location == NSNotFound) {
        return self.key;
    } else {
        NSUInteger location = match.range.location;
        if (location > 0 && [[CompletionManager specialSymbols] containsObject:[self.key substringWithRange:NSMakeRange(location-1, 1)]]) {
            location--;
        }
        return [self.key substringToIndex:location];
    }
}

- (NSComparisonResult)compare:(Completion *)other {
        if (self.counter > other.counter) {
            return NSOrderedAscending;
        } else if (self.counter < other.counter) {
            return NSOrderedDescending;
        }
    return [self.insertion caseInsensitiveCompare:other.insertion];
}


#pragma mark -
#pragma mark NSCoding Protocol
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _insertion = [aDecoder decodeObjectForKey:TMTCompletionInsertionKey];
        _extension = [aDecoder decodeObjectForKey:TMTCompletionExtensionKey];
        _hasPlaceholders = [aDecoder decodeBoolForKey:TMTCompletionHasPlaceholdersKey];
        _counter = [aDecoder decodeIntegerForKey:TMTCompletionCounterKey];
    }
    return self;
}


- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.insertion forKey:TMTCompletionInsertionKey];
    [aCoder encodeObject:self.extension forKey:TMTCompletionExtensionKey];
    [aCoder encodeBool:self.hasPlaceholders forKey:TMTCompletionHasPlaceholdersKey];
    [aCoder encodeInteger:self.counter forKey:TMTCompletionCounterKey];
}



- (NSMutableDictionary *)dictionaryRepresentation {
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:self.insertion,TMTCompletionInsertionKey,@(self.hasPlaceholders),TMTCompletionHasPlaceholdersKey, self.extension, TMTCompletionExtensionKey, [NSNumber numberWithInteger:self.counter],TMTCompletionCounterKey, nil];

}


- (NSUInteger)hash {
    return [[self key] hash];
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[Completion class]]) {
        Completion *other = (Completion *)object;
        
        return [self.key isEqualToString:[other key]];
    }
    return false;
}

- (NSString *)autoCompletionWord {
    return self.insertion;
}


@end
