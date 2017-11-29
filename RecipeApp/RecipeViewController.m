//
//  RecipeViewController.m
//  RecipeApp
//
//  Created by Javier Xing on 2017-11-28.
//  Copyright © 2017 Daniel Grosman. All rights reserved.
//

#import "RecipeViewController.h"
#import "AppDelegate.h"




@interface RecipeViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *recipeDetailImageView;
@property (weak, nonatomic) IBOutlet UILabel *recipeDetailName;
@property (weak, nonatomic) IBOutlet UILabel *recipeDetailIngredients;
@property (weak, nonatomic) IBOutlet UILabel *recipeDetailCalories;
@property (weak, nonatomic) IBOutlet UILabel *recipeDetailFat;
@property (weak, nonatomic) IBOutlet UILabel *recipeDetailProtein;
@property (weak, nonatomic) IBOutlet UILabel *recipeDetailSugar;
@property (weak, nonatomic) IBOutlet UILabel *recipeDetailCarbs;

@end

@implementation RecipeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

}

-(void)setupRecipe{
    
    self.recipeDetailName.text = self.selectedRecipe.recipeName;
    self.recipeDetailIngredients.text = self.selectedRecipe.ingredients;
    self.recipeDetailCalories.text = [NSString stringWithFormat:@"%2.0f",self.selectedRecipe.calories];
    self.recipeDetailProtein.text = [NSString stringWithFormat:@"%2.0f",self.selectedRecipe.protein];
    self.recipeDetailSugar.text = [NSString stringWithFormat:@"%2.0f",self.selectedRecipe.sugar];
    self.recipeDetailFat.text = [NSString stringWithFormat:@"%2.0f",self.selectedRecipe.fat];
    self.recipeDetailCarbs.text = [NSString stringWithFormat:@"%2.0f",self.selectedRecipe.carbs];
    NSURL *largeImageURL = [NSURL URLWithString:self.selectedRecipe.largePictureURL];
    NSURLSessionTask *imageTask = [[NSURLSession sharedSession] dataTaskWithURL:largeImageURL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        UIImage *largeImage = [UIImage imageWithData:data];

        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            self.recipeDetailImageView.image = largeImage;
        }];
    }];
    [imageTask resume];
}


- (IBAction)cancelButtonTapped:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)saveButtonTapped:(id)sender {
    [self saveRecipe];
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(void)saveRecipe{
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    Recipe *recipe = [[Recipe alloc]initWithContext:appDelegate.persistentContainer.viewContext];
    
    recipe.recipeName = self.selectedRecipe.recipeName;
    recipe.recipeID = self.selectedRecipe.recipeID;
    recipe.totalTime = self.selectedRecipe.totalTime;
    
    recipe.smallPictureURL = self.selectedRecipe.smallPictureURL;
    recipe.largePictureURL = self.selectedRecipe.largePictureURL;
    
    recipe.ingredients = self.selectedRecipe.ingredients;
    recipe.recipeURL = self.selectedRecipe.recipeURL;
    recipe.rating = self.selectedRecipe.rating;
    recipe.protein = self.selectedRecipe.protein;
    recipe.calories = self.selectedRecipe.calories;
    recipe.sugar = self.selectedRecipe.sugar;
    recipe.fat = self.selectedRecipe.fat;
    recipe.carbohydrate = self.selectedRecipe.carbs;
    
    [appDelegate.persistentContainer.viewContext insertObject:recipe];
    [appDelegate saveContext];
}






@end
