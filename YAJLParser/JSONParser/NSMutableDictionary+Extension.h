//
//  NSMutableDictionary+Extension.h
//  YAJLDemo
//
//  Created by Gautam Lodhiya on 07/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (Extension)

- (NSString*)nameForNode;
- (NSString*)typeForNode;
- (NSObject*)objectForNode;
- (NSMutableArray*)arrayForKey:(NSObject*)key;

@end
