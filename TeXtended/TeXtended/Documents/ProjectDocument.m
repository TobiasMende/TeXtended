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
    }
    return self;
}


- (void)saveEntireDocumentWithDelegate:(id)delegate andSelector:(SEL)action {
    //FIXME: implement this!
}

- (BOOL)writeToURL:(NSURL *)absoluteURL ofType:(NSString *)typeName forSaveOperation:(NSSaveOperationType)saveOperation originalContentsURL:(NSURL *)absoluteOriginalContentsURL error:(NSError *__autoreleasing *)error {
    
    /* save all documents */
    for (DocumentController* dc in self.documentControllers) {
        [dc saveDocumentModel:error];
        if (*error) {
            DDLogError(@"%@", (*error).userInfo);
        }
    }
    
    return [super writeToURL:absoluteURL ofType:typeName forSaveOperation:saveOperation originalContentsURL:absoluteOriginalContentsURL error:error];
}

- (BOOL)readFromURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError *__autoreleasing *)error {
    NSURL *finalURL;
    if ([typeName isEqualToString:@"TeXtendedProjectFolder"]) {
        finalURL = [self projectFileUrlFromDirectory:absoluteURL];
    } else if([typeName isEqualToString:@"TeXtendedProjectFile"]) {
        finalURL = absoluteURL;
    }
    DDLogError(@"Project(%@): %@", typeName, absoluteURL);
    
    if (!finalURL) {
        // Abort reading if no matching project was found
        return NO;
    }
//    if (!self.projectModel) {
//        _projectModel = [[ProjectModel alloc] init];
//        if (self.documentControllers) {
//            for (DocumentController* dc in self.documentControllers) {
//                if ([[[self.projectModel.documents allObjects] objectAtIndex:0] isEqual:dc.model]) {
//                    [dc setWindowController:self.mainWindowController];
//                }
//            }
//        }
//    }
    BOOL success = [super readFromURL:finalURL ofType:@"TeXtendedProjectFile" error:error];
    if (!success) {
        return NO;
    }
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Project"
                                              inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    
    NSError *fetchError;
    NSArray *fetchedObjects = [self.context executeFetchRequest:fetchRequest error:&fetchError];
    if (fetchedObjects.count != 1) {
        DDLogWarn(@"Number of ProjectModels is %li", fetchedObjects.count);
    }
    if (fetchedObjects == nil) {
        DDLogError(@"%@", fetchError.userInfo);
        success = NO;
    } else {
        self.model = [fetchedObjects objectAtIndex:0];
        if (![self.model.path isEqualToString:finalURL.path]) {
            self.model.path = finalURL.path;
        }
    }
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
