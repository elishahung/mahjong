enum TileType: String, CaseIterable {
    case WAN = "萬"
    case TIAO = "條"
    case TON = "筒"
    case DONG = "東"
    case NAN = "南"
    case XI = "西"
    case BEI = "北"
    case RED = "中"
    case GREEN = "發"
    case WHITE = "白"
}


let numTypes: [TileType] = [.WAN, .TIAO, .TON]
let pureTypes: [TileType] = [.DONG, .NAN, .XI, .BEI, .RED, .GREEN, .WHITE]


extension Int {
    init(from tileType: TileType, order: Int?) {
        if pureTypes.contains(tileType) {
            self = pureTypes.firstIndex(of: tileType)! * 3
        } else {
            self = (numTypes.firstIndex(of: tileType)! + 1) * 30 + order!
        }
    }

    var tile: String {
        if self < 30 {
            return pureTypes[self / 3].rawValue
        } else {
            return "\(self % 30)\(numTypes[self / 30 - 1].rawValue)"
        }
    }
}


func getEveryTilesNumber() -> [Int] {
    var tiles: [Int] = []
    for type in TileType.allCases {
        if numTypes.contains(type) {
            for n in 1...9 {
                tiles.append(Int(from: type, order: n))
            }
        } else {
            tiles.append(Int(from: type, order: nil))
        }
    }
    return tiles
}

let everyTilesNumber = getEveryTilesNumber()


extension Array where Element == Int {
    var tiles: String {
        return self.map{ $0.tile }.joined(separator: " ")
    }
    
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
    
    func isResolved() -> Bool {
        var notPass = false
        var ignore = false
        var ignoreTimes = 0
        
        for (idx, i) in self.enumerated() {
            if ignore && ignoreTimes != 0 {
                ignoreTimes -= 1
                if ignoreTimes == 0 {
                    ignore = false
                }
                continue
            } else if idx + 3 > self.count {
                notPass = true
                break
            } else {
                if i == self[idx + 2] {
                    ignore = true
                    ignoreTimes = 2
                    continue
                }else if i > 30 {
                    var step = 1
                    var lst: [Int] = []
                    for a in self[(idx + 1)...] {
                        if step == -1 {
                            lst.append(a)
                            continue
                        }
                        if a - i > 2 {
                            notPass = true
                            break
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
                    if notPass {
                        break
                    }
                    return lst.isResolved()
                }
            }
            notPass = true
            break
        }
        return notPass
    }
    
    func isHu() -> Bool {
        let eyes = self.getDuplicates(moreThan: 2)
        
        for eye in eyes {
            let numbers = self.removeNumber(number: eye, times: 2)
            let notPass = numbers.isResolved()
            if !notPass {
                return true
            }
        }
        return false
    }
    
    func listTin() -> [Int] {
        let fullTiles = self.getDuplicates(moreThan: 4)
        var tinTiles: [Int] = []
        for t in everyTilesNumber {
            if fullTiles.contains(t) {
                continue
            }
            if (self + [t]).sorted().isHu() {
                tinTiles.append(t)
            }
        }
        return tinTiles
    }
}


extension String {
    var tilesNumber: [Int] {
        let numbers: [Int] = self.split(separator: " ").map{
            if $0.count == 1 {
                return Int(from: TileType(rawValue: String($0))!, order: nil)
            } else {
                let order = Int($0.prefix(1))
                let type = TileType(rawValue: String($0.suffix(1)))!
                return Int(from: type, order: order)
            }
        }
        return numbers.sorted()
    }
}


class Deck {
    private var tileNumbers: [Int]
    
    init() {
        var numbers: [Int] = []
        for t in TileType.allCases {
            for _ in 1...4 {
                if numTypes.contains(t) {
                    for n in 1...9 {
                        numbers.append(Int(from: t, order: n))
                    }
                } else {
                    numbers.append(Int(from: t, order: nil))
                }
            }
        }
        self.tileNumbers = numbers
    }
    
    func drawTileNumbers(tileCount: Int) -> [Int] {
        self.tileNumbers.shuffle()
        return Array(self.tileNumbers[0...(tileCount - 1)]).sorted()
    }
}
