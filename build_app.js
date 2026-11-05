const fs=require('fs');
let html=fs.readFileSync('app-template.html','utf8');
for(const n of ['Nigeria','Ghana','Botswana','Somalia'])html=html.replaceAll(`__${n}__`,'data:image/png;base64,'+fs.readFileSync(`tmp/pptx-build/${n}.png`).toString('base64'));
fs.writeFileSync('index.html',html);
