//
//  FileInfoWindowController.h
//  TeXtended
//
//  Created by Tobias Mende on 09.06.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TMTQuickLookView;

@interface TMTPassiveFileWrapper : NSObject

@property (readonly) NSURL *fileURL;
@property (readonly) NSFileWrapper *wrapper;

- (NSString *)fileName;
- (NSDate *) modificationDate;
- (NSUInteger) fileSize;
- (NSString *)fileType;
- (NSString *)fileTypeInfo;

- (TMTPassiveFileWrapper *)initWithURL:(NSURL *) url;


@end

@interface FileInfoWindowController : NSWindowController

@property (strong, nonatomic) IBOutlet TMTQuickLookView *quickLook;
@property TMTPassiveFileWrapper *wrapper;
@property (nonatomic) NSURL *fileURL;
@end


