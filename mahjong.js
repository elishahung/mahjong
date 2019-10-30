const { performance } = require('perf_hooks');

const Tile = {
    strs: ['萬', '條', '筒', '東', '南', '西', '北', '中', '發', '白'],
    nums: [0, 20, 40, 60, 65, 70, 75, 80, 85, 90],
    numberToString: function(num) {
        if (num >= 60) return this.strs[this.nums.indexOf(num)];
        const order = num % 10;
        return order + this.strs[this.nums.indexOf(num - order)];
    },
    make: function(type, order=0) {
        return this.nums[this.strs.indexOf(type)] + order;
    },
    makeAll: function(duplicates=1) {
        var tiles = [];
        while (duplicates != 0) {
            this.nums.forEach(n => {
                if (n >= 60) {
                    tiles.push(n);
                } else {
                    for (var i = 1; i < 10; i++) {
                        tiles.push(n + i);
                    }
                }
            });
            duplicates -= 1;
        }
        return tiles;
    },
    isResolved: function(numbers) {
        var isIgnore = false;
        var ignoreTimes = 0;

        for (var idx = 0; idx < numbers.length; idx++) {
            const i = numbers[idx];
            if (isIgnore && ignoreTimes != 0) {
                ignoreTimes -= 1;
                if (ignoreTimes === 0) isIgnore = -1;
                continue;
            }
            if (idx + 3 > numbers.length) return false;
            if (i === numbers[idx + 2]) {
                isIgnore = true;
                ignoreTimes = 2;
                continue;
            }
            if (i < 60) {
                var step = 1;
                var lst = [];
                for (var ia = idx + 1; ia < numbers.length; ia++) {
                    const a = numbers[ia];
                    if (step == -1) {
                        lst.push(a);
                        continue;
                    }
                    if (a - i > 2) return false;
                    if (a - i === step) {
                        if (step === 2) {
                            step = -1;
                            continue;
                        }
                        step += 1;
                        continue;
                    }
                    lst.push(a);
                }
                return this.isResolved(lst);
            }
            return false;
        }

        return true;
    },
    isHu: function(numbers) {
        const eyes = numbers.getDuplicates(2);
        for (var i = 0; i < eyes.length; i++) {
            const eye = eyes[i];
            const ns = numbers.removeDuplicates(eye, 2);
            if (this.isResolved(ns)) return true;
        };
        return false;
    },
    listTin: function(numbers) {
        const fullTiles = numbers.getDuplicates(4);
        var tinTiles = [];
        this.all.forEach(t => {
            if (fullTiles.includes(t)) return;
            var huTiles = [...numbers, t];
            huTiles.sort((a, b) => a - b);
            if (this.isHu(huTiles)) tinTiles.push(t);
        });
        return tinTiles;
    }
}

Tile.all = Tile.makeAll();

Object.defineProperty(Number.prototype, 't', {
    get: function() {return Tile.numberToString(this)}
})

Object.defineProperty(Array.prototype, 't', {
    get: function() {return this.map(n => Tile.numberToString(n)).join(' ')}
})

String.prototype.toTiles = function() {
    var tiles = [];
    this.split(' ').forEach(s => {
        if (s.length === 1) {
            tiles.push(Tile.make(s));
        } else {
            tiles.push(Tile.make(s[1], Number(s[0])));
        }
    });
    tiles.sort((a, b) => a - b);
    return tiles;
}

Array.prototype.getDuplicates = function(times) {
    var last = this[0];
    var ocu = 1;
    var result = [];
    for (var i = 1; i < this.length; i++) {
        const n = this[i];
        if (n === last) {
            ocu += 1;
            if (ocu === times) result.push(n);
        } else {
            ocu = 1;
        }
        last = n;
    }
    return result;
}

Array.prototype.removeDuplicates = function(number, times) {
    var result = [];
    for (var i = 0; i < this.length; i++) {
        const n = this[i];
        if (n === number && times != 0) {
            times -= 1;
            continue;
        }
        result.push(n);
    }
    return result;
}

const Deck = {
    tiles: Tile.makeAll(4),
    draw: function(num) {
        var currentIndex = this.tiles.length, temporaryValue, randomIndex;
        while (0 !== currentIndex) {
            randomIndex = Math.floor(Math.random() * currentIndex);
            currentIndex -= 1;
            temporaryValue = this.tiles[currentIndex];
            this.tiles[currentIndex] = this.tiles[randomIndex];
            this.tiles[randomIndex] = temporaryValue;
        }
        var tiles = this.tiles.slice(0, num);
        tiles.sort((a, b) => a - b);
        return tiles;
    }
}

class Timer  {
    constructor() {
        this.time = performance.now();
    }
    
    log(message='', count=1) {
        console.log(message + (performance.now() - this.time) / 1000 / count + 's');
    }
}

const performanceTin = count => {
    var tilesList = [];
    for (var i = 0; i < count; i++) {
        tilesList.push(Deck.draw(16));
    }

    const timer = new Timer();
    tilesList.forEach(tiles => Tile.listTin(tiles));
    timer.log('Per tin time: ', count)
}

const inspect = tilesStr => {
    const tiles = tilesStr.toTiles();
    if (tiles.length === 17) {
        return Tile.isHu(tiles);
    }
    return Tile.listTin(tiles);
}

const findHuForm = () => {
    var count = 0;
    var th = 0;
    var tiles;
    const timer = new Timer();

    do {
        tiles = Deck.draw(17);
        count += 1;
        th += 1;
        if (th === 10000) {
            th = 0;
            console.log(count);
        }
    }while(!Tile.isHu(tiles));

    console.log('Found form: ' + tiles.t);
    console.log('Draw count: ' + count);
    timer.log('Per draw & isHu time: ', count);
}

const r = inspect('6萬 7萬 8萬 5條 6條 7條 9條 9條 4筒 5筒 6筒 7筒 8筒 9筒 中 中 中')
console.log(r)

performanceTin(10000)

findHuForm()
