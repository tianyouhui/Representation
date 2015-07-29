//
//  ResponseModel.h
//  RepresentationDemo
//
//  Created by tianyouhui on 7/24/15.
//  Copyright © 2015 Hesion 3D. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+Representation.h"
//
REP_COLLECTION_TYPE(GitHubRepoModel)

@interface GitHubRepoModel : NSObject

@property (strong, nonatomic) NSString* created;
@property (strong, nonatomic) NSString* pushed_at;
@property (strong, nonatomic) NSString* created_at;
@property (strong, nonatomic) NSString* pushed;
@property (assign, nonatomic) int watchers;
@property (strong, nonatomic) NSString* owner;
@property (assign, nonatomic) int forks;
@property (strong, nonatomic) NSString* language;
@property (assign, nonatomic) BOOL fork;
@property (assign, nonatomic) double size;
@property (assign, nonatomic) int followers;
@property (strong, nonatomic) NSString* name;
// It is not a good idea to have a description property, because description can not be used for debugging properly anymore.
@property (strong, nonatomic) NSString *desc;

@end

@interface ReposModel : NSObject

@property (strong, nonatomic) NSArray<GitHubRepoModel> *repositories;

- (void)checkDate;

@end
