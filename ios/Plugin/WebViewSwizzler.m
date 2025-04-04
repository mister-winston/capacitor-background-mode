#import "WebViewSwizzler.h"
#import "APPMethodMagic.h"
#import <objc/runtime.h>
#import <Foundation/Foundation.h>

@implementation WebViewSwizzler

#define IsAtLeastiOSVersion(version) ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:(NSOperatingSystemVersion){version, 0, 0}])

/**
 * Find out if the app runs inside the webkit powered webview.
 */
+ (BOOL) isRunningWebKit
{
    return IsAtLeastiOSVersion(8) && NSClassFromString(@"CDVWKWebViewEngine");
}

+ (NSString*) wkProperty
{
    NSString* str = @"YWx3YXlzUnVuc0F0Rm9yZWdyb3VuZFByaW9yaXR5";
    NSData* data  = [[NSData alloc] initWithBase64EncodedString:str options:0];

    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

+ (void)swizzleWebViewEngine {
    if (![self isRunningWebKit])
        return;
    
    Class wkWebViewEngineCls = NSClassFromString(@"CDVWKWebViewEngine");
    SEL selector = NSSelectorFromString(@"createConfigurationFromSettings:");

    if (!wkWebViewEngineCls || !selector) {
        NSLog(@"CDVWKWebViewEngine not found, skipping swizzling.");
        return;
    }

    SwizzleSelectorWithBlock_Begin(wkWebViewEngineCls, selector)
    ^(id self, NSDictionary *settings) {
        id obj = ((id (*)(id, SEL, NSDictionary*))_imp)(self, _cmd, settings);

        [obj setValue:[NSNumber numberWithBool:YES] forKey:[WebViewSwizzler wkProperty]];
        [obj setValue:[NSNumber numberWithBool:NO] forKey:@"requiresUserActionForMediaPlayback"];

        return obj;
    }
    SwizzleSelectorWithBlock_End;
}

@end
