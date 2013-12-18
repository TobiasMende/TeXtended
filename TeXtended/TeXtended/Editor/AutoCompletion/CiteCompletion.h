//
//  CiteCompletion.h
//  TeXtended
//
//  Created by Tobias Mende on 18.12.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CompletionProtocol.h"
@class DBLPPublication;
@interface CiteCompletion : NSObject <CompletionProtocol>
@property DBLPPublication *entry;
@end
