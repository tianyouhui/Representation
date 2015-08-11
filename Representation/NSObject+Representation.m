//
//  NSObject+Representation.m
//  Object
//
//  Created by tianyouhui on 7/17/15.
//  Copyright (c) 2015 Hesion 3D. All rights reserved.
//

#import "NSObject+Representation.h"
#import <objc/runtime.h>

#ifndef __nonnull
#define __nonnull
#endif

static const void *REPPropertyKeys = &REPPropertyKeys;
static const NSString *REPSwiftModuleNameKey = @"#swiftREPModuleName";
static const NSString *REPPropertyEntryKey = @"#propertyREPEntry";

@implementation NSObject (Representation)

static BOOL REPIsScalarType(Class c) {
    static NSSet *scalarTypeSet;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        scalarTypeSet = [NSSet setWithObjects:[NSString class], [NSValue class],
                         [NSDate class], [NSData class], nil];
    });
    if (c == [NSObject class] || [scalarTypeSet containsObject:c]) {
        return YES;
    }
    __block BOOL result = NO;
    [scalarTypeSet enumerateObjectsUsingBlock:^(id  __nonnull obj, BOOL * __nonnull stop) {
        result = [c isSubclassOfClass:obj];
        if (result) {
            *stop = YES;
        }
    }];
    return result;
}

static NSDictionary *REPKeysForDictionaryRepresentationOfClass(Class cls) {
    // Dictionary that will hold properties names.
    NSMutableDictionary *dict = @{}.mutableCopy;
    
    // Go through superClasses from self class to NSObject to get all inherited properties.
    Class curClass = cls;
    while (1) {
        // Stop on NSObject.
        if (curClass == Nil || curClass == [NSObject class]) {
            break;
        }
        // Use objc runtime to get all properties and return their names.
        unsigned int outCount;
        objc_property_t *properties = class_copyPropertyList(curClass, &outCount);
        
        for (int i = outCount - 1; i >= 0; --i) {
            objc_property_t curProperty = properties[i];
            const char *name = property_getName(curProperty);
            
            NSString *propertyKey = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
            NSArray *array = REPPropertyClassKey(curClass, name);
            dict[propertyKey] = array ?: [NSNull null];
        }
        
        if (properties) {
            free(properties);
        }
        // Next.
        curClass = [curClass superclass];
    }
    return dict;
}

static NSArray *REPPropertyClassKey(Class class, const char *key) {
    objc_property_t property = class_getProperty(class, key);
    if (property) {
        const char *attributes = property_getAttributes(property);
        char *classNameCString = strstr(attributes, "@\"");
        if (classNameCString) {
            classNameCString += 2; //< skip @" substring
            NSMutableOrderedSet *set = [[NSMutableOrderedSet alloc] init];
            int j = 0;
            NSString *className;
            unsigned long length = strlen(classNameCString);
            char *p = calloc(length, sizeof(char));
            for (int i = 0; i < length; ++i) {
                switch (classNameCString[i]) {
                    case '"':
                    case '<':
                    case '>':
                        p[j++] = '\0';
                        j = 0;
                        className = [NSString stringWithCString:p encoding:NSUTF8StringEncoding];
                        [set addObject:className];
                        break;
                    case ' ':
                    case '\r':
                    case '\n':
                        break;
                    default:
                        p[j++] = classNameCString[i];
                        break;
                }
                if (classNameCString[i] == '"' || classNameCString[i] == '>') {
                    break;
                }
            }
            free(p);
            return [set array];
        }
    } else {
        // private.... ignore...
    }
    return nil;
}

