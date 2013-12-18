//
//  CompletionManager.m
//  TeXtended
//
//  Created by Tobias Mende on 18.12.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "CompletionManager.h"
#import "ApplicationController.h"
#import "CommandCompletion.h"
#import "Completion.h"
#import "EnvironmentCompletion.h"
#import "TMTLog.h"
static CompletionManager *instance;
static NSSet* SPECIAL_SYMBOLS;
@implementation CompletionManager

#pragma mark - Initializing & Deallocation

+(void)initialize {
    if ([self class] == [CompletionManager class]) {
        SPECIAL_SYMBOLS = [NSSet setWithObjects:@"{",@"}", @"[", @"]", @"(", @")", @" ", nil];
    }
}

- (id)init {
    self = [super init];
    if (self) {
        instance = self;
        commandCompletionTypeIndex = [NSMutableDictionary new];
        [self loadCompletions];
    }
    return self;
}

+ (CompletionManager *)sharedInstance {
    if (!instance) {
        instance = [CompletionManager new];
    }
    return instance;
}


#pragma mark -
#pragma mark Loading & Saving

- (void) loadCompletions {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *applicationSupport = [ApplicationController userApplicationSupportDirectoryPath];
    NSString *commandPath, *envPath;
    if (applicationSupport) {
        commandPath = [applicationSupport stringByAppendingPathComponent:@"CommandCompletions.plist"];
        envPath = [applicationSupport stringByAppendingPathComponent:@"EnvironmentCompletions.plist"];
        if (![fm fileExistsAtPath:commandPath]) {
            commandPath = nil;
        }
        if (![fm fileExistsAtPath:envPath]) {
            envPath = nil;
        }
    }
    
    if(!commandPath) {
        commandPath = [[NSBundle mainBundle] pathForResource:@"CommandCompletions" ofType:@"plist"];
    }
    if(!envPath) {
        envPath = [[NSBundle mainBundle] pathForResource:@"EnvironmentCompletions" ofType:@"plist"];
    }
    
    [self loadCommandCompletionsFromPath:commandPath];
    [self loadEnvironmentCompletionsFromPath:envPath];
}


- (void)loadCommandCompletionsFromPath:(NSString *)path {
    NSArray *commandDicts = [NSArray arrayWithContentsOfFile:path];
    self.commandCompletions = [[NSMutableDictionary alloc] initWithCapacity:commandDicts.count];
    self.commandKeys = [[NSMutableArray alloc] initWithCapacity:commandDicts.count];
    
    for(NSDictionary *d in commandDicts) {
        CommandCompletion *c = [[CommandCompletion alloc] initWithDictionary:d];
        [self addCommandCompletion:c];
    }
    [self.commandKeys sortUsingSelector:@selector(caseInsensitiveCompare:)];
}


- (void)loadEnvironmentCompletionsFromPath:(NSString *)path {
    NSArray *envDicts = [NSArray arrayWithContentsOfFile:path];
    self.environmentCompletions = [[NSMutableDictionary alloc] initWithCapacity:envDicts.count];
    self.environmentKeys = [[NSMutableArray alloc] initWithCapacity:envDicts.count];
    
    for(NSDictionary *d in envDicts) {
        EnvironmentCompletion *c = [[EnvironmentCompletion alloc] initWithDictionary:d];
        [self addEnvironmentCompletion:c];
    }
    [self.environmentKeys sortUsingSelector:@selector(caseInsensitiveCompare:)];
}


