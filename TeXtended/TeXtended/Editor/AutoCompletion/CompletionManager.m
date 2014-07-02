//
//  CompletionManager.m
//  TeXtended
//
//  Created by Tobias Mende on 18.12.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "CompletionManager.h"
#import "CommandCompletion.h"
#import "EnvironmentCompletion.h"
#import "DropCompletion.h"
#import "CompletionTableController.h"
#import <TMTHelperCollection/TMTLog.h>

static CompletionManager *instance;

static NSSet *SPECIAL_SYMBOLS;

@implementation CompletionManager

#pragma mark - Initializing & Deallocation

    + (void)initialize
    {
        if ([self class] == [CompletionManager class]) {
            SPECIAL_SYMBOLS = [NSSet setWithObjects:@"{", @"}", @"[", @"]", @"(", @")", @" ", nil];
        }
    }

    - (id)init
    {
        self = [super init];
        if (self) {
            instance = self;
            commandCompletionTypeIndex = [NSMutableDictionary new];
            self.commandCompletions = [[CompletionTableController alloc] initWithFileName:@"CommandCompletions" andContentType:[CommandCompletion class]];
            self.environmentCompletions = [[CompletionTableController alloc] initWithFileName:@"EnvironmentCompletions" andContentType:[EnvironmentCompletion class]];
            self.dropCompletions = [[CompletionTableController alloc] initWithFileName:@"DropCompletions" andContentType:[DropCompletion class]];
            [self loadCompletions];
        }
        return self;
    }

    + (CompletionManager *)sharedInstance
    {
        if (!instance) {
            instance = [CompletionManager new];
        }
        return instance;
    }


#pragma mark -
#pragma mark Loading & Saving

    - (void)loadCompletions
    {
        [self.commandCompletions loadCompletions];
        [self.environmentCompletions loadCompletions];
        [self.dropCompletions loadCompletions];
    }


    - (void)saveCompletions
    {
        [self.commandCompletions saveCompletions];
        [self.environmentCompletions saveCompletions];
        [self.dropCompletions saveCompletions];

    }

#pragma mark - Maintaining the Command Completion Type Index

    - (void)addToTypeIndex:(CommandCompletion *)completion
    {
        NSMutableSet *completions = [self commandCompletionsByType:completion.completionType];
        if (!completions) {
            completions = [NSMutableSet new];
            commandCompletionTypeIndex[completion.completionType] = completions;
        }
        [completions addObject:[NSValue valueWithNonretainedObject:completion]];
        DDLogInfo(@"Adding %@", completion);

    }

    - (void)removeFromTypeIndex:(CommandCompletion *)completion
    {
        NSMutableSet *completions = [self commandCompletionsByType:completion.completionType];
        if (completions) {
            [completions removeObject:[NSValue valueWithNonretainedObject:completion]];
            DDLogInfo(@"Removing %@", completion);
            if (completions.count == 0) {
                [commandCompletionTypeIndex removeObjectForKey:completion.completionType];
            }
        }
    }

    - (NSMutableSet *)commandCompletionsByType:(NSString *)type
    {
        return commandCompletionTypeIndex[type];
    }

#pragma mark - Maintaining the Drops

    - (NSAttributedString *)getDropCompletionForPath:(NSString *)path
    {
        NSString *pathExtension = [path pathExtension];
        for (DropCompletion *dropCompletion in self.dropCompletions.completions) {
            
            if ([dropCompletion.fileExtensions containsObject:pathExtension.lowercaseString]) {
                return [dropCompletion getCompletion:path];
            }
        }
        // return the path by default.
        return [[NSAttributedString alloc] initWithString:path];
    }

    + (NSSet *)specialSymbols
    {
        return SPECIAL_SYMBOLS;
    }

@end
