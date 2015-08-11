//
//  ObjTestModel.h
//  Representation
//
//  Created by tianyouhui on 11/8/15.
//  Copyright (c) 2015 Hesion 3d Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+Representation.h"

REP_COLLECTION_TYPE(TestModel)

@interface ObjTestModel : NSObject

@property(nonatomic, strong) NSString *aa;

@property(nonatomic, strong) NSDictionary *bb;

@property(nonatomic, strong) NSDictionary<TestModel> *test;

+ (instancetype)defaultModel;

@end

@interface TestModel : NSObject

@property(nonatomic, strong) NSString *a;
@property(nonatomic) NSInteger b;

@end
