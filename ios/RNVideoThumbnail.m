#import "RNVideoThumbnail.h"

@implementation RNVideoThumbnail

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(get:(NSString *)filepath resolve:(RCTPromiseResolveBlock)resolve
                               reject:(RCTPromiseRejectBlock)reject)
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @try {
            NSString *newfilepath = [filepath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
            NSURL *vidURL = [NSURL fileURLWithPath:newfilepath];

            AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:vidURL options:nil];
            AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
            generator.appliesPreferredTrackTransform = YES;

            NSError *err = NULL;
            CMTime time = CMTimeMake(0, 60);

            CGImageRef imgRef = [generator copyCGImageAtTime:time actualTime:NULL error:&err];
            UIImage *thumbnail = [UIImage imageWithCGImage:imgRef];

            NSMutableDictionary *result = [NSMutableDictionary new];
            if (thumbnail) {
                CMTime duration = asset.duration;
                [result setObject:@(thumbnail.size.width) forKey:@"width"];
                [result setObject:@(thumbnail.size.height) forKey:@"height"];
                [result setObject:@(CMTimeGetSeconds(duration)) forKey:@"duration"];

                NSString *header = @"data:image/png;base64,";
                NSString *imgdata = [UIImagePNGRepresentation(thumbnail) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
                NSString *data = [header stringByAppendingString:imgdata];

                [result setObject:data forKey:@"data"];
            }
            CGImageRelease(imgRef);

            resolve(result);

        } @catch(NSException *e) {
            reject(e.reason, nil, nil);
        }
    });
}


@end
