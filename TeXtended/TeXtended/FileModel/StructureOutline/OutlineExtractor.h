//
//  OutlineExtractor.h
//  TeXtended
//
//  Created by Tobias Mende on 26.01.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DocumentModel;
@interface OutlineExtractor : NSObject
@property (readonly) BOOL isExtracting;
- (void)extractIn:(NSString *)content forModel:(DocumentModel *)model withCallback:(void (^) (NSArray *outline))completionHandler;
@end
