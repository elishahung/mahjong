import random
from time import perf_counter


class Tile():
    strs = ['萬', '條', '筒', '東', '南', '西', '北', '中', '發', '白']
    nums = [0, 20, 40, 60, 65, 70, 75, 80, 85, 90]
    all_tiles = None

    @classmethod
    def number_to_string(cls, num):
        if num >= 60:
            return cls.strs[cls.nums.index(num)]
        order = num % 10
        return f'{order}{cls.strs[cls.nums.index(num - order)]}'

    @classmethod
    def make(cls, _type, order=0):
        return cls.nums[cls.strs.index(_type)] + order

    @classmethod
    def make_all(cls, duplicates=1):
        tiles = []
        while duplicates != 0:
            for n in cls.nums:
                if n >= 60:
                    tiles.append(n)
                    continue
                for i in range(9):
                    tiles.append(n + i + 1)
            duplicates -= 1
        return tiles

    @staticmethod
    def get_duplicates(numbers, times):
        last = numbers[0]
        ocu = 1
        result = []
        for i in numbers[1:]:
            if i == last:
                ocu += 1
                if ocu == times:
                    result.append(i)
            else:
                ocu = 1
            last = i
        return result

    @staticmethod
    def remove_duplicates(numbers, number, times):
        result = []
        for i in numbers:
            if i == number and times != 0:
                times -= 1
                continue
            result.append(i)
        return result

    @classmethod
    def is_resolved(cls, numbers):
        is_ignore = False
        ignore_times = 0

        for idx, i in enumerate(numbers):
            if is_ignore and ignore_times != 0:
                ignore_times -= 1
                if ignore_times == 0:
                    is_ignore = False
                continue
            if idx + 3 > len(numbers):
                return False
            if i == numbers[idx + 2]:
                is_ignore = True
                ignore_times = 2
                continue
            if i < 60:
                step = 1
                lst = []
                for a in numbers[idx + 1:]:
                    if step == -1:
                        lst.append(a)
                        continue
                    if a - i > 2:
                        return False
                    if a - i == step:
                        if step == 2:
                            step = -1
                            continue
                        step += 1
                        continue
                    lst.append(a)
                return cls.is_resolved(lst)
            return False

        return True

    @classmethod
    def is_hu(cls, numbers):
        eyes = cls.get_duplicates(numbers, 2)

        for eye in eyes:
            ns = cls.remove_duplicates(numbers, eye, 2)
            if cls.is_resolved(ns):
                return True
        return False

    @classmethod
    def get_all(cls):
        if cls.all_tiles is None:
            cls.all_tiles = cls.make_all()
        return cls.all_tiles

    @classmethod
    def tiles_from_string(cls, tiles_string):
        tiles = []
        for s in tiles_string.split(' '):
            if len(s) == 1:
                tiles.append(cls.make(s))
            else:
                tiles.append(cls.make(s[1], int(s[0])))

        return sorted(tiles)

    @classmethod
    def list_tin(cls, numbers):
        full_tiles = cls.get_duplicates(numbers, 4)
        tin_tiles = []
        for t in cls.get_all():
            if t in full_tiles:
                continue
            if cls.is_hu(sorted([*numbers, t])):
                tin_tiles.append(t)
        return tin_tiles

    @classmethod
    def translate(cls, num):
        if isinstance(num, int):
            return(cls.number_to_string(num))
        else:
            return(' '.join([cls.number_to_string(n) for n in num]))


class Deck():
    _tiles = Tile.make_all(4)

    @classmethod
    def draw(cls, num):
        random.shuffle(cls._tiles)
        return sorted(cls._tiles[:num])


class Timer():
    def __init__(self):
        self._time = perf_counter()

    def log(self, message='', count=1):
        duration = perf_counter() - self._time
        print(f'{message}{duration / count}s')


# ============================================================================


def performance_tin(count):
    tiles_list = []
    for i in range(count):
        tiles = Deck.draw(16)
        tiles_list.append(tiles)

    timer = Timer()
    for tiles in tiles_list:
        Tile.list_tin(tiles)
    timer.log('Per tin time: ', count)


def inspect(tiles_str):
    tiles = Tile.tiles_from_string(tiles_str)
    if len(tiles) == 17:
        return Tile.is_hu(tiles)
    return Tile.list_tin(tiles)


def find_hu_form():
    count = 0
    th = 0
    timer = Timer()
    tiles = Deck.draw(17)

    while not Tile.is_hu(tiles):
        tiles = Deck.draw(17)
        count += 1
        th += 1
        if th == 10000:
            th = 0
            print(count)

    print(f'Found form: {Tile.translate(tiles)}')
    print(f'Draw count: {count}')
    timer.log('Per draw & isHu time: ', count)


r = inspect(
    '6萬 7萬 8萬 5條 6條 7條 9條 9條 4筒 5筒 6筒 7筒 8筒 9筒 中 中 中'
)
print(r)

performance_tin(10000)

find_hu_form()
