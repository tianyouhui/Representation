//
//  NSObject+Representation.h
//  Object
//
//  Created by tianyouhui on 7/17/15.
//  Copyright (c) 2015 Hesion 3D. All rights reserved.
//

#import <Foundation/Foundation.h>

#define REP_COLLECTION_TYPE(class_type)  @protocol class_type @end

#if !__has_feature(objc_arc)
#error "We must use in arc!"
#endif

@interface NSObject (Representation)

// representation is NSDictionary or NSArray
// if representation is NSDictionary, return object, else array.
// module name used in swift. Note that we only support class inherited from NSObject.
+ (id)objectWithRepresentation:(id)representation;
+ (id)objectWithRepresentation:(id)representation inModule:(NSString *)moduleName;

// Only plist or json.
+ (id)objectWithContentsOfFile:(NSString *)file;
+ (id)objectWithContentsOfFile:(NSString *)file inModule:(NSString *)moduleName;

// return NSDictionary or NSArray
- (id)representation;

// Used for unknown array types, such as swift or objc generic. @{@"key": @"Class"}
+ (void)setArrayClassType:(NSDictionary *)type;

// Need be override by subclass.
// If dictionary key is distinct with property.
// Dictionary key from property.
+ (NSString *)keyWithPropertyName:(NSString *)propertyName;

// We only supply date convert method.
// If value is NSString, format is such as "yyyyMMdd" and so on, if format is nil,
// the default format is RFC3339, which is "yyyy-MM-dd'T'HH:mm:ssZZZ".
// If value is NSNumber, it should be be milliseconds, and the format should be one
// selector of [@"dateWithTimeIntervalSinceNow:",
// @"dateWithTimeIntervalSinceReferenceDate:", @"dateWithTimeIntervalSince1970:"].
// If format is nil, the default is @"dateWithTimeIntervalSince1970:".
+ (NSDate *)dateWithValue:(id)value format:(NSString *)format;

@end
