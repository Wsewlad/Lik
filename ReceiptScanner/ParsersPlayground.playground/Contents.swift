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
