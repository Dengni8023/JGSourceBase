#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "JGSourceBase.h"
#import "JGSCCommon.h"
#import "JGSCWeakStrongProperty.h"
#import "JGSCLog.h"
#import "JGSCRuntime.h"

FOUNDATION_EXPORT double JGSourceBaseVersionNumber;
FOUNDATION_EXPORT const unsigned char JGSourceBaseVersionString[];

