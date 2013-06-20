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
    
    parseStreamJSONButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [parseStreamJSONButton setTitle:@"Parse Stream/Chunk JSON" forState:UIControlStateNormal];
    [parseStreamJSONButton setFrame:CGRectMake(20, 20, 50, 20)];
    [parseStreamJSONButton sizeToFit];
    [parseStreamJSONButton addTarget:self action:@selector(parseStreamEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:parseStreamJSONButton];
    
    
    parseCompleteJSONButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [parseCompleteJSONButton setTitle:@"Parse Complete JSON" forState:UIControlStateNormal];
    [parseCompleteJSONButton setFrame:CGRectMake(20, parseStreamJSONButton.frame.origin.y + parseStreamJSONButton.frame.size.height + 20, 50, 20)];
    [parseCompleteJSONButton sizeToFit];
    [parseCompleteJSONButton addTarget:self action:@selector(parseCompleteEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:parseCompleteJSONButton];
    
    
    outputLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(parseCompleteJSONButton.frame) + 20, CGRectGetWidth(self.view.frame) - 40, 20)];
    outputLabel.font = [UIFont systemFontOfSize:14];
    outputLabel.text = @"Human readable text";
    [self.view addSubview:outputLabel];
    
    
    outputTextView = [[UITextView alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(outputLabel.frame) + 5, CGRectGetWidth(self.view.frame) - 40, CGRectGetHeight(self.view.frame) - CGRectGetMaxY(outputLabel.frame) - 20)];
    outputTextView.font = [UIFont systemFontOfSize:14];
    outputTextView.backgroundColor = [UIColor lightGrayColor];
    outputTextView.text = [NSString stringWithFormat:@"%@", @"SAMPLE OUTPUT"];
    [self.view addSubview:outputTextView];
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
    
    
    if ([key isEqualToString:@"glossary"]) {
        NSMutableDictionary* titleDictionary = [dictionary objectForKey:@"title"];
        NSString* title = (NSString *)[titleDictionary objectForNode];
        outputTextView.text = [NSString stringWithFormat:@"Glossary title: %@", title];
    }
}



- (void)parseStreamJSON {
    NSLog(@"================================================\n");
    NSLog(@"====== START parseStreamJSON");
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
    [self.parser parse:chunk1];
    [self.parser parse:chunk2];
    
    NSLog(@"====== END parseStreamJSON");
    NSLog(@"================================================\n");
    NSLog(@"\n\n\n\n\n\n\n");
}

- (void)parseCompleteJSON {
    NSLog(@"================================================\n");
    NSLog(@"====== START parseCompleteJSON");
    
    
    NSString* path = [[NSBundle mainBundle] pathForResource:@"complete" ofType:@"json"];
    NSString* chunk = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    
    
    self.parser = [[JSONParser alloc] init];
    self.parser.JSONParserDelegate = self;
    self.parser.receiveEvents = NO;
    self.status = [self.parser parse:chunk];
    
    
    if (self.status == YAJLParserStatusOK) {
        NSMutableDictionary* rootDictionary = (NSMutableDictionary*)[self.parser rootObject];
        
        
        NSMutableDictionary* menuDict = [rootDictionary objectForKey:@"menu"];
        NSMutableDictionary* nameDict = [menuDict objectForKey:@"header"];
        NSString* header = (NSString *)[nameDict objectForNode];
        NSLog(@"header: %@", header);
        
        
        outputTextView.text = [NSString stringWithFormat:@"Menu header: %@", header];
        
        
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
    
    
    NSLog(@"====== END parseCompleteJSON");
    NSLog(@"================================================\n");
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
