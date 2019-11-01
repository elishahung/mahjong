function find_index(arr, value)
    for k, v in ipairs(arr) do
        if (v == value) then
            return k
        end
    end
    return -1
end

function aprint(arr)
    local str = {}
    for _, v in ipairs(arr) do
        str[#str + 1] = v
    end
    print('['..table.concat(str, ', ')..']')
end

STRS = {'萬', '條', '筒', '東', '南', '西', '北', '中', '發', '白'}
NUMS = {0, 20, 40, 60, 65, 70, 75, 80, 85, 90}

function number_to_string(num)
    if num >= 60 then
        return STRS[find_index(NUMS, num)]
    end
    local order = num % 10
    return order..STRS[find_index(NUMS, num - order)]
end

function make(_type, order)
    local order = order or 0
    return NUMS[find_index(STRS, _type)] + order
end

function make_all(duplicates)
    duplicates = duplicates or 1
    local tiles = {}
    repeat
        for _, n in ipairs(NUMS) do
            if n >= 60 then
                table.insert(tiles, n)
                goto continue
            end
            for i = 1, 9 do
                tiles[#tiles + 1] = n + i
            end
            ::continue::
        end
        duplicates = duplicates - 1
    until duplicates == 0
    return tiles
end

ALL_TILES = make_all()

function get_duplicates(numbers, times)
    local last = numbers[1]
    local ocu = 1
    local result = {}
    for idx = 2, #numbers do
        local i = numbers[idx]
        if i == last then
            ocu = ocu + 1
            if ocu == times then
                result[#result + 1] = i
            end
        else
            ocu = 1
        end
        last = i
    end
    return result
end

function remove_duplicates(numbers, number, times)
    local result = {}
    for _, i in ipairs(numbers) do
        if i == number and times ~= 0 then
            times = times - 1
            goto continue
        end
        result[#result + 1] = i
        ::continue::
    end
    return result
end

function is_resolved(numbers)
    local is_ignore = false
    local ignore_times = 0

    for idx, i in ipairs(numbers) do
        if is_ignore and ignore_times ~= 0 then
            ignore_times = ignore_times - 1
            if ignore_times == 0 then
                is_ignore = false
            end
            goto continue
        end

        if idx + 2 > #numbers then
            return false
        end

        if i == numbers[idx + 2] then
            is_ignore = true
            ignore_times = 2
            goto continue
        end

        if i < 60 then
            local step = 1
            local lst = {}
            for aidx = idx + 1, #numbers do
                a = numbers[aidx]
                if step == -1 then
                    lst[#lst + 1] = a
                    goto acontinue
                end
                if a - i > 2 then
                    return false
                end
                if a - i == step then
                    if step == 2 then
                        step = -1
                    else
                        step = step + 1
                    end
                    goto acontinue
                end
                lst[#lst + 1] = a
                ::acontinue::
            end
            return is_resolved(lst)
        end

        if true then
            return false
        end

        ::continue::
    end
    return true
end

function is_hu(numbers)
    local eyes = get_duplicates(numbers, 2)
    for _, eye in ipairs(eyes) do
        local ns = remove_duplicates(numbers, eye, 2)
        if is_resolved(ns) then
            return true
        end
    end
    return false
end

function list_tin(numbers)
    local full_tiles = get_duplicates(numbers, 4)
    local tin_tiles = {}
    for _, t in ipairs(ALL_TILES) do
        if find_index(full_tiles, t) == -1 then
            local tiles = {t}
            table.move(numbers, 1, #numbers, 2, tiles)
            table.sort(tiles)
            if is_hu(tiles) then
                tin_tiles[#tin_tiles + 1] = t
            end
        end
    end
    return tin_tiles
end

function tiles_from_string(tile_string)
    local tiles = {}
    for s in string.gmatch(tile_string, '([^%s]+)') do
        if string.len(s) == 3 then
            tiles[#tiles + 1] = make(s)
        else
            local order = tonumber(string.sub(s, 1, 1))
            tiles[#tiles + 1] = make(string.sub(s, 2, 4), order)
        end
    end
    return tiles
end

function translate(num)
    if type(num) == 'number' then
        return number_to_string(num)
    end
    local str = {}
    for _, v in ipairs(num) do
        str[#str + 1] = number_to_string(v)
    end
    return table.concat(str, ' ')
end

DECK_TILES = make_all(4)

function draw(num)
    for i = #DECK_TILES, 2, -1 do
        local j = math.random(i)
        DECK_TILES[i], DECK_TILES[j] = DECK_TILES[j], DECK_TILES[i]
    end
    local tiles = table.move(DECK_TILES, 1, num, 1, {})
    table.sort(tiles)
    return tiles
end

set_time = 0
function timer(message, count)
    count = count or 1
    if set_time ~= 0 then
        print(
            string.format(
                message..' %.8f',
                (os.clock() - set_time) / count
            )
        )
        set_time = 0
    else
        set_time = os.clock()
    end
end

function performance_tin(count)
    local tiles_list = {}
    for i = 1, count do
        tiles_list[#tiles_list + 1] = draw(16)
    end
    timer()
    for _, tiles in ipairs(tiles_list) do
        list_tin(tiles)
    end
    timer('Per tin time', count)
end

function find_hu_form()
    local count = 0
    local th = 0
    local tiles
    timer()
    repeat
        tiles = draw(17)
        count = count + 1
        th = th + 1
        if th == 10000 then
            th = 0
            print(count)
        end
    until is_hu(tiles)

    print('Found form: '..translate(tiles))
    print('Draw count: '..count)
    timer('Per draw & isHu time: ', count)
end
    

test_tiles = tiles_from_string('6萬 7萬 8萬 5條 6條 7條 9條 9條 4筒 5筒 6筒 7筒 8筒 9筒 中 中')
print(translate(list_tin(test_tiles)))

performance_tin(10000)

find_hu_form()
