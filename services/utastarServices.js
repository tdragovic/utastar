const matlabScript = require('../utils/config').matlab;
var shell = require('shelljs');
const fs = require('fs');
const readline = require("readline");

const runScript = async (req, res, next) => {

  try {

    let body = req.body;

    request = formatRequest(body);

    matlabpath = "\"" + matlabScript.path + "\"";

    let testFile = request.test;
    let metatestFile = request.metatest;
    let scriptPath = 'run_uta';
    
    let dataCode = Math.floor(Math.random() * 1000000000);
    let testPath =  'data/'+ dataCode + '_test.txt';
    let metatestPath =  'data/'+ dataCode + '_metatest.txt';

    // Saving the test.txt, metatest.txt files to read from them
    saveTxtFile(testPath, testFile);
    saveTxtFile(metatestPath, metatestFile);

    // path to run_uta.m output file
    let outputPath = './data/response_' + dataCode + '.txt';
    console.log("Output path: %s", outputPath);
    

    // Command that runs the run_uta.m script

    let cmd = matlabpath +
    ' -noFigureWindows' +
    ' -nodesktop -nosplash' +
    ' -logfile ' +  outputPath +
    ' -r ' + scriptPath + '(\'' + testPath + '\',\'' + metatestPath + '\');quit';

    console.log("Matlab script run: \n%s\n", cmd);

    shell.exec(cmd, (code, stdout, stderr) => {
      checkFileUntilThere(outputPath, dataCode, (response) => {
        res.status(200).send(response);
      });
    });

  } catch(err) {
    console.log('ERROR:', err);
    console.log('Runscript error');
  }
};

function checkFileUntilThere(path, dataCode, callback) {
  try {
      fs.access(path, (err) => {
      if(err) {
        console.log("File %s does not exist", dataCode);
        setTimeout( () => {
          checkFileUntilThere(path, dataCode, callback);
        }, 1500);
      } else {
        console.log("File %s exists", dataCode);
        checkFileDone(path, dataCode, callback);
      }
    });
  } catch(err) {
    console.log("ERROR: ", err);
  }
}

const checkFileDone = (path, dataCode, callback) => {
  fs.readFile(path, async (err, data) => {
    if(err) {
      console.log('ERROR', err);
      console.log('File %s wont open', dataCode);
    } else {
      if(data.includes("(g3)")) {
        console.log("Starting file %s reading" , (dataCode));
        console.log("File %s writing done" , (dataCode));
        
        let stdoutJsonFormat = await formatResponse(path);
        if(typeof callback == "function") {
          callback(stdoutJsonFormat);
          setTimeout(() => {
            deleteFiles(dataCode);
          }, 1500);
        }
      } else {
        setTimeout(() => {
          checkFileDone(path, dataCode, callback);
        }, 1500);
      }
    }
  });
}

const saveTxtFile = (fileTxtPath, txt) => {
  fs.writeFile(fileTxtPath, txt, function(err) {
      if(err => {
        console.log("ERROR" + err)
        console.log("Save %s file error", fileTxtPath);
      });
  });
};

const deleteFiles = (code) => {

  let filePath = './data/' + code + "_test.txt";
  let filePath2 = './data/' + code + "_metatest.txt";
  let responsePath = './data/' + "response_" + code + ".txt"; 
  try {
    fs.unlinkSync(filePath);
    console.log("File deleted: Test");
  } catch(err) {
    console.log("ERROR:", err);
    console.log("File not deleted: Test");
  }
  try {
    fs.unlinkSync(filePath2);
    console.log("File deleted: Metatest");
  } catch(err) {
    console.log("ERROR:", err);
    console.log("File not deleted: Metatest");
  }
  // Response file deletion
  // try {
  //   fs.unlinkSync(responsePath);
  //   console.log("File deleted: Response");
  // } catch(err) {
  //   console.log("ERROR:", err);
  //   console.log("File not deleted: Response");
  // }
};

const formatResponse = async (outputPath) => {
  
  try {

    var arr = [];

    async function processLineByLine() {
        const fileStream = fs.createReadStream(outputPath);
      
        const rl = readline.createInterface({
          input: fileStream,
          crlfDelay: Infinity
        });
        
        let obj = {
            "title": "",
            "value": [],
        }
        let comments = [];
        i = 0
        for await (const line of rl) {
          i++;

          if(line.trim() != "") {
            if(line.includes(':')){

              splittedLine = line.split(':');
              if(splittedLine[0].trim() == 'Average') {
                arr.push(obj);
                obj = {
                  title: '',
                  value: [],
                };
              }
              obj.title = splittedLine[0];

            } else if(line.includes('=')){

              splittedLine = line.split('=');
              obj.title = splittedLine[0];
              if(splittedLine[1].trim() != '') {
                obj.value = (splittedLine[1]);
                arr.push(obj);
                obj = {
                  "title": "",
                  "value": []
                };
              }
            } else if(line.includes('Simplex...')) {
              comments.push({ 'line': i, 'comment': line });
            } else if(line.includes('...')) {
              if(obj.title != '' && obj.value.length > 0) {
                arr.push(obj);
                obj = {
                  "title": "",
                  "value": []
                };
              }
              obj.title = line;
            } else {
              let lv = line.split(/\s+/);
              temp = []
              if(lv.length > 1) {
                lv.forEach(v => {
                  if(v.trim() != ""){
                    temp.push(v.trim());
                  }
                });
              } else {
                if(lv[0].trim != '') {
                  temp = lv[0];
                }
              }
              obj.value.push(temp);
            }
          }
          else {
            if(obj.title != '') {
              arr.push(obj);
            }
            obj = {
              "title": "",
              "value": []
            };
          }
        }
        arr.push(obj);
      arr.push({'comments': comments});
    }
    
    await processLineByLine();

    return await arr;

  } catch(err) {
    console.log("ERROR: ", err);
    console.log('Format response err: ', err);
  }
};
const formatRequest = (body) => {
  let test = formatText(body);
  let metatest = formatMetatest(body);

  return { test: test, metatest: metatest };
}

const formatMetatest = (body) => {
  let text = 'Cri/Attributes' + '\t' + 'Monotonicity' + '\t' + 'Type' + '\t' + 'Worst' + '\t' + 'Best' + '\t' + 'a' + '\n';
  try {
    body.criteria.forEach(c => {
    text += c.name + '\t' + c.monotonicity + '\t' + c.type + '\t' + c.worst + '\t' + c.best + '\t' + c.a + '\n';
  });
  } catch(err) {
    console.log("ERROR: ", err);
    console.log("FORMAT METATEST ERROR: ", err);
  }
  return text;
}

const formatText = (body) => {

  let text = body.altName;
  body.criteria.forEach(c => {
    text += '\t'+ c.name;
  });
  if(body.rank.length > 0) {
    text += '\tRanking\n';
  } else {
    text += '\n';
  }
  body.altVals.forEach(
    (alt, i) => {
      let add = [];
      body.criteria.forEach(c => {
        add += c.values[i] + '\t'
      });
      text += alt.name + '\t' + add;
      if(body.rank.length > 0) {
        text += body.rank[i] + '\n';
      } else {
        text += '\n';
      }
  });
  return text;
};


module.exports = {
    runScript
}