//
//  BookDetailViewController.m
//  DemoCloudKit
//
//  Created by HuyTCM1 on 9/9/16.
//  Copyright © 2016 HuyTCM1. All rights reserved.
//

#import "Constants.h"
#import "BookDetailViewController.h"

@interface BookDetailViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *buttonImage;
@property (weak, nonatomic) IBOutlet UITextField *bookTitle;
@property (weak, nonatomic) IBOutlet UITextField *author;
@property (weak, nonatomic) IBOutlet UITextField *price;
@property (weak, nonatomic) IBOutlet UITextView *bookDescription;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;

@property (strong, nonatomic) UIImagePickerController *imagePickerController;

@end

@implementation BookDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //Set border for book description text view
    [self.bookDescription.layer setBorderColor:[[UIColor grayColor] CGColor]];
    [self.bookDescription.layer setBorderWidth:0.5f];
    [self.bookDescription.layer setCornerRadius:5.0f];
    
    self.imagePickerController = [[UIImagePickerController alloc] init];
    self.imagePickerController.delegate = self;
    
    // fill book detail if any
    if(self.book) {
        self.bookTitle.text = self.book[kBookTitle];
        self.author.text = self.book[kBookAuthor];
        self.price.text = self.book[kBookPrice];
        self.bookDescription.text = self.book[kBookDescription];
        
        if (self.book[kBookImage]) {
            dispatch_async(dispatch_get_main_queue(), ^(){
                CKAsset *imageAsset = self.book[kBookImage];
                NSData *imageData = [NSData dataWithContentsOfURL:imageAsset.fileURL];
                
                UIImage *image = [UIImage imageWithData:imageData];
                if (image) {
                    [self.buttonImage setImage:image forState:UIControlStateNormal];
                }
            });
        }
    }
    
}

- (IBAction)saveBookDetail:(id)sender {
}

- (IBAction)pickImage:(id)sender {
    [self.imagePickerController setAllowsEditing:NO];
    [self.imagePickerController setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}

#pragma mark - Image Picker Controller Delegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    if ([info objectForKey:UIImagePickerControllerOriginalImage]) {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        [self.buttonImage setImage:image forState:UIControlStateNormal];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
