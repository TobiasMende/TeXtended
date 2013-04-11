//
//  LatexDocument.h
//  SimpleLatexEditor
//
//  Created by Tobias Mende on 04.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LatexDocument : NSObject
@property (strong) NSString *content;
@property (strong) NSURL *path;
@property (readonly,nonatomic) NSString* pdfPath;
- (NSString*)directoryPath;
@end
