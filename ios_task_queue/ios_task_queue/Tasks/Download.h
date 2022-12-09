

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSInteger, DownloadState) {
    DownloadStateWaiting,
    DownloadStateRunning,
    DownloadStatePaused,
    DownloadStateFinished,
    DownloadStateCanceled,
    DownloadStateFailed
};

@interface Download : NSObject
@property(nonatomic) DownloadState state;
@property(nonatomic) NSString *identifier;
@property(nonatomic) float progress;
@end

NS_ASSUME_NONNULL_END
