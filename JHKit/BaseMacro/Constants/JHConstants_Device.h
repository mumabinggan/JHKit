//
//  JHConstants_Device.h
//  JHKit
//
//  Created by muma on 16/10/4.
//  Copyright © 2016年 mumuxinxinCompany. All rights reserved.
//

#ifndef JHConstants_Device_h
#define JHConstants_Device_h

#define kMainScreenScale (UIScreen.mainScreen().scale)

#ifndef kDeviceWidth
    #define kDeviceWidth ([[UIScreen mainScreen] bounds].size.width)
#endif

#ifndef kDeviceHeight
    #define kDeviceHeight ([[UIScreen mainScreen] bounds].size.height)
#endif

#ifndef kAppFrame
    #define kAppFrame [[UIScreen mainScreen] applicationFrame]
#endif

#ifndef kAppBounds
    #define kAppBounds [[UIScreen mainScreen] bounds]
#endif

#ifndef kAppScale
    #define kAppScale [[UIScreen mainScreen] scale]
#endif

#ifndef kDeviceWidthScaleTo35Inch
    #define kDeviceWidthScaleTo35Inch (kDeviceWidth/320.0)
#endif

#ifndef kDeviceHeightScaleTo35Inch
    #define kDeviceHeightScaleTo35Inch (kDeviceHeight/480.0)
#endif

#ifndef kDeviceWidthScaleTo47Inch
    #define kDeviceWidthScaleTo47Inch (kDeviceWidth/375.0)
#endif

#ifndef kDeviceHeightScaleTo47Inch
    #define kDeviceHeightScaleTo47Inch (kDeviceHeight/667.0)
#endif

#ifndef kAppTabBarHeight
    #define kAppTabBarHeight 49
#endif

#ifndef kAppStateHeight
    #define kAppStateHeight [[UIApplication sharedApplication] statusBarFrame].size.height
#endif

#ifndef kAppNavigationBarHeight
    #define kAppNavigationBarHeight 44
#endif

#ifndef kAppNavigationVCY
    #define kAppNavigationVCY (kAppNavigationBarHeight + kAppStateHeight)
#endif

#define kAppAdaptHeight(height) (((NSInteger)((height) * kDeviceWidthScaleTo47Inch * kAppScale)) / kAppScale)

#define kAppAdaptWidth(width) (((NSInteger)((width) * kDeviceWidthScaleTo47Inch * kAppScale)) / kAppScale)

#define kAppSepratorLineHeight (1.0 / kAppScale)

#endif /* JHConstants_Device_h */
