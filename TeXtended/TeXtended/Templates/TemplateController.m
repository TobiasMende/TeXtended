//
//  TemplateController.m
//  TeXtended
//
//  Created by Max Bannach on 14.09.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "TemplateController.h"
#import "PathFactory.h"
#import "ApplicationController.h"
#import "newTemplateController.h"

@implementation TemplateController

- (id)init {
    self = [super init];
    if (self) {
        newTemplateController = [[NewTemplateController alloc] initWithTemplateController:self];
        templates = [[NSMutableArray alloc] init];
        [self mergeTemplates];
    }
    return self;
}

- (void) loadTemplate:(id)sender {
    if ([table selectedRow] == -1) return;
    
    NSString* file = [NSString stringWithFormat:@"%@/%@", [self path], [[templates objectAtIndex:[table selectedRow]] objectForKey:@"template"]];
    NSData*   data = [NSData dataWithContentsOfFile:file];
   
    NSPasteboard* board = [NSPasteboard generalPasteboard];
    [board clearContents];
    [board setData:data forType:NSPasteboardTypeString];
    
    [self closeSheet:nil];
}

- (void) saveTemplate:(id)sender {
    if ([table selectedRow] == -1) return;
    
    NSString* file = [NSString stringWithFormat:@"%@/%@", [self path], [[templates objectAtIndex:[table selectedRow]] objectForKey:@"template"]];
    [self addContentFromPasteboardToFile:file];
    
    [self closeSheet:nil];
}

- (void) addTemplate:(id)sender {
    [newTemplateController openSheetIn:self.sheet];
}

- (void) addTemplateWithName:(NSString*) fileName andContent:(BOOL) addContent {
    NSString* file = [NSString stringWithFormat:@"%@/%@", [self path], fileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:file]) {
        [[NSFileManager defaultManager] createFileAtPath:file contents:nil attributes:nil];
        [templates addObject:@{@"template" : fileName}];
        [table reloadData];
        
        if (addContent) {
            [self addContentFromPasteboardToFile:file];
        }
 
    }
}

/** Add the content from the pasteboard to the given file */
- (void) addContentFromPasteboardToFile:(NSString*) file {
    NSPasteboard* board = [NSPasteboard generalPasteboard];
    NSArray *classes = [[NSArray alloc] initWithObjects:[NSString class], nil];
    NSDictionary *options = [NSDictionary dictionary];
    NSArray *copiedItems = [board readObjectsForClasses:classes options:options];
    if (copiedItems != nil) {
        [[copiedItems objectAtIndex:0] writeToFile:file atomically:YES];
    }
}

- (void) removeTemplate:(id)sender {
    if ([table selectedRow] == -1) return;
    NSString* file = [NSString stringWithFormat:@"%@/%@", [self path], [[templates objectAtIndex:[table selectedRow]] objectForKey:@"template"]];
    [[NSFileManager defaultManager] removeItemAtPath:file error:nil];
    [templates removeObjectAtIndex:[table selectedRow]];
    [table reloadData];
}

- (void)openSheetIn:(NSWindow*)window {
    if (!_sheet) {
        [NSBundle loadNibNamed:@"TemplateSheet" owner:self];
    }
    
    [templates removeAllObjects];
    for (NSString* tmp in [self getTemplates]) {
        [templates addObject:@{@"template" : tmp}];
    }
    
    [NSApp beginSheet:self.sheet
       modalForWindow:window
       modalDelegate:self
       didEndSelector:nil
       contextInfo:nil
     ];
}

- (IBAction)closeSheet:(id)sender {
    [NSApp endSheet:self.sheet];
    [self.sheet close];
    self.sheet = nil;
}

/** Calculate the path */
- (NSString*) path {
    NSString *dir =[[ApplicationController userApplicationSupportDirectoryPath] stringByAppendingPathComponent:@"/templates/"];
    return dir;
}

/** Returns a list of all available templates */
- (NSArray*) getTemplates {
    NSString* templatePath = [self path];
    NSFileManager* fm = [NSFileManager defaultManager];
    NSError* error;
    NSArray *files = [fm contentsOfDirectoryAtPath:templatePath error:&error];
    return files;
}

/** Megres default templates to users templates */
- (void) mergeTemplates {
    NSString* templatePath = [self path];
    BOOL exists = [PathFactory checkForAndCreateFolder:templatePath];
    if (exists) {
        NSString* bundlePath = [[NSBundle mainBundle] pathForResource:@"TemplateFiles" ofType:nil];
        NSFileManager* fm = [NSFileManager defaultManager];
        NSError* error;
        NSArray *files = [fm contentsOfDirectoryAtPath:bundlePath error:&error];
        if (error) {
            NSLog(@"Can't read template from %@. Error: %@", bundlePath, [error userInfo]);
        } else {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init]; [dict setObject:[NSNumber numberWithInt:511] forKey:NSFilePosixPermissions];
            for(NSString *path in files) {
                NSString* srcPath = [bundlePath stringByAppendingPathComponent:path];
                NSString* destPath = [templatePath stringByAppendingPathComponent:path];
                NSError *copyError;
                [fm copyItemAtPath:srcPath toPath:destPath error:&copyError];
                if (copyError) {
                    NSError* underlying = [[copyError userInfo] valueForKey:NSUnderlyingErrorKey];
                    if (underlying && [underlying code] != 17) {
                        NSLog(@"Can't merge template %@:\t %@", path, [copyError userInfo]);
                        
                    }
                } else {
                    [fm setAttributes:dict ofItemAtPath:destPath error:&error];
                    if (error) {
                        NSLog(@"Error while setting permission: %@", [error userInfo]);
                    }
                }
            }
        }
    }
}

- (NSInteger) numberOfRowsInTableView:(NSTableView *)tableView {
    return [templates count];
}

- (id) tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    return [[templates objectAtIndex:row] objectForKey:tableColumn.identifier];
}

@end
