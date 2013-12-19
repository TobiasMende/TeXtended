//
//  EncodingController.m
//  TeXtended
//
//  Created by Tobias Hecht on 21.09.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "EncodingController.h"
#import <TMTHelperCollection/TMTLog.h>

@interface EncodingController ()

@end

@implementation EncodingController

- (id)init
{
    self = [super initWithNibName:@"EncodingView" bundle:nil];
    if (self) {
        const NSStringEncoding *encodings = [NSString availableStringEncodings];
        NSMutableArray *allEncodings = [[NSMutableArray alloc] init];
        while (*encodings != 0) {
            [allEncodings addObject:[NSNumber numberWithUnsignedLong:*encodings]];
            encodings++;
        }
        [allEncodings sortUsingComparator:^NSComparisonResult(id first, id second) {
            NSString *firstName = [NSString localizedNameOfStringEncoding:[first intValue]];
            NSString *secondName = [NSString localizedNameOfStringEncoding:[second intValue]];
            return [firstName compare:secondName];
        }];
        self.encodings = allEncodings;
        self.selectionDidChange = NO;
    }
    return self;
}


- (void)loadView
{
    [super loadView];
    
    [self.popUp removeAllItems];
    // Fill with encodings
    for (NSInteger cnt = 0; cnt < [self.encodings count]; cnt++) {
        NSNumber *encodingNumber = [self.encodings objectAtIndex:cnt];
        NSStringEncoding encoding = [encodingNumber unsignedLongValue];
        [self.popUp addItemWithTitle:[NSString localizedNameOfStringEncoding:encoding]];
        [[self.popUp lastItem] setRepresentedObject:encodingNumber];
        [[self.popUp lastItem] setEnabled:YES];
    }
}

- (void) panelSelectionDidChange:(id)sender
{
    NSOpenPanel *openPanel = (NSOpenPanel*)sender;
    NSStringEncoding encoding;
    NSError *error;
    NSString *content = [[NSString alloc] initWithContentsOfFile:[[openPanel URL] path] usedEncoding:&encoding error:&error];
#pragma unused(content)
    [self.popUp selectItemAtIndex:[self.encodings indexOfObject:[NSNumber numberWithUnsignedLong:encoding]]];
    self.selectionDidChange = YES;
}

-(NSStringEncoding)selection
{
    self.selectionDidChange = NO;
    if (self.popUp.indexOfSelectedItem < self.encodings.count) {
        return [[self.encodings objectAtIndex:self.popUp.indexOfSelectedItem] unsignedLongValue];
    } else {
        return [NSString defaultCStringEncoding];
    }
}

@end
