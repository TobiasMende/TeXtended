//
//  CompletionTableController.h
//  TeXtended
//
//  Created by Tobias Mende on 12.01.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CompletionTableController : NSObject {
    NSString *fileName;
    Class type;
}
@property (strong) NSMutableArray *completions;
- (id) initWithFileName:(NSString *)name andContentType:(Class)class;
- (void) loadCompletions;
- (void) loadCompletionsWithPath:(NSString *)path;
- (void) saveCompletions;
- (void) resetRanking;
- (void) resetDefaults;
@end
