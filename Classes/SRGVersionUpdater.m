//
//  SRGVersionUpdater.m
//  Example
//
//  Created by Kazuhiro Sakamoto on 2015/01/22.
//  Copyright (c) 2015年 Soragoto. All rights reserved.
//

#import "SRGVersionUpdater.h"
#import "UIAlertView+Blocks.h"
#import "AFHTTPSessionManager.h"

@implementation SRGVersionUpdater {
    NSDictionary *versionInfo;
}

#ifndef SRGVersionUpdaterLocalizedStrings
#define SRGVersionUpdaterLocalizedStrings(key) \
NSLocalizedStringFromTableInBundle(key, @"SRGVersionUpdater", [NSBundle bundleWithPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"SRGVersionUpdater.bundle"]], nil)
#endif

- (void) executeVersionCheck {
    NSAssert(_endPointUrl, @"Set EndPointUrl Before Execute Check");
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.session.configuration.URLCache = nil;
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"application/json",nil];
    [manager GET:_endPointUrl parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        versionInfo = responseObject;
        [self showUpdateAnnounceIfNeeded];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Request Operation Error! %@", error);
    }];
}

- (void) showUpdateAnnounceIfNeeded {
    if( ![self isVersionUpNeeded] ) {
        return;
    }
    [self showUpdateAnnounce];
}

- (BOOL) isVersionUpNeeded {
    NSString *currentVersion  = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *requiredVersion = versionInfo[@"required_version"];
    
    return ( [requiredVersion compare:currentVersion options:NSNumericSearch] == NSOrderedDescending );
}

- (void) showUpdateAnnounce {
    BOOL hasCancelButton = [versionInfo[@"type"] isEqualToString:@"optional"];
    NSInteger updateIndex = hasCancelButton ? 1 : 0;
    [UIAlertView showWithTitle:[self alertTitle]
                       message:[self alertBody]
             cancelButtonTitle:hasCancelButton ? [self cancelButtonText] : nil
             otherButtonTitles:@[[self updateButtonText]]
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex){
                          if (buttonIndex == updateIndex) {
                              NSURL *updateUrl = [NSURL URLWithString:versionInfo[@"update_url"]];
                              [[UIApplication sharedApplication] openURL:updateUrl];
                          }
                      }];
}

- (NSString *) alertTitle {
    return _customAlertTitle ? _customAlertTitle : [self localizedStringWithFormat:@"SRGVersionUpdater.alert.title"];
}

- (NSString *) alertBody {
    return _customAlertBody ? _customAlertBody : [self localizedStringWithFormat:@"SRGVersionUpdater.alert.body"];
}

- (NSString *) updateButtonText {
    return [self localizedStringWithFormat:@"SRGVersionUpdater.alert.updateButton"];
}

- (NSString *) cancelButtonText {
    return [self localizedStringWithFormat:@"SRGVersionUpdater.alert.calcelButton"];
}

- (NSInteger) versionNumberFromString:(NSString *)versionString{
    return [[versionString stringByReplacingOccurrencesOfString:@"." withString:@""] intValue];
}

- (NSString *) localizedStringWithFormat:(NSString *)format {
    return SRGVersionUpdaterLocalizedStrings(format);
}

@end
