//
//  WeatherInfo.h
//  Representation
//
//  Created by Tian Youhui on 15/7/26.
//  Copyright (c) 2015年 Hesion 3D. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+Representation.h"

REP_COLLECTION_TYPE(Forecast)

@class WeatherData, Forecasted;

@interface WeatherInfo : NSObject

@property(nonatomic, strong) NSString *desc;
@property(nonatomic) NSInteger status;
@property(nonatomic, strong) WeatherData *data;

@end

@interface WeatherData : NSObject

@property(nonatomic) NSInteger wendu;
@property(nonatomic, strong) NSString *ganmao;
@property(nonatomic, strong) NSArray<Forecast> *forecast; // Though XCode7 has Generic Type, we also should this protocol to simulate, because the generic cannot get the Forecast type but only NSArray.... In all, generic is compile time but not runtime.
@property(nonatomic, strong) Forecasted *yesterday;
@property(nonatomic) NSInteger aqi;
@property(nonatomic, strong) NSString *city;

@end

@interface Forecast : NSObject

@property(nonatomic, strong) NSString *fengxiang;
@property(nonatomic, strong) NSString *fengli;
@property(nonatomic, strong) NSString *high;
@property(nonatomic, strong) NSString *type;
@property(nonatomic, strong) NSString *low;
@property(nonatomic, strong) NSString *date; // If we use NSDate, we should use dateFormat...

@end

@interface Forecasted : Forecast

@property(nonatomic, strong) NSString *fx;
@property(nonatomic, strong) NSString *fl;

@end