- (void) saveCompletions {
    NSString *commandPath;// = [[NSBundle mainBundle] pathForResource:@"CommandCompletions" ofType:@"plist"];
    NSString *envPath;// = [[NSBundle mainBundle] pathForResource:@"EnvironmentCompletions" ofType:@"plist"];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *applicationSupport = [ApplicationController userApplicationSupportDirectoryPath];
    if (applicationSupport) {
        commandPath = [applicationSupport stringByAppendingPathComponent:@"CommandCompletions.plist"];
        envPath = [applicationSupport stringByAppendingPathComponent:@"EnvironmentCompletions.plist"];
        if (![fm fileExistsAtPath:commandPath]) {
            [fm createFileAtPath:commandPath contents:nil attributes:nil];
        }
        if (![fm fileExistsAtPath:envPath]) {
            [fm createFileAtPath:envPath contents:nil attributes:nil];
        }
        // Storing Command Completions:
        NSMutableArray *commandSaving = [[NSMutableArray alloc] initWithCapacity:self.commandCompletions.count];
        for(CommandCompletion *c in [self.commandCompletions allValues]) {
            [commandSaving addObject:[c dictionaryRepresentation]];
        }
        [commandSaving writeToFile:commandPath atomically:YES];
        // Storing Environment Completions:
        NSMutableArray *envSaving = [[NSMutableArray alloc] initWithCapacity:self.commandCompletions.count];
        for(EnvironmentCompletion *c in [self.environmentCompletions allValues]) {
            [envSaving addObject:[c dictionaryRepresentation]];
        }
        [envSaving writeToFile:envPath atomically:YES];
    } else {
        DDLogWarn(@"Can't store user completions");
    }
    
    
}

#pragma mark - Modifying the Collections
- (void)addCommandCompletion:(CommandCompletion *)completion forKey:(id)key {
    [self.commandKeys addObject:key];
    [self.commandCompletions setObject:completion forKey:key];
}

- (void)addCommandCompletion:(CommandCompletion *)completion {
    [self addCommandCompletion:completion forKey:completion.key];
}


- (void)addEnvironmentCompletion:(EnvironmentCompletion *)completion forKey:(id)key {
    [self.environmentKeys addObject:key];
    [self.environmentCompletions setObject:completion forKey:key];
}

- (void)addEnvironmentCompletion:(EnvironmentCompletion *)completion {
    [self addEnvironmentCompletion:completion forKey:completion.key];
}

- (void)removeCommandsForKeys:(NSArray *)keys {
    [self.commandCompletions removeObjectsForKeys:keys];
    [self.commandKeys removeObjectsInArray:keys];
}

- (void)removeEnvironmentsForKeys:(NSArray *)keys {
    [self.environmentCompletions removeObjectsForKeys:keys];
    [self.environmentKeys removeObjectsInArray:keys];
}

- (void)setCommandCompletion:(CommandCompletion *)completion forIndex:(NSInteger)idx {
    [self.commandCompletions setObject:completion forKey:[completion key]];
    [self.commandKeys replaceObjectAtIndex:idx withObject:[completion key]];
    [self.commandKeys sortUsingSelector:@selector(caseInsensitiveCompare:)];
    if (completion.insertion && [completion.insertion length] != 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:TMTCommandCompletionsDidChangeNotification object:self];
    }
}

- (void)setEnvironmentCompletion:(EnvironmentCompletion *)completion forIndex:(NSInteger)idx {
    [self.environmentCompletions setObject:completion forKey:[completion key]];
    [self.environmentKeys replaceObjectAtIndex:idx withObject:[completion key]];
    [self.environmentKeys sortUsingSelector:@selector(caseInsensitiveCompare:)];
    if (completion.insertion && [completion.insertion length] != 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:TMTEnvironmentCompletionsDidChangeNotification object:self];
    }
}


#pragma mark - Maintaining the Command Completion Type Index

- (void)addToTypeIndex:(CommandCompletion *)completion {
    NSMutableSet *completions = [self commandCompletionsByType:completion.completionType];
    if (!completions) {
        completions = [NSMutableSet new];
        [commandCompletionTypeIndex setObject:completions forKey:completion.completionType];
    }
    [completions addObject:[NSValue valueWithNonretainedObject:completion]];
    DDLogInfo(@"Adding %@", completion);
    
}

- (void)removeFromTypeIndex:(CommandCompletion *)completion {
    NSMutableSet *completions = [self commandCompletionsByType:completion.completionType];
    if (completions) {
        [completions removeObject:[NSValue valueWithNonretainedObject:completion]];
        DDLogInfo(@"Removing %@", completion);
        if (completions.count == 0) {
            [commandCompletionTypeIndex removeObjectForKey:completion.completionType];
        }
    }
}

- (NSMutableSet *)commandCompletionsByType:(NSString *)type {
    return [commandCompletionTypeIndex objectForKey:type];
}

+ (NSSet *)specialSymbols {
    return SPECIAL_SYMBOLS;
}

@end
