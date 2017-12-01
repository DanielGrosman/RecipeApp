//
//  ViewController.m
//  RecipeApp
//
//  Created by Daniel Grosman on 2017-11-27.
//  Copyright © 2017 Daniel Grosman. All rights reserved.
//

#import "ViewController.h"
#import "RecipeTableViewCell.h"
#import "YummlyAPI.h"
#import "Recipe+customInitializer.h"
#import "AppDelegate.h"
#import "SavedRecipesTableViewCell.h"
#import "RecipeDetailViewController.h"
#import <XLPagerTabStrip/XLPagerTabStripViewController.h>
#import "UIScrollView+EmptyDataSet.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import <ChameleonFramework/Chameleon.h>


@interface ViewController () <UITableViewDelegate, UITableViewDataSource,XLPagerTabStripChildItem,DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>
//@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic)NSArray <Recipe*> *savedRecipies;
@property (weak, nonatomic) IBOutlet UIButton *editButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.emptyDataSetSource = self;
    self.tableView.emptyDataSetDelegate = self;
    self.tableView.tableFooterView = [UIView new];
    
    self.tableView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0);
    //    [self.tableView setContentOffset:CGPointMake(0, 44)];
    
    [self fetchRecipesData];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchRecipesData) name:NSManagedObjectContextDidSaveNotification object:nil];
}


- (void)viewDidLayoutSubviews {
    
    
}

-(void)fetchRecipesData{
    AppDelegate *appDelegate = ((AppDelegate*)[[UIApplication sharedApplication] delegate]);
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Recipe"];
    //    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"tagName" ascending:YES];
    self.savedRecipies = [appDelegate.persistentContainer.viewContext executeFetchRequest:request error:nil];
}

-(void)setSavedRecipies:(NSArray<Recipe *> *)savedRecipies{
    _savedRecipies = savedRecipies;
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.savedRecipies.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SavedRecipesTableViewCell *cell = (SavedRecipesTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"savedRecipeCell" forIndexPath:indexPath];
    
    Recipe *currentRecipe = self.savedRecipies[indexPath.row];
    
    cell.savedRecipeName.text = currentRecipe.recipeName;
    
    //    NSURL *smallImageURL = [NSURL URLWithString:currentRecipe.smallPictureURL];
    //    NSData *smallImageData = [NSData dataWithContentsOfURL:smallImageURL];
    //    UIImage *smallImage = [UIImage imageWithData:smallImageData];
    //    cell.savedRecipeImageView.image = smallImage;
    NSArray *docDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *imageFilePath = [docDirectory firstObject];
    imageFilePath = [imageFilePath stringByAppendingString:currentRecipe.largeImagePath];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:imageFilePath]) {
        NSData *imageData = [NSData dataWithContentsOfFile:imageFilePath];
        UIImage *smallImage = [UIImage imageWithData:imageData];
        cell.savedRecipeImageView.image = smallImage;
        cell.savedRecipeImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    
    cell.savedRecipeRating.text = [NSString stringWithFormat:@"Rating: %2.0f",currentRecipe.rating];
    
    if ([currentRecipe.totalTime isEqualToString:@"<null>"]) {
        cell.savedRecipeTime.text = @"";
    }
    else{
        int timeinSeconds = [currentRecipe.totalTime intValue];
        int timeInMinutes = timeinSeconds/60;
        NSString *timeString = [NSString stringWithFormat:@"%d",timeInMinutes];
        cell.savedRecipeTime.text =  [NSString stringWithFormat:@"%@ Minutes",timeString];
    }
    
    return cell;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"savedRecipeDetails"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Recipe *recipe = self.savedRecipies[indexPath.row];
        
        RecipeDetailViewController *controller = [segue destinationViewController];
        [controller setRecipe:recipe];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (NSString *)titleForPagerTabStripViewController:(XLPagerTabStripViewController *)pagerTabStripViewController{
    return @"Saved Recipes";
}

#pragma mark - EmptyTableView

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView
{
    return [UIImage imageNamed:@"empty_placeholder"];
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = @"Your Saved Recipes Will Be Displayed Here";
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0f],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = @"Swipe Left to Search for Recipes.The Menu in the Top Right Corner Will Allow You to Choose From a List of Dietary Preferences for Your Search.";
    
    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    paragraph.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:14.0f],
                                 NSForegroundColorAttributeName: [UIColor lightGrayColor],
                                 NSParagraphStyleAttributeName: paragraph};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

//- (CAAnimation *)imageAnimationForEmptyDataSet:(UIScrollView *)scrollView
//{
//    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath: @"transform"];
//
//    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
//    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI_2, 0.0, 0.0, 1.0)];
//
//    animation.duration = 0.25;
//    animation.cumulative = YES;
//    animation.repeatCount = MAXFLOAT;
//
//    return animation;
//}




@end
