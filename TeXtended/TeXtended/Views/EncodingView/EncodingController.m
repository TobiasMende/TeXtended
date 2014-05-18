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
        for (NSInteger cnt = 0 ; cnt < [self.encodings count] ; cnt++) {
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
        NSString *content = [[NSString alloc] initWithContentsOfFile:[[openPanel URL] path] usedEncoding:&encoding error:&error];
#pragma unused(content)
        [self.popUp selectItemAtIndex:[self.encodings indexOfObject:@(encoding)]];
        self.selectionDidChange = YES;
    }

    - (NSStringEncoding)selection
    {
        self.selectionDidChange = NO;
        if (self.popUp.indexOfSelectedItem < self.encodings.count) {
            return [(self.encodings)[self.popUp.indexOfSelectedItem] unsignedLongValue];
        } else {
            return [NSString defaultCStringEncoding];
        }
    }

@end
