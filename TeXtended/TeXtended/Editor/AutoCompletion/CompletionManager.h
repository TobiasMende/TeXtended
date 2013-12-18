//
//  CompletionManager.h
//  TeXtended
//
//  Created by Tobias Mende on 18.12.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CommandCompletion, EnvironmentCompletion;
@interface CompletionManager : NSObject {
    NSMutableDictionary *commandCompletionTypeIndex;
}
/** The command completions
 @see CommandCompletion
 */
@property (strong) NSMutableDictionary *commandCompletions;

/** The environment completions
 @see EnironmentCompletion
 */
@property (strong) NSMutableDictionary *environmentCompletions;

/** The keys for command completions */
@property (strong) NSMutableArray *commandKeys;

/** The keys for environment completions */
@property (strong) NSMutableArray *environmentKeys;



+ (CompletionManager *)sharedInstance;

/**
 Method for loading the completions and creating appropriate completion objects.
 
 The method tries to load the completions from the application support folder. If no completion lists where found it loads the default lists from the application bundle
 */
- (void) loadCompletions;

/** Loads command completions from a specific path
 @param path the path to load from
 */
- (void) loadCommandCompletionsFromPath:(NSString*) path;

/** Loads environment completions from a specific path
 @param path the path to load from
 */
- (void) loadEnvironmentCompletionsFromPath:(NSString* )path;

- (void) saveCompletions;

- (void) removeCommandsForKeys:(NSArray *)keys;
- (void) removeEnvironmentsForKeys:(NSArray *)keys;
- (void) addCommandCompletion:(CommandCompletion *)completion forKey:(id)key;
- (void) addEnvironmentCompletion:(EnvironmentCompletion *)completion forKey:(id)key;
- (void) addCommandCompletion:(CommandCompletion *)completion;
- (void) addEnvironmentCompletion:(EnvironmentCompletion *)completion;
- (void) setCommandCompletion:(CommandCompletion *)completion forIndex:(NSInteger)idx;
- (void) setEnvironmentCompletion:(EnvironmentCompletion *)completion forIndex:(NSInteger)idx;


- (void)addToTypeIndex:(CommandCompletion *)completion;
- (void)removeFromTypeIndex:(CommandCompletion *)completion;
- (NSMutableSet *)commandCompletionsByType:(NSString *)type;

+ (NSSet*)specialSymbols;

@end
