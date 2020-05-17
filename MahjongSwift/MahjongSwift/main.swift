import Foundation


extension Array where Element == Int {
    func getDuplicates(moreThan times: Int) -> [Int] {
        var last = self[0]
        var ocu = 1
        var result: [Int] = []
        for i in self[1...] {
            if i == last {
                ocu += 1
                if ocu == times {
                    result.append(i)
                }
            } else {
                ocu = 1
            }
            last = i
        }
        return result
    }
    
    func removeNumber(number: Int, times: Int) -> [Int] {
        var numbers: [Int] = []
        var ocu = 0
        for i in self {
            if i == number && ocu < times {
                ocu += 1
                continue
            }
            numbers.append(i)
        }
        return numbers
    }
}


class Tile {
    private static let strs: [String] = ["萬", "條", "筒", "東", "南", "西", "北", "中", "發", "白"]
    private static let nums: [Int] = [0, 20, 40, 60, 65, 70, 75, 80, 85, 90]
    private static var allTiles: [Int] = []
    
    static func numberToString(from num: Int) -> String {
        if num > 60 {
            return self.strs[self.nums.firstIndex(of: num)!]
        }
        let order = num % 10
        return "\(order)\(self.strs[self.nums.firstIndex(of: num - order)!])"
    }
    static func make(from type: String, order: Int = 0) -> Int {
        return self.nums[self.strs.firstIndex(of: type)!] + order
    }
    static func getAllTiles(with duplicates: Int = 1) -> [Int] {
        if allTiles.isEmpty {
            for n in self.nums {
                if n >= 60 {
                    allTiles.append(n)
                } else {
                    for i in 1...9 {
                        allTiles.append(n + i)
                    }
                }
            }
        }
        if duplicates == 1{
            return allTiles
        }
        var tiles = allTiles
        for _ in 2...duplicates {
            tiles += allTiles
        }
        return tiles
    }
    private static func isResolved(from numbers: [Int]) -> Bool {
        var isIgnore = false
        var ignoreTimes = 0
        
        for (idx, i) in numbers.enumerated() {
            if isIgnore && ignoreTimes != 0 {
                ignoreTimes -= 1
                if ignoreTimes == 0 {
                    isIgnore = false
                }
                continue
            }
            if idx + 3 > numbers.count {
                return false
            }
            if i == numbers[idx + 2] {
                isIgnore = true
                ignoreTimes = 2
                continue
            }
            
            if i < 60 {
                var step = 1
                var lst: [Int] = []
                for a in numbers[(idx + 1)...] {
                    if step == -1 {
                        lst.append(a)
                        continue
                    }
                    if a - i > 2 {
                        return false
                    }
                    if a - i == step {
                        if step == 2 {
                            step = -1
                            continue
                        }
                        step += 1
                        continue
                    }
                    lst.append(a)
                }
                return self.isResolved(from: lst)
            }
            return false
        }
        return true
    }
    static func isHu(with numbers: [Int]) -> Bool {
        let eyes = numbers.getDuplicates(moreThan: 2)
        
        for eye in eyes {
            let ns = numbers.removeNumber(number: eye, times: 2)
            if self.isResolved(from: ns) {
                return true
            }
        }
        return false
    }
    static func listTin(with numbers: [Int]) -> [Int] {
        let fullTiles = numbers.getDuplicates(moreThan: 4)
        var tinTiles: [Int] = []
        for t in self.getAllTiles() {
            if fullTiles.contains(t) {
                continue
            }
            if self.isHu(with: (numbers + [t]).sorted()) {
                tinTiles.append(t)
            }
        }
        return tinTiles
    }
}


extension Int {
    var t: String {
        return Tile.numberToString(from: self)
    }
}


extension Array where Element == Int {
    var t: String {
        return self.map{Tile.numberToString(from: $0)}.joined(separator: " ")
    }
}


extension String {
    func toTiles() -> [Int] {
        let tiles: [Int] = self.split(separator: " ").map{
            if $0.count == 1 {
                return Tile.make(from: String($0))
            } else {
                let order = Int($0.prefix(1))!
                return Tile.make(from: String($0.suffix(1)), order: order)
            }
        }
        return tiles.sorted()
    }
}


class Deck {
    private static var tiles: [Int] = Tile.getAllTiles(with: 4)
    
    static func draw(num: Int) -> [Int] {
        self.tiles.shuffle()
        return Array(self.tiles[0...(num - 1)]).sorted()
    }
}


class Timer {
    private let time: CFAbsoluteTime
    
    init() {
        self.time = CFAbsoluteTimeGetCurrent()
    }
    
    func log(message: String, count: Int = 1) {
        let duration = CFAbsoluteTimeGetCurrent() - self.time
        print("\(message)\(duration / Double(count))s")
    }
}


func performanceTin(count: Int) {
    var tilesList: [[Int]] = []
    for _ in 1...count {
        tilesList.append(Deck.draw(num: 16))
    }
    
    let timer = Timer()
    for tiles in tilesList {
        Tile.listTin(with: tiles)
    }
    timer.log(message: "Per tin time: ", count: count)
}


func findHuForm() {
    var count = 0
    var th = 0
    var tiles: [Int] = [];
    let timer = Timer()
    
    repeat {
        tiles = Deck.draw(num: 17)
        count += 1
        th += 1
        if th == 10000 {
            th = 0
            print(count)
        }
    } while !Tile.isHu(with: tiles)
    
    print("Found form: \(tiles.t)")
    print("Draw count: \(count)")
    timer.log(message: "Per draw & isHu time: ", count: count)
}

let r = "6萬 7萬 8萬 5條 6條 7條 9條 9條 4筒 5筒 6筒 7筒 8筒 9筒 中 中"
print(Tile.listTin(with: r.toTiles()).t)

performanceTin(count: 10000)

findHuForm()
