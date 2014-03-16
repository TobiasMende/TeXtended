//
//  DBLPConfiguration.m
//  DBLP Tool
//
//  Created by Tobias Mende on 11.08.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "DBLPConfiguration.h"
#import <TMTHelperCollection/TMTLog.h>

static const NSString *SERVER_KEY = @"server";
static const NSString *AUTHOR_SEARCH_APPENDIX_KEY = @"authorSearchAppendix";
static const NSString *KEY_SEARCH_APPENDIX_KEY = @"keySearchAppendix";
static const NSString *BIBTEX_SEARCH_APPENDIX_KEY = @"bibtexSearchAppendix";

@interface DBLPConfiguration ()
- (void) appWillTerminate:(NSNotification*)note;
@end
@implementation DBLPConfiguration
- (id)init {
    self = [super init];
    if (self) {
        NSDictionary *config = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle bundleForClass:[self class]]pathForResource:@"DBLPConfiguration" ofType:@"plist"]];
        self.server = config[SERVER_KEY];
        self.authorSearchAppendix = config[AUTHOR_SEARCH_APPENDIX_KEY];
        self.keySearchAppendix = config[KEY_SEARCH_APPENDIX_KEY];
        self.bibtexSearchAppendix = config[BIBTEX_SEARCH_APPENDIX_KEY];
        if (![self configIsValid]) {
            DDLogError(@"Loading of config failed!");
        }
        NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self
               selector:@selector(appWillTerminate:)
                   name:NSApplicationWillTerminateNotification
                 object:nil];
    }
    return self;
}

+(DBLPConfiguration *)sharedInstance {
    static dispatch_once_t pred;
    static DBLPConfiguration *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[DBLPConfiguration alloc] init];
    });
    return shared;
}


- (BOOL)configIsValid {
    return self.server && self.authorSearchAppendix && self.keySearchAppendix && self.bibtexSearchAppendix;
}

- (void)appWillTerminate:(NSNotification *)note {
    if (self == DBLPConfiguration.sharedInstance) {
        NSDictionary *dict = @{SERVER_KEY: self.server, AUTHOR_SEARCH_APPENDIX_KEY: self.authorSearchAppendix, KEY_SEARCH_APPENDIX_KEY: self.keySearchAppendix, BIBTEX_SEARCH_APPENDIX_KEY: self.bibtexSearchAppendix};
        [dict writeToFile:[[NSBundle mainBundle]pathForResource:@"DBLPConfiguration" ofType:@"plist"] atomically:YES];
    }
}

@end
