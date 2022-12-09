

#import "DownloadViewController.h"
#import "TaskQueue.h"
#import "DownloadTask.h"
#import "DownloadCell.h"

@interface DownloadViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic) TaskQueue *queue;
@property (nonatomic) NSMutableArray<Download *> *downloads;
@property (nonatomic) NSMutableDictionary<NSString *, NSNumber *> *downloadIndexs;
@property (nonatomic) UITableView *tableView;
@property (nonatomic) UILabel *maxCountLabel;
@end

@implementation DownloadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"下载管理";
    self.view.backgroundColor = UIColor.whiteColor;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(downloadTaskDidUpdate:)
                                                 name:DownloadTaskDidUpdateNotification
                                               object:nil];
    self.queue = [TaskQueue queue];
    self.queue.maxTaskCount = 1;
    self.downloads = [NSMutableArray array];
    self.downloadIndexs = [NSMutableDictionary dictionary];

    for (int i = 0; i < 30; i++) {
        Download *download = [Download new];
        download.identifier = [NSString stringWithFormat:@"%d",i];
        [self.downloads addObject:download];
        self.downloadIndexs[download.identifier] = @(i);
        
        DownloadTask *task = [[DownloadTask alloc] initWithDownloadDuration:i+30 download:download];
        [self.queue addTask:task forIdentifier: download.identifier];
    }
    
    self.tableView = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStylePlain];
    self.tableView.contentInset = UIEdgeInsetsMake(90, 0, 0, 0);
    [self.tableView registerClass:DownloadCell.class forCellReuseIdentifier:@"DownloadCell"];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 50;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
    [self controlView];
    [self.queue startAllTasks];
}

- (void)refreshDownloadIndexs {
    [self.downloadIndexs removeAllObjects];
    for (int i = 0; i < self.downloads.count; i++) {
        Download *download = self.downloads[i];
        self.downloadIndexs[download.identifier] = @(i);
    }
}

- (void)controlView {
    UIView *v = [UIView new];
    v.frame = CGRectMake(0, 64, self.view.frame.size.width, 90);
    v.backgroundColor = UIColor.groupTableViewBackgroundColor;
    [self.view addSubview:v];
    
    UILabel *a = [UILabel new];
    a.text = @"最大下载数";
    a.font = [UIFont systemFontOfSize:13];
    a.frame = CGRectMake(10, 20, 80, 20);
    [v addSubview:a];
    [a sizeToFit];
    
    UIButton *b = [UIButton new];
    b.tag = 100;
    b.backgroundColor = UIColor.orangeColor;
    [b setTitle:@"-" forState:UIControlStateNormal];
    [b setTitleColor:UIColor.blueColor forState:UIControlStateNormal];
    b.frame = CGRectMake(CGRectGetMaxX(a.frame) + 10, 10, 80, 20);
    [b addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [v addSubview:b];
    [b sizeToFit];
    
    UILabel *c = [UILabel new];
    c.text = @"000";
    c.textAlignment = NSTextAlignmentCenter;
    c.font = [UIFont systemFontOfSize:13];
    c.frame = CGRectMake(CGRectGetMaxX(b.frame) + 5, a.frame.origin.y, 80, 20);
    [v addSubview:c];
    [c sizeToFit];
    self.maxCountLabel = c;
    self.maxCountLabel.text = [NSString stringWithFormat:@"%ld", (long)self.queue.maxTaskCount];
    
    UIButton *d = [UIButton new];
    d.tag = 200;
    d.backgroundColor = UIColor.orangeColor;
    [d setTitle:@"+" forState:UIControlStateNormal];
    [d setTitleColor:UIColor.blueColor forState:UIControlStateNormal];
    d.frame = CGRectMake(CGRectGetMaxX(c.frame) + 10, 10, 80, 20);
    [d addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [v addSubview:d];
    [d sizeToFit];
    
    UIButton *e = [UIButton new];
    e.tag = 300;
    e.titleLabel.font = [UIFont systemFontOfSize:13];
    [e setTitle:@"全部暂停" forState:UIControlStateNormal];
    [e setTitleColor:UIColor.blueColor forState:UIControlStateNormal];
    e.frame = CGRectMake(10, CGRectGetMaxY(d.frame) + 5, 0, 20);
    [e addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [v addSubview:e];
    [e sizeToFit];
    
    UIButton *g = [UIButton new];
    g.tag = 500;
    g.titleLabel.font = [UIFont systemFontOfSize:13];
    [g setTitle:@"全部删除" forState:UIControlStateNormal];
    [g setTitleColor:UIColor.blueColor forState:UIControlStateNormal];
    g.frame = CGRectMake(CGRectGetMaxX(e.frame) + 20, e.frame.origin.y, 0, 20);
    [g addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [v addSubview:g];
    [g sizeToFit];
}

- (void)buttonClicked:(UIButton *)btn {
    if (btn.tag == 100) {
        self.queue.maxTaskCount--;
        self.maxCountLabel.text = [NSString stringWithFormat:@"%ld", (long)self.queue.maxTaskCount];
    }
    if (btn.tag == 200) {
        self.queue.maxTaskCount++;
        self.maxCountLabel.text = [NSString stringWithFormat:@"%ld", (long)self.queue.maxTaskCount];
    }
    if (btn.tag == 300) {
        NSString *str = [btn titleForState:UIControlStateNormal];
        if ([str isEqualToString:@"全部开始"]) {
            [self.queue startAllTasks];
            [btn setTitle:@"全部暂停" forState:UIControlStateNormal];
        } else {
            [self.queue pauseAllTasks];
            [btn setTitle:@"全部开始" forState:UIControlStateNormal];
        }
    }
    if (btn.tag == 500) {
        [self.queue removeAllTasks];
        [self.downloads removeAllObjects];
        [self.downloadIndexs removeAllObjects];
        [self.tableView reloadData];
    }
}

- (void)downloadTaskDidUpdate:(NSNotification *)note {
    Download *download = note.userInfo[@"download"];
    int index = self.downloadIndexs[download.identifier].intValue;
    DownloadCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    [cell update:download];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DownloadCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DownloadCell" forIndexPath:indexPath];
    [cell update:self.downloads[indexPath.row]];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.downloads.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Download *download = self.downloads[indexPath.row];
    [self.queue removeTask:download.identifier];
    [self.downloads removeObjectAtIndex:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self refreshDownloadIndexs];
}

@end
