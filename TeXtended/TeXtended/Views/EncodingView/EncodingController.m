//
//  EncodingController.m
//  TeXtended
//
//  Created by Tobias Hecht on 21.09.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "EncodingController.h"
#import <TMTHelperCollection/TMTEncodingManager.h>

@interface EncodingController ()

@end

@implementation EncodingController

    - (id)init
    {
        self = [super initWithNibName:@"EncodingView" bundle:nil];
        if (self) {

            self.encodings = [[TMTEncodingManager sharedManager] stringEncodings];
            self.selectionDidChange = NO;
        }
        return self;
    }


    - (void)loadView
    {
        [super loadView];

        [self.popUp removeAllItems];
        // Fill with encodings
        for (NSUInteger cnt = 0 ; cnt < [self.encodings count] ; cnt++) {
            NSNumber *encodingNumber = (self.encodings)[cnt];
            NSStringEncoding encoding = [encodingNumber unsignedLongValue];
            [self.popUp addItemWithTitle:[NSString localizedNameOfStringEncoding:encoding]];
            [[self.popUp lastItem] setRepresentedObject:encodingNumber];
            [[self.popUp lastItem] setEnabled:YES];
        }
    }

    - (void)panelSelectionDidChange:(id)sender
    {
        NSOpenPanel *openPanel = (NSOpenPanel *) sender;
        NSStringEncoding encoding;
        NSError *error;
        (void)[[NSString alloc] initWithContentsOfFile:[[openPanel URL] path] usedEncoding:&encoding error:&error];
        [self.popUp selectItemAtIndex:(NSInteger)[self.encodings indexOfObject:@(encoding)]];
        self.selectionDidChange = YES;
    }

    - (NSStringEncoding)selection
    {
        self.selectionDidChange = NO;
        NSInteger selection = self.popUp.indexOfSelectedItem;
        if (selection >= 0 && (NSUInteger)selection < self.encodings.count) {
            return [self.encodings[(NSUInteger)selection] unsignedLongValue];
        } else {
            return [NSString defaultCStringEncoding];
        }
    }

@end
