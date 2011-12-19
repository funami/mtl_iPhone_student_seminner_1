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
#import "SVProgressHUD.h"
#import "AboutViewController.h"

// ↓こちらのAPI_KEYの値は、https://webservice.recruit.co.jp/register/index.htmlで新規登録したキーと差し替えてください
#define API_KEY @"b4fd444e7fd8d7b9"


@implementation RootViewController

@synthesize items = _items;
@synthesize filtereditems = _filtereditems;
@synthesize resultsAvailable = _resultsAvailable;
@synthesize url = _url;
@synthesize currentMiddleArea = _currentMiddleArea;



#pragma mark -
#pragma mark Model
//テーブルビューに表示するための配列(NSArray)を用意する。
//_itemsがからの時はインターネット経由でホットペッパーWebサービスのデータを取得する。
//ただし、非同期通信なので、_itemsは最初は、空のまま。

- (void)startUpdateData{
    [SVProgressHUD showWithStatus:@"読み込み中" networkIndicator:YES];

	
    if (!_currentMiddleArea){
        [self editSearchParam:nil];
    }
    
	NSString *url = [NSString stringWithFormat:@"http://webservice.recruit.co.jp/hotpepper/gourmet/v1/?key=%@&format=json&middle_area=%@",API_KEY,[_currentMiddleArea objectForKey:@"code"]];
	
	NSLog(@"api url:%@",url);
	
    
	// itemsを空にしておく
    self.title = [self.currentMiddleArea objectForKey:@"name"];
    [_items release];
	_items = [[NSMutableArray alloc] init];
    [self.tableView reloadData];
	_start = 1;
	self.url = url;
	[self requestAPI];
}	

- (void)startAddMoreData{
	_start = [_items count]+1;
	[self requestAPI];
}

- (void)requestAPI{
	NSString *url = [_url stringByAppendingFormat:@"&count=100&start=%d",_start];
    NSLog(@"url:%@",url);
	// 既に通信中の場合は、キャンセルしておく。複数の接続はさせない方針とする。
	if (_connection){
		[_connection cancel];
		[_connection release];
		_connection = nil;
	}
	if (_receivedData){
		[_receivedData release];
		_receivedData = nil;
	}
	
	// 非同期で取得を開始する　http://bit.ly/dMk4sh のソースを参考に
	// Create the request. - urlからリクエストを作成
	NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:url]
											  cachePolicy:NSURLRequestUseProtocolCachePolicy
										  timeoutInterval:60.0];
	// create the connection with the request - delegateを自分にして非同期通信を開始。
	// and start loading the data
	_connection =[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	if (_connection) {
		// Create the NSMutableData to hold the received data. - 接続に成功したら、receivedDataインスタンス変数を初期化 このあと、didReceiveResponseでデータを受ける
		// receivedData is an instance variable declared elsewhere.
		_receivedData = [[NSMutableData data] retain];
	} else {
		// Inform the user that the connection failed. - 接続失敗
	}	
}


//検索条件を設定する
-(void)editSearchParam:(id)sender{
    SearchViewController *searchVC = [[SearchViewController alloc] init];
    searchVC.delegate = self;
    searchVC.currentMiddleArea = self.currentMiddleArea;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:searchVC];
        
    [self presentModalViewController:navigationController animated:YES];
    
    [navigationController release];
    [searchVC release];
    
    
}

- (void)didCancelSearchParamsSelection{
    [self dismissModalViewControllerAnimated:YES];
}
- (void)didFinishSearchParamsSelection:(NSDictionary *)params{
    self.currentMiddleArea = params;
    [self dismissModalViewControllerAnimated:YES];
    [self startUpdateData]; 
}
//
#pragma mark -
#pragma mark NSURLConnection Delegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	// 接続後このdidReceiveResponseが呼ばれるが、リダイレクトが発生したばあいは、didReceiveResponseが再度呼ばれる。
	// 毎回データをリセットしておけばOK
	[_receivedData setLength:0];
	//この後。didReceiveDataが複数回繰り返して呼ばれるが、前述のとおり、再度didReceiveResponseに戻る場合もある
	
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	//複数回呼び出される - 呼び出されるたびに、_receiverdDataにアペンドしてゆく
    [_receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    // release the connection, and the data object
    [_connection release];
	_connection = nil;
	
    // receivedData is declared as a method instance elsewhere
    [_receivedData release];
	_receivedData = nil;
	
    // inform the user
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    
    [SVProgressHUD dismissWithError:@"読み込み失敗" afterDelay:1.0f];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    // do something with the data
    // receivedData is declared as a method instance elsewhere
    NSLog(@"Succeeded! Received %d bytes of data",[_receivedData length]);
	
	NSDictionary *json = [_receivedData objectFromJSONData];
	
	
	NSDictionary *results  = [json objectForKey:@"results"] ;
	//NSLog(@"api response:%@",results);
	_resultsAvailable = [[results objectForKey:@"results_available"] intValue];
	[_items addObjectsFromArray:[results objectForKey:@"shop"]];
	
    // release the connection, and the data object
    [_connection release];
	_connection = nil;
    [_receivedData release];
	_receivedData = nil;
	

    
	
    if ([_items count] < _resultsAvailable && [_items count] <= 500){
		[self startAddMoreData];
        _headerLabel.text = [NSString stringWithFormat:@"%d件",_resultsAvailable];
	}else{
        // モデルの更新が終了したので、テーブルを読み込み直す
        [self.tableView reloadData];
        [SVProgressHUD dismissWithSuccess:@"完了" afterDelay:1.0f];
        self.filtereditems = [NSMutableArray arrayWithCapacity:[self.items count]];
        
    }
}


