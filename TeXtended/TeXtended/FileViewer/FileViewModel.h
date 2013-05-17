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
    NSArray* pathComponents;
    NSInteger pathIndex;
    NSString* fileName;
    NSImage* icon;
    NSMutableArray* children;
    FileViewModel *parent;
}

-(void)addPath:(NSString*)path;
-(FileViewModel*)getChildren:(NSInteger)index;
-(NSString*)getFileName;
-(NSString*)getPath;
-(void)setFileName:(NSString*)oldName
            toName:(NSString*)newName;
-(NSImage*)getIcon;
-(NSInteger)numberOfChildren;

@end
