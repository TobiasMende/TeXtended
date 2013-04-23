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
NSRegularExpression *PLACEHOLDER_REGEX;
@implementation Completion

+ (void)initialize {
    NSError *error;
    PLACEHOLDER_REGEX = [NSRegularExpression regularExpressionWithPattern:@"@@[^@@]*@@" options:NSRegularExpressionCaseInsensitive error:&error];
    if (error) {
        NSLog(@"Regex Error");
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
    NSString *insertion = [dict objectForKey:TMTCompletionInsertionKey];
    BOOL hasPlaceholders = [[dict objectForKey:TMTCompletionHasPlaceholdersKey] boolValue];
    NSString *extension = [dict objectForKey:TMTCompletionExtensionKey];
    if (extension) {
        return [self initWithInsertion:insertion containingPlaceholders:hasPlaceholders andExtension:extension];
    }
    return [self initWithInsertion:insertion containingPlaceholders:hasPlaceholders];
}



- (NSString *)description {
    return [NSString stringWithFormat:@"Completion: %@ hasPlaceholders: %@", self.insertion, [NSNumber numberWithBool:self.hasPlaceholders]];
}


#pragma mark -
#pragma mark Getter & Setter

- (BOOL)hasExtension {
    return self.extension && self.extension.length > 0;
}


-(NSString *)key {
    return [NSString stringWithFormat:@"%@%@", self.insertion, self.extension];
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



#pragma mark -
#pragma mark NSCoding Protocol
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _insertion = [aDecoder decodeObjectForKey:TMTCompletionInsertionKey];
        _extension = [aDecoder decodeObjectForKey:TMTCompletionExtensionKey];
        _hasPlaceholders = [aDecoder decodeBoolForKey:TMTCompletionHasPlaceholdersKey];
    }
    return self;
}


- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.insertion forKey:TMTCompletionInsertionKey];
    [aCoder encodeObject:self.extension forKey:TMTCompletionExtensionKey];
    [aCoder encodeBool:self.hasPlaceholders forKey:TMTCompletionHasPlaceholdersKey];
}



- (NSMutableDictionary *)dictionaryRepresentation {
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:self.insertion,TMTCompletionInsertionKey,[NSNumber numberWithBool:self.hasPlaceholders],TMTCompletionHasPlaceholdersKey, self.extension, TMTCompletionExtensionKey, nil];

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
@end
