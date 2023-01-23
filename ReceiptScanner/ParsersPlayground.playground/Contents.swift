import Foundation

// 40.6782 N, 73.9442 W

struct Coordinate {
    let latitude: Double
    let longitude: Double
}

func parseLatLong(_ str: String) -> Coordinate? {
    let parts = str.split(separator: " ")
    guard parts.count == 4 else { return nil }
    
    guard
        let lat = Double(parts[0].dropLast()),
        let lon = Double(parts[2].dropLast())
    else { return nil }
    let latCard = parts[1].dropLast()
    guard latCard == "N" || latCard == "S" else { return nil }
    let lonCard = parts[3]
    guard lonCard == "E" || lonCard == "W" else { return nil }
    let latSign = latCard == "N" ? 1.0 : -1
    let lonSign = lonCard == "E" ? 1.0 : -1
    return Coordinate(latitude: lat * latSign, longitude: lon * lonSign)
}

print(parseLatLong("40.6782 N, 73.9442 W"))

struct Parser<A> {
  let run: (inout String) -> A?
}

let int = Parser<Int> { str in
    let prefix = str.prefix(while: { $0.isNumber })
    guard let int = Int(prefix) else { return nil }
    str.removeFirst(prefix.count)
    return int
}

extension Parser {
    func run(_ str: String) -> (match: A?, rest: String) {
        var str = str
        let match = self.run(&str)
        return (match, str)
    }
}

int.run("42")
int.run("42 Hello World")
int.run("Hello World")
