//
//  MessageInfoViewController.m
//  TeXtended
//
//  Created by Tobias Mende on 30.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "MessageInfoViewController.h"
#import "DocumentModel.h"
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
        keys = [keys setByAddingObjectsFromArray:[NSArray arrayWithObjects:@"self.model.texPath", @"self.message.document", nil]];
    }
    return keys;
}


- (BOOL)isExternal {
    return ![self.model.texPath isEqualToString:self.message.document] &&(self.model.texPath && self.message.document);
}

- (NSImage *)image {
    //FIXME: return image;
    NSImage *image = [TrackingMessage imageForType:self.message.type];
    [image setFlipped:NO];
    return image;
}

@end
