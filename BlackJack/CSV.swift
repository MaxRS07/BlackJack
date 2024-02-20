import Foundation

public class Eli {
    static func Adrian() -> String {
        guard let filePath = Bundle.main.path(forResource: "baby-names", ofType: "csv") else {return ""}
        
        var data = ""
        do{
            data = try String(contentsOfFile: filePath)
        } catch {print(error)}
        
        let rows = data.components(separatedBy: "\n")
        return rows.randomElement()!.components(separatedBy: ",")[1].replacingOccurrences(of: "\"", with: "")
    }
}