+ (NSMutableDictionary *)__dictionaryForRepresentationKeys {
    NSMutableDictionary *dict = objc_getAssociatedObject(self, REPPropertyKeys);
    if (dict == nil) {
        dict = @{}.mutableCopy;
        dict[REPPropertyEntryKey] = REPKeysForDictionaryRepresentationOfClass(self);
        objc_setAssociatedObject(self, REPPropertyKeys, dict, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return dict;
}

+ (id)objectWithRepresentation:(id)representation {
    @autoreleasepool {
        return [self __objectWithRepresentation:representation inModule:nil];
    }
}

+ (id)objectWithRepresentation:(id)representation inModule:(NSString *)moduleName {
    @autoreleasepool {
        return [self __objectWithRepresentation:representation inModule:moduleName];
    }
}

+ (id)__objectWithRepresentation:(id)representation inModule:(NSString *)moduleName {
    if (moduleName) {
        [self __dictionaryForRepresentationKeys][REPSwiftModuleNameKey] = moduleName;
    }
    if ([representation isKindOfClass:[NSDictionary class]]) {
        return [self objectWithDictionaryRepresentation:representation];
    } else if ([representation isKindOfClass:[NSArray class]]) {
        NSMutableArray *array = @[].mutableCopy;
        for (id obj in representation) {
            [array addObject:[self __objectWithRepresentation:obj inModule:moduleName]];
        }
        return array;
    } else {
        return [[self alloc] init];
    }
}
+ (id)objectWithContentsOfFile:(NSString *)file {
    return [self objectWithContentsOfFile:file inModule:nil];
}

+ (id)objectWithContentsOfFile:(NSString *)file inModule:(NSString *)moduleName {
    NSData *data = [NSData dataWithContentsOfFile:file];
    if (data == nil) {
        return nil;
    }
    id obj = nil;
    NSError *error;
    NSString *fileExtension = [file pathExtension];
    if (![fileExtension isEqualToString:@"json"]) {
        obj = [NSPropertyListSerialization propertyListWithData:data options:0 format:NULL error:&error];
    }
    if (obj == nil) {
        obj = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        if (obj == nil) {
            NSLog(@"Error: %@", error);
            return nil; // Unknown format...
        }
    }
    return [self objectWithRepresentation:obj inModule:moduleName];
}

- (id)representation {
    @autoreleasepool {
        return [self __objectRepresentation];
    }
}

- (id)__objectRepresentation {
    if (REPIsScalarType([self class])) {
        return self;
    }
    id container;
    id rep = self;
    if ([self isKindOfClass:[NSArray class]]) {
        container = [[NSMutableArray alloc] init];
        for (id obj in rep) {
            id object = [obj representation];
            [container addObject:object];
        }
        return container;
    } else if ([self isKindOfClass:[NSDictionary class]]) {
        container = [[NSMutableDictionary alloc] init];
        for (id key in rep) {
            id object = [rep[key] representation];
            [container setObject:object forKey:key];
        }
        return container;
    } else {
        return [self dictionaryRepresentation];
    }
}

- (NSDictionary *)dictionaryRepresentation {
    NSDictionary *properties = [[self class] __dictionaryForRepresentationKeys];
    NSDictionary *dict = properties[REPPropertyEntryKey];
    NSMutableDictionary *dictionary = @{}.mutableCopy;
    [[dict allKeys] enumerateObjectsUsingBlock:^(id  __nonnull obj, NSUInteger idx, BOOL * __nonnull stop) {
        NSString *key = [[self class] keyWithPropertyName:obj];
        id object = [self valueForKey:obj];
        id value = [object __objectRepresentation];
        if (value) {
            dictionary[key] = value;
        }
    }];
    return dictionary;
}

+ (instancetype)objectWithDictionaryRepresentation:(NSDictionary *)representation {
    return [[self alloc] initWithDictionaryRepresentation:representation];
}

- (instancetype)initWithDictionaryRepresentation:(NSDictionary *)representation {
    if (![representation isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    self = [self init];
    NSDictionary *properties = [[self class] __dictionaryForRepresentationKeys];
    NSDictionary *dict = properties[REPPropertyEntryKey];
    [[dict allKeys] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *key = [[self class] keyWithPropertyName:obj];
        id value = representation[key];
        if ([value isEqual:[NSNull null]] ||
            ([value isKindOfClass:[NSString class]] && [value isEqualToString:@"<null>"])) {
            return;
        }

        value = [self decodeValue:value collectionClass:dict[obj] propertyName:obj];
        if (value) {
            [self setValue:value forKey:obj];
        }
    }];
    return self;
}

+ (void)setArrayClassType:(NSDictionary *)type {
    if ([type count]) {
        NSMutableDictionary *dict = [self __dictionaryForRepresentationKeys][REPPropertyEntryKey];
        for (NSString *key in type) {
            dict[key] = @[@"NSArray", type[key]];
        }
    }
}

+ (NSString *)keyWithPropertyName:(NSString *)propertyName {
    return propertyName;
}

- (id)decodeValue:(id)value collectionClass:(id)classes propertyName:(NSString *)name {
    if (classes == [NSNull null]) {
        return value;
    }
    NSString *firstClass = [classes firstObject];
    Class cls = NSClassFromString(firstClass);
    if (cls == Nil) {
        // is swift?
        NSString *moduleName = [[self class] __dictionaryForRepresentationKeys][REPSwiftModuleNameKey];
        if (moduleName && firstClass) {
            cls = NSClassFromString([@[moduleName, firstClass] componentsJoinedByString:@"."]);
            if (cls) {
                return [cls objectWithRepresentation:value inModule:moduleName];
            }
        }
        return value;
    } else if (REPIsScalarType([value class])) {
        return value;
    } else if ([cls isSubclassOfClass:[NSArray class]]) {
        NSArray *array = [classes subarrayWithRange:NSMakeRange(1, [classes count] - 1)];
        return [self decodeValue:value collectionClass:array propertyName:name];
    } else if ([value isKindOfClass:[NSArray class]]) {
        NSMutableArray *dstCollection = [NSMutableArray arrayWithCapacity:[value count]];
        [value enumerateObjectsUsingBlock:^(id  __nonnull obj, NSUInteger idx, BOOL * __nonnull stop) {
            id dstObject = [self decodeValue:obj collectionClass:classes propertyName:name];
            [dstCollection addObject:dstObject];
        }];
        return dstCollection;
    } else if ([value isKindOfClass:[NSDictionary class]]) {
        if (![cls isSubclassOfClass:[NSDictionary class]]) {
            return [cls objectWithDictionaryRepresentation:value];
        }
        NSMutableDictionary *dstCollection = [NSMutableDictionary dictionaryWithCapacity:[value count]];
        NSArray *array = [classes subarrayWithRange:NSMakeRange(1, [classes count] - 1)];
        for (NSString *curKey in value) {
            id decodeObject = [self decodeValue:value[curKey] collectionClass:array propertyName:name];
            dstCollection[curKey] = decodeObject;
        }
        return dstCollection;
    }
    
    return value;
}

+ (NSDate *)dateWithValue:(id)value format:(NSString *)format {
    if ([value isKindOfClass:[NSNumber class]]) {
        NSTimeInterval timeInterval = [value longLongValue] / 1000.0;
        SEL selector = format== nil ? @selector(dateWithTimeIntervalSince1970:) : NSSelectorFromString(format);
        return [NSDate performSelector:selector withObject:@(timeInterval)];
    } else if ([value isKindOfClass:[NSString class]]) {
        static NSCache *dateFormatters;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            dateFormatters = [[NSCache alloc] init];
        });
        format = format ?: @"yyyy-MM-dd'T'HH:mm:ssZZZ";
        NSDateFormatter *dateFormatter = [dateFormatters objectForKey:format];
        if (!dateFormatter) {
            dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:format];
            [dateFormatters setObject:dateFormatter forKey:format];
        }
        return [dateFormatter dateFromString:value];
    }
    return nil;
}

@end
