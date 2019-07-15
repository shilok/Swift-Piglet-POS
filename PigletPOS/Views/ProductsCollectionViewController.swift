import UIKit


let window = UIApplication.shared.delegate?.window
let app = UIApplication.shared

class ProductsCollectionViewController: UIViewController {
    
    
    var socketDelegate: SocketDelegate?
    
    
    private let reuseIdentifier = "Cell"
    let searchController = UISearchController(searchResultsController: nil)
    private let spacing:CGFloat = 16.0
    var products: [Product]?
    var filterProducts = [Product]()
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBAction func dismissView(dis: UIStoryboardSegue){}
    
    
    override func viewDidAppear(_ animated: Bool) {
        print("viewDidAppear")
            checkToken()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        initSearchController()
        setCellsSpacing()
        
        setSocketEvents()

        
        NotificationCenter.default.addObserver(self, selector: #selector(storeNotification(notification:)), name: .StoreSelected, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(checkToken), name: .LoginSubmitted, object: nil)
    }
    
    deinit {
        print("DeInit Product CollectionView")
        NotificationCenter.default.removeObserver(self, name: .StoreSelected, object: nil)
        NotificationCenter.default.removeObserver(self, name: .LoginSubmitted, object: nil)
    }
    
    @objc func storeNotification(notification: Notification){
        guard let store = notification.userInfo?["store"] as? Store else {return}
        if let token = UserDefaults.standard.string(forKey: "token"){
            connectToStore(token: token, stockID: store.stockID)
        }
    }
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let dest = segue.destination as? ProductDetailsVC{
            guard let product = sender as? Product else {return}
            print("Prepare for details")
            dest.product = product
            socketDelegate = dest
        }
        if let dest = segue.destination as? StoresViewController{
            dest.stores = sender as? [Store]
        }
    }
    
    
    

    
    @objc func checkToken() {
        
        print("checkToken")
        if let token = UserDefaults.standard.string(forKey: "token"){
            
                if !self.defaultStoreIsSet(){
                    self.pullProduct(token: token, stockID: nil)
                }else{
                    self.pullProduct(token: token, stockID: self.defaultStoreStockID())
                }
            
        }else{
            print("Perform Seg - LoginVCSegue")
            guard let rootView = window??.rootViewController else {return}
   
            let loginVC = LoginViewController.storyboardInstance()
                loginVC.modalPresentationStyle = .fullScreen
            rootView.present(loginVC, animated: true)


            print("dismissed")
        }
    }

    
    func defaultStoreIsSet() -> Bool{
        return UserDefaults.standard.bool(forKey: "storeSet")
    }
    func defaultStoreStockID() -> Int{
        return UserDefaults.standard.integer(forKey: "stockID")
    }
    
    func connectToStore(token: String, stockID: Int){
        
        DataSource().getData(token: token, stockID: stockID, callBack: {[weak self] data in
            guard let status = data["status"]as? String else {return}
            print("connectToStore: \(status)")
            if status == "products"{
                do{
                    
                    let json = try JSONSerialization.data(withJSONObject: data, options: [])
                    let newProducts = try JSONDecoder().decode(ProductSource.self, from: json)
                    self?.saveProducts(products: newProducts.products)
                    self?.products = newProducts.products
                    self?.collectionView.reloadData()
                }catch let err { print(err) }
            }
        })
    }
    
    func saveProducts(products: [Product]){
        let data = try! JSONEncoder().encode(products)
        UserDefaults.standard.set(data, forKey: "products")
    }
    
