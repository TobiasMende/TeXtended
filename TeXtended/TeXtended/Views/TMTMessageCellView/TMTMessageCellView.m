//
//  TMTMessageCellView.m
//  TeXtended
//
//  Created by Tobias Mende on 23.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "TMTMessageCellView.h"
#import "TrackingMessage.h"
#import "DocumentModel.h"
#import "FirstResponderDelegate.h"

@interface TMTMessageCellView ()

    - (void)firstResponderDidChangeNotification:(NSNotification *)note;

    - (void)configure;
@end

@implementation TMTMessageCellView

    - (id)init
    {
        self = [super init];
        if (self) {
            [self configure];
        }
        return self;
    }

    - (id)initWithCoder:(NSCoder *)aDecoder
    {
        self = [super initWithCoder:aDecoder];
        if (self) {
            [self configure];
        }
        return self;
    }

    - (void)configure
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(firstResponderDidChangeNotification:) name:TMTFirstResponderDelegateChangeNotification object:nil];
    }

    - (void)setModel:(DocumentModel *)model
    {
        if (!model) {
            self.isExternal = YES;
        }
        _model = model;
    }

    - (void)firstResponderDidChangeNotification:(NSNotification *)note
    {
        id <FirstResponderDelegate> del = (note.userInfo)[TMTFirstResponderKey];
        self.isExternal = !self.model || ![[del model].texPath isEqualToString:self.model.texPath];
    }

    - (NSImage *)image
    {
        NSImage *image = [TrackingMessage imageForType:self.message.type];
        return image;
    }

    - (NSString *)lineString
    {
        if (self.message.column > 0) {
            return [NSString stringWithFormat:@"%li:%li", self.message.line, self.message.column];
        } else {
            return [NSString stringWithFormat:@"%li", self.message.line];
        }
        return [NSLocalizedString(@"Line", @"line") stringByAppendingFormat:@" %li", self.message.line];
    }

    - (TrackingMessage *)message
    {
        return self.objectValue;
    }

    + (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key
    {
        NSSet *keys = [super keyPathsForValuesAffectingValueForKey:key];

        if ([key isEqualToString:@"image"]) {
            keys = [keys setByAddingObject:@"objectValue"];
        } else if ([key isEqualToString:@"lineString"]) {
            keys = [keys setByAddingObject:@"objectValue"];

        } else if ([key isEqualToString:@"message"]) {
            keys = [keys setByAddingObject:@"objectValue"];
        }
        return keys;
    }

    - (void)dealloc
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }

@end
