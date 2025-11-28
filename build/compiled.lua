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
local g=a.n()local h='storage.io_inv'local i='storage.system_invs'local j=
'storage.processors'local k='Exporting %d items...'local l='Importing items...'
local m='Transferred %d items.'local n=peripheral.find('modem')local function o(
)local p={}for q,r in ipairs(n.getNamesRemote())do if peripheral.hasType(r,
'inventory')then table.insert(p,r)end end table.sort(p)return p end settings.
load()local p=settings.get(h)local q=settings.get(i)if p==nil or not n.
isPresentRemote(p)then p=f.choice_list(o(),'Choose IO Inventory',c)settings.set(
h,p)settings.save()end if q==nil then q=f.checkbox_list(e(o(),function(r,s)
return s~=p end),'Select System Inventories',c)settings.set(i,q)settings.save()
end local r=d.StorageSystem(q)local s=d.AutoProcessing(r,settings.get(j,{}))
local t,u=term.getSize()local v=peripheral.find('monitor')v.setTextScale(0.5)
local w=window.create(term.current(),t*2/3,2,math.ceil(t/3),u-2,false)local x=
window.create(term.current(),1,1,t,u-1,false)local y=d.StorageDisplay(v,{
column_count=2,index_justification=4})local z=d.StorageDisplay(w,{column_count=1
,index_justification=3})local A=d.StorageDisplay(x,{column_count=2,
index_justification=3})local function B()local C=fs.getDir(shell.
getRunningProgram())local D=fs.combine(C,'patterns')for E,F in ipairs(fs.list(D)
)do local G=F:gsub('%..*','')s:register_pattern(G,require('patterns/'..G))end
end local function C(D,E)local F=nil local G=math.huge for H,I in ipairs(D)do
local J=string.find(I,E)if J and J<G then G=J F=I end end return F end
local function D(E)local F={}for G in next,r:get_system_items()do local H,I=
string.find(G,E)if H~=nil then table.insert(F,G:sub(H,-1))end end return b.
choice(E,F,false)end local function E()return e(o(),function(F,G)return not(G==p
or r.inventories[G]~=nil or s.processors[G]~=nil)end)end local function F(G,H,I)
table.insert(G,'Exit')while true do local J,K=f.choice_list(G,H)if K==#G then
break end I(K,J)end end local function G(H)local I=s:get_pattern_info(H)if I==
nil then return'UNKNOWN PATTERN'end return I.label end local function H()return
f.checkbox_list(s:get_registered_patterns(),'Choose Patterns',G)end
local function I()local J={}for K,L in next,s.processors do J[K]=L.patterns end
settings.set(j,J)settings.save()end local function J()w.setVisible(true)
local function K()term.clear()w.redraw()local L=f.text_page(
'Storage System Output',"'exit' to return to menu",D)if L=='exit'then return
true end local M=r:get_system_items()local N={}for O in next,M do table.insert(N
,O)end local O=C(N,L)if O==nil then printError(string.format(
"Unable to find '%s'",L))g()return false end term.clear()w.redraw()local P=f.
text_page(string.format('Item Count - %s | %d in system',c(O),M[O]),
"'cancel' to restart")if P=='cancel'then return false end local Q=tonumber(P)or
64 print(k:format(Q))local R=r:export_item(O,p,nil,Q)print(m:format(R))g()end
while true do if K()then break end end w.setVisible(false)end local function K()
local L,M=f.choice_list({'yesss!!!!!!','wait nvm'},
'Storage System Input - Are you sure?')if M==2 then return end term.clear()term.
setCursorPos(1,1)print(l)local N=r:import_inventory(p)print(m:format(N))g()end
local function L()term.clear()term.setCursorPos(1,u)term.write(
'Press any key to return')x.setVisible(true)g()x.setVisible(false)end
local function M(N)local O=H()for P,Q in ipairs(N)do for R,S in ipairs(O)do s:
add_pattern_to_processor(Q,S)end end end local function N(O)local P=H()for Q,R
in ipairs(O)do for S,T in ipairs(P)do s:remove_pattern_from_processor(R,T)end
end end local function O(P)local Q={'Add patterns','Remove patterns'}F(Q,string.
format('Processor Patterns | %d Selected',#P),function(R)if R==1 then M(P)else
N(P)end end)end local function P()local Q=s:get_processors()if#Q<=0 then term.
clear()term.setCursorPos(1,1)term.write('No processors have been registered!')g(
)return end local R=f.checkbox_list(Q,'Select processors to configure',c)if#R==0
then return end O(R)I()end local function Q()local R=f.checkbox_list(E(),
'Register Processors',c)for S,T in ipairs(R)do s:add_processor(T,{})end I()end
local function R()local S=f.checkbox_list(s:get_processors(),
'Deregister Processors',c)for T,U in ipairs(S)do s:remove_processor(U)end I()end
local function S()F({'Configure patterns','Register','Deregister'},
'Processor Inventories',function(T)if T==1 then P()elseif T==2 then Q()elseif T
==3 then R()end end)end local function T()local U=f.choice_list(s:
get_registered_patterns(),'Choose Pattern',G)local V=s:get_available_processors(
U)if#V==0 then term.clear()term.setCursorPos(1,1)term.write(
'No available processors have this pattern!')g()return end term.clear()local W=
tonumber(f.text_page(string.format('Process Iterations | %s',G(U))))or 1 if W==0
then return end local X=f.checkbox_list(V,string.format(
'Select Processor Distribution | %dx %s',W,G(U)),c)if#X==0 then return end local
Y=math.floor(W/#X)local Z=W%#X local _={}for aa,ab in ipairs(X)do local ac=0 if
Z>0 then Z=Z-1 ac=1 end table.insert(_,{processor=ab,pattern=U,count=Y+ac})end
os.queueEvent('start_processing',_)end local function aa()F({'Craft',
'Processor inventories'},'Auto Processing Menu',function(ab)if ab==1 then T()
elseif ab==2 then S()end end)end local function ab()F({'Storage output',
'Storage input','Processing','View chart'},'Storage IO Menu',function(ac)if ac==
1 then J()elseif ac==2 then K()elseif ac==3 then aa()elseif ac==4 then L()end
end)term.clear()term.setCursorPos(1,1)end local function ac()while true do local
U,V=os.pullEvent('start_processing')local W={}for X,Y in ipairs(V)do local Z=
function()s:start_process_async(Y.processor,Y.pattern,Y.count)end table.insert(W
,Z)end parallel.waitForAll(table.unpack(W))end end local function U()while true
do r:update_inventories()local V,W=term.getCursorPos()local X=r:
get_system_items_sorted()z:draw_item_cells(X)A:draw_item_cells(X)y:
draw_item_cells(X)term.setCursorPos(V,W)sleep(5)end end B()parallel.waitForAny(
ab,ac,U)