    func pullProduct(token: String, stockID: Int?){
        DataSource().getData(token: token, stockID: stockID, callBack: {[weak self] data in
            

            guard let status = data["status"]as? String else {return}
            print("pullProduct: \(status)")

            switch status{
            case "stores":
                print("stores")
                do{
                    let json = try JSONSerialization.data(withJSONObject: data, options: [])
                    let source = try JSONDecoder().decode(StoreSource.self, from: json)
                    guard let window = window else {return}
                    let storesVC = StoresViewController.storyboardInstance()
                    storesVC.stores = source.stores
                    window?.rootViewController?.present(storesVC, animated: true)
                    
                }catch let err { print(err) }
                
            case "products":
                print("products")
                do{
                    let json = try JSONSerialization.data(withJSONObject: data, options: [])
                    let newProducts = try JSONDecoder().decode(ProductSource.self, from: json)
                    self?.products = newProducts.products
                    self?.saveProducts(products: newProducts.products)
                    print(newProducts.products[1].descriptions)
                    self?.collectionView.reloadData()
                    
                }catch let err { print(err) }
                
            case "empty": print("Employee Not connected to any store")
            case "Unauthorized": print("Unauthorized")
            default: print("Default")
            }
            
        })
        
    }

    
    
    

    
    func setCellsSpacing(){
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        self.collectionView?.collectionViewLayout = layout
    }
    
    private func setSocketEvents(){
        
        
        
        socket.on(clientEvent: .connect) {data, ack in
            print("socket connected");
        };
        
       
        
        socket.on("quantity_updated") {[weak self] data, ack in
            
            guard
                let json = data.first as? Json,
                let products = self?.products,
                let invetoryID = json["inventoryID"] as? Int,
                let productID = json["productID"] as? Int,
                let quantity = json["quantity"] as? Int,
                
                let productIndex = products.firstIndex(where: { (product) -> Bool in
                    product.stockID == invetoryID && product.productID == productID})
                else {return}
            print("invetoryID: \(invetoryID), productID: \(productID), quantity: \(quantity)")
            
            let index = IndexPath(indexes: [productIndex])
            let product = products[productIndex]
            product.quantity = quantity
            
            self?.socketDelegate?.receiveUpdate(product)
            self?.collectionView.reloadItems(at: [index])
            
        };
    };
    
    func initSearchController(){
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Product"
        navigationItem.searchController = searchController
        searchController.searchBar.scopeButtonTitles = ["All", "Category"]
        searchController.searchBar.delegate = self
        
        
        definesPresentationContext = true
        
    }
    
    func searchBarIsEmpty() -> Bool{
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    func filterContentForSearchBar(_ searchBar: String, scope: String = "All"){
        guard let products = products else {return}
        filterProducts = products.filter({ product -> Bool in
            return product.name.lowercased().contains(searchBar.lowercased())
        })
        collectionView.reloadData()
    }
    
    func animateToDetails(){
        
    }
    
    
}





extension ProductsCollectionViewController : UISearchResultsUpdating, UISearchBarDelegate{
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchBar(searchController.searchBar.text!)
    }
}

extension ProductsCollectionViewController : UICollectionViewDataSource{
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if (kind == UICollectionView.elementKindSectionHeader){
            let headerView : UICollectionReusableView = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: "cvHeader",
                for: indexPath)
            return headerView
        }
        
        return UICollectionReusableView()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isFiltering(){
            return filterProducts.count
        }
        guard let products = products else {return 0}
        return products.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ProductCollectionViewCell
        
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 5
        cell.layer.borderColor = #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1).cgColor
        
        guard var products = products else {return cell}
        if isFiltering(){
            products = filterProducts
        }
        cell.nameField.text = products[indexPath.item].name
        cell.priceField.text = String(products[indexPath.item].quantity)

        return cell
    }
    
    
}

extension ProductsCollectionViewController: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let products = products else {return}
        var product = products[indexPath.item]
        if isFiltering(){
            product = filterProducts[indexPath.item]
        }
        performSegue(withIdentifier: "detailsSegue", sender: product)
    }
    
    
}

extension ProductsCollectionViewController : UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfItemsPerRow:CGFloat = 2
        let spacingBetweenCells:CGFloat = 16
        
        let totalSpacing = (2 * self.spacing) + ((numberOfItemsPerRow - 1) * spacingBetweenCells) //Amount of total spacing in a row
        
        if let collection = self.collectionView{
            let width = (collection.bounds.width - totalSpacing)/numberOfItemsPerRow
            return CGSize(width: width, height: width)
        }else{
            return CGSize(width: 0, height: 0)
        }
    }
}


