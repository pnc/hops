#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <QuickLook/QuickLook.h>
#import <Foundation/Foundation.h>
#import "PCApplicationPreview.h"

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options);
void CancelPreviewGeneration(void *thisInterface, QLPreviewRequestRef preview);

/* -----------------------------------------------------------------------------
   Generate a preview for file

   This function's job is to create preview for designated file
   ----------------------------------------------------------------------------- */

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef request, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options) {
  PCApplicationPreview *preview = [[PCApplicationPreview alloc]
                                   initWithURL:(__bridge NSURL *)(url)];
  @autoreleasepool {
    NSError *error = nil;
    BOOL result = [preview generate:&error];
    if (result) {
      NSData *data = [preview.HTML dataUsingEncoding:NSUTF8StringEncoding];
      QLPreviewRequestSetDataRepresentation(request,
                                            (__bridge CFDataRef)data,
                                            kUTTypeHTML,
                                            NULL);
    } else {
      NSLog(@"Hops: Unable to generate preview for IPA: %@", error);
    }
  }
  return noErr;
}

void CancelPreviewGeneration(void *thisInterface, QLPreviewRequestRef preview)
{
    // Implement only if supported
}
