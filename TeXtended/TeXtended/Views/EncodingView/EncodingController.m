//
//  EncodingController.m
//  TeXtended
//
//  Created by Tobias Hecht on 21.09.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "EncodingController.h"
#import "TMTLog.h"

@interface EncodingController ()

@end

@implementation EncodingController

- (id)init
{
    self = [super initWithNibName:@"EncodingView" bundle:nil];
    if (self) {
        const CFStringEncoding *cfEncodings = CFStringGetListOfAvailableEncodings();
        CFStringEncoding *tmp;
        NSInteger cnt, num = 0;
        while (cfEncodings[num] != kCFStringEncodingInvalidId) num++;	// Count
        tmp = malloc(sizeof(CFStringEncoding) * num);
        memcpy(tmp, cfEncodings, sizeof(CFStringEncoding) * num);	// Copy the list
        qsort(tmp, num, sizeof(CFStringEncoding), encodingCompare);	// Sort it
        NSMutableArray *allEncodings = [[NSMutableArray alloc] init];			// Now put it in an NSArray
        for (cnt = 0; cnt < num; cnt++) {
            NSStringEncoding nsEncoding = CFStringConvertEncodingToNSStringEncoding(tmp[cnt]);
            if (nsEncoding && [NSString localizedNameOfStringEncoding:nsEncoding]) [allEncodings addObject:[NSNumber numberWithUnsignedInteger:nsEncoding]];
        }
        self.encodings = [NSArray arrayWithArray:allEncodings];
        free(tmp);
        self.selectionDidChange = NO;
    }
    return self;
}

int encodingCompare(const void *firstPtr, const void *secondPtr) {
    CFStringEncoding first = *(CFStringEncoding *)firstPtr;
    CFStringEncoding second = *(CFStringEncoding *)secondPtr;
    CFStringEncoding macEncodingForFirst = CFStringGetMostCompatibleMacStringEncoding(first);
    CFStringEncoding macEncodingForSecond = CFStringGetMostCompatibleMacStringEncoding(second);
    if (first == second) return 0;	// Should really never happen
    if (macEncodingForFirst == kCFStringEncodingUnicode || macEncodingForSecond == kCFStringEncodingUnicode) {
        if (macEncodingForSecond == macEncodingForFirst) return (first > second) ? 1 : -1;	// Both Unicode; compare second order
        return (macEncodingForFirst == kCFStringEncodingUnicode) ? -1 : 1;	// First is Unicode
    }
    if ((macEncodingForFirst > macEncodingForSecond) || ((macEncodingForFirst == macEncodingForSecond) && (first > second))) return 1;
    return -1;
}

- (void)loadView
{
    [super loadView];
    
    [self.popUp removeAllItems];
    // Fill with encodings
    for (NSInteger cnt = 0; cnt < [self.encodings count]; cnt++) {
        NSNumber *encodingNumber = [self.encodings objectAtIndex:cnt];
        NSStringEncoding encoding = [encodingNumber unsignedIntegerValue];
        [self.popUp addItemWithTitle:[[NSString localizedNameOfStringEncoding:encoding] stringByAppendingString:[NSString stringWithFormat:@" (%ld)", encoding]]];
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
    [self.popUp selectItemAtIndex:[self.encodings indexOfObject:[NSNumber numberWithUnsignedInteger:encoding]]];
    self.selectionDidChange = YES;
}

-(NSStringEncoding)selection
{
    self.selectionDidChange = NO;
    return [[self.encodings objectAtIndex:self.popUp.indexOfSelectedItem] unsignedIntegerValue];
}

@end
