//
//  MoviesViewController.m
//  CinemaCity
//
//  Created by Alex Studnicka on 27/03/14.
//  Copyright (c) 2014 Alex Studnicka. All rights reserved.
//

#import "MoviesViewController.h"
#import "TFHpple.h"
#import "MovieCell.h"
#import "MovieDetailViewController.h"

@implementation MoviesViewController {
	
	UIRefreshControl *_refreshControl;
	
	NSInteger _selectedCategory;
	RMPickerViewController *_pickerVC;
	
	NSArray *_allMovies;
	NSArray *_movies;
	
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.collectionView.backgroundColor = UIColor.blackColor;
	
	self.navigationItem.title = NSLocalizedString(@"MOVIES", nil);
//	self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"BACK", nil) style:UIBarButtonItemStyleBordered target:nil action:NULL];
	
	UIImageView *bgLogoImageView = [UIImageView new];
	bgLogoImageView.alpha = 0.2;
	bgLogoImageView.frame = CGRectMake(0, 0, 320, 180);
	bgLogoImageView.center = self.view.center;
	bgLogoImageView.image = [UIImage imageNamed:@"bg_logo.png"];
	bgLogoImageView.contentMode = UIViewContentModeCenter;
	self.collectionView.backgroundView = bgLogoImageView;
	
	UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
	flowLayout.sectionInset = UIEdgeInsetsMake(20, 20, 20, 20);
	flowLayout.minimumLineSpacing = 20;
	flowLayout.minimumInteritemSpacing = 20;
	
	_refreshControl = [UIRefreshControl new];
	_refreshControl.tintColor = AppDelegate.instance.window.tintColor;
	[_refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
	[self.collectionView addSubview:_refreshControl];
	
	// --------------------
	
	_selectedCategory = 0;
	
	RMAction *selectAction = [RMAction actionWithTitle:NSLocalizedString(@"SELECT", nil) style:RMActionStyleDone andHandler:^(RMActionController *controller) {
		UIPickerView *picker = ((RMPickerViewController *)controller).picker;
		_selectedCategory = [picker selectedRowInComponent:0];
		
		_movies = [_allMovies filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"category = %d", _selectedCategory]];
		_movies = [_movies sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:(_selectedCategory == 7)]]];
		
		self.navigationItem.rightBarButtonItem.title = [self pickerView:_pickerVC.picker titleForRow:_selectedCategory forComponent:0];
		
		[self.collectionView reloadData];

	}];
	
	RMAction *cancelAction = [RMAction actionWithTitle:NSLocalizedString(@"CANCEL", nil) style:RMActionStyleCancel andHandler:nil];
	
	_pickerVC = [RMPickerViewController actionControllerWithStyle:RMActionControllerStyleDefault selectAction:selectAction andCancelAction:cancelAction];
	_pickerVC.picker.delegate = self;
	_pickerVC.picker.dataSource = self;
	
	// --------------------
	
	self.collectionView.alwaysBounceVertical = YES;
	[self.collectionView setContentOffset:CGPointMake(0, -_refreshControl.frame.size.height) animated:YES];
	[self refresh];
	
}

#pragma mark - Refresh

- (void)refresh {
	
	[_refreshControl beginRefreshing];
	
	[API.sharedInstance getMoviesWithCompletionHandler:^(NSArray *movies) {
		
		_allMovies = movies;
		_movies = [_allMovies filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"category = %d", _selectedCategory]];
		_movies = [_movies sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:(_selectedCategory == 7)]]];
		
		[self.collectionView reloadData];
		[_refreshControl endRefreshing];
		
	}];
	
}

#pragma mark - UICollectionViewDataSource & UICollectionViewDelegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return _movies.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	MovieCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MovieCell" forIndexPath:indexPath];
	cell.movieDict = _movies[indexPath.item];
	return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
	MovieDetailViewController *movieDetailVC = [storyboard instantiateViewControllerWithIdentifier:@"MovieDetailViewController"];
	movieDetailVC.featureCode = _movies[indexPath.item][@"code"];
	[self.navigationController pushViewController:movieDetailVC animated:YES];
}

#pragma mark - UIPickerViewDataSource & UIPickerViewDelegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	return 8;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	
	switch (row) {
		case 0:
			return @"Uvádíme";
		case 1:
			return @"IMAX";
		case 2:
			return @"4DX";
		case 3:
			return @"3D";
		case 4:
			return @"S titulky";
		case 5:
			return @"Dabované";
		case 6:
			return @"České filmy";
		case 7:
			return @"Připravujeme";
		default:
			return @"";
	}
	
}

#pragma mark - Actions

- (IBAction)changeCategory {
	[self.tabBarController presentViewController:_pickerVC animated:YES completion:nil];
}

@end
