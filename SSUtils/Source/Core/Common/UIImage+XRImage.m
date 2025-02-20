//
//  UIImage+XRImage.m
//  SSUtils
//
//  Created by yangsq on 2021/11/24.
//

#import "UIImage+XRImage.h"
#import <objc/runtime.h>
#define IS_IPHONE_Xr  ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(828, 1792), [[UIScreen mainScreen] currentMode].size) : NO) || ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1624), [[UIScreen mainScreen] currentMode].size) : NO)
@implementation UIImage (XRImage)
+ (void)load {
    static dispatch_once_t onceToken;
     dispatch_once(&onceToken, ^{

         Class selfClass = object_getClass([self class]);
         [self methodSwizzlingOrignalSel:@selector(imageNamed:inBundle:compatibleWithTraitCollection:) replaceSel:@selector(ss_imageNamed:inBundle:compatibleWithTraitCollection:) class:selfClass];
         [self methodSwizzlingOrignalSel:@selector(imageNamed:) replaceSel:@selector(ss_imageNamed:) class:selfClass];
     });
}

+ (void)methodSwizzlingOrignalSel:(SEL)orginalSel replaceSel:(SEL)replaceSel class:(Class)class {
    Method oriMethod = class_getInstanceMethod(class, orginalSel);
    Method cusMethod = class_getInstanceMethod(class, replaceSel);
    BOOL addSucc = class_addMethod(class, orginalSel, method_getImplementation(cusMethod), method_getTypeEncoding(cusMethod));
    if (addSucc) {
        class_replaceMethod(class, replaceSel, method_getImplementation(oriMethod), method_getTypeEncoding(oriMethod));
    }else {
        method_exchangeImplementations(oriMethod, cusMethod);
    }
}

+ (UIImage *)ss_imageNamed:(NSString *)name inBundle:(nullable NSBundle *)bundle compatibleWithTraitCollection:(nullable UITraitCollection *)traitCollection  {
//    CGFloat scale = IS_IPHONE_Xr ? 6 : [UIScreen mainScreen].scale;
//    UITraitCollection *traitC = [UITraitCollection traitCollectionWithDisplayScale: scale];
    return  [self ss_imageNamed:name inBundle:bundle compatibleWithTraitCollection:traitCollection];
}

+ (UIImage *)ss_imageNamed:(NSString *)name {
    return  [self ss_imageNamed:name];
}

@end
