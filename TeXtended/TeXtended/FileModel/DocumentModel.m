//
//  DocumentModel.m
//  TeXtended
//
//  Created by Tobias Mende on 01.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "DocumentModel.h"
#import "ProjectModel.h"


@implementation DocumentModel

@dynamic lastChanged;
@dynamic lastCompile;
@dynamic pdfPath;
@dynamic texPath;
@dynamic project;
@dynamic encoding;
@dynamic mainDocuments;
@dynamic subDocuments;
@dynamic headerDocument;

- (NSString *)loadContent {
    self.lastChanged = [[NSDate alloc] init];
    NSError *error;
    NSString *content;
    if (!self.texPath) {
        return nil;
    }
    if (self.encoding) {
        content = [NSString stringWithContentsOfFile:self.texPath encoding:[self.encoding unsignedLongValue] error:&error];
    } else {
        NSStringEncoding encoding;
        content = [NSString stringWithContentsOfFile:self.texPath usedEncoding:&encoding error:&error];
        self.encoding = [NSNumber numberWithUnsignedLong:encoding];
    }
    if (error) {
        NSLog(@"Error while reading document: %@", error);
        return nil;
    }
    return content;
}

- (BOOL)saveContent:(NSString *)content error:(NSError *__autoreleasing *)error{
    self.lastChanged = [[NSDate alloc] init];
    if (!self.texPath) {
        return NO;
    }
    return [content writeToURL:[NSURL fileURLWithPath:self.texPath] atomically:YES encoding:[self.encoding unsignedLongValue] error:error];
}


- (id)initWithContext:(NSManagedObjectContext *)context {
    NSEntityDescription *description = [NSEntityDescription entityForName:@"Document" inManagedObjectContext:context];
    self = [super initWithEntity:description insertIntoManagedObjectContext:context];
    if (self) {
        self.encoding = [NSNumber numberWithUnsignedLong:NSUTF8StringEncoding];
    }
    return self;
}

- (Compilable *)mainCompilable {
    if (self.project) {
        return [self.project mainCompilable];
    }
    return [super mainCompilable];
}
@end
