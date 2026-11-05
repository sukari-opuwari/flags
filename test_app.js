const fs=require('fs'),vm=require('vm');
const html=fs.readFileSync('index.html','utf8');const script=html.match(/<script>([\s\S]*?)<\/script>/)[1];new vm.Script(script);
const harness=`<script>
const results=[];function check(v,t){if(!v)throw new Error(t);results.push(t)}
try{check(document.querySelectorAll('.flag-card').length===4,'Four learning flags');document.getElementById('start').click();check(!document.getElementById('play').hidden,'Quiz opens');
for(let i=0;i<4;i++){const name=document.getElementById('prompt').textContent.replace('Where is ','').replace('?','');const buttons=[...document.querySelectorAll('.choice')];const wrong=buttons.find(b=>b.querySelector('img').alt!=='Flag of '+name);wrong.click();check(!document.getElementById('next').hidden===false,'Wrong answer keeps question open '+i);const right=buttons.find(b=>b.querySelector('img').alt==='Flag of '+name);right.click();check(!document.getElementById('next').hidden,'Correct answer advances '+i);document.getElementById('next').click()}
check(!document.getElementById('finish').hidden,'Completion appears');document.getElementById('again').click();check(document.getElementById('round').textContent==='Flag 1 of 4','Replay resets');document.getElementById('learn-tab').click();check(!document.getElementById('learn').hidden,'Return to learning');const out=document.createElement('pre');out.id='test-results';out.textContent='PASS '+results.join('; ');document.body.append(out)}catch(e){document.body.textContent='FAIL '+e.message}
</script>`;
fs.writeFileSync('tmp/app-test.html',html.replace('</body>',harness+'</body>'));
console.log('App JavaScript parses; browser test prepared');
