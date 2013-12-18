//
//  CompletionProtocol.h
//  TeXtended
//
//  Created by Tobias Mende on 18.12.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CompletionProtocol <NSObject>
/** Method returns the word which is used during auto completion */
- (NSString*)autoCompletionWord;

/**
 Method for retreiving a key which represents the completion and can be shown to the user to identify this completion.
 @return a key string
 */
- (NSString*)key;
@end
