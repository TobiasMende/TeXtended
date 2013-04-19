//
//  Completion.m
//  TeXtended
//
//  Created by Tobias Mende on 18.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "Completion.h"
#import "Constants.h"

@implementation Completion

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


- (id)initWithDictionary:(NSDictionary *)dict {
    NSString *insertion = [dict objectForKey:TMTCompletionInsertionKey];
    BOOL hasPlaceholders = [[dict objectForKey:TMTCompletionHasPlaceholdersKey] boolValue];
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
@end
