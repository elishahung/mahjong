//
// Created by 洪健淇 on 2019/10/30.
//

#include <iostream>
#include <vector>
#include <chrono>
#include <random>

using namespace std;

class Tile {
private:
    inline static const string strs[10] = {"萬", "條", "筒", "東", "南", "西", "北", "中", "發", "白"};
    static constexpr int nums[10] = {0, 20, 40, 60, 65, 70, 75, 80, 85, 90};
    inline static int allTiles[34] = {0};
    inline static int deckTiles[136] = {0};

    template<class T> static int getIndex(const T *arr, const T& item) {
        auto itr = find(arr, arr + 10, item);
        return distance(arr, itr);
    };

    static string numberToString(const int& num) {
        if (num >= 60) {
            return strs[getIndex(nums, num)];
        }
        int order = num % 10;
        return to_string(order) + strs[getIndex(nums, num - order)];
    }

    static int make(const string& type, const int& order=0) {
        return nums[getIndex(strs, type)] + order;
    }

    static vector<int>getDuplicates(const vector<int>& numbers, const int& times) {
        int last = numbers[0];
        int ocu = 1;
        vector<int> result;
        for (size_t i = 1; i < numbers.size(); i++) {
            int num = numbers[i];
            if (num == last) {
                ocu += 1;
                if (ocu == times) {
                    result.push_back(num);
                }
            } else {
                ocu = 1;
            }
            last = num;
        }
        return result;
    }

    static vector<int> removeDuplicates(const vector<int>& numbers, const int& delNum, int times) {
        vector<int> result;
        for (int num : numbers) {
            if (num == delNum && times != 0) {
                times -= 1;
                continue;
            }
            result.push_back(num);
        }
        return result;
    }

    static bool isResolved(const vector<int>& numbers) {
        bool isIgnore = false;
        int ignoreTimes = 0;

        for (size_t idx = 0; idx < numbers.size(); idx++) {
            if (isIgnore && ignoreTimes != 0) {
                ignoreTimes -= 1;
                if (ignoreTimes == 0) {
                    isIgnore = -1;
                }
                continue;
            }
            if (idx + 3 > numbers.size()) {
                return false;
            }

            int i = numbers[idx];
            if (i == numbers[idx + 2]) {
                isIgnore = true;
                ignoreTimes = 2;
                continue;
            }

            if (i < 60) {
                int step = 1;
                vector<int> lst;
                for (size_t ia = idx + 1; ia < numbers.size(); ia++) {
                    int a = numbers[ia];
                    if (step == -1) {
                        lst.push_back(a);
                        continue;
                    }
                    if (a - i > 2) {
                        return false;
                    }
                    if (a - i == step) {
                        if (step == 2) {
                            step = -1;
                            continue;
                        }
                        step += 1;
                        continue;
                    }
                    lst.push_back(a);
                }
                return isResolved(lst);
            }
            return false;
        }
        return true;
    }

    static void checkAllTiles() {
        if (allTiles[0] == 0) {
            int count = 0;
            for (int n : nums) {
                if (n >= 60) {
                    allTiles[count] = n;
                    count += 1;
                    continue;
                }
                for (int i = 1; i < 10; i++) {
                    allTiles[count] = n + i;
                    count += 1;
                }
            }
        }
    }

    static void checkDeckTiles() {
        if (deckTiles[0] == 0) {
            checkAllTiles();
            for (int i = 0; i < 4; i++) {
                copy(allTiles, end(allTiles), deckTiles + i * size(allTiles));
            }
        }
    }

public:
    static bool isHu(const vector<int>& numbers) {
        vector<int> eyes = getDuplicates(numbers, 2);

        for (int eye : eyes) {
            vector<int> ns = removeDuplicates(numbers, eye, 2);
            if (isResolved(ns)) return true;
        }

        return false;
    }

    static vector<int> listTin(const vector<int>& numbers) {
        vector<int> fullTiles = getDuplicates(numbers, 4);
        vector<int> tinTiles;

        checkAllTiles();
        for (int t : allTiles) {
            if (find(fullTiles.begin(), fullTiles.end(), t) != fullTiles.end()) {
                continue;
            }

            vector<int> ns(numbers);
            ns.push_back(t);
            sort(ns.begin(), ns.end());

            if (isHu(ns)) {
                tinTiles.push_back(t);
            }
        }
        return tinTiles;
    }

    static vector<int> tilesFromString(const string& tileString) {
        vector<int> tiles;
        int order = 0;
        for (size_t i = 0; i < tileString.length();) {
            int cplen = 1;
            if ((tileString[i] & 0xf8) == 0xf0) cplen = 4;
            else if ((tileString[i] & 0xf0) == 0xe0) cplen = 3;
            else if ((tileString[i] & 0xe0) == 0xc0) cplen = 2;
            if ((i + cplen) > tileString.length()) cplen = 1;

            const string c = tileString.substr(i, cplen);
            i += cplen;

            if (isdigit(c[0])) {
                order = c[0] - '0';
                continue;
            }
            if (c == " ") {
                order = 0;
                continue;
            }
            tiles.push_back(make(c, order));
        }
        sort(tiles.begin(), tiles.end());
        return tiles;
    }

    static string translate(const int& num) {
        return numberToString(num);
    }

    static string translate(const vector<int>& numbers) {
        string str;
        for (size_t i = 0; i < numbers.size(); i++) {
            int num = numbers[i];
            str += numberToString(num);
            if (i != numbers.size() - 1) str += " ";
        }
        return str;
    }

    static vector<int> draw(const int& num) {
        checkDeckTiles();
        random_device rd;
        shuffle(deckTiles, end(deckTiles), default_random_engine(rd()));
        vector<int> drawTiles(deckTiles, deckTiles + num);
        sort(drawTiles.begin(), drawTiles.end());
        return drawTiles;
    }
};

class Timer {
private:
    chrono::time_point<chrono::high_resolution_clock> startTime;
public:
    Timer() {
        startTime = chrono::high_resolution_clock::now();
    }
    void log(const string& message, const int& count=1) {
        chrono::duration<double> elapsed = chrono::high_resolution_clock::now() - startTime;
        cout << message << fixed << elapsed.count() / count << endl;
    }
};

void performanceTin(const int& count) {
    vector<int> tilesList[count];
    for (int i = 0; i < count; i++) {
        tilesList[i] = Tile::draw(16);
    }

    Timer timer = Timer();
    for (const vector<int>& tiles : tilesList) {
        Tile::listTin(tiles);
    }
    timer.log("Per tin time: ", count);
}

void findHuForm() {
    int count = 0;
    int th = 0;
    vector<int> tiles;
    Timer timer = Timer();

    do {
        tiles = Tile::draw(17);
        count += 1;
        th += 1;
        if (th == 10000) {
            th = 0;
            cout << count << endl;
        }
    } while (!Tile::isHu(tiles));

    cout << "Found form: " << Tile::translate(tiles) << endl;
    cout << "Draw count: " << count << endl;
    timer.log("Per draw & isHu time: ", count);
}

int main() {
    vector<int> tiles = Tile::tilesFromString("6萬 7萬 8萬 5條 6條 7條 9條 9條 4筒 5筒 6筒 7筒 8筒 9筒 中 中");
    cout << Tile::translate(Tile::listTin(tiles)) << endl;

    performanceTin(10000);

    findHuForm();

    return 0;
}