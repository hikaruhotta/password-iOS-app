// courtesy of https://medium.com/@nitinpatel_20236/how-to-shuffle-correctly-shuffle-an-array-in-javascript-15ea3f84bfb
exports.shuffleArray = function (inputArray) {
    // copy input array:
    let array = inputArray.slice();
    for (let i = array.length - 1; i > 0; i--){
        const j = Math.floor(Math.random() * i)
        const temp = array[i]
        array[i] = array[j]
        array[j] = temp
    }
    return array;
}

// courtesy of https://medium.com/@Dragonza/four-ways-to-chunk-an-array-e19c889eac4
exports.chunkArray = function (array, size) {
    const chunked_arr = [];
    for (let i = 0; i < array.length; i++) {
      const last = chunked_arr[chunked_arr.length - 1];
      if (!last || last.length === size) {
        chunked_arr.push([array[i]]);
      } else {
        last.push(array[i]);
      }
    }
    return chunked_arr;
}