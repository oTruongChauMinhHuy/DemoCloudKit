//
//  BookDetailViewController.m
//  DemoCloudKit
//
//  Created by HuyTCM1 on 9/9/16.
//  Copyright © 2016 HuyTCM1. All rights reserved.
//

#import "Constants.h"
#import "BookDetailViewController.h"

@interface BookDetailViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *buttonImage;
@property (weak, nonatomic) IBOutlet UITextField *bookTitle;

@property (weak, nonatomic) IBOutlet UITextField *author;
@property (weak, nonatomic) CKRecord *authorRecord;

@property (weak, nonatomic) IBOutlet UITextField *price;
@property (weak, nonatomic) IBOutlet UITextView *bookDescription;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;

@property (strong, nonatomic) UIImagePickerController *imagePickerController;

@property (strong, nonatomic) NSMutableArray *listAuthor;
@property (strong, nonatomic) UIPickerView *authorPickerView;

@end

@implementation BookDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initPickerAuthorview];
    self.author.delegate = self;
    self.authorPickerView = [[UIPickerView alloc] init];
    self.authorPickerView.delegate = self;
    self.authorPickerView.dataSource = self;
    [self.authorPickerView setShowsSelectionIndicator:YES];
    
    self.author.inputView = self.authorPickerView;
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

- (void)initPickerAuthorview {
    CKContainer *container = [CKContainer defaultContainer];
    CKDatabase *database = [container publicCloudDatabase];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"TRUEPREDICATE"];
    CKQuery *query = [[CKQuery alloc] initWithRecordType:@"Author" predicate:predicate];
    
    [database performQuery:query inZoneWithID:nil completionHandler:^(NSArray <CKRecord *> *result, NSError *error) {
        if (!error) {
            if (result) {
                self.listAuthor = [[NSMutableArray alloc] initWithArray:result];
            }
        } else {
            NSLog(@"%s -- %@", __func__, error);
        }
    }];
}

- (IBAction)saveBookDetail:(id)sender {
    if (![self.bookTitle.text isEqualToString:@""]) {
        if (!self.book) {
            self.book = [[CKRecord alloc] initWithRecordType:@"Book"];
        }
        self.book[kBookTitle] = self.bookTitle.text;
        
        if (self.authorRecord) {
            CKReference *authorReference = [[CKReference alloc] initWithRecordID:self.authorRecord.recordID action:CKReferenceActionNone];
            self.book[kBookAuthor] = authorReference;
        }
    
        self.book[kBookPrice] = self.price.text;
        self.book[kBookDescription] = self.bookDescription.text;
        
        if (self.buttonImage.currentImage) {
            NSData *data = UIImageJPEGRepresentation(self.buttonImage.imageView.image, 0.2f);
            NSURL *fileUrl = [[NSURL fileURLWithPath:NSTemporaryDirectory()] URLByAppendingPathComponent:[[NSUUID UUID] UUIDString]];
            if ([data writeToURL:fileUrl atomically:YES]) {
                CKAsset *imageAsset = [[CKAsset alloc] initWithFileURL:fileUrl];
                self.book[kBookImage] = imageAsset;
            }
        }
        CKContainer *container = [CKContainer defaultContainer];
        CKDatabase *database = [container publicCloudDatabase];
        [database saveRecord:self.book completionHandler:^(CKRecord *record, NSError *error) {
            if (!error) {
                dispatch_async(dispatch_get_main_queue(), ^() {
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Success" message:@"Saved!" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
                    [alert addAction:alertAction];
                    [self presentViewController:alert animated:YES completion:nil];
                });
            }
        }];
    }
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

#pragma mark - Author picker view
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.listAuthor count];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    CKRecord *author = [self.listAuthor objectAtIndex:row];
    return author[kAuthorName];
}
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.authorRecord = [self.listAuthor objectAtIndex:row];
    self.author.text = self.authorRecord[kAuthorName];
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
