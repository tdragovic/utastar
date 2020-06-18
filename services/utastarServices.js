const octaveScript = require('../utils/config').octave;
var shell = require('shelljs');
var rimraf = require("rimraf");
const fs = require('fs');
const readline = require("readline");
const { format } = require('path');

const runScript = (req, res, next) => {

    //let request = formatRequest(req.body);

    //let testFile = request.test;
    //let metaTestFile = request.metatest;

    let scriptPath = './run_uta.m';
    
    let code = Math.floor(Math.random() * 10);
    //let testPath =  code + '/test.txt';
    //let metatestPath = code + '/metatest.txt';
    let testPath = 'data/test.txt';
    let metatestPath = 'data/metatest.txt';

    //saveTxtFile(testFile, testPath);
    //saveTxtFile(metatestFile, metatestPath);

    let cmd = octaveScript.path + ' ' + scriptPath + ' ' + testPath + ' ' + metatestPath;

    shell.exec(cmd, async function (code, stdout, stderr) {
        let outputPath = './data/response.txt';
        //let outputPath = 'code/response.txt';
        saveTxtFile(outputPath, stdout);
        let stdoutJosnFormat = await formatResponse(outputPath);
        console.log(stdoutJosnFormat);
        // res.status(200).send(stdoutJosnFormat);
        //deleteFolder(code);
        
        if(stderr){
            res.status(404).send('Failed to run script. Error: ' + stderr)
        }

    });

};

const saveTxtFile = (fileTxtPath, txt) => {
    //console.log("TXT: " + txt);
    fs.writeFile(fileTxtPath, txt, function(err) {
        if(err => console.log("ERROR!" + err));
    });

};

const deleteFolder = (code) => {

    let folderPath = '../' + code;

    if (fs.existsSync(folderPath)) {
        rimraf.sync(folderPath, (err) => {
            if (err) { console.error(err); return }
        });
    }
};

const formatResponse = async (outputPath) => {

    var arr = [];

    async function processLineByLine() {
        const fileStream = fs.createReadStream(outputPath);
      
        const rl = readline.createInterface({
          input: fileStream,
          crlfDelay: Infinity
        });
        
        let obj = {
            "title": "",
            "value": []
        }
        for await (const line of rl) {

          let splittedLine;

          if(line.trim() !="" && line !='\n'){
            if(line.includes(':')){
                splittedLine = line.split(':');
                obj.title = splittedLine[0];
            }else if(line.includes('=')){
                splittedLine = line.split('=');
                obj.title = splittedLine[0];
                obj.value = splittedLine[1];
            }else{
                let lineValues = line.split(/\s+/);
                let temp = [];
                if(lineValues.length > 1) {
                    for(let v of lineValues) {
                        if(v.trim() == ''){ break; }
                        temp.push(v.trim());
                    }
                    obj.value.push(temp);
                    console.log(obj.value);
                } else {
                    obj.value.push(lineValues[0].trim());
                }
                
            }
           } else {
            arr.push(obj);
            obj = {
                "title": "",
                "value": []
            };
           }


        }
        
        // console.log("arr" + arr);
    }
    
      await processLineByLine();

    // let outputJson = await arr;

    return arr;
};

const formatRequest = (body) => {
    let requestFormated;
    //formate request {text and metatest} to txt files
    return requestFormated;
};


module.exports = {
    runScript
}