//
//  ViewController.m
//  PullVideoThumbnail
//
//  Created by Terry Bu on 3/27/15.
//  Copyright (c) 2015 Terry Bu. All rights reserved.
//

#import "ViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface ViewController () {
    UIImage *thumbnail;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //we don't show imagepickercontroller from viewdidload - because it complains of attempting to present pickercontroller before this vc is ready - viewDidLayOutSubviews does better.
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self showImagePickerController];
}

-(void)showImagePickerController {
    // 1 - Validations
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == NO) {
        NSLog(@"couldn't open photo library");
    }
    // 2 - Get image picker
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    //To allow only VIDEOS to show up on selection picker menu - default is all photos/videos
    //Note that kUTypeMovie throws "undeclared identifier" error, if you don't import MobileCoreServices Framework
    imagePickerController.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, nil];

    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    imagePickerController.allowsEditing = NO;
    imagePickerController.delegate = self;
    // 3 - Display image picker
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    [self dismissViewControllerAnimated:YES completion:^{
        //validate that it's a video
        if (CFStringCompare ((__bridge_retained CFStringRef)mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
            NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
            //import <AssetsLibrary> for this
            [library assetForURL:videoURL resultBlock:^(ALAsset *asset) {
                //this is the block to use with your asset
                //whatever you want to perform to your asset, you should do so in this block
                //user might have to say yes to permission. If denied, failure block will get called
                AVAsset *avAsset = [AVURLAsset URLAssetWithURL:videoURL options:nil];
                NSLog(@"%@", avAsset.description);
                AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:avAsset];
                imageGenerator.appliesPreferredTrackTransform = YES;
                imageGenerator.maximumSize = CGSizeMake(320, 180);
                
                CMTime thumbTime = CMTimeMakeWithSeconds(1, 30);
                //controls at which point of the video, you want to pull the thumbnail from
                
                CMTime actualTime;
                NSError *error = nil;
                CGImageRef image = [imageGenerator copyCGImageAtTime:thumbTime actualTime:&actualTime error:&error];
                thumbnail = [[UIImage alloc] initWithCGImage:image];
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2-100, 200, 200, 200)];
                    imageView.image = thumbnail;
                    NSLog(@"%@", imageView.image.description);
                    [self.view addSubview:imageView];
                });
            } failureBlock:nil];
        }
    }];
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
