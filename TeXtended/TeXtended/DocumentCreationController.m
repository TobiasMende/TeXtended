//
//  DocumentController.m
//  TeXtended
//
//  Created by Tobias Mende on 17.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "DocumentCreationController.h"
#import "Constants.h"

@implementation DocumentCreationController


- (NSInteger)runModalOpenPanel:(NSOpenPanel *)openPanel forTypes:(NSArray *)types {
    [openPanel setCanChooseDirectories:YES];
    return [super runModalOpenPanel:openPanel forTypes:types];
}


- (NSString *)typeForContentsOfURL:(NSURL *)url error:(NSError *__autoreleasing *)outError {
    NSString *type = [super typeForContentsOfURL:url error:outError];
    if(!type && CFURLHasDirectoryPath((CFURLRef)url)) {
        // If no type was found yet and the url is a path to a directory, its a project folder type
        type = TMT_FOLDER_DOCUMENT_TYPE;
    }
    return type;
}

@end
