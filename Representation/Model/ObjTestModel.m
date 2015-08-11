//
//  ObjTestModel.m
//  Representation
//
//  Created by tianyouhui on 11/8/15.
//  Copyright (c) 2015 Hesion 3d Inc. All rights reserved.
//

#import "ObjTestModel.h"

@implementation ObjTestModel

+ (instancetype)defaultModel {
    NSDictionary *dictionary = @{@"aa": @"aaaoboa", @"bb": @{@"ooo": @"hhh"},
                                 @"test": @{@"1": @{@"a": @"IIII", @"b": @230},
                                            @"2": @{@"a": @"OOOO", @"b": @36}}};
    ObjTestModel *model = [self objectWithRepresentation:dictionary];
    return model;
}

@end

@implementation TestModel

@end