//
//  RecorderProxy.mm
//  ProFootball
//
//  Created by Soli Nagosa on 10/05/2026.
//

// RecorderProxy.mm
#import <Foundation/Foundation.h>

// אנחנו מצהירים שהפונקציות האלו קיימות איפשהו (ב-Swift)
extern "C" {
    void startNativeRecording(int width, int height);
    void sendFrameToNative(void* texturePtr);
    void stopNativeRecording();
}

// אין צורך לכתוב כאן מימוש, רק ההצהרה ב-extern "C" גורמת ל-Linker של יוניטי למצוא אותן ב-Swift
