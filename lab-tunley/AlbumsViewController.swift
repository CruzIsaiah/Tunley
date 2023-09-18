import UIKit
import Nuke

class AlbumsViewController: UIViewController, UICollectionViewDataSource {

    // Add the property to hold the array of albums
    var albums: [Album] = []

    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the collection view's data source
        collectionView.dataSource = self

        // Create a search URL for fetching albums (`entity=album`)
        let url = URL(string: "https://itunes.apple.com/search?term=blackpink&attribute=artistTerm&entity=album&media=music")!
        let request = URLRequest(url: url)

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in

            // Handle any errors
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                return
            }

            // Make sure we have data
            guard let data = data else {
                print("❌ Data is nil")
                return
            }

            do {
                // Create a JSON Decoder
                let decoder = JSONDecoder()

                // Try to parse the response into our custom model
                let response = try decoder.decode(AlbumSearchResponse.self, from: data)
                let albums = response.results

                // Set the 'albums' property with the fetched albums and reload the collection view data on the main thread
                DispatchQueue.main.async {
                    self?.albums = albums
                    self?.collectionView.reloadData()
                }
            } catch {
                print(error.localizedDescription)
            }
        }

        // Initiate the network request
        task.resume()
        
        // Get a reference to the collection view's layout
        // We want to dynamically size the cells for the available space and desired number of columns.
        // NOTE: This collection view scrolls vertically, but collection views can alternatively scroll horizontally.
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout

        // The minimum spacing between adjacent cells (left / right, in vertical scrolling collection)
        // Set this to taste.
        layout.minimumInteritemSpacing = 4

        // The minimum spacing between adjacent cells (top / bottom, in vertical scrolling collection)
        // Set this to taste.
        layout.minimumLineSpacing = 4

        // Set this to however many columns you want to show in the collection.
        let numberOfColumns: CGFloat = 3

        // Calculate the width each cell needs to be to fit the number of columns, taking into account the spacing between cells.
        let width = (collectionView.bounds.width - layout.minimumInteritemSpacing * (numberOfColumns - 1)) / numberOfColumns

        // Set the size that each item/cell should display at
        layout.itemSize = CGSize(width: width, height: width)
    }

    // MARK: - UICollectionViewDataSource Methods

    // Tells the collection view how many items to display.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albums.count
    }

    // Creates, configures, and returns the cell to display for a given index path.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Get a collection view cell (based on the identifier you set in the storyboard) and cast it to your custom AlbumCell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumCell", for: indexPath) as! AlbumCell

        // Use the indexPath.item to index into the albums array to get the corresponding album
        let album = albums[indexPath.item]

        // Get the artwork image URL
        let imageUrl = album.artworkUrl100

        // Load and set the image on the image view of the cell using NUKE
        Nuke.loadImage(with: imageUrl, into: cell.albumImageView)

        return cell
    }
}
