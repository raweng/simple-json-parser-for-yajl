//
//  JSONParser.m
//  YAJLDemo
//
//  Created by Gautam Lodhiya on 05/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "JSONParser.h"
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

static NSString* kDictionaryEntityName = @"parent";

static int kNumberOfInternalKeys = 3;



@interface JSONParser () {
    YAJLParser* parser;    
    NSMutableArray* _objectStack;
}

- (NSObject*)prepareObjectForElementName:(NSString*)elementName OfType:(NSString*)type;
- (NSObject*)allocObjectForElementName:(NSString*)elementName withAttributes:(NSMutableDictionary**)attributeDict;
- (void)addChildObject:(NSObject*)childObject toObject:(NSObject*)parentObject;
- (void)addElementName:(NSString*)elementName toObject:(NSObject*)toObject;
- (void)addValue:(NSString*)value toObject:(NSObject*)toObject;
- (void)stepBackUpTheTree;

@end



@implementation JSONParser

@synthesize receiveEvents;
@synthesize JSONParserDelegate;
@synthesize rootObject = _rootObject;
@synthesize rootObjectEntityName = _rootObjectEntityName;


#pragma mark -
#pragma mark Initialization

- (id)init {
    if(self == [super init]) {
        parser = [[YAJLParser alloc] initWithParserOptions:YAJLParserOptionsAllowComments];
        parser.delegate = self;
        
        self.receiveEvents = NO;
        _objectStack = [[NSMutableArray alloc] init];
    }
    return self;
}



#pragma mark -
#pragma mark Cleanup

- (void)dealloc {
    [_objectStack release];
    _objectStack = nil;
    self.rootObjectEntityName = nil;
    self.rootObject = nil;
    parser.delegate = nil;
    [parser release];
    
    [super dealloc];
}




#pragma mark -
#pragma mark Public methods

- (YAJLParserStatus)parse:(NSString*)str {
    NSData* data = [str dataUsingEncoding:NSUTF8StringEncoding];
    YAJLParserStatus status = [parser parse:data];
    
    return status;
}

- (YAJLParserStatus)parseWithData:(NSData*)data {
    YAJLParserStatus status = [parser parse:data];
    return status;
}



- (NSString*)rootObjectEntityName {
    return [((NSMutableDictionary*)_rootObject) objectForKey:kInternalKey_EntityName];
}



#pragma mark -
#pragma mark Private Helper Methods

- (NSObject*)prepareObjectForElementName:(NSString*)elementName OfType:(NSString*)type {
    NSMutableDictionary* attrHashMap = [[NSMutableDictionary alloc] init];
    [attrHashMap setValue:type forKey:kCommonKey_Type];
    NSObject* object = [self allocObjectForElementName:elementName withAttributes:&attrHashMap] ;
    [attrHashMap release];
    attrHashMap = nil;
    
    if (object == nil) {
        object = nil;
    }
    
    if (_objectStack.count > 0) {
        [self addChildObject:object toObject:[_objectStack objectAtIndex:(_objectStack.count - 1)]];
    }
    
    return object;
}

- (NSObject*)allocObjectForElementName:(NSString*)elementName withAttributes:(NSMutableDictionary**)attributeDict {
    NSMutableDictionary* attrDictionary = *attributeDict;
    NSObject* object = [NSMutableDictionary dictionaryWithCapacity:(kNumberOfInternalKeys + attrDictionary.count)];
    
    NSString* type = nil;
    if ([attrDictionary objectForKey:kCommonKey_Type]) {
        type = [attrDictionary objectForKey:kCommonKey_Type];
    }
    
    if (type == nil) {
        type = kCommonType_Unknown;
    }
    
    if ([type isEqualToString:kCommonType_Array]) {
        NSMutableArray* array = [[NSMutableArray alloc] init];
        [((NSMutableDictionary*)object) setObject:array forKey:kInternalKey_Array];
        [array release];
        array = nil;
    }
    
    [object setValuesForKeysWithDictionary:attrDictionary];
    [self addElementName:elementName toObject:object];
    [object setValue:type forKey:kInternalKey_EntityType];
    
    return object;
}

