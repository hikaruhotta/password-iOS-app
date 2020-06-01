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

exports.tempWordlists = [
    ['energy','brain','speed','coast','light','department','video','sip','office','sound',],
    ['jacket','game','block','blood','frame','field','line','nuclear','age','object',],
    ['magic','book','party','park','city','island','stage','fame','captain','machine',],
    ['dome','shipment','industry','college','baker','work','radius','movie','color','dance',],
    ['gallery','shoes','power','bar','water','laser','theater','autumn','badge','weather',],
    ['sing','court','kingdom','rocket','advance','card','rock','property','editor','motor',],
    ['blanket','time', 'opera','stone','lens','radio','motorcycle','appliance','black','camera',],
    ['permit','customer','shadow','library','chain','world','plant','bird','house','film',],
    ['floor','picture','score','music','audio','hotel','cart','student','paper','prize',],
    ['home','life','building','construction','money','culture','drive','triangle','link','island',]
];