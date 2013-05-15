//
//  FileViewModel.h
//  TeXtended
//
//  Created by Tobias Hecht on 15.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileViewModel : NSObject {
    NSString* filePath;
    NSString* fileName;
    NSImage* icon;
    NSMutableArray* childs;
    FileViewModel *parent;
}

-(void)addChild:(NSString*)path;
-(FileViewModel*)getChild:(NSInteger)index;

@end
