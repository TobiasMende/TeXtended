//
//  FileViewModel.h
//  TeXtended
//
//  Created by Tobias Hecht on 15.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DocumentModel;

@interface FileViewModel : NSObject <NSFilePresenter> {
    NSInteger pathIndex;
    NSMutableArray* children;
}

@property (readonly) NSURL *presentedItemURL;
@property (readonly) NSOperationQueue *presentedItemOperationQueue;
@property (weak) DocumentModel *docModel;
@property (weak) FileViewModel *parent;
@property (nonatomic, strong) NSString *filePath;
@property NSImage* icon;
@property NSString* fileName;
@property NSArray* pathComponents;
@property (readonly) BOOL isDir;
@property BOOL expandable;

-(void)addPath:(NSString*)path;
-(void)addModel:(FileViewModel*)newModel;
-(FileViewModel*)getChildrenByName:(NSString*)name;
-(FileViewModel*)getChildrenByIndex:(NSInteger)index;
-(void)setFileName:(NSString*)oldPath
            toName:(NSString*)newName;
-(void)setFileNameOfParent:(NSString*)name
          atComponentIndex:(NSInteger)index;
-(NSInteger)numberOfChildren;
-(void)checkPath:(NSString*)path;
-(void)updateFilePath:(NSString*)newPath;
-(void)addDocumentModel:(DocumentModel*)newModel
                 atPath:(NSString*)path;
-(void)addExitsingChildren:(FileViewModel*)newChildren;
-(void)removeChildren:(FileViewModel*) childrenModel;
@end
