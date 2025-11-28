local a={cache={}}do do local function b()local function c(d)local e=d:gsub(
'^[^:]*:',''):gsub('_',' ')local f=e:gsub('%s%l',string.upper):gsub('^%l',string
.upper)return f end return c end function a.a()local c=a.cache.a if not c then c
={c=b()}a.cache.a=c end return c.c end end do local function b()local function c
(d,e)for f,g in next,d do if g==e then return f end end return nil end return c
end function a.b()local c=a.cache.b if not c then c={c=b()}a.cache.b=c end
return c.c end end do local function b()local c=a.b()local d=
'Unable to find peripheral "%s"'local e=
'Unable to find processor "%s", did you add it?'local f=
'Unable to find pattern "%s", did you register it?'local g=
'Processor "%s" does not support this pattern!'local h='Processor "%s" is busy!'
local function i(j,k)local l={}for m,n in next,j.patterns do if n.results[k]~=
nil then table.insert(l,n)end end return l end local function j(k,l)local m={}
for n,o in next,k.input_slots do local p,q=o[1],o[2]m[q]=(m[q]or 0)+(p*l)end
return m end local function k(l)local m=0 for n,o in next,l.results do m=m+o end
return m end local l={add_processor=function(l,m,n)if not peripheral.isPresent(m
)then error(d:format(m),2)end l.processors[m]={patterns=n,in_use=false}end,
remove_processor=function(l,m)l.processors[m]=nil end,get_processors=function(l)
local m={}for n in next,l.processors do table.insert(m,n)end return m end,
register_pattern=function(l,m,n)l._patterns[m]=n end,deregister_pattern=function
(l,m)l._patterns[m]=nil end,get_registered_patterns=function(l)local m={}for n
in next,l._patterns do table.insert(m,n)end return m end,get_pattern_info=
function(l,m)return l._patterns[m]end,add_pattern_to_processor=function(l,m,n)
local o=l.processors[m]if o==nil then error(e:format(m),2)end if c(o.patterns,n)
then return end table.insert(o.patterns,n)end,remove_pattern_from_processor=
function(l,m,n)local o=l.processors[m]if o==nil then error(e:format(m),2)end
local p=c(o.patterns,n)if p then table.remove(o.patterns,p)end end,
is_processor_available=function(l,m)local n=l.processors[m]if n==nil then error(
e:format(m))end return not n.in_use end,get_available_processors=function(l,m)
local n={}for o,p in next,l.processors do if l:is_processor_available(o)and c(p.
patterns,m)then table.insert(n,o)end end return n end,get_missing_ingredients=
function(l,m,n)local o=l._system:get_system_items()local p={}for q,r in next,j(m
,n)do local s=o[q]if s==nil or s<r then table.insert(p,q)end end return p end,
start_process_async=function(l,m,n,o)local p=l.processors[m]if p==nil then
error(e:format(m),2)end if p.in_use then error(h:format(m),2)end if c(p.patterns
,n)==nil then error(g:format(m),2)end local q=l._patterns[n]local r=l._system
local s=1/q.poll_rate local t=k(q)local u=l:get_missing_ingredients(q,o)if#u>0
then error(table.concat(u,', '))end local v=q.input_slots local w=q.output_slots
p.in_use=true for x=1,o do for y,z in next,v do local A,B=z[1],z[2]r:
export_item(B,m,y,A)end r:update_inventories()local y=t while y>0 do sleep(s)for
z,A in next,w do local B=r:import_from_slot(m,A)y=y-B end end end p.in_use=false
end}local m={__index=l}local function n(o,p)local q=setmetatable({_system=o,
_patterns={},processors={}},m)for r,s in next,p do q:add_processor(r,s)end
return q end return n end function a.c()local c=a.cache.c if not c then c={c=b()
}a.cache.c=c end return c.c end end do local function b()local c={'K','M','B',
'T','Qa','Qi','Sx','Sp','Oc','No','Dc'}local function d(e)if e<1000 then return
tostring(e)end local f=math.floor(math.log(e+1,10)/3)local g=c[f]if g==nil then
g='!?'end return string.format('%.1f%s',e/10^(f*3),g)end return d end function a
.d()local c=a.cache.d if not c then c={c=b()}a.cache.d=c end return c.c end end
do local function b()local function c(d,e)local f=math.abs(e)-#d local g=string.
rep(' ',f)if e<0 then return g..d end return d..g end return c end function a.e(
)local c=a.cache.e if not c then c={c=b()}a.cache.e=c end return c.c end end do
local function b()local function c(d,e,f)return d,string.rep(e,#d),string.rep(f,
#d)end return c end function a.f()local c=a.cache.f if not c then c={c=b()}a.
cache.f=c end return c.c end end do local function b()local function c(d,e)if#d
<=e then return d end return(d:sub(1,math.max(e-3,1)):gsub('%s*$','')..'...'):
sub(1,e)end return c end function a.g()local c=a.cache.g if not c then c={c=b()}
a.cache.g=c end return c.c end end do local function b()local c=a.d()local d=a.
a()local e=a.e()local f=a.f()local g=a.g()local h='%d. 'local i={reconfigure=
function(i,j)i.config=j end,draw_item_cells=function(i,j)local k=i.redirect
local l,m=k.getSize()local n=i.config local o=n.column_count local p=colors.
toBlit(n.index_text_color or colors.lightBlue)local q=colors.toBlit(n.
name_text_color or colors.white)local r=colors.toBlit(n.count_text_color or
colors.pink)local s=colors.toBlit(n.cell_background_color or colors.black)local
t=colors.toBlit(n.cell_alt_background_color or colors.gray)local u=math.floor(l/
o)-1 local v=(l%o)+1 k.clear()for w,x in next,j do local y=math.floor((w-1)/m)
local z=(w-1)%m+1 local A=y*(u+1)+1 if y>=o then break end local B=(z+y)%2==0
and t or s local C=e(h:format(w),-n.index_justification)local D=' '..c(x.count)
local E=u-#C-#D if y+1>=o then E=E+v end local F=e(g(d(x.name),E),E)k.
setCursorPos(A,z)k.blit(f(C,p,B))k.blit(f(F,q,B))k.blit(f(D,r,B))end end}local j
={__index=i}local function k(l,m)local n=setmetatable({redirect=l,config=m},j)
return n end return k end function a.h()local c=a.cache.h if not c then c={c=b()
}a.cache.h=c end return c.c end end do local function b()local c=
'Unable to find peripheral "%s"'local d=
'Peripheral "%s" is not a valid inventory!'local e=
'Unable to find inventory "%s", is it being tracked?'local f=
[[Unable to find items for inventory "%s", did you update the cache?]]
local function g(h)local i=peripheral.wrap(h)if i==nil then error(c:format(h),2)
end if i.list==nil then error(d:format(h),2)end return i end local function h(i,
j)return i.count>j.count end local i={track_inventory=function(i,j)i.inventories
[j]=g(j)end,untrack_inventory=function(i,j)i.inventories[j]=nil end,
update_inventories=function(i)for j,k in next,i.inventories do i._item_cache[j]=
k.list()end end,get_inventories=function(i)local j={}for k in next,i.inventories
do table.insert(j,k)end return j end,get_system_size=function(i)local j=0 for k,
l in next,i.inventories do j=j+l.size()end return j end,get_system_items=
function(i)local j={}for k,l in next,i._item_cache do for m,n in next,l do local
o=n.name local p=n.count j[o]=(j[o]or 0)+p end end return j end,
get_system_items_sorted=function(i,j)local k={}for l,m in next,i:
get_system_items()do table.insert(k,{name=l,count=m})end table.sort(k,j or h)
return k end,find_item=function(i,j)local k=nil local l=nil return function()for
m,n in next,i._item_cache,k do for o,p in next,n,l do l=o if p.name==j then
return m,o,p end end k=m l=nil end return nil,nil,nil end end,pull_items=
function(i,j,k,l,m,n)local o=i.inventories[l]if o==nil then error(e:format(l),2)
end return o.pullItems(j,k,n,m)end,push_items=function(i,j,k,l,m,n)local o=i.
inventories[j]if o==nil then error(e:format(j),2)end return o.pushItems(l,k,n,m)
end,import_from_slot=function(i,j,k,l)local m=next(i.inventories)if m==nil then
return 0 end local n=0 while true do local o=l and l-n or nil local p=i:
pull_items(j,k,m,nil,o)n=n+p if l==nil or n>=l then break end if p==0 then m=
next(i.inventories,m)if m==nil then break end end end return n end,
import_inventory=function(i,j)local k=0 local l=g(j)for m in next,l.list()do
local n=i:import_from_slot(j,m)k=k+n end return k end,import_item=function(i,j,k
,l)local m=0 local n=g(k)for o,p in next,n.list()do if p.name==j then local q=l
and l-m or p.count local r=i:import_from_slot(k,o,math.min(q,p.count))m=m+r if l
==nil or m>=l or r==0 then break end end end return m end,export_item=function(i
,j,k,l,m)local n=0 for o,p in i:find_item(j)do local q=m~=nil and m-n or nil
local r=i:push_items(o,p,k,l,q)n=n+r if m==nil or n>=m then break end end return
n end}local j={__index=i}local function k(l)local m=setmetatable({inventories={}
,_item_cache={}},j)if l~=nil then for n,o in next,l do m:track_inventory(o)end
end return m end return k end function a.i()local c=a.cache.i if not c then c={c
=b()}a.cache.i=c end return c.c end end do local function b()local c={
AutoProcessing=a.c(),StorageDisplay=a.h(),StorageSystem=a.i()}return c end
function a.j()local c=a.cache.j if not c then c={c=b()}a.cache.j=c end return c.
c end end do local function b()local function c(d,e)local f={}for g,h in next,d
do if e(g,h)then if type(g)=='number'then table.insert(f,h)else f[g]=h end end
end return f end return c end function a.k()local c=a.cache.k if not c then c={c
=b()}a.cache.k=c end return c.c end end do local function b()local function c(d)
local e={}for f,g in next,d do e[f]=g end return e end return c end function a.l
()local c=a.cache.l if not c then c={c=b()}a.cache.l=c end return c.c end end do
local function b()local c=a.l()local function d(e,f,g,h)if#e==0 then return 0
end local i=h or 1 local j,k=term.getSize()local l=k-4 local m=math.ceil(#e/l)
while true do term.clear()term.setCursorPos(1,1)term.write(f)local n=math.ceil(i
/l)local o=(n-1)*l+1 local p=math.min(o+l-1,#e)for q=o,p do local r=e[q]local s=
g(tostring(r),q,i)if q==i then term.setTextColor(colors.lightBlue)end term.
setCursorPos(1,(q-o)+3)term.write(s)term.setTextColor(colors.white)end term.
setCursorPos(1,k)term.write(string.format('Page %d/%d',n,m))local q,r=os.
pullEvent('key')if r==keys.up then i=math.max(i-1,1)elseif r==keys.left then i=
math.max(i-l,1)elseif r==keys.down then i=math.min(i+1,#e)elseif r==keys.right
then i=math.min(i+l,#e)elseif r==keys.enter then break end end return i end
return{checkbox_list=function(e,f,g)local h={}local i=nil local j=c(e)table.
insert(j,'')local k=#j while true do local l=d(j,f,function(l,m,n)local o=m==n
if m==k then term.setTextColor(colors.red)return string.format('%s Done',o and
'>'or' ')end local p=h[m]~=nil local q=g and g(l)or l if p then term.
setTextColor(colors.green)end return string.format('%s [%s] %s',o and'>'or' ',p
and'x'or' ',q)end,i)if l==k then break end i=l h[l]=not h[l]and true or nil end
local l={}for m in next,h do table.insert(l,e[m])end return l end,choice_list=
function(e,f,g)local h=d(e,f,function(h,i,j)local k=g and g(h)or h local l=i==j
return string.format('%s %s',l and'>'or' ',k)end)return e[h],h end,text_page=
function(e,f,g)local h,i=term.getSize()term.setCursorPos(1,1)term.write(e)if f~=
nil then term.setTextColor(colors.lightGray)term.setCursorPos(1,i)term.write(f)
term.setTextColor(colors.white)end term.setCursorPos(1,3)term.write('$ ')return
read(nil,nil,g)end}end function a.m()local c=a.cache.m if not c then c={c=b()}a.
cache.m=c end return c.c end end do local function b()local function c()os.
pullEvent('key')os.pullEvent('key_up')end return c end function a.n()local c=a.
cache.n if not c then c={c=b()}a.cache.n=c end return c.c end end end local b=
require('cc/completion')local c=a.a()local d=a.j()local e=a.k()local f=a.m()
local g=a.n()local h='Exporting %d items...'local i='Importing items...'local j=
'Transferred %d items.'local k=peripheral.find('modem')local function l()local m
={}for n,o in ipairs(k.getNamesRemote())do if peripheral.hasType(o,'inventory')
then table.insert(m,o)end end table.sort(m)return m end local m=nil if m==nil or
not k.isPresentRemote(m)then m=f.choice_list(l(),'Choose IO Inventory',c)end
local n=f.checkbox_list(e(l(),function(n,o)return o~=m end),
'Select System Inventories',c)local o=d.StorageSystem(n)local p=d.
AutoProcessing(o,{})local q,r=term.getSize()local s=peripheral.find('monitor')s.
setTextScale(0.5)local t=window.create(term.current(),q*2/3,2,math.ceil(q/3),r-2
,false)local u=window.create(term.current(),1,1,q,r-1,false)local v=d.
StorageDisplay(s,{column_count=2,index_justification=4})local w=d.
StorageDisplay(t,{column_count=1,index_justification=3})local x=d.
StorageDisplay(u,{column_count=2,index_justification=3})local function y()local
z=fs.getDir(shell.getRunningProgram())local A=fs.combine(z,'patterns')for B,C in
ipairs(fs.list(A))do local D=C:gsub('%..*','')p:register_pattern(D,require(
'patterns/'..D))end end local function z(A,B)local C=nil local D=math.huge for E
,F in ipairs(A)do local G=string.find(F,B)if G and G<D then D=G C=F end end
return C end local function A(B)local C={}for D in next,o:get_system_items()do
local E,F=string.find(D,B)if E~=nil then table.insert(C,D:sub(E,-1))end end
return b.choice(B,C,false)end local function B()return e(l(),function(C,D)return
not(D==m or o.inventories[D]~=nil or p.processors[D]~=nil)end)end local function
C(D,E,F)table.insert(D,'Exit')while true do local G,H=f.choice_list(D,E)if H==#D
then break end F(H,G)end end local function D(E)local F=p:get_pattern_info(E)if
F==nil then return'UNKNOWN PATTERN'end return F.label end local function E()
return f.checkbox_list(p:get_registered_patterns(),'Choose Patterns',D)end
local function F()t.setVisible(true)local function G()term.clear()t.redraw()
local H=f.text_page('Storage System Output',"'exit' to return to menu",A)if H==
'exit'then return true end local I=o:get_system_items()local J={}for K in next,I
do table.insert(J,K)end local K=z(J,H)if K==nil then printError(string.format(
"Unable to find '%s'",H))g()return false end term.clear()t.redraw()local L=f.
text_page(string.format('Item Count - %s | %d in system',c(K),I[K]),
"'cancel' to restart")if L=='cancel'then return false end local M=tonumber(L)or
64 print(h:format(M))local N=o:export_item(K,m,nil,M)print(j:format(N))g()end
while true do if G()then break end end t.setVisible(false)end local function G()
local H,I=f.choice_list({'yesss!!!!!!','wait nvm'},
'Storage System Input - Are you sure?')if I==2 then return end term.clear()term.
setCursorPos(1,1)print(i)local J=o:import_inventory(m)print(j:format(J))g()end
local function H()term.clear()term.setCursorPos(1,r)term.write(
'Press any key to return')u.setVisible(true)g()u.setVisible(false)end
local function I(J)local K=E()for L,M in ipairs(J)do for N,O in ipairs(K)do p:
add_pattern_to_processor(M,O)end end end local function J(K)local L=E()for M,N
in ipairs(K)do for O,P in ipairs(L)do p:remove_pattern_from_processor(N,P)end
end end local function K(L)local M={'Add patterns','Remove patterns'}C(M,string.
format('Processor Patterns | %d Selected',#L),function(N)if N==1 then I(L)else
J(L)end end)end local function L()local M=p:get_processors()if#M<=0 then term.
clear()term.setCursorPos(1,1)term.write('No processors have been registered!')g(
)return end local N=f.checkbox_list(M,'Select processors to configure',c)if#N==0
then return end K(N)end local function M()local N=f.checkbox_list(B(),
'Register Processors',c)for O,P in ipairs(N)do p:add_processor(P,{})end end
local function N()local O=f.checkbox_list(p:get_processors(),
'Deregister Processors',c)for P,Q in ipairs(O)do p:remove_processor(Q)end end
local function O()C({'Configure patterns','Register','Deregister'},
'Processor Inventories',function(P)if P==1 then L()elseif P==2 then M()elseif P
==3 then N()end end)end local function P()local Q=f.choice_list(p:
get_registered_patterns(),'Choose Pattern',D)local R=p:get_available_processors(
Q)if#R==0 then term.clear()term.setCursorPos(1,1)term.write(
'No available processors have this pattern!')g()return end term.clear()local S=
tonumber(f.text_page(string.format('Process Iterations | %s',D(Q))))or 1 if S==0
then return end local T=f.checkbox_list(R,string.format(
'Select Processor Distribution | %dx %s',S,D(Q)),c)if#T==0 then return end local
U=math.floor(S/#T)local V=S%#T local W={}for X,Y in ipairs(T)do local Z=0 if V>0
then V=V-1 Z=1 end table.insert(W,{processor=Y,pattern=Q,count=U+Z})end os.
queueEvent('start_processing',W)end local function Q()C({'Craft',
'Processor inventories'},'Auto Processing Menu',function(R)if R==1 then P()
elseif R==2 then O()end end)end local function R()C({'Storage output',
'Storage input','Processing','View chart'},'Storage IO Menu',function(S)if S==1
then F()elseif S==2 then G()elseif S==3 then Q()elseif S==4 then H()end end)term
.clear()term.setCursorPos(1,1)end local function S()while true do local T,U=os.
pullEvent('start_processing')local V={}for W,X in ipairs(U)do local Y=function()
p:start_process_async(X.processor,X.pattern,X.count)end table.insert(V,Y)end
parallel.waitForAll(table.unpack(V))end end local function T()while true do o:
update_inventories()local U,V=term.getCursorPos()local W=o:
get_system_items_sorted()w:draw_item_cells(W)x:draw_item_cells(W)v:
draw_item_cells(W)term.setCursorPos(U,V)sleep(5)end end y()parallel.waitForAny(R
,S,T)