//
//  CompletionManager.h
//  TeXtended
//
//  Created by Tobias Mende on 18.12.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CommandCompletion, EnvironmentCompletion, DropCompletion, CompletionTableController;
@interface CompletionManager : NSObject {
    NSMutableDictionary *commandCompletionTypeIndex;
}
/** The command completions
 @see CommandCompletion
 */
@property (strong)  CompletionTableController *commandCompletions;

/** The environment completions
 @see EnironmentCompletion
 */
@property (strong) CompletionTableController *environmentCompletions;

/** The drop completions
 @see DropCompletion
 */
@property (strong) CompletionTableController *dropCompletions;


+ (CompletionManager *)sharedInstance;

/**
 Method for loading the completions and creating appropriate completion objects.
 
 The method tries to load the completions from the application support folder. If no completion lists where found it loads the default lists from the application bundle
 */
- (void) loadCompletions;

- (void) saveCompletions;



- (void)addToTypeIndex:(CommandCompletion *)completion;
- (void)removeFromTypeIndex:(CommandCompletion *)completion;
- (NSMutableSet *)commandCompletionsByType:(NSString *)type;

- (NSAttributedString*)getDropCompletionForPath:(NSString*)path;

+ (NSSet*)specialSymbols;

@end
