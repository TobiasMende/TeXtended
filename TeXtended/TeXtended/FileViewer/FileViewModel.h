//
//  FileViewModel.h
//  TeXtended
//
//  Created by Tobias Hecht on 15.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileViewModel : NSObject <NSFilePresenter> {
    NSArray* pathComponents;
    NSInteger pathIndex;
    NSMutableArray* children;
    __weak FileViewModel *parent;
}

@property (readonly) NSURL *presentedItemURL;
@property (readonly) NSOperationQueue *presentedItemOperationQueue;
@property (nonatomic, strong) NSString *filePath;
@property NSImage* icon;
@property NSString* fileName;
-(void)addPath:(NSString*)path;
-(FileViewModel*)getChildrenByName:(NSString*)name;
-(FileViewModel*)getChildrenByIndex:(NSInteger)index;
-(void)setFileName:(NSString*)oldName
            toName:(NSString*)newName;
-(NSInteger)numberOfChildren;
-(void)checkPath:(NSString*)path;

@end
