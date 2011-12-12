//
//  SearchViewController.m
//  mtl-iphone-1
//
//  Created by Funami Takao on 11/12/12.
//  Copyright (c) 2011年 Recruit. All rights reserved.
//

#import "SearchViewController.h"
#import "JSONKit.h"

@implementation SearchViewController

@synthesize delegate = _delegate;
@synthesize currentMiddleArea = _currentMiddleArea;
@synthesize sections = _sections;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc{
    [_sections release];
    [_currentMiddleArea release];
    [super dealloc];
}


#pragma mark - Model
- (NSArray *)sections {
    if (!_sections){
        NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"middle_area" ofType:@"json"];
		NSData *data = [NSData dataWithContentsOfFile:jsonPath];
		
		
		// 読み込んだjsonをオブジェクトに変換
		NSDictionary *rootObj = [data objectFromJSONData];
		
		if (rootObj){
            NSDictionary *results = [rootObj objectForKey:@"results"];
            NSMutableArray *sectionCodes = [[NSMutableArray alloc] init];
            
            
			// オブジェクトに変換できたら,results要素を取り出す。
            for (NSDictionary *item in [results objectForKey:@"middle_area"]){
                NSString *largeAreaCode = [[item objectForKey:@"large_area"] objectForKey:@"code"];
                if ([sectionCodes indexOfObject:largeAreaCode] == NSNotFound){
                    [sectionCodes addObject:largeAreaCode];
                }
            }
            NSMutableArray *sections = [[NSMutableArray alloc] init];
            for (NSString *code in sectionCodes){
                NSMutableDictionary *section = [NSMutableDictionary dictionaryWithObject:code forKey:@"code"];
                NSMutableArray *items = [NSMutableArray array];
                NSString *large_area_name;
                for (NSDictionary *item in [results objectForKey:@"middle_area"]){
                    if ([[[item objectForKey:@"large_area"]objectForKey:@"code"] isEqualToString:code]){
                        [items addObject:item];
                        large_area_name = [[item objectForKey:@"large_area"]objectForKey:@"name"];
                    }
                }
                [section setObject:large_area_name forKey:@"name"];
                [section setObject:items forKey:@"items"];
                
                [sections addObject:section];
            }
            _sections = sections;
        }
    }
    return _sections;
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"キャンセル" style:UIBarButtonItemStyleBordered target:self action:@selector(didCancelEditSearchParam:)];
    self.navigationItem.rightBarButtonItem = cancelButton;
    self.title = @"エリア指定";
    

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    //現在選択のセルに移動
    NSString *currentMiddleAreaCode = [self.currentMiddleArea objectForKey:@"code"];
    NSInteger i = 0 ;
    NSIndexPath *indexPath = nil;
    for (NSDictionary *section in self.sections){
        NSArray *items = [section objectForKey:@"items"];
        NSInteger row = 0;
        for (NSDictionary *item in items){
            if ([[item objectForKey:@"code"] isEqualToString:currentMiddleAreaCode]){
                indexPath = [NSIndexPath indexPathForRow:row inSection:i];
                break;
            }
            row++;
        }
        if (indexPath)
            break;
        i++;
    }
    
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO ];

    
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.sections count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    //セクションのタイトルをレスポンスする。
    return [(NSDictionary *)[self.sections objectAtIndex:section] objectForKey:@"name"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[(NSDictionary *)[self.sections objectAtIndex:section] objectForKey:@"items"] count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    NSDictionary *section = [self.sections objectAtIndex:indexPath.section];
    NSArray *items = [section objectForKey:@"items"];
    NSDictionary *item = [items objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [item objectForKey:@"name"];
    NSString *currentMiddleAreaCode = [self.currentMiddleArea objectForKey:@"code"];
    if ([[item objectForKey:@"code"] isEqualToString:currentMiddleAreaCode]){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *section = [self.sections objectAtIndex:indexPath.section];
    NSDictionary *item = [[section objectForKey:@"items"] objectAtIndex:indexPath.row];
    [self.delegate didFinishSearchParamsSelection:item];
}

#pragma mark - end edit
- (void) didFinishEditSearchParam:(id)sender{
    if (_delegate)
        [self.delegate didFinishSearchParamsSelection:nil]; 
}

- (void) didCancelEditSearchParam:(id)sender{
    if (_delegate)
        [self.delegate didCancelSearchParamsSelection]; 
}


@end
