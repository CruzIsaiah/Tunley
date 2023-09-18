import UIKit

class TracksViewController: UIViewController, UITableViewDataSource {

    var tracks: [Track] = []

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // TODO: Pt 1 - Set tracks property with mock tracks array

        // Create a URL for the request
        // In this case, the custom search URL you created in part 1
        let url = URL(string: "https://itunes.apple.com/search?term=blackpink&attribute=artistTerm&entity=song&media=music")!

        // Use the URL to instantiate a request
        let request = URLRequest(url: url)

        // Create a URLSession using a shared instance and call its dataTask method
        // The data task method attempts to retrieve the contents of a URL based on the specified URL.
        // When finished, it calls its completion handler (closure) passing in optional values for data (the data we want to fetch), response (info about the response like status code) and error (if the request was unsuccessful)
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in

            // Handle any errors
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                return // Exit early if there's an error
            }

            // Make sure we have data
            guard let data = data else {
                print("❌ Data is nil")
                return // Exit early if there's no data
            }

            // Create a JSON Decoder
            let decoder = JSONDecoder()

            // Create a date formatter with the specific format that matches what's in our JSON
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"

            // Set the decoding strategy on the JSON decoder to use our custom date format
            decoder.dateDecodingStrategy = .formatted(dateFormatter)

            do {
                // Use the JSON decoder to try and map the data to our custom model.
                // TrackResponse.self is a reference to the type itself, tells the decoder what to map to.
                let response = try decoder.decode(TracksResponse.self, from: data)

                // Access the array of tracks from the `results` property
                let tracks = response.results
                print("✅ \(tracks)")

                // Execute UI updates on the main thread when calling from a background callback
                DispatchQueue.main.async {
                    // Set the view controller's tracks property as this is the one the table view references
                    self?.tracks = tracks

                    // Make the table view reload now that we have new data
                    self?.tableView.reloadData()
                }
            } catch {
                print(error.localizedDescription)
            }
        }

        // Initiate the network request
        task.resume()
        print("👋 Below the closure")
        
        // Set the table view data source here
        tableView.dataSource = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // TODO: Deselect any selected table view rows
        
        // Get the index path for the currently selected table view row (if exists)
        if let indexPath = tableView.indexPathForSelectedRow {
            
            // Deselect the row at the corresponding index path
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // TODO: Pt 1 - Pass the selected track to the detail view controller

        // Get the cell that triggered the segue
        if let cell = sender as? UITableViewCell,
           // Get the index path of the cell from the table view
           let indexPath = tableView.indexPath(for: cell),
           // Get the detail view controller
           let detailViewController = segue.destination as? DetailViewController {

            // Use the index path to get the associated track
            let track = tracks[indexPath.row]

            // Set the track on the detail view controller
            detailViewController.track = track
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // Get a cell with identifier, "TrackCell"
        // the `dequeueReusableCell(withIdentifier:)` method just returns a generic UITableViewCell so it's necessary to cast it to our specific custom cell.
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrackCell", for: indexPath) as! TrackCell

        // Get the track that corresponds to the table view row
        let track = tracks[indexPath.row]

        // Configure the cell with its associated track
        cell.configure(with: track)

        // Return the cell for display in the table view
        return cell
    }
}