#pragma mark -
#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
	/*
	 Update the filtered array based on the search text and scope.
	 */
	
	[self.filtereditems removeAllObjects]; // First clear the filtered array.
	
	/*
	 Search the main list for products whose type matches the scope (if selected) and whose name matches searchText; add items that match to the filtered array.
	 */
	for (NSDictionary *item in _items)
	{
        NSString *targetText ;
        if ([scope isEqualToString:@"住所"]) {
            targetText = [NSString stringWithFormat:@"%@",[item objectForKey:@"address"]];
        }else if ([scope isEqualToString:@"店名"]) {
            targetText = [NSString stringWithFormat:@"%@:%@",[item objectForKey:@"name"],[item objectForKey:@"name_kana"]];
            
        }else if ([scope isEqualToString:@"料理"]) {
            targetText = [NSString stringWithFormat:@"%@:%@",[[item objectForKey:@"food"] objectForKey:@"name"],[[item objectForKey:@"sub_food"] objectForKey:@"name"]];
        }else{
            targetText = [NSString stringWithFormat:@"%@:%@:%@;%@",[item objectForKey:@"name"],[item objectForKey:@"name_kana"],[item objectForKey:@"address"],[[item objectForKey:@"food"] objectForKey:@"name"],[[item objectForKey:@"sub_food"] objectForKey:@"name"]];
        }
        NSRange result = [targetText rangeOfString:searchText];
    
        
        if (result.location != NSNotFound)
        {
            [self.filtereditems addObject:item];
        }

	}
}


#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


-(void) showAbout:(id)sender{
    AboutViewController *aboutVC = [[AboutViewController alloc] init];
    aboutVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:aboutVC animated:YES];
    
    [aboutVC release];
    
}

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];

    UIBarButtonItem *searchEditButton = [[UIBarButtonItem alloc] initWithTitle:@"エリア" style:UIBarButtonItemStyleDone target:self action:@selector(editSearchParam:)];
    self.navigationItem.rightBarButtonItem = searchEditButton;
	
    
    UIBarButtonItem *aboutButton = [[UIBarButtonItem alloc] initWithTitle:@"情報" style:UIBarButtonItemStyleBordered target:self action:@selector(showAbout:)];
    self.navigationItem.leftBarButtonItem = aboutButton;
    
    
	[self setTitle:@"MTLグルメ"];
    
    
    
    [self startUpdateData];
    
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
    if (tableView == self.searchDisplayController.searchResultsTableView){
        return [self.filtereditems count];
    }else{
        return [self.items count];
    }   
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
	NSDictionary *item;
    if (tableView == self.searchDisplayController.searchResultsTableView){
        item = [self.filtereditems objectAtIndex:indexPath.row];
    }else{
        item = [self.items objectAtIndex:indexPath.row];
    }  
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
    if (tableView == self.searchDisplayController.searchResultsTableView){
        detailViewController.item = [self.filtereditems objectAtIndex:indexPath.row];
    }else{
        detailViewController.item = [self.items objectAtIndex:indexPath.row];
    }  
	
    
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
    [_headerLabel release];
    _headerLabel = nil;
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
    if (_connection){
        [_connection cancel];
        [_connection release];
        _connection = nil;
    }
    [_url release];
    _url = nil;
    [_receivedData release];
    _receivedData = nil;
    [_filtereditems release];
    _filtereditems = nil;
}


- (void)dealloc {
    if (_connection){
        [_connection cancel];
        [_connection release];
        _connection = nil;
    }
    [_currentMiddleArea release];
    [_url release];
    [_receivedData release];
	[_items release];
    [_filtereditems release];
    [_headerLabel release];
    [super dealloc];
}


@end

