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
            self.model = [[ProjectModel alloc] initWithContext:self.context];
    }
    return self;
}


- (void)saveEntireDocumentWithDelegate:(id)delegate andSelector:(SEL)action {
    //FIXME: implement this!
}


- (void)saveToURL:(NSURL *)url ofType:(NSString *)typeName forSaveOperation:(NSSaveOperationType)saveOperation completionHandler:(void (^)(NSError *))completionHandler {
    NSError *error;
    [self.context save:&error];
    for (DocumentController *dc in self.documentControllers) {
        [dc saveDocumentModel:&error];
    }
    if (error) {
        DDLogError(@"Saving failed: %@", error.userInfo);
    }
    
}


- (BOOL)readFromURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError *__autoreleasing *)error {
    NSURL *finalURL;
    if ([typeName isEqualToString:@"TeXtendedProjectFolder"]) {
        finalURL = [self projectFileUrlFromDirectory:absoluteURL];
    } else if([typeName isEqualToString:@"TeXtendedProjectFile"]) {
        finalURL = absoluteURL;
    }
    DDLogInfo(@"Project(%@): %@", typeName, absoluteURL);
    
    if (!finalURL) {
        // Abort reading if no matching project was found
        return NO;
    }
    BOOL success = YES;
    self.fileURL = finalURL;
    [self setupPeristentStore];

//    NSError *fetchError;
//    NSArray *fetchedObjects = [self.context executeFetchRequest:fetchRequest error:&fetchError];
//    if (fetchedObjects.count != 1) {
//        DDLogWarn(@"Number of ProjectModels is %li", fetchedObjects.count);
//    }
//    if (fetchedObjects == nil) {
//        DDLogError(@"%@", fetchError.userInfo);
//        success = NO;
//    } else {
//        self.model = [fetchedObjects objectAtIndex:0];
//        if (![self.model.path isEqualToString:finalURL.path]) {
//            self.model.path = finalURL.path;
//        }
//    }
    return success;
}

- (NSURL *)projectFileUrlFromDirectory:(NSURL *)directory {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *lastComponent = [directory lastPathComponent];
    NSArray * dirContents =
    [fm contentsOfDirectoryAtURL:directory
      includingPropertiesForKeys:@[]
                         options:NSDirectoryEnumerationSkipsHiddenFiles
                           error:nil];
    NSPredicate * fltr = [NSPredicate predicateWithFormat:@"pathExtension='textendedproj'"];
    NSArray * projectFiles = [dirContents filteredArrayUsingPredicate:fltr];
    if (projectFiles.count == 1) {
        return [projectFiles objectAtIndex:0];
    }else if(projectFiles.count > 1) {
        NSURL *defaultFileURL = [directory URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.textendedproj",lastComponent]];
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
