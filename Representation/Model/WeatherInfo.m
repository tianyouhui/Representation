//
//  WeatherInfo.m
//  Representation
//
//  Created by Tian Youhui on 15/7/26.
//  Copyright (c) 2015年 Hesion 3D. All rights reserved.
//

#import "WeatherInfo.h"

@implementation WeatherInfo

@end

@implementation WeatherData

@end

@implementation Forecast

@end

@implementation Forecasted

@dynamic fl, fx;

- (void)setFl:(NSString *)fl {
    self.fengli = fl;
}

- (NSString *)fl {
    return self.fengli;
}

- (void)setFx:(NSString *)fx {
    self.fengxiang = fx;
}

- (NSString *)fx {
    return self.fengxiang;
}

@end
