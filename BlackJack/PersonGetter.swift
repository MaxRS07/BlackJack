import Foundation
import SwiftUI

public class PersonGetter {
    
    static let url = "https://thispersondoesnotexist.com/"
    
    static func getPerson() async -> UIImage? {
        let request = NSMutableURLRequest(url: NSURL(string: url)! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        let session = URLSession.shared
        let (data, response) = try! await session.data(for: request as URLRequest)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            print("Error with the response, unexpected status code: \(response)")
            return nil
        }
        return UIImage(data: data)
    }
}
