//
//  ResponseModel.m
//  RepresentationDemo
//
//  Created by tianyouhui on 7/24/15.
//  Copyright © 2015 Hesion 3D. All rights reserved.
//

#import "ResponseModel.h"

@implementation GitHubRepoModel

+ (NSString *)keyWithPropertyName:(NSString *)propertyName {
    if ([propertyName isEqualToString:@"desc"]) {
        return @"description";
    }
    return propertyName;
}

@end

@implementation ReposModel

- (void)checkDate {
    for (GitHubRepoModel *model in self.repositories) {
        NSDate *date = [NSObject dateWithValue:model.created format:nil];
        NSLog(@"%@", [date descriptionWithLocale:[NSLocale currentLocale]]);
    }
}

@end
