//
//  MessageInfoViewController.m
//  TeXtended
//
//  Created by Tobias Mende on 30.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "MessageInfoViewController.h"
#import "Compilable.h"
#import "TrackingMessage.h"

@interface MessageInfoViewController ()

@end

@implementation MessageInfoViewController


- (id)init {
    self = [super initWithNibName:@"MessageInfoView" bundle:nil];
    if (self) {
        
    }
    return self;
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
    NSSet *keys = [super keyPathsForValuesAffectingValueForKey:key];
    
    if ([key isEqualToString:@"image"]) {
        keys = [keys setByAddingObject:@"message"];
    } else if ([key isEqualToString:@"isExternal"]) {
        keys = [keys setByAddingObjectsFromArray:[NSArray arrayWithObjects:@"self.model", @"self.message.document", nil]];
    }
    return keys;
}


- (void)setModel:(Compilable *)model {
    isExternalCache = nil;
    _model = model;
}

- (BOOL)isExternal {
    if (!isExternalCache) {
        isExternalCache = [NSNumber numberWithBool:[self.model modelForTexPath:self.message.document byCreating:NO] != nil];
    }
    return isExternalCache.boolValue;
}

- (NSImage *)image {
    //FIXME: return image;
    NSImage *image = [TrackingMessage imageForType:self.message.type];
    [image setFlipped:NO];
    return image;
}

@end
