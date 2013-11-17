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


- (void)saveEntireDocumentWithDelegate:(id)delegate andSelector:(SEL)action {
    //FIXME: implement this!
}



- (void)saveToURL:(NSURL *)url ofType:(NSString *)typeName forSaveOperation:(NSSaveOperationType)saveOperation completionHandler:(void (^)(NSError *))completionHandler {
    @try {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.model];
        [data writeToURL:url atomically:YES];
    }
    @catch (NSException *exception) {
        DDLogError(@"Can't write content: %@", exception.userInfo);
    }

    
}


- (BOOL)readFromURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError *__autoreleasing *)error {
    NSData *data = [NSData dataWithContentsOfURL:absoluteURL];
    @try {
        NSObject *obj = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        if (obj) {
            self.model = (ProjectModel*)obj;
        }
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
