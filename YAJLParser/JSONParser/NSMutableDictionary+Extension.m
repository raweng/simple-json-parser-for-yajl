//
//  NSMutableDictionary+Extension.m
//  YAJLDemo
//
//  Created by Gautam Lodhiya on 07/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSMutableDictionary+Extension.h"



// Attribute keys
static NSString* kCommonKey_Type = @"type";

// Object types
static NSString* kCommonType_Array = @"array";
static NSString* kCommonType_Collection = @"collection";
static NSString* kCommonType_Unknown = @"unknown";

// Internal key names for the resulting Dictionary
static NSString* kInternalKey_EntityName = @"___Entity_Name___";
static NSString* kInternalKey_EntityType = @"___Entity_Type___";
static NSString* kInternalKey_EntityValue = @"___Entity_Value___";
static NSString* kInternalKey_Array = @"___Array___";

static NSString* kInternalKey_Parent = @"parent";



@implementation NSMutableDictionary (Extension)

- (NSString*)nameForNode {
    return [self objectForKey:kInternalKey_EntityName];
}

- (NSString*)typeForNode {
    return [self objectForKey:kInternalKey_EntityType];
}

- (NSObject*)objectForNode {
    if ([[self typeForNode] isEqualToString:kCommonType_Array]) {
        return [self objectForKey:kInternalKey_Array];
    } else {
        return [self objectForKey:kInternalKey_EntityValue];
    }
}

- (NSMutableArray*)arrayForKey:(NSObject*)key {
    NSMutableArray* finalList = [NSMutableArray new];
    // if it's not an array, then make it a 1-element array
    if (![[self objectForKey:key] isKindOfClass:[NSMutableArray class]]) {
        NSMutableArray* list = [NSMutableArray new];
        [list addObject:[self objectForKey:key]];
        finalList = list;
    } else {
        return ((NSMutableArray*)[self objectForKey:key]);
    }
    
    return finalList;
}

@end
