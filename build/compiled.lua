local a={cache={}}do do local function b()local function c(d)local e=d:gsub(
'^[^:]*:',''):gsub('_',' ')local f=e:gsub('%s%l',string.upper):gsub('^%l',string
.upper)return f end return c end function a.a()local c=a.cache.a if not c then c
={c=b()}a.cache.a=c end return c.c end end do local function b()local function c
(d,e)for f,g in next,d do if g==e then return f end end return nil end return c
end function a.b()local c=a.cache.b if not c then c={c=b()}a.cache.b=c end
return c.c end end do local function b()local c=a.b()local d=
'Unable to find peripheral "%s"'local e=
'Unable to find processor "%s", did you add it?'local f=
'Processor "%s" does not support this pattern!'local g='Processor "%s" is busy!'
local function h(i,j)local k={}for l,m in next,i.input_slots do local n,o=m[1],m
[2]k[o]=(k[o]or 0)+(n*j)end return k end local function i(j)local k=0 for l,m in
next,j.results do k=k+m end return k end local j={add_processor=function(j,k,l)
if not peripheral.isPresent(k)then error(d:format(k),2)end j.processors[k]={
patterns=l,in_use=false}end,remove_processor=function(j,k)j.processors[k]=nil
end,get_processors=function(j)local k={}for l in next,j.processors do table.
insert(k,l)end return k end,register_pattern=function(j,k,l)j._patterns[k]=l end
,deregister_pattern=function(j,k)j._patterns[k]=nil end,get_registered_patterns=
function(j)local k={}for l in next,j._patterns do table.insert(k,l)end return k
end,get_pattern_info=function(j,k)return j._patterns[k]end,
add_pattern_to_processor=function(j,k,l)local m=j.processors[k]if m==nil then
error(e:format(k),2)end if c(m.patterns,l)then return end table.insert(m.
patterns,l)end,remove_pattern_from_processor=function(j,k,l)local m=j.processors
[k]if m==nil then error(e:format(k),2)end local n=c(m.patterns,l)if n then table
.remove(m.patterns,n)end end,is_processor_available=function(j,k)local l=j.
processors[k]if l==nil then error(e:format(k))end return not l.in_use end,
get_available_processors=function(j,k)local l={}for m,n in next,j.processors do
if j:is_processor_available(m)and c(n.patterns,k)then table.insert(l,m)end end
return l end,get_missing_ingredients=function(j,k,l)local m=j._system:
get_system_items()local n={}for o,p in next,h(k,l)do local q=m[o]if q==nil or q<
p then table.insert(n,o)end end return n end,start_process_async=function(j,k,l,
m)local n=j.processors[k]if n==nil then error(e:format(k),2)end if n.in_use then
error(g:format(k),2)end if c(n.patterns,l)==nil then error(f:format(k),2)end
local o=j._patterns[l]local p=j._system local q=1/o.poll_rate local r=i(o)local
s=j:get_missing_ingredients(o,m)if#s>0 then error(table.concat(s,', '))end local
t=o.input_slots local u=o.output_slots n.in_use=true for v=1,m do for w,x in
next,t do local y,z=x[1],x[2]p:export_item(z,k,w,y)end p:update_inventories()
local w=r while w>0 do sleep(q)for x,y in next,u do local z=p:import_from_slot(k
,y)w=w-z end end end n.in_use=false end}local k={__index=j}local function l(m,n)
local o=setmetatable({_system=m,_patterns={},processors={}},k)if n~=nil then for
p,q in next,n do o:add_processor(p,q)end end return o end return l end function
a.c()local c=a.cache.c if not c then c={c=b()}a.cache.c=c end return c.c end end
do local function b()local c={'K','M','B','T','Qa','Qi','Sx','Sp','Oc','No','Dc'
}local function d(e)if e<1000 then return tostring(e)end local f=math.floor(math
.log(e+1,10)/3)local g=c[f]if g==nil then g='!?'end return string.format(
'%.1f%s',e/10^(f*3),g)end return d end function a.d()local c=a.cache.d if not c
then c={c=b()}a.cache.d=c end return c.c end end do local function b()
local function c(d,e)local f=math.abs(e)-#d local g=string.rep(' ',f)if e<0 then
return g..d end return d..g end return c end function a.e()local c=a.cache.e if
not c then c={c=b()}a.cache.e=c end return c.c end end do local function b()
local function c(d,e,f)return d,string.rep(e,#d),string.rep(f,#d)end return c
end function a.f()local c=a.cache.f if not c then c={c=b()}a.cache.f=c end
return c.c end end do local function b()local function c(d,e)if#d<=e then return
d end return(d:sub(1,math.max(e-3,1)):gsub('%s*$','')..'...'):sub(1,e)end return
c end function a.g()local c=a.cache.g if not c then c={c=b()}a.cache.g=c end
return c.c end end do local function b()local c=a.d()local d=a.a()local e=a.e()
local f=a.f()local g=a.g()local h='%d. 'local i={reconfigure=function(i,j)i.
config=j end,draw_item_cells=function(i,j)local k=i.redirect local l,m=k.
getSize()local n=i.config local o=n.column_count local p=colors.toBlit(n.
index_text_color or colors.lightBlue)local q=colors.toBlit(n.name_text_color or
colors.white)local r=colors.toBlit(n.count_text_color or colors.pink)local s=
colors.toBlit(n.cell_background_color or colors.black)local t=colors.toBlit(n.
cell_alt_background_color or colors.gray)local u=math.floor(l/o)-1 local v=(l%o)
+1 k.clear()for w,x in next,j do local y=math.floor((w-1)/m)local z=(w-1)%m+1
local A=y*(u+1)+1 if y>=o then break end local B=(z+y)%2==0 and t or s local C=
e(h:format(w),-n.index_justification)local D=' '..c(x.count)local E=u-#C-#D if y
+1>=o then E=E+v end local F=e(g(d(x.name),E),E)k.setCursorPos(A,z)k.blit(f(C,p,
B))k.blit(f(F,q,B))k.blit(f(D,r,B))end end}local j={__index=i}local function k(l
,m)local n=setmetatable({redirect=l,config=m},j)return n end return k end
function a.h()local c=a.cache.h if not c then c={c=b()}a.cache.h=c end return c.
c end end do local function b()local c='Unable to find peripheral "%s"'local d=
'Peripheral "%s" is not a valid inventory!'local e=
'Unable to find inventory "%s", is it being tracked?'local function f(g)local h=
peripheral.wrap(g)if h==nil then error(c:format(g),2)end if h.list==nil then
error(d:format(g),2)end return h end local function g(h,i)return h.count>i.count
end local h={track_inventory=function(h,i)h.inventories[i]=f(i)end,
untrack_inventory=function(h,i)h.inventories[i]=nil end,update_inventories=
function(h)for i,j in next,h.inventories do h._item_cache[i]=j.list()end end,
get_inventories=function(h)local i={}for j in next,h.inventories do table.
insert(i,j)end return i end,get_system_size=function(h)local i=0 for j,k in next
,h.inventories do i=i+k.size()end return i end,get_system_items=function(h)local
i={}for j,k in next,h._item_cache do for l,m in next,k do local n=m.name local o
=m.count i[n]=(i[n]or 0)+o end end return i end,get_system_items_sorted=function
(h,i)local j={}for k,l in next,h:get_system_items()do table.insert(j,{name=k,
count=l})end table.sort(j,i or g)return j end,find_item=function(h,i)local j
local k return function()for l,m in next,h._item_cache,j do for n,o in next,m,k
do k=n if o.name==i then return l,n,o end end j=l k=nil end return nil,nil,nil
end end,pull_items=function(h,i,j,k,l,m)local n=h.inventories[k]if n==nil then
error(e:format(k),2)end return n.pullItems(i,j,m,l)end,push_items=function(h,i,j
,k,l,m)local n=h.inventories[i]if n==nil then error(e:format(i),2)end return n.
pushItems(k,j,m,l)end,import_from_slot=function(h,i,j,k)local l=next(h.
inventories)if l==nil then return 0 end local m=0 while true do local n=k and k-
m or nil local o=h:pull_items(i,j,l,nil,n)m=m+o if k~=nil and m>=k then break
end if o==0 then l=next(h.inventories,l)if l==nil then break end elseif k==nil
then break end end return m end,import_inventory=function(h,i)local j=0 local k=
f(i)for l in next,k.list()do local m=h:import_from_slot(i,l)j=j+m end return j
end,import_item=function(h,i,j,k)local l=0 local m=f(j)for n,o in next,m.list()
do if o.name==i then local p=k and k-l or o.count local q=h:import_from_slot(j,n
,math.min(p,o.count))l=l+q if k==nil or l>=k or q==0 then break end end end
return l end,export_item=function(h,i,j,k,l)local m=0 for n,o in h:find_item(i)
do local p=l~=nil and l-m or nil local q=h:push_items(n,o,j,k,p)m=m+q if l==nil
or m>=l then break end end return m end}local i={__index=h}local function j(k)
local l=setmetatable({inventories={},_item_cache={}},i)if k~=nil then for m,n in
next,k do l:track_inventory(n)end end return l end return j end function a.i()
local c=a.cache.i if not c then c={c=b()}a.cache.i=c end return c.c end end do
local function b()local c={AutoProcessing=a.c(),StorageDisplay=a.h(),
StorageSystem=a.i()}return c end function a.j()local c=a.cache.j if not c then c
={c=b()}a.cache.j=c end return c.c end end do local function b()local c=
'.storagesystem'local d='storage.io_inventory'local e=
'storage.system_inventories'local f='storage.processors'settings.define(d,{type=
'string',description='The inventory the system uses for IO operations.'})
settings.define(e,{type='table',description=
'The inventories the system has registered.'})settings.define(f,{type='table',
description='The processors the system has registered.'})return{settings={
IO_INVENTORY=d,SYSTEM_INVENTORIES=e,PROCESSORS=f},get=function(g)return settings
.get(g)end,set=function(g,h)settings.set(g,h)end,load=function()settings.load(c)
end,save=function()settings.save(c)end}end function a.k()local c=a.cache.k if
not c then c={c=b()}a.cache.k=c end return c.c end end do local function b()
local function c(d,e)local f={}for g,h in next,d do if e(g,h)then if type(g)==
'number'then table.insert(f,h)else f[g]=h end end end return f end return c end
function a.l()local c=a.cache.l if not c then c={c=b()}a.cache.l=c end return c.
c end end do local function b()local function c(d)local e={}for f,g in next,d do
e[f]=g end return e end return c end function a.m()local c=a.cache.m if not c
then c={c=b()}a.cache.m=c end return c.c end end do local function b()local c=a.
m()local function d(e,f,g,h)if#e==0 then return 0 end local i=h or 1 local j,k=
term.getSize()local l=k-4 local m=math.ceil(#e/l)while true do term.clear()term.
setCursorPos(1,1)term.write(f)local n=math.ceil(i/l)local o=(n-1)*l+1 local p=
math.min(o+l-1,#e)for q=o,p do local r=e[q]local s=g(tostring(r),q,i)if q==i
then term.setTextColor(colors.lightBlue)end term.setCursorPos(1,(q-o)+3)term.
write(s)term.setTextColor(colors.white)end term.setCursorPos(1,k)term.write(
string.format('Page %d/%d',n,m))local q,r=os.pullEvent('key')if r==keys.up then
i=math.max(i-1,1)elseif r==keys.left then i=math.max(i-l,1)elseif r==keys.down
then i=math.min(i+1,#e)elseif r==keys.right then i=math.min(i+l,#e)elseif r==
keys.enter then break end end return i end return{checkbox_list=function(e,f,g)
local h={}local i local j=c(e)table.insert(j,'')local k=#j while true do local l
=d(j,f,function(l,m,n)local o=m==n if m==k then term.setTextColor(colors.red)
return string.format('%s Done',o and'>'or' ')end local p=h[m]~=nil local q=g and
g(l)or l if p then term.setTextColor(colors.green)end return string.format(
'%s [%s] %s',o and'>'or' ',p and'x'or' ',q)end,i)if l==k then break end i=l h[l]
=not h[l]and true or nil end local l={}for m in next,h do table.insert(l,e[m])
end return l end,choice_list=function(e,f,g)local h=d(e,f,function(h,i,j)local k
=g and g(h)or h local l=i==j return string.format('%s %s',l and'>'or' ',k)end)
return e[h],h end,text_page=function(e,f,g)local h,i=term.getSize()term.
setCursorPos(1,1)term.write(e)if f~=nil then term.setTextColor(colors.lightGray)
term.setCursorPos(1,i)term.write(f)term.setTextColor(colors.white)end term.
setCursorPos(1,3)term.write('$ ')return read(nil,nil,g)end}end function a.n()
local c=a.cache.n if not c then c={c=b()}a.cache.n=c end return c.c end end do
local function b()local function c()os.pullEvent('key')os.pullEvent('key_up')end
return c end function a.o()local c=a.cache.o if not c then c={c=b()}a.cache.o=c
end return c.c end end end local b=require('cc/completion')local c=a.a()local d=
a.j()local e=a.k()local f=a.l()local g=a.n()local h=a.o()local i=
'Exporting %d items...'local j='Importing items...'local k=
'Transferred %d items.'local l=peripheral.find('modem')local function m()local n
={}for o,p in ipairs(l.getNamesRemote())do if peripheral.hasType(p,'inventory')
then table.insert(n,p)end end table.sort(n)return n end e.load()local n=e.get(e.
settings.IO_INVENTORY)local o=settings.get(e.settings.SYSTEM_INVENTORIES)if n==
nil or not l.isPresentRemote(n)then n=g.choice_list(m(),'Choose IO Inventory',c)
e.set(e.settings.IO_INVENTORY,n)end if o==nil then o=g.checkbox_list(f(m(),
function(p,q)return q~=n end),'Select System Inventories',c)e.set(e.settings.
SYSTEM_INVENTORIES,o)end e.save()local p=d.StorageSystem(o)local q=d.
AutoProcessing(p,e.get(e.settings.PROCESSORS))local r,s=term.getSize()local t=
peripheral.find('monitor')t.setTextScale(0.5)local u=window.create(term.current(
),r*2/3,2,math.ceil(r/3),s-2,false)local v=window.create(term.current(),1,1,r,s-
1,false)local w=d.StorageDisplay(t,{column_count=1,index_justification=4})local
x=d.StorageDisplay(u,{column_count=1,index_justification=3})local y=d.
StorageDisplay(v,{column_count=2,index_justification=3})local function z()local
A=fs.getDir(shell.getRunningProgram())local B=fs.combine(A,'patterns')for C,D in
ipairs(fs.list(B))do local E=D:gsub('%..*','')q:register_pattern(E,require(
'patterns/'..E))end end local function A(B,C)local D local E=math.huge for F,G
in ipairs(B)do local H=string.find(G,C)if H and H<E then E=H D=G end end return
D end local function B(C)local D={}for E in next,p:get_system_items()do local F=
string.find(E,C)if F~=nil then table.insert(D,E:sub(F,-1))end end return b.
choice(C,D,false)end local function C()return f(m(),function(D,E)return not(E==n
or p.inventories[E]~=nil or q.processors[E]~=nil)end)end local function D(E,F,G)
table.insert(E,'Exit')while true do local H,I=g.choice_list(E,F)if I==#E then
break end G(I,H)end end local function E(F)local G=q:get_pattern_info(F)if G==
nil then return'UNKNOWN PATTERN'end return G.label end local function F()return
g.checkbox_list(q:get_registered_patterns(),'Choose Patterns',E)end
local function G()local H={}for I,J in next,q.processors do H[I]=J.patterns end
e.set(e.settings.PROCESSORS,H)e.save()end local function H()u.setVisible(true)
local function I()term.clear()u.redraw()local J=g.text_page(
'Storage System Output',"'exit' to return to menu",B)if J=='exit'then return
true end local K=p:get_system_items()local L={}for M in next,K do table.insert(L
,M)end local M=A(L,J)if M==nil then printError(string.format(
"Unable to find '%s'",J))h()return false end term.clear()u.redraw()local N=g.
text_page(string.format('Item Count - %s | %d in system',c(M),K[M]),
"'cancel' to restart")if N=='cancel'then return false end local O=tonumber(N)or
64 print(i:format(O))local P=p:export_item(M,n,nil,O)print(k:format(P))h()end
while true do if I()then break end end u.setVisible(false)end local function I()
local J,K=g.choice_list({'yesss!!!!!!','wait nvm'},
'Storage System Input - Are you sure?')if K==2 then return end term.clear()term.
setCursorPos(1,1)print(j)local L=p:import_inventory(n)print(k:format(L))h()end
local function J()term.clear()term.setCursorPos(1,s)term.write(
'Press any key to return')v.setVisible(true)h()v.setVisible(false)end
local function K(L)local M=F()for N,O in ipairs(L)do for P,Q in ipairs(M)do q:
add_pattern_to_processor(O,Q)end end end local function L(M)local N=F()for O,P
in ipairs(M)do for Q,R in ipairs(N)do q:remove_pattern_from_processor(P,R)end
end end local function M(N)local O={'Add patterns','Remove patterns'}D(O,string.
format('Processor Patterns | %d Selected',#N),function(P)if P==1 then K(N)else
L(N)end end)end local function N()local O=q:get_processors()if#O<=0 then term.
clear()term.setCursorPos(1,1)term.write('No processors have been registered!')h(
)return end local P=g.checkbox_list(O,'Select processors to configure',c)if#P==0
then return end M(P)G()end local function O()local P=g.checkbox_list(C(),
'Register Processors',c)for Q,R in ipairs(P)do q:add_processor(R,{})end G()end
local function P()local Q=g.checkbox_list(q:get_processors(),
'Deregister Processors',c)for R,S in ipairs(Q)do q:remove_processor(S)end G()end
local function Q()D({'Configure patterns','Register','Deregister'},
'Processor Inventories',function(R)if R==1 then N()elseif R==2 then O()elseif R
==3 then P()end end)end local function R()local S=g.choice_list(q:
get_registered_patterns(),'Choose Pattern',E)local T=q:get_available_processors(
S)if#T==0 then term.clear()term.setCursorPos(1,1)term.write(
'No available processors have this pattern!')h()return end term.clear()local U=
tonumber(g.text_page(string.format('Process Iterations | %s',E(S))))or 1 if U==0
then return end local V=g.checkbox_list(T,string.format(
'Select Processor Distribution | %dx %s',U,E(S)),c)if#V==0 then return end local
W=math.floor(U/#V)local X=U%#V local Y={}for Z,_ in ipairs(V)do local aa=0 if X>
0 then X=X-1 aa=1 end table.insert(Y,{processor=_,pattern=S,count=W+aa})end os.
queueEvent('start_processing',Y)end local function aa()D({'Craft',
'Processor inventories'},'Auto Processing Menu',function(S)if S==1 then R()
elseif S==2 then Q()end end)end local function S()D({'Storage output',
'Storage input','Processing','View chart'},'Storage IO Menu',function(T)if T==1
then H()elseif T==2 then I()elseif T==3 then aa()elseif T==4 then J()end end)
term.clear()term.setCursorPos(1,1)end local function T()while true do local U,V=
os.pullEvent('start_processing')local W={}for X,Y in ipairs(V)do local Z=
function()q:start_process_async(Y.processor,Y.pattern,Y.count)end table.insert(W
,Z)end parallel.waitForAll(table.unpack(W))end end local function U()while true
do p:update_inventories()local V,W=term.getCursorPos()local X=p:
get_system_items_sorted()x:draw_item_cells(X)y:draw_item_cells(X)w:
draw_item_cells(X)term.setCursorPos(V,W)sleep(5)end end z()parallel.waitForAny(S
,T,U)