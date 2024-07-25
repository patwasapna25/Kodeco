/*:
 [Previous](@previous)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Next](@next)
 
 # Strategy
 - - - - - - - - - -
 ![Strategy Diagram](Strategy_Diagram.png)
 
 The strategy pattern defines a family of interchangeable objects.
 
 This pattern makes apps more flexible and adaptable to changes at runtime, instead of requiring compile-time changes.
 
 ## Code Example
 */
import UIKit

public protocol MovieRatingStrategy {
    var ratingServiceName: String { get }
    func fetchRating(for movieTitle: String, success: (_ rating: String, _ review: String) -> ())
}

public class RottenTomatoesClient: MovieRatingStrategy {
    public let ratingServiceName = "Rotten Tomatoes"
    
    public func fetchRating(for movieTitle: String, success: (String, String) -> ()) {
        let rating = "95%"
        let review = "It rocked!"
        success(rating, review)
    }
}

public class IMDbClient: MovieRatingStrategy {
    public let ratingServiceName = "IMDb"
    
    public func fetchRating(for movieTitle: String, success: (String, String) -> ()) {
        let rating = "3/10"
        let review = "It was terrible!"
        success(rating, review)
    }
}

class MovieRatingViewController: UIViewController {
    public var movieRatingClient: MovieRatingStrategy!
    
    @IBOutlet public var movieTitleTextFeild: UITextField!
    @IBOutlet public var ratingServiceLabel: UILabel!
    @IBOutlet public var ratingLabel: UILabel!
    @IBOutlet public var reviewLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ratingServiceLabel.text = movieRatingClient.ratingServiceName
    }
    
    func searchButtonPressed(_ sender: Any) {
        guard let title = movieTitleTextFeild.text, title.count > 0 else {
            return
        }
        movieRatingClient.fetchRating(for: title, success: { (rating, review) in
            self.ratingLabel.text = rating
            self.reviewLabel.text = review
        })
    }
}
