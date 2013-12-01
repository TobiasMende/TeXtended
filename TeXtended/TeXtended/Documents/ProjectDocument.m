//
//  ProjectDocument.m
//  TeXtended
//
//  Created by Tobias Mende on 17.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "ProjectDocument.h"
#import "MainWindowController.h"
#import "DocumentController.h"
#import "ProjectModel.h"
#import "TMTLog.h"

@interface ProjectDocument ()
- (NSURL*)projectFileUrlFromDirectory:(NSURL*)directory;
@end

@implementation ProjectDocument

- (id)init
{
    self = [super init];
    if (self) {
            // Add your subclass-specific initialization here.
            self.model = [ProjectModel new];
    }
    return self;
}

- (void)saveDocumentWithDelegate:(id)delegate didSaveSelector:(SEL)didSaveSelector contextInfo:(void *)contextInfo {
    NSLog(@"1");
    NSLog(@"%@", [self fileURL]);
    NSLog(@"%@", [self fileType]);
   [self saveToURL:[self fileURL] ofType:[self fileType] forSaveOperation:NSAutosaveInPlaceOperation delegate:delegate didSaveSelector:didSaveSelector contextInfo:contextInfo];
    //[self saveToURL:[self fileURL] ofType:[self fileType] forSaveOperation:NSAutosaveInPlaceOperation completionHandler:nil];
    NSLog(@"3");
}

- (void)saveEntireDocumentWithDelegate:(id)delegate andSelector:(SEL)action {
    [self saveToURL:[self fileURL] ofType:[self fileType] forSaveOperation:NSAutosaveInPlaceOperation delegate:delegate didSaveSelector:action contextInfo:NULL];
}

//- (void)saveToURL:(NSURL *)url ofType:(NSString *)typeName forSaveOperation:(NSSaveOperationType)saveOperation delegate:(id)delegate didSaveSelector:(SEL)didSaveSelector contextInfo:(void *)contextInfo {
//    [self saveToURL:url ofType:typeName forSaveOperation:saveOperation completionHandler:^(NSError *errorOrNil) {
//        [delegate performSelector:didSaveSelector withObject:self];
//    }];
//}

- (void)saveToURL:(NSURL *)url ofType:(NSString *)typeName forSaveOperation:(NSSaveOperationType)saveOperation completionHandler:(void (^)(NSError *))completionHandler {
    NSLog(@"2");
    @try {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.model];
        [data writeToURL:url atomically:YES];
        for( DocumentController *dc in self.documentControllers) {
            NSError *error;
            [dc saveDocumentModel:&error];
            if (error) {
                DDLogError(@"Can't save texfile %@. Error: %@", dc.model.texPath, error.userInfo);
            }
        }
    }
    @catch (NSException *exception) {
        DDLogError(@"Can't write content: %@", exception.userInfo);
    }    
}


- (BOOL)readFromURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError *__autoreleasing *)error {
    DDLogInfo(@"%@", absoluteURL);
    NSData *data = [NSData dataWithContentsOfURL:absoluteURL];
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    @try {
        self.model = [[ProjectModel alloc] initWithCoder:unarchiver];
    }
    @catch (NSException *exception) {
        DDLogError(@"Can't read content: %@", exception.userInfo);
        return NO;
    }
    return YES;
}

- (NSURL *)projectFileUrlFromDirectory:(NSURL *)directory {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *lastComponent = [directory lastPathComponent];
    NSArray * dirContents =
    [fm contentsOfDirectoryAtURL:directory
      includingPropertiesForKeys:@[]
                         options:NSDirectoryEnumerationSkipsHiddenFiles
                           error:nil];
    NSPredicate * fltr = [NSPredicate predicateWithFormat:@"pathExtension='teXpf'"];
    NSArray * projectFiles = [dirContents filteredArrayUsingPredicate:fltr];
    if (projectFiles.count == 1) {
        return [projectFiles objectAtIndex:0];
    }else if(projectFiles.count > 1) {
        NSURL *defaultFileURL = [directory URLByAppendingPathComponent:[lastComponent stringByAppendingPathExtension:@"teXpf"]];
        for (NSURL *url in projectFiles) {
            if ([url.path isEqualToString:defaultFileURL.path]) {
                return url;
            }
        }
        return [projectFiles objectAtIndex:0];
    }
    return nil;
}


- (void)dealloc {
    DDLogVerbose(@"ProjectDocument dealloc");
}

@end
