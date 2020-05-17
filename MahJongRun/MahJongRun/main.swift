import Foundation

let deck = Deck()
var tilesLibrary: [[Int]] = []
let cnt = 1000

for _ in 1...cnt {
    tilesLibrary.append(deck.drawTileNumbers(tileCount: 16))
}

let st = CFAbsoluteTimeGetCurrent()

for tiles in tilesLibrary {
    tiles.listTin()
}

print((CFAbsoluteTimeGetCurrent() - st) / Double(cnt))
