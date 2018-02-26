//
//  ImageTestViewController.m
//  demo
//
//  Created by xiaozhuzhu on 2018/2/10.
//  Copyright © 2018年 xiaozhuzhu. All rights reserved.
//

#import "ImageTestViewController.h"
#import "IconCollectionViewCell.h"
#import <Masonry.h>

@interface ImageTestViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UIImageView   *showImage;
@property (nonatomic, strong) NSArray *icons;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIImageView *selectedImageView;
@property (nonatomic, strong) UIButton *backButton;

@end

@implementation ImageTestViewController
{
    BOOL isAnimoIcon;
    NSInteger selectedNumber;
}

- (void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:true animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:false animated:animated];
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
 
    self.icons = @[@"001.jpg",@"002.jpg",@"003.jpg",@"004.jpg",@"005.jpg"];
    self.view.backgroundColor = UIColor.clearColor;
    isAnimoIcon = true;
    selectedNumber = 0;
    
    self.bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    self.bgView.backgroundColor = UIColor.blackColor;
    [self.view addSubview:self.bgView];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.itemSize = CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT);
    flowLayout.minimumLineSpacing = 0;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) collectionViewLayout:flowLayout];
    self.collectionView.showsVerticalScrollIndicator = false;
    self.collectionView.showsHorizontalScrollIndicator = false;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.pagingEnabled = true;
    [self.collectionView registerNib:[UINib nibWithNibName:@"IconCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"cellid"];
    [self.view addSubview:self.collectionView];
    
    UIPanGestureRecognizer *panTouch = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(iconViewClick:)];
    [self.collectionView addGestureRecognizer:panTouch];
    
    UISwipeGestureRecognizer *swipeTouchLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(iconViewSwipeLClick:)];
    swipeTouchLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.collectionView addGestureRecognizer:swipeTouchLeft];
    [panTouch requireGestureRecognizerToFail:swipeTouchLeft];
    UISwipeGestureRecognizer *swipeTouchRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(iconViewSwipeRClick:)];
    swipeTouchRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.collectionView addGestureRecognizer:swipeTouchRight];
    [panTouch requireGestureRecognizerToFail:swipeTouchRight];
    

    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-60, 10, 50, 40)];
    btn.backgroundColor = UIColor.yellowColor;
    [btn setTitle:@"返回" forState:UIControlStateNormal];
    [btn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(closeSelfView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    self.backButton = btn;

}

- (void) backWithRemoveSelf{
    [UIView animateWithDuration:.3 animations:^{
        CGRect frame = self.view.frame;
        frame.origin.x = SCREEN_WIDTH;
        self.view.frame = frame;
    } completion:^(BOOL finished) {
        [self closeSelfView];
    }];
}

- (void) closeSelfView{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.icons.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    IconCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellid" forIndexPath:indexPath];
    cell.icon.image = [UIImage imageNamed:self.icons[indexPath.row]];
    cell.icon.userInteractionEnabled = true;

    return cell;
}

- (UIImage *) createImage:(UIView *)view{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void) iconViewClick:(UIPanGestureRecognizer *)gesture{
    //拖拽的距离(距离是一个累加)
    CGPoint trans = [gesture translationInView:gesture.view];
    
    //设置图片移动
    CGPoint center =  self.showImage.center;
    center.x += trans.x;
    center.y += trans.y;
    self.showImage.center = center;
    [gesture setTranslation:CGPointZero inView:gesture.view];
    
    //图片变小
    CGPoint view_center = self.view.center;
    CGPoint icon_center = self.showImage.center;
    float x = ABS(icon_center.x-view_center.x);
    float y = ABS(icon_center.y-view_center.y);
    float r0 = SCREEN_HEIGHT/2;
    float r1 = sqrt(x*x+y*y);
    CGFloat ratio = 1-r1/r0;
    
    //允许最小尺寸
    if (ratio>0.4) {
        CGAffineTransform transform = CGAffineTransformMakeScale(1, 1);
        self.showImage.transform = CGAffineTransformScale(transform, ratio, ratio);
    }
    self.collectionView.alpha = 0;
    self.bgView.alpha = ratio-0.4;
    self.selectedImageView.hidden = true;
    if(gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled){
        [self.showImage removeFromSuperview];
        self.showImage = nil;
        
        if (ratio>0.4) {
            self.selectedImageView.hidden = false;
            self.collectionView.alpha = 1.0;
            self.bgView.alpha = 1;
        }else{
            [self.view removeFromSuperview];
        }
    }
}

- (void) iconViewSwipeLClick:(UISwipeGestureRecognizer *)gesture{
    if (selectedNumber+1<self.icons.count) {
        selectedNumber++;
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:selectedNumber inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:true];
    }
}
- (void) iconViewSwipeRClick:(UISwipeGestureRecognizer *)gesture{
    if (selectedNumber-1>=0) {
        selectedNumber--;
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:selectedNumber inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:true];
    }else{
        [self backWithRemoveSelf];
    }
}

- (UIImageView *)showImage{
    NSInteger number = self.collectionView.contentOffset.x/SCREEN_WIDTH;
    IconCollectionViewCell *cell = (IconCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:number inSection:0]];
    self.selectedImageView = cell.icon;
    if (!_showImage) {
        _showImage = [[UIImageView alloc] initWithImage:[self createImage:self.selectedImageView]];
        [self.view addSubview:_showImage];
    }
    return _showImage;
}


@end
