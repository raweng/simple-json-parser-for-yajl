//
//  JSONParser.h
//  YAJLDemo
//
//  Created by Gautam Lodhiya on 05/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YAJLiOS/YAJL.h>


@protocol JSONParserDelegate <NSObject>
- (void)dictionary:(NSMutableDictionary*)dictionary forKey:(NSString*)key withParents:(NSString*)parents;
@end


@interface JSONParser : NSObject <YAJLParserDelegate> {
    NSObject* _rootObject;
}

@property(nonatomic, assign, getter = shouldReceiveEvents)BOOL receiveEvents;
@property(nonatomic, assign)id<JSONParserDelegate> JSONParserDelegate;
@property(nonatomic, retain)NSObject* rootObject;
@property(nonatomic, retain, getter = rootObjectEntityName)NSString* rootObjectEntityName;

- (YAJLParserStatus)parse:(NSString*)str;
- (YAJLParserStatus)parseWithData:(NSData*)data;
- (void)notifyEvent:(BOOL)isArray;

@end
