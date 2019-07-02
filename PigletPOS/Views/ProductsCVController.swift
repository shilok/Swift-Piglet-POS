import UIKit
import SocketIO




class ProductsCVController: UIViewController {
    
    
    var socket:SocketIOClient!
    let manager = SocketManager(socketURL: URL(string: "https://piglet-pos.com:5000")!, config: [.log(false), .compress])
    var socketDelegate: SocketDelegate?
    var postFromStoreVC = false
    
    
    private let reuseIdentifier = "Cell"
    let searchController = UISearchController(searchResultsController: nil)
    private let spacing:CGFloat = 16.0
    var products: [Product]?
    var filterProducts = [Product]()
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var blur: UIVisualEffectView!
    @IBAction func dismissView(dis: UIStoryboardSegue){}
    
    
    override func viewDidAppear(_ animated: Bool) {
            checkToken()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        initSearchController()
        initSocket()
        setCellsSpacing()
        
        NotificationCenter.default.addObserver(self, selector: #selector(storeNotification(notification:)), name: .StoreSelected, object: nil)
        
        
        
        
    }
    
    @objc func storeNotification(notification: Notification){
        guard let store = notification.userInfo?["store"] as? Store else {return}
        postFromStoreVC = true
        if let token = UserDefaults.standard.string(forKey: "token"){
//            UIView.animate(withDuration: 0.3) {
//                self.blur.alpha = 0
//                self.blur.isHidden = true
//            }
            connectToStore(token: token, stockID: store.stockID)
        }
        
    }
    
    
    
    @IBAction func addBtn(_ sender: UIButton) {
        print("selected")
    }
    
    @IBAction func infoBtn(_ sender: UIButton) {
        print("selected")
    }
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? LoginViewController{
            dest.delegate = self
        }
        if let dest = segue.destination as? ProductDetailsVC{
            guard let product = sender as? Product else {return}
            dest.product = product
            socketDelegate = dest
        }
        if let dest = segue.destination as? StoresViewController{
            dest.stores = sender as? [Store]
            
        }
    }
    
    
    override func unwind(for unwindSegue: UIStoryboardSegue, towards subsequentVC: UIViewController) {
        let segue = ZoomOutSegue(identifier: unwindSegue.identifier, source: unwindSegue.source, destination: unwindSegue.destination)
        segue.perform()
    }
    
    func checkToken() {
        if let token = UserDefaults.standard.string(forKey: "token"){
            UIView.animate(withDuration: 0.3) {
                self.blur.alpha = 0
                self.blur.isHidden = true
                if !self.defaultStoreIsSet(){
                    self.pullProduct(token: token, stockID: nil)
                }else{
                    self.pullProduct(token: token, stockID: self.defaultStoreStockID())
                }

            }
        }else{
            performSegue(withIdentifier: "LoginVCSegue", sender: nil)
            blur.isHidden = false
            blur.alpha = 0.75
        }

    }
    
    func defaultStoreIsSet() -> Bool{
        return UserDefaults.standard.bool(forKey: "storeSet")
    }
    func defaultStoreStockID() -> Int{
        return UserDefaults.standard.integer(forKey: "stockID")
    }
    
    func connectToStore(token: String, stockID: Int){
        InitPull().getData(token: token, stockID: stockID, callBack: {data in
            guard let status = data["status"]as? String else {return}
            if status == "stores"{
                do{
                    let json = try JSONSerialization.data(withJSONObject: data, options: [])
                    let newProducts = try JSONDecoder().decode(ProductSource.self, from: json)
                    self.products = newProducts.products
                    self.collectionView.reloadData()
                }catch let err { print(err) }
            }
        })
    }
    
    func pullProduct(token: String, stockID: Int?){
        InitPull().getData(token: token, stockID: stockID, callBack: { data in
            guard let status = data["status"]as? String else {return}
            
            switch status{
            case "stores":
                do{
                    let json = try JSONSerialization.data(withJSONObject: data, options: [])
                    let source = try JSONDecoder().decode(StoreSource.self, from: json)
                    self.performSegue(withIdentifier: "storesSegue", sender: source.stores)
                    return
                }catch let err { print(err) }
                
            case "store":
                print("Store")
                do{
                    let json = try JSONSerialization.data(withJSONObject: data, options: [])
                    let newProducts = try JSONDecoder().decode(ProductSource.self, from: json)
                    self.products = newProducts.products
                    self.collectionView.reloadData()
                    
                }catch let err { print(err) }
                
            case "empty": print("Employee Not connected to any store")
            case "Unauthorized": print("Unauthorized")
            default: print("Default")
            }
            
        })
        
    }

    

    
    
    func initSocket(){
        socket = manager.defaultSocket
        setSocketEvents()
        socket.connect()
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
        
        socket.on("quantity_updated") {data, ack in
            
            print(data)
            guard
                let json = data.first as? Json,
                let products = self.products,
                
                
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
            
            self.socketDelegate?.receiveUpdate(product)
            self.collectionView.reloadItems(at: [index])
            
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
    
    
    
    
}


extension ProductsCVController : UISearchBarDelegate{
    
}
extension ProductsCVController : LoginDelegate{
    func loginFinish() {
        checkToken()
    }
}

extension ProductsCVController : UISearchResultsUpdating{
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchBar(searchController.searchBar.text!)
    }
}

extension ProductsCVController : UICollectionViewDataSource{
    
    
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ProductCVCell
        
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

extension ProductsCVController: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let products = products else {return}
        let product = products[indexPath.item]
        performSegue(withIdentifier: "detailsSegue", sender: product)
    }
}

extension ProductsCVController : UICollectionViewDelegateFlowLayout{
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


