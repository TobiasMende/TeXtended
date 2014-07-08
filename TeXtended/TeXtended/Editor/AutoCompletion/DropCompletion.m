//
//  DropCompletion.m
//  TeXtended
//
//  Created by Tobias Hecht on 05.01.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import "DropCompletion.h"
#import "Constants.h"

static const NSString *DEST_PLACEHOLDER = @"@@destination@@";

@implementation DropCompletion

    - (id)init
    {
        return [self initWithInsertion:@"" andExtension:DEST_PLACEHOLDER.copy];
    }

    - (id)initWithDictionary:(NSDictionary *)dict
    {
        self = [super initWithDictionary:dict];
        if (self) {
            self.usePathExtentsion = [dict[TMTCompletionUseExtensionKey] boolValue];
        }
        return self;
    }

    - (NSMutableDictionary *)dictionaryRepresentation
    {
        NSMutableDictionary *result = [super dictionaryRepresentation];
        result[TMTCompletionUseExtensionKey] = @(self.usePathExtentsion);
        return result;
    }

    - (NSAttributedString *)attributedStringByInsertingDestination:(NSString *)path
    {
        NSString *retValue;
        if (!self.usePathExtentsion) {
            retValue = [self.extension stringByReplacingOccurrencesOfString:DEST_PLACEHOLDER.copy withString:[path stringByDeletingPathExtension]];
        }
        else {
            retValue = [self.extension stringByReplacingOccurrencesOfString:DEST_PLACEHOLDER.copy withString:path];
        }

        return [self substitutePlaceholdersInString:retValue];
    }

- (NSArray *)fileExtensions {
    NSArray *extensions = [self.insertion componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@",; "]];
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:extensions.count];
    for(NSString *ext in extensions) {
        if (ext.length > 0) {
            [result addObject:ext.lowercaseString];
        }
    }
    return result;
}

@end
