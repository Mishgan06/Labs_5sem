#!/usr/bin/env python3
"""Validate transition tables, Moore triangular reduction and all four JFLAP models."""
from collections import deque
from itertools import combinations, product
from pathlib import Path
import xml.etree.ElementTree as ET
ABC='abc'
T=[[(1,'y'),(1,'y'),(4,'y')],[(0,'x'),(3,'y'),(3,'y')],[(1,'y'),(1,'y'),(4,'y')],[(2,'x'),(1,'y'),(1,'y')],[(5,'y'),(3,'y'),(2,'y')],[(7,'x'),(8,'y'),(5,'y')],[(5,'y'),(1,'y'),(7,'y')],[(3,'y'),(3,'y'),(6,'y')],[(6,'x'),(8,'y'),(6,'y')]]
MC=[{0,2,7},{1,3},{4,6},{5},{8}]; mid={s:i for i,g in enumerate(MC) for s in g}
MT=[[ (mid[v],o) for v,o in T[min(g)]] for g in MC]
full=[(i,o) for i in range(9) for o in 'xy']; initial=(0,'y')
reach={initial}; queue=deque([initial])
while queue:
 s=queue.popleft()
 for v in T[s[0]]:
  if v not in reach:reach.add(v);queue.append(v)
S=sorted(reach); idx={s:i for i,s in enumerate(S)}; ST=[[idx[v] for v in T[s[0]]] for s in S]
# Simultaneous rounds of triangular table marking.
pairs=list(combinations(range(len(S)),2)); marked={p:0 for p in pairs if S[p[0]][1]!=S[p[1]][1]}; witnesses={p:'' for p in marked}
rounds=[]; r=1
while True:
 new={}; nw={}
 for p in pairs:
  if p in marked:continue
  for k,a in enumerate(ABC):
   dest=tuple(sorted((ST[p[0]][k],ST[p[1]][k])))
   if dest[0]!=dest[1] and dest in marked:
    new[p]=r;nw[p]=a+witnesses[dest];break
 if not new:break
 rounds.append(new);marked.update(new);witnesses.update(nw);r+=1
classes=[];assigned=set()
for i in range(len(S)):
 if i in assigned:continue
 g={j for j in range(len(S)) if j==i or tuple(sorted((i,j))) not in marked}
 classes.append(g);assigned|=g
# Friendly class order: initial, x counterpart, B/y, C/y, D/y, E/y, C/x.
class_by_state={i:g for g in classes for i in g}
reps=[(0,'y'),(0,'x'),(1,'y'),(4,'y'),(5,'y'),(8,'y'),(6,'x')]
CG=[class_by_state[idx[s]] for s in reps]; cid={s:i for i,g in enumerate(CG) for s in g}
CT=[[cid[v] for v in ST[min(g)]] for g in CG]; CO=[S[min(g)][1] for g in CG]
assert len(S)==13 and len(CG)==7
assert sorted(map(len,CG))==[1,1,1,2,2,3,3]
assert all(CO[cid[i]]==S[i][1] and all(CT[cid[i]][a]==cid[ST[i][a]] for a in range(3)) for i in range(len(S)))
assert len({cid[v] for v in range(len(S))})==7
# Verify every distinct quotient pair is distinguishable; all quotient states reachable.
assert all(tuple(sorted((min(a),min(b)))) in marked for a,b in combinations(CG,2))
for g in MC:
 for s in g: assert [(mid[v],o) for v,o in T[s]]==MT[mid[s]]
# Full product traversal verifies equivalence for every finite word, allowing initial Moore output y.
visited=set(); q=deque([(0,idx[initial],0,0)])
while q:
 z=q.popleft()
 if z in visited:continue
 visited.add(z)
 me,mo,mme,mmo=z
 assert S[mo][1]==CO[mmo]
 for a in range(3):
  v,o=T[me][a]; mv,oo=MT[mme][a]; nv=ST[mo][a]; ncv=CT[mmo][a]
  assert o==oo==S[nv][1]==CO[ncv]
  q.append((v,nv,mv,ncv))
def test(word):
 q=0;out=''
 for a in word:q,o=T[q][ABC.index(a)];out+=o
 return out
TESTS=['abcacbacbcab','aaaaaa','bbbbbb','cccccc','abcabc','acbacbac','aabccbaabc']
# Exhaustive checks, including empty input, for all words of length <= 8.
nt=0
for n in range(9):
 for letters in product(ABC,repeat=n):
  word=''.join(letters);me=0;mo=idx[initial];mme=0;mmo=0;om='';oo='';ou='y';oc='y'
  for a in word:
   k=ABC.index(a);me,o=T[me][k];om+=o;mme,o=MT[mme][k];oo+=o;mo=ST[mo][k];ou+=S[mo][1];mmo=CT[mmo][k];oc+=CO[mmo]
  assert om==oo==ou[1:]==oc[1:]; nt+=1


def verify_model(name,kind,expected,outputs,start):
    root=ET.parse(Path(__file__).parent/name).getroot()
    assert root.findtext('type')==kind
    auto=root.find('automaton')
    states=auto.findall('state')
    assert len(states)==len(expected)
    assert [int(s.attrib['id']) for s in states if s.find('initial') is not None]==[start]
    if kind=='moore':
        assert [s.findtext('output') for s in states]==outputs
    found={}
    for edge in auto.findall('transition'):
        key=int(edge.findtext('from')),ABC.index(edge.findtext('read'))
        assert key not in found
        found[key]=(int(edge.findtext('to')),edge.findtext('transout')) if kind=='mealy' else int(edge.findtext('to'))
    assert len(found)==3*len(expected)
    for i,row in enumerate(expected):
        for a,value in enumerate(row):assert found[i,a]==value,(name,i,a)
verify_model('01_mealy_original.jff','mealy',T,[],0)
verify_model('02_mealy_minimal.jff','mealy',MT,[],0)
verify_model('03_moore_reachable.jff','moore',ST,[s[1] for s in S],idx[initial])
verify_model('04_moore_minimal.jff','moore',CT,CO,0)
assert len(marked)==70 and len(pairs)-len(marked)==8
assert {k:sum(v==k for v in marked.values()) for k in set(marked.values())}=={0:36,1:20,2:3,3:2,4:9}
print('PASS: Moore reachable 13, minimal 7; Mealy minimal 5')
print('PASS: 78 triangular cells; 70 distinguishable, 8 equivalent pairs')
print(f'PASS: {nt} input words; {len(visited)} reachable product states; all four XML models match')
for word in TESTS:print(word,test(word),'y'+test(word))
