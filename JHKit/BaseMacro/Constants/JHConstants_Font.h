//
//  JHConstants_Font.h
//  JHKit
//
//  Created by muma on 16/10/4.
//  Copyright © 2016年 mumuxinxinCompany. All rights reserved.
//

#ifndef JHConstants_Font_h
#define JHConstants_Font_h

#define kFont(fsize, name) [UIFont fontWithName:name size:fsize]
#define kAppFont(size) [UIFont systemFontOfSize:size]
#define kAppFontBold(size) [UIFont boldSystemFontOfSize:size]

#define kAdaptFont(fsize, name) [UIFont fontWithName:name size:fsize*kDeviceWidthScaleTo47Inch]
#define kAppAdaptFont(size) [UIFont systemFontOfSize:size*kDeviceWidthScaleTo47Inch]
#define kAppAdaptFontBold(size) [UIFont boldSystemFontOfSize:size*kDeviceWidthScaleTo47Inch]

#endif /* JHConstants_Font_h */
