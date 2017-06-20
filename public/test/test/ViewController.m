//
//  ViewController.m
//  test
//
//  Created by apple on 2017/6/13.
//  Copyright © 2017年 金色童年. All rights reserved.
//

#import "ViewController.h"
#import <Photos/Photos.h>

#define Log(A) NSLog(@"imageData = %ld, Size = (%.2lf, %.2lf)", UIImageJPEGRepresentation(A, 1.0).length, A.size.width, A.size.height)

@interface ViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic, strong) UIImagePickerController* imagePickerController;
@property (nonatomic, copy) void (^singlePass)(NSString *str);   //单个传值回调


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    [self testBlockComplete:^(NSString *str) {
        NSLog(@"%@", str);
    }];
}

- (void)testBlockComplete:(void (^)(NSString *str))block
{
    NSArray* array = @[@"1",@"2",@"3",@"4",@"5"];
    __block NSUInteger currentIndex = 0;
    __weak ViewController *weakSelf = self;
    __block BOOL isFinished = false;

    self.singlePass = ^(NSString *str){
        currentIndex ++;
        //接着遍历
        if (currentIndex < array.count) {
            if (currentIndex == array.count - 1) {
                isFinished = true;
            }else{
                isFinished = false;
            }
            [weakSelf passBlockWithString:array[currentIndex] finished:isFinished Complete:weakSelf.singlePass];
        }else{
            block(str);
            return;
        }
    };
    [self passBlockWithString:array[currentIndex] finished:isFinished Complete:self.singlePass];
}

- (void)passBlockWithString:(NSString *)string finished:(BOOL)isFinished Complete:(void (^)(NSString * str))block{
    
    NSLog(@"string = %@", string);
    
    if (block) {
        block(@"false");
    }
}

/*
 *  测试图片压缩
 */
- (void)testZipImage{
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"IMG_20170616_161730" ofType:@"jpg"];
    
    NSData* fileData = [NSData dataWithContentsOfFile:filePath];
    UIImage* fileImage = [UIImage imageWithData:fileData];
    NSLog(@"fileData = %ld, size = (%.2f, %.2f)", fileData.length, fileImage.size.width, fileImage.size.height);
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        
        //写入图片到相册
        PHAssetChangeRequest *req = [PHAssetChangeRequest creationRequestForAssetFromImage:[UIImage imageWithData:[self zipImageWithImage:fileImage]]];
        
        
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        
        NSLog(@"success = %d, error = %@", success, error);
        
    }];
}

/**
 压图片质量
 
 @param image image
 @return Data
 */
- (NSData *)zipImageWithImage:(UIImage *)image
{
    if (!image) {
        return nil;
    }
    CGFloat compression = 0.9f;
    NSData *compressedData = UIImageJPEGRepresentation([self compressImage:image newWidth:image.size.width*compression], 0.5);
    UIImage* image1 = [UIImage imageWithData:compressedData];

    NSLog(@"fileData = %ld, size = (%.2f, %.2f)", compressedData.length, image1.size.width, image1.size.height);

    if (compressedData.length < 1000000) {
        return compressedData;
    }else{
        return [self zipImageWithImage:image1];
    }
}

/**
 *  等比缩放本图片大小
 *
 *  @param newImageWidth 缩放后图片宽度，像素为单位
 *
 *  @return self-->(image)
 */
- (UIImage *)compressImage:(UIImage *)image newWidth:(CGFloat)newImageWidth
{
    if (!image) return nil;
    float imageWidth = image.size.width;
    float imageHeight = image.size.height;
    float width = newImageWidth;
    float height = image.size.height/(image.size.width/width);
    
    float widthScale = imageWidth /width;
    float heightScale = imageHeight /height;
    
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    
    if (widthScale > heightScale) {
        [image drawInRect:CGRectMake(0, 0, imageWidth /heightScale , height)];
    }
    else {
        [image drawInRect:CGRectMake(0, 0, width , imageHeight /widthScale)];
    }
    
    // 从当前context中创建一个改变大小后的图片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    
    return newImage;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
