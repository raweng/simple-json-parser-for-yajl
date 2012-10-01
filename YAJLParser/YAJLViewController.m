//
//  YAJLViewController.m
//  YAJLDemo
//
//  Created by Gautam Lodhiya on 07/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "YAJLViewController.h"
#import "NSMutableDictionary+Extension.h"


@implementation YAJLViewController
@synthesize parser;
@synthesize status;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.view.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)loadView {
    [super loadView];
    
    UIButton *parseStreamJSONButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [parseStreamJSONButton setTitle:@"Parse Stream/Chunk JSON" forState:UIControlStateNormal];
    [parseStreamJSONButton setFrame:CGRectMake(20, 20, 50, 20)];
    [parseStreamJSONButton sizeToFit];
    [parseStreamJSONButton addTarget:self action:@selector(parseStreamEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:parseStreamJSONButton];
    
    
    UIButton *parseCompleteJSONButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [parseCompleteJSONButton setTitle:@"Parse Complete JSON" forState:UIControlStateNormal];
    [parseCompleteJSONButton setFrame:CGRectMake(20, parseStreamJSONButton.frame.origin.y + parseStreamJSONButton.frame.size.height + 20, 50, 20)];
    [parseCompleteJSONButton sizeToFit];
    [parseCompleteJSONButton addTarget:self action:@selector(parseCompleteEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:parseCompleteJSONButton];
}

- (void)parseStreamEvent:(id)sender {    
    [self parseStreamJSON];
}

- (void)parseCompleteEvent:(id)sender {
    [self parseCompleteJSON];
}



#pragma mark -
#pragma mark JSONParserDelegate methods

- (void)dictionary:(NSMutableDictionary*)dictionary forKey:(NSString*)key withParents:(NSString*)parents {
    // Handle response accordingly.
    NSLog(@"<key>: %@; <parents>: %@", key, parents);
    NSLog(@"<Dict>: %@: ", dictionary);
}



- (void)parseStreamJSON {
    NSString* path = [[NSBundle mainBundle] pathForResource:@"stream1"
                                                     ofType:@"json"];
    NSString* chunk1 = [NSString stringWithContentsOfFile:path
                                                 encoding:NSUTF8StringEncoding
                                                    error:NULL];
    
    NSString* path2 = [[NSBundle mainBundle] pathForResource:@"stream2"
                                                      ofType:@"json"];
    NSString* chunk2 = [NSString stringWithContentsOfFile:path2
                                                 encoding:NSUTF8StringEncoding
                                                    error:NULL];
    
    
    
    self.parser = [[JSONParser alloc] init];
    self.parser.JSONParserDelegate = self;
    self.parser.receiveEvents = YES;
    self.status = [self.parser parse:chunk1];
    self.status = [self.parser parse:chunk2];
    
    
    
    if (!self.parser.receiveEvents) {
        // Handle response accordingly.
        
        if (self.status == YAJLParserStatusInsufficientData || self.status == YAJLParserStatusOK) {
            NSMutableDictionary* rootDictionary = (NSMutableDictionary*)[self.parser rootObject];
            
            
            
            
            NSMutableDictionary* glossaryDictionary = [rootDictionary objectForKey:@"glossary"];
            NSMutableDictionary* titleDictionary = [glossaryDictionary objectForKey:@"title"];
            NSString* title = (NSString *)[titleDictionary objectForNode];
            
            
            NSMutableDictionary* glossaryDivDictionary = [glossaryDictionary objectForKey:@"GlossDiv"];
            NSMutableDictionary* dicTitleDictionary = [glossaryDivDictionary objectForKey:@"title"];
            NSString* divTitle = (NSString *)[dicTitleDictionary objectForNode];
            
            
            NSMutableDictionary* glossListDictionary = [glossaryDivDictionary objectForKey:@"GlossList"];
            NSMutableDictionary* glossEntryDictionary = [glossListDictionary objectForKey:@"GlossEntry"];
            NSMutableDictionary* glossDefDictionary = [glossEntryDictionary objectForKey:@"GlossDef"];
            NSMutableDictionary* glossSeeAlsoDictionary = [glossDefDictionary objectForKey:@"GlossSeeAlso"];
            
            
            
            
            NSLog(@"rootDictionary: %@", rootDictionary);
            NSLog(@"title: %@", title);
            NSLog(@"divTitle: %@", divTitle);
            NSLog(@"glossSeeAlsoDictionary: %@", [glossSeeAlsoDictionary objectForNode]);
        }
        
        if (self.status == YAJLParserStatusError) {
            // error
        }
    }
    
    
    NSLog(@"================================================");
    NSLog(@"\n\n\n\n\n\n\n");
}

- (void)parseCompleteJSON {
    NSString* path = [[NSBundle mainBundle] pathForResource:@"complete" ofType:@"json"];
    NSString* chunk = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    
    
    self.parser = [[JSONParser alloc] init];
    self.parser.JSONParserDelegate = self;
    self.parser.receiveEvents = NO;
    self.status = [self.parser parse:chunk];
    
    
    if (!self.parser.receiveEvents) {
        // Handle response accordingly.
        
        if (self.status == YAJLParserStatusInsufficientData || self.status == YAJLParserStatusOK) {
            NSMutableDictionary* rootDictionary = (NSMutableDictionary*)[self.parser rootObject];
            
            
            NSMutableDictionary* menuDict = [rootDictionary objectForKey:@"menu"];
            NSMutableDictionary* nameDict = [menuDict objectForKey:@"header"];
            NSString* header = (NSString *)[nameDict objectForNode];
            NSLog(@"header: %@", header);
            
            NSMutableDictionary* windowDict = [menuDict objectForKey:@"items"];
            NSMutableArray* arr = (NSMutableArray*)[windowDict objectForNode];
            for (NSMutableDictionary* dict in arr) {
                if ([dict objectForKey:@"label"]) {
                    NSMutableDictionary* idDict = [dict objectForKey:@"label"];
                    NSLog(@"obj: %@", [idDict objectForNode]);
                }
            }
        }
        
        if (self.status == YAJLParserStatusError) {
            // error
        }
    }
    
    
    NSLog(@"================================================");
    NSLog(@"\n\n\n\n\n\n\n");
}




#pragma mark -
#pragma mark Cleanup

- (void)dealloc {
    self.parser.JSONParserDelegate = nil;
    self.parser = nil;
    
    [super dealloc];
}


@end
