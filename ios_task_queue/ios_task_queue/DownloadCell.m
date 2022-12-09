

#import "DownloadCell.h"

@interface DownloadCell()
@property (nonatomic) UIProgressView *progressView;
@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UILabel *stateLabel;
@end

@implementation DownloadCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.titleLabel = [UILabel new];
        self.titleLabel.textColor = UIColor.blackColor;
        [self.contentView addSubview:self.titleLabel];
        
        self.stateLabel = [UILabel new];
        self.stateLabel.font = [UIFont systemFontOfSize:13];
        self.stateLabel.textAlignment = NSTextAlignmentRight;
        self.stateLabel.textColor = UIColor.grayColor;
        [self.contentView addSubview:self.stateLabel];
        
        self.progressView = [UIProgressView new];
        [self.contentView addSubview:self.progressView];
    }
    return self;
}

- (void)layout {
    self.bounds = CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, 50);
    self.titleLabel.frame = CGRectMake(15, 5, (self.frame.size.width - 30) / 2, 25);
    self.stateLabel.frame = CGRectMake(CGRectGetMaxX(self.titleLabel.frame), 5, (self.frame.size.width - 30) / 2, 25);
    self.progressView.frame = CGRectMake(15, CGRectGetMaxY(self.titleLabel.frame) + 5,
                                         self.frame.size.width - 30, 5);
}

- (void)update:(Download *)download {
    [self layout];
    self.titleLabel.text = download.identifier;
    self.progressView.progress = download.progress;
    switch (download.state) {
        case DownloadStateWaiting:
            self.stateLabel.text = @"等待中";
            break;
        case DownloadStateRunning:
            self.stateLabel.text = @"下载中";
            break;
        case DownloadStatePaused:
            self.stateLabel.text = @"暂停中";
            break;
        case DownloadStateFinished:
            self.stateLabel.text = @"已完成";
            break;
        case DownloadStateCanceled:
            self.stateLabel.text = @"已取消";
            break;
        default:
            break;
    }
}


@end