- (void)addChildObject:(NSObject*)childObject toObject:(NSObject*)parentObject { 
    if ([parentObject isKindOfClass:[NSMutableDictionary class]]) {
        if ([[((NSMutableDictionary*)parentObject) objectForKey:kInternalKey_EntityType] isEqualToString:kCommonType_Array]) {            
            // Yes, it is. Let's add this object to the array then.
            if (childObject) {                
                [((NSMutableArray*) [((NSMutableDictionary*)parentObject) objectForKey:kInternalKey_Array]) addObject:childObject];
            }
            
            // Is it any type?
        } else if ([((NSMutableDictionary*)parentObject) objectForKey:kInternalKey_EntityType]) {
            NSString* entityName = [((NSMutableDictionary*)childObject) objectForKey:kInternalKey_EntityName];
            NSObject* entityObject = [((NSMutableDictionary*)parentObject) objectForKey:entityName];            
            
            if (entityObject == nil) {
                // No collision, add it!
                [((NSMutableDictionary*)parentObject) setObject:childObject forKey:entityName];
                
            } else {
                // Collision, check if it's already an array. 
                if ([entityObject isKindOfClass:[NSMutableArray class]]) {
                    if (childObject) {
                        [((NSMutableArray*)entityObject) addObject:childObject];
                    }
                    
                } else {    
                    NSMutableArray* array = [[NSMutableArray alloc] init];
                    [array addObject:entityObject];
                    [array addObject:childObject];
                    [((NSMutableDictionary*)parentObject) setObject:array forKey:entityName];
                    [array release];
                    array = nil;
                }
            }
        }
    }
}

- (void)addElementName:(NSString*)elementName toObject:(NSObject*)toObject {
    if ([toObject isKindOfClass:[NSMutableDictionary class]]) {
        if (elementName == nil) {
            elementName = @"";
        }
        [((NSMutableDictionary*)toObject) setValue:elementName forKey:kInternalKey_EntityName];
    }    
}

- (void)addValue:(NSString*)value toObject:(NSObject*)toObject {
    if ([toObject isKindOfClass:[NSMutableDictionary class]]) {
        if (value == nil) {
            value = @"";
        }
        
        
        if ([[((NSMutableDictionary*)toObject) objectForKey:kInternalKey_EntityType] isEqualToString:kCommonType_Array]) {
            [((NSMutableArray*) [((NSMutableDictionary*)toObject) objectForKey:kInternalKey_Array]) addObject:value];
            
        } else {
            [((NSMutableDictionary*)toObject) setValue:value forKey:kInternalKey_EntityValue];
        }
    }
}

- (void)stepBackUpTheTree {
    if (!self.shouldReceiveEvents && _objectStack.count == 1) {
        _rootObject = [_objectStack objectAtIndex:(_objectStack.count - 1)];
    }
    
    // Now that we've finished a node, let's step back up the tree.
    [_objectStack removeObjectAtIndex:(_objectStack.count - 1)];    
}


-(void)notifyEvent:(BOOL)isArray {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    if ([JSONParserDelegate respondsToSelector:@selector(dictionary:forKey:withParents:)] && _objectStack.count > 1) {
        if (isArray) {            
            NSMutableDictionary* parentDict = ((NSMutableDictionary*)[_objectStack objectAtIndex:(_objectStack.count - 2)]);  
            if ([parentDict objectForKey:[[_objectStack objectAtIndex:(_objectStack.count - 1)]  objectForKey:kInternalKey_EntityName]]) {
                NSMutableString* parents = [[NSMutableString alloc] init];
                for (NSObject* obj in _objectStack) {
                    if ([obj isKindOfClass:[NSMutableDictionary class]]) {
                        if ([_objectStack indexOfObject:obj] != _objectStack.count - 1) {
                            if ([_objectStack indexOfObject:obj] != 0) {
                                [parents appendString:@", "];
                            }
                            [parents appendString:[((NSMutableDictionary*)obj) objectForKey:kInternalKey_EntityName]];
                        }                        
                    }
                }

                [JSONParserDelegate dictionary:[_objectStack objectAtIndex:(_objectStack.count - 1)] forKey:[[_objectStack objectAtIndex:(_objectStack.count - 1)]  objectForKey:kInternalKey_EntityName] withParents:parents];
                
                [parents release];
                parents = nil;
                [parentDict setValue:nil forKey:[[_objectStack objectAtIndex:(_objectStack.count - 1)]  objectForKey:kInternalKey_EntityName]];
                [parentDict removeObjectForKey:[[_objectStack objectAtIndex:(_objectStack.count - 1)]  objectForKey:kInternalKey_EntityName]];
            }
        }
    }
    [pool drain];
}



