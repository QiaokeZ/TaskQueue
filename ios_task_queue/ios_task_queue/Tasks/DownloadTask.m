

#import "DownloadTask.h"
#define WeakObject(o) try{}@finally{} __weak typeof(o) o##Weak = o;
#define StrongObject(o) autoreleasepool{} __strong typeof(o) o = o##Weak;

NSString * const DownloadTaskDidUpdateNotification = @"DownloadTaskDidUpdateNotification";

@interface DownloadTask()
@property (nonatomic) NSTimer *timer;
@property (nonatomic) int timeCount;
@end

@implementation DownloadTask

- (instancetype)initWithDownloadDuration:(int)duration download:(Download *)download {
    if (self = [super init]) {
        _duration = duration;
        _download = download;
        self.download.state = DownloadStateWaiting;
        [[NSNotificationCenter defaultCenter] postNotificationName:DownloadTaskDidUpdateNotification
                                                            object:self
                                                          userInfo:@{@"download":self.download}];
    }
    return self;
}

- (void)dealloc {
    [self.timer invalidate];
    self.timer = nil;
    NSLog(@"%@任务销毁了", self.download.identifier);
}

- (void)start {
    [super start];
    self.download.state = DownloadStateRunning;
    @WeakObject(self);
    self.timer = [NSTimer timerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        @StrongObject(self);
        if (self && self.state == TaskStateRunning) {
            self.timeCount++;
            self.download.progress = 1.0 * self.timeCount / self.duration;
            [[NSNotificationCenter defaultCenter] postNotificationName:DownloadTaskDidUpdateNotification
                                                                object:self
                                                              userInfo:@{@"download":self.download}];
            if (self.timeCount == self.duration) {
                [self finish];
                self.download.state = DownloadStateFinished;
                [[NSNotificationCenter defaultCenter] postNotificationName:DownloadTaskDidUpdateNotification
                                                                    object:self
                                                                  userInfo:@{@"download":self.download}];
            }
        }
    }];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)pause {
    [super pause];
    [self.timer invalidate];
    self.timer = nil;
    self.download.state = DownloadStatePaused;
    [[NSNotificationCenter defaultCenter] postNotificationName:DownloadTaskDidUpdateNotification
                                                        object:self
                                                      userInfo:@{@"download":self.download}];
}

- (void)dispose {
    [super dispose];
    [self.timer invalidate];
    self.timer = nil;
    self.download.state = DownloadStateCanceled;
    [[NSNotificationCenter defaultCenter] postNotificationName:DownloadTaskDidUpdateNotification
                                                        object:self
                                                      userInfo:@{@"download":self.download}];
}

@end
