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
    __weak FileViewModel *parent;
}

@property (readonly) NSURL *presentedItemURL;
@property (readonly) NSOperationQueue *presentedItemOperationQueue;
@property (weak) DocumentModel *docModel;
@property (nonatomic, strong) NSString *filePath;
@property NSImage* icon;
@property NSString* fileName;
@property NSArray* pathComponents;
-(void)addPath:(NSString*)path;
-(FileViewModel*)getChildrenByName:(NSString*)name;
-(FileViewModel*)getChildrenByIndex:(NSInteger)index;
-(void)setFileName:(NSString*)oldPath
            toName:(NSString*)newName;
-(void)setFileNameOfParent:(NSString*)name
          atComponentIndex:(NSInteger)index;
-(NSInteger)numberOfChildren;
-(void)checkPath:(NSString*)path;
-(void)addDocumentModel:(DocumentModel*)newModel
                 atPath:(NSString*)path;
@end