#pragma mark -
#pragma mark Delegate for YAJL JSON parser

- (void)parserDidStartDictionary:(YAJLParser *)parser {
    if (_objectStack.count == 0 || [[[_objectStack objectAtIndex:(_objectStack.count - 1)] objectForKey:kInternalKey_EntityType] isEqualToString:kCommonType_Array]) {        
        // If stack is 0, then kDictionaryEntityName will be 'parent'.        
        NSObject* object = [self prepareObjectForElementName:@"parent" OfType:kCommonType_Collection];    
        [_objectStack addObject:object];
    }
}

- (void)parserDidEndDictionary:(YAJLParser *)parser {
    if (self.shouldReceiveEvents && _objectStack.count > 1) {
        [self notifyEvent:(![[[_objectStack objectAtIndex:(_objectStack.count - 1)]  objectForKey:kInternalKey_EntityType] isEqualToString:kCommonType_Array])];    
    }
    
    if (_objectStack.count > 1) {
        [self stepBackUpTheTree];        
        
        if ([[[_objectStack objectAtIndex:(_objectStack.count - 1)] objectForKey:kInternalKey_EntityName] isEqualToString:@"parent"]) {
            [self stepBackUpTheTree];
        }    
    }
}


- (void)parserDidStartArray:(YAJLParser *)parser {
    if (_objectStack.count == 0) {
        NSObject* object = [self prepareObjectForElementName:kDictionaryEntityName OfType:kCommonType_Array];    
        [_objectStack addObject:object];
        
    } else {
        NSMutableDictionary* parentDict = ((NSMutableDictionary*)[_objectStack objectAtIndex:(_objectStack.count - 2)]);  
        if ([parentDict objectForKey:kDictionaryEntityName]) {
            [parentDict removeObjectForKey:kDictionaryEntityName];
        }        
        
        [self stepBackUpTheTree];        
        NSObject* object = [self prepareObjectForElementName:kDictionaryEntityName OfType:kCommonType_Array];  
        [_objectStack addObject:object];
    }
}

- (void)parserDidEndArray:(YAJLParser *)parser {
    if (self.shouldReceiveEvents && _objectStack.count > 1) {
        [self notifyEvent:[[[_objectStack objectAtIndex:(_objectStack.count - 1)]  objectForKey:kInternalKey_EntityType] isEqualToString:kCommonType_Array]] ; 
    }
    
    if (_objectStack.count > 1) {
        [self stepBackUpTheTree];
        
        if ([[[_objectStack objectAtIndex:(_objectStack.count - 1)] objectForKey:kInternalKey_EntityName] isEqualToString:@"parent"]) {
            [self stepBackUpTheTree];
        }
    }
}


- (void)parser:(YAJLParser *)parser didMapKey:(NSString *)key {
    kDictionaryEntityName = key;
    NSObject* object = [self prepareObjectForElementName:key OfType:kCommonType_Collection];  
    [_objectStack addObject:object];
}

- (void)parser:(YAJLParser *)parser didAdd:(id)value {
    [self addValue:value toObject:[_objectStack objectAtIndex:(_objectStack.count - 1)]];    
    
    if (![[[_objectStack objectAtIndex:(_objectStack.count - 1)] objectForKey:kCommonKey_Type] isEqualToString:kCommonType_Array]) {
        [self stepBackUpTheTree];
    }
}



@end
