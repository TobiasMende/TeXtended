//
//  MessageCoordinator.m
//  TeXtended
//
//  Created by Tobias Mende on 13.02.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import "MessageCoordinator.h"
#import "TrackingMessage.h"
#import <TMTHelperCollection/TMTLog.h>
static MessageCoordinator *instance;
static const NSArray *GENERATOR_TYPES_TO_USE;
@interface MessageCoordinator ()
- (NSArray *)messagesFromCollection:(NSDictionary *)collection forPath:(NSString *)path;
- (void)messagesDidChange:(NSNotification *)note;
- (void)insert:(NSArray *)messages forGenratorType:(TMTMessageGeneratorType)type andMainDocument:(NSString *)path;
@end

@implementation MessageCoordinator

+ (void)initialize {
    if ([self class] == [MessageCoordinator class]) {
        GENERATOR_TYPES_TO_USE = @[@(TMTLogFileParser), @(TMTLacheckParser), @(TMTChktexParser)];
    }
}

- (id)init {
    self = [super init];
    if (self) {
        generatorToGlobalMessagesMap = [NSMutableDictionary new];
        generatorToLocalMessagesMap = [NSMutableDictionary new];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messagesDidChange:) name:TMTMessagesDidChangeNotification object:nil];
        [self bind:@"logLevel" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:TMTLatexLogLevelKey] options:nil];
    }
    return self;
}


- (void)messagesDidChange:(NSNotification *)note {
    NSArray *messages = note.userInfo[TMTMessageCollectionKey];
    TMTMessageGeneratorType type = [note.userInfo[TMTMessageGeneratorTypeKey] unsignedLongValue];
    NSString *path = note.object;
    [self insert:messages forGenratorType:type andMainDocument:path];
    [[NSNotificationCenter defaultCenter] postNotificationName:TMTMainDocumentMessagesDidChangeNotification object:path userInfo:@{TMTMessageCollectionKey: [self messagesForMainDocumentPath:path]}];
}


- (void)insert:(NSArray *)messages forGenratorType:(TMTMessageGeneratorType)type andMainDocument:(NSString *)path {
    
    NSMutableDictionary *pathToGlobalMessagesMap = generatorToGlobalMessagesMap[@(type)];
    if (!pathToGlobalMessagesMap) {
        pathToGlobalMessagesMap = [NSMutableDictionary new];
        generatorToGlobalMessagesMap[@(type)] = pathToGlobalMessagesMap;
    }
    
    pathToGlobalMessagesMap[path] = messages;
    
    
    NSMutableDictionary *pathToLocalMessagesMap = generatorToLocalMessagesMap[@(type)];
    if (!pathToLocalMessagesMap) {
        pathToLocalMessagesMap = [NSMutableDictionary new];
        generatorToLocalMessagesMap[@(type)] = pathToLocalMessagesMap;
    }
    
    NSMutableSet *handledPaths = [NSMutableSet new];
    for (TrackingMessage *message in messages) {
        if (![handledPaths containsObject:message.document]) {
            pathToLocalMessagesMap[message.document] = [NSMutableArray new];
            [handledPaths addObject:message.document];
        }
        [pathToLocalMessagesMap[message.document] addObject:message];
    }
    
    
    for (NSString *path in handledPaths) {
        NSArray *messages = [self messagesForPartialDocumentPath:path];
        [[NSNotificationCenter defaultCenter] postNotificationName:TMTPartialMessagesDidChangeNotification object:path userInfo:@{TMTMessageCollectionKey: messages}];
    }
}

- (NSArray *)messagesForMainDocumentPath:(NSString *)path {
    return [self messagesFromCollection:generatorToGlobalMessagesMap forPath:path];
}

- (NSArray *)messagesForPartialDocumentPath:(NSString *)path {
    return [self messagesFromCollection:generatorToLocalMessagesMap forPath:path];
}

- (NSArray *)messagesFromCollection:(NSDictionary *)collection forPath :(NSString *)path {
    NSMutableArray *result = [NSMutableArray new];
    for(NSNumber *type in GENERATOR_TYPES_TO_USE) {
        NSMutableDictionary *pathToMessagesMap = collection[type];
        if (pathToMessagesMap && pathToMessagesMap[path]) {
            [result addObjectsFromArray:pathToMessagesMap[path]];
        }
    }
    return result;
}

- (void)clearMessagesForPath:(NSString *)path {
    for(NSNumber *type in GENERATOR_TYPES_TO_USE) {
        [generatorToGlobalMessagesMap[type] removeObjectForKey:path];
        [generatorToLocalMessagesMap[type] removeObjectForKey:path];
    }
}


+ (MessageCoordinator *)sharedMessageCoordinator {
    if (!instance) {
        instance = [MessageCoordinator new];
    }
    return instance;
}


- (void)dealloc {
    [self unbind:@"logLevel"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
