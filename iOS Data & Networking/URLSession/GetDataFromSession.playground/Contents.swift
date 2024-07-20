import SwiftUI

let configuration = URLSessionConfiguration.default
let session = URLSession(configuration: configuration)

guard let url = URL(string: "https://itunes.apple.com/search?media=music&entity=song&term=starlight") else {
    fatalError("Could not create URL")
}

Task {
    let (data, response) = try await session.data(from: url) 
    // check if response is a success and it has some data
    guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode), let datastring = String(data: data, encoding: .utf8) else {
        return
    }
    
    print(datastring)
}
