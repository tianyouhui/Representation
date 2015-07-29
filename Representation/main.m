//
//  main.m
//  Representation
//
//  Created by Tian Youhui on 15/7/26.
//  Copyright (c) 2015年 Hesion 3D. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ResponseModel.h"
#import "WeatherInfo.h"
#import "Representation-swift.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSLog(@"Start");
        ReposModel *model;
        NSData *data = [NSData dataWithContentsOfFile:@"github-iphone.json"];
        id obj = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        for (int i = 0; i < 100; i++) {
            model = [ReposModel objectWithRepresentation:obj];
        }
        NSLog(@"End");
        [model checkDate];
        id dic = [model representation];
        NSLog(@"%@", dic);
        
        NSURL *url = [NSURL URLWithString:@"http://wthrcdn.etouch.cn/weather_mini?citykey=101010100"]; // 北京
        data = [NSData dataWithContentsOfURL:url];
        NSError *error;
        dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        if (dic == nil) {
            NSLog(@"%@", error);
        } else {
            NSLog(@"weather:%@", dic);
            WeatherInfo *info = [WeatherInfo objectWithRepresentation:dic];
            NSLog(@"%@", info);
        }
        NSString *search = @"https://api.douban.com/v2/music/search?q=中国";
        search = [search stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        url = [NSURL URLWithString:search];
        data = [NSData dataWithContentsOfURL:url];
        dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        if (dic == nil) {
            NSLog(@"%@", error);
        } else {
            NSLog(@"musics:%@", dic);
            [SearchMusics setArrayClassType:@{@"musics": @"Music"}];
            [Music setArrayClassType:@{@"tags": @"Tag"}];
            SearchMusics *result = [SearchMusics objectWithRepresentation:dic inModule:@"Representation"];
            Music *music = result.musics.lastObject;
            Tag *tag = music.tags.firstObject;
            NSLog(@"count is %ld, name is %@", tag.count, tag.name);
        }
    }
    return 0;
}
