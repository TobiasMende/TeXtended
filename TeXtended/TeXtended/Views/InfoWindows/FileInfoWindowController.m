//
//  FileInfoWindowController.m
//  TeXtended
//
//  Created by Tobias Mende on 09.06.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import "FileInfoWindowController.h"
#import "TMTQuickLookView.h"
#import <TMTHelperCollection/TMTLog.h>

@interface FileInfoWindowController ()

@end

@implementation FileInfoWindowController

- (id)init
{
    self = [super initWithWindowNibName:@"FileInfoWindow"];
    return self;
}

- (void)setFileURL:(NSURL *)fileURL {
    
    _fileURL = fileURL;
    self.wrapper = [[TMTPassiveFileWrapper alloc] initWithURL:fileURL];
    
}


- (void)windowDidLoad
{
    [super windowDidLoad];
    self.quickLook.shouldCloseWithWindow = NO;
    
    [self.quickLook bind:@"previewItem" toObject:self withKeyPath:@"fileURL" options:nil];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void)dealloc {
    [self.quickLook close];
}


@end


@implementation TMTPassiveFileWrapper

- (TMTPassiveFileWrapper *)initWithURL:(NSURL *)url {
    self = [super init];
    if (self) {
        _fileURL = url;
        NSError *error;
        _wrapper = [[NSFileWrapper alloc] initWithURL:self.fileURL options:0 error:&error];
        
        if (!_wrapper && error) {
            DDLogError(@"Can't generate wrapper for %@:\n\t%@", self.fileURL, error);
        }
    }
    return self;
}

-(NSString *)fileName {
    return self.wrapper.filename;
}

- (NSDate *)modificationDate {
    return self.wrapper.fileAttributes.fileModificationDate;
}

- (NSUInteger)fileSize {
    return self.wrapper.fileAttributes.fileSize;
}

- (NSString *)fileType {
    return self.wrapper.fileAttributes.fileType;
}

- (NSString *)fileTypeInfo {
    return @"TODO";
}

@end