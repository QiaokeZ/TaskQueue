

#import "Task.h"
#import "Download.h"

NS_ASSUME_NONNULL_BEGIN

@interface DownloadTask : Task
- (instancetype)initWithDownloadDuration:(int)duration download:(Download *)download;
@property (nonatomic, readonly) int duration;
@property (nonatomic, readonly) Download *download;
@end

FOUNDATION_EXPORT NSString * const DownloadTaskDidUpdateNotification;

NS_ASSUME_NONNULL_END
