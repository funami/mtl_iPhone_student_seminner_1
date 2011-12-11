//
//  RootViewController.m
//  mtl-iphone-1
//
//  Created by Takao Funami on 11/12/11.
//  Copyright 2011 Recruit CO., LTD. All rights reserved.
//

#import "RootViewController.h"
#import "DetailViewController.h"
#import "JSONKit.h"


@implementation RootViewController

@synthesize items = _items;
@synthesize resultsAvailable = _resultsAvailable;

#pragma mark -
#pragma mark Model
//テーブルビューに表示するための配列(NSArray)を用意する。
//この配列には、ホットペッパーWebサービスから取得したjsonから生成されたハッシュ(NSDictionary)が入っている。
//itemsはreadonlyのプロパティで、self.itemsのようにして呼び出されたとき、_itemsがnilだったら、jsonから取り込みを行う
// Mock/gourmet_Y005_pp.json 参照 実際の取得は以下のURLから取得した
// curl "http://webservice.recruit.co.jp/hotpepper/gourmet/v1/?key=b4fd444e7fd8d7b9&middle_area=Y005&format=json&count=5" -o gourmet_Y005.json
// ブラウザでxmlで表示するなら -> http://webservice.recruit.co.jp/hotpepper/gourmet/v1/?key=b4fd444e7fd8d7b9&middle_area=Y005&format=xml&count=5
- (NSArray *)items{
	if (!_items){
		// 事前に用意してあるjsonを読み込む。
		NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"gourmet_Y005_pp" ofType:@"json"];
		NSData *data = [NSData dataWithContentsOfFile:jsonPath];
		
		// 読み込んだjsonをオブジェクトに変換
		NSDictionary *rootObj = [data objectFromJSONData];
		
		if (rootObj){
			
			// オブジェクトに変換できたら,results要素を取り出す。
			NSDictionary *results = [rootObj objectForKey:@"results"];
			
			// 検索対象の総件数を取得 
			_resultsAvailable = [[results objectForKey:@"results_available"] intValue];
			_items = [[results objectForKey:@"shop"] retain];
		}else{
			NSLog(@"json parse error:%@",rootObj);
		}
	}
	return _items;
}


#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	[self setTitle:@"MTLグルメ"];
}


/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

/*
 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 */

	


#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	//セクションは1つだけ。
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	//行数は、jsonから取り込んだitemsに含まれる、ハッシュ(この場合各お店ごとの情報)の数
    return [self.items count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	//セルのViewを取得する。再利用(dequeueReusableCellWithIdentifier)するか、新規作成(alloc)するか
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
	
	// Configure the cell.
	NSDictionary *item = [self.items objectAtIndex:indexPath.row];
	cell.textLabel.text = [item objectForKey:@"name"];
	cell.detailTextLabel.text = [item objectForKey:@"address"];
	
	/*
		detailTextLabel.textに投入している、[item objectForKey:@"address"] の部分を変更してみよう。 
		textLabel.textの変更もしてみよう。
			例：
			お店キャッチ	[item objectForKey:@"catch"]
			住所			[item objectForKey:@"address"]
			アクセス		[item objectForKey:@"access"]
			お店ジャンル	[[item objectForKey:@"genre"] objectForKey:@"name"]
		参照:http://webservice.recruit.co.jp/hotpepper/reference.html
	 */

    return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	// 詳細画面用のViewControllerを作り
	DetailViewController *detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
	// ...
	// 詳細画面用のViewControllerにデータを渡す
	detailViewController.item = [self.items objectAtIndex:indexPath.row];
	[self.navigationController pushViewController:detailViewController animated:YES];
	[detailViewController release];
	 
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
	[_items release];
	_items = nil;
}


- (void)dealloc {
	[_items release];
    [super dealloc];
}


@end

