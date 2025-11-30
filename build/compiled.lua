local a={cache={}}do do local function b()local function c(d,e)for f,g in next,d
do if g==e then return f end end return nil end return c end function a.a()local
c=a.cache.a if not c then c={c=b()}a.cache.a=c end return c.c end end do
local function b()local c=a.a()local d='Unable to find peripheral "%s"'local e=
'Unable to find processor "%s", did you add it?'local f=
'Processor "%s" does not support this pattern!'local g='Processor "%s" is busy!'
local h='Not enough ingredients!'local function i(j,k)local l={}for m,n in next,
j.input_slots do local o,p=n[1],n[2]l[p]=(l[p]or 0)+(o*k)end return l end
local function j(k)local l=0 for m,n in next,k.results do l=l+n end return l end
local k={register_pattern=function(k,l,m)k._patterns[l]=m end,deregister_pattern
=function(k,l)k._patterns[l]=nil end,get_registered_patterns=function(k)local l=
{}for m in next,k._patterns do table.insert(l,m)end return l end,
get_pattern_info=function(k,l)return k._patterns[l]end,add_processor=function(k,
l,m)if not peripheral.isPresent(l)then error(d:format(l),2)end k.processors[l]={
patterns=m,in_use=false}end,remove_processor=function(k,l)k.processors[l]=nil
end,get_processors=function(k)local l={}for m in next,k.processors do table.
insert(l,m)end return l end,add_pattern_to_processor=function(k,l,m)local n=k.
processors[l]if n==nil then error(e:format(l),2)end if c(n.patterns,m)then
return end table.insert(n.patterns,m)end,remove_pattern_from_processor=function(
k,l,m)local n=k.processors[l]if n==nil then error(e:format(l),2)end local o=c(n.
patterns,m)if o then table.remove(n.patterns,o)end end,is_processor_available=
function(k,l)local m=k.processors[l]if m==nil then error(e:format(l))end return
not m.in_use end,get_available_processors=function(k,l)local m={}for n,o in next
,k.processors do if k:is_processor_available(n)and c(o.patterns,l)then table.
insert(m,n)end end return m end,get_missing_ingredients=function(k,l,m)local n=k
._system:get_system_items()local o={}local p=i(k._patterns[l],m)for q,r in next,
p do local s=n[q]or 0 if s<r then o[q]=r-s end end return o end,
start_process_async=function(k,l,m,n)local o=k.processors[l]if o==nil then
error(e:format(l),2)end if o.in_use then error(g:format(l),2)end if c(o.patterns
,m)==nil then error(f:format(l),2)end local p=k:get_missing_ingredients(m,n)if
next(p)~=nil then error(h,2)end local q=k._patterns[m]local r=k._system local s=
1/q.poll_rate local t=j(q)local u=q.input_slots local v=q.output_slots o.in_use=
true for w=1,n do for x,y in next,u do local z,A=y[1],y[2]r:export_item(A,l,x,z)
end r:update_inventories()local x=t while x>0 do sleep(s)for y,z in next,v do
local A=r:import_from_slot(l,z)x=x-A end end end o.in_use=false end}local l={
__index=k}local function m(n,o)local p=setmetatable({_system=n,_patterns={},
processors={}},l)if o~=nil then for q,r in next,o do p:add_processor(q,r)end end
return p end return m end function a.b()local c=a.cache.b if not c then c={c=b()
}a.cache.b=c end return c.c end end do local function b()local c={'K','M','B',
'T','Qa','Qi','Sx','Sp','Oc','No','Dc'}local function d(e)if e<1000 then return
tostring(e)end local f=math.floor(math.log(e+1,10)/3)local g=c[f]if g==nil then
g='!?'end return string.format('%.1f%s',e/10^(f*3),g)end return d end function a
.c()local c=a.cache.c if not c then c={c=b()}a.cache.c=c end return c.c end end
do local function b()local function c(d)local e=d:gsub('^[^:]*:',''):gsub('_',
' ')local f=e:gsub('%s%l',string.upper):gsub('^%l',string.upper)return f end
return c end function a.d()local c=a.cache.d if not c then c={c=b()}a.cache.d=c
end return c.c end end do local function b()local function c(d,e)local f=math.
abs(e)-#d local g=string.rep(' ',f)if e<0 then return g..d end return d..g end
return c end function a.e()local c=a.cache.e if not c then c={c=b()}a.cache.e=c
end return c.c end end do local function b()local function c(d,e,f)return d,
string.rep(e,#d),string.rep(f,#d)end return c end function a.f()local c=a.cache.
f if not c then c={c=b()}a.cache.f=c end return c.c end end do local function b(
)local function c(d,e)if#d<=e then return d end return(d:sub(1,math.max(e-3,1)):
gsub('%s*$','')..'...'):sub(1,e)end return c end function a.g()local c=a.cache.g
if not c then c={c=b()}a.cache.g=c end return c.c end end do local function b()
local c=a.c()local d=a.d()local e=a.e()local f=a.f()local g=a.g()local h='%d. '
local i={reconfigure=function(i,j)i.config=j end,draw_item_cells=function(i,j)
local k=i.redirect local l,m=k.getSize()local n=i.config local o=n.column_count
local p=colors.toBlit(n.index_text_color or colors.lightBlue)local q=colors.
toBlit(n.name_text_color or colors.white)local r=colors.toBlit(n.
count_text_color or colors.pink)local s=colors.toBlit(n.cell_background_color or
colors.black)local t=colors.toBlit(n.cell_alt_background_color or colors.gray)
local u=math.floor(l/o)-1 local v=(l%o)+1 k.clear()for w,x in next,j do local y=
math.floor((w-1)/m)local z=(w-1)%m+1 local A=y*(u+1)+1 if y>=o then break end
local B=(z+y)%2==0 and t or s local C=e(h:format(w),-n.index_justification)local
D=' '..c(x.count)local E=u-#C-#D if y+1>=o then E=E+v end local F=e(g(d(x.name),
E),E)k.setCursorPos(A,z)k.blit(f(C,p,B))k.blit(f(F,q,B))k.blit(f(D,r,B))end end}
local j={__index=i}local function k(l,m)local n=setmetatable({redirect=l,config=
m},j)return n end return k end function a.h()local c=a.cache.h if not c then c={
c=b()}a.cache.h=c end return c.c end end do local function b()local c=
'Unable to find peripheral "%s"'local d=
'Peripheral "%s" is not a valid inventory!'local function e(f)local g=peripheral
.wrap(f)if g==nil then error(c:format(f),2)end if g.list==nil then error(d:
format(f),2)end return g end return e end function a.i()local c=a.cache.i if not
c then c={c=b()}a.cache.i=c end return c.c end end do local function b()local c=
a.i()local d='Unable to find inventory "%s", is it being tracked?'local function
e(f,g)return f.count>g.count end local f={track_inventory=function(f,g)f.
inventories[g]=c(g)end,untrack_inventory=function(f,g)f.inventories[g]=nil end,
update_inventories=function(f)for g,h in next,f.inventories do f._item_cache[g]=
h.list()end end,get_inventories=function(f)local g={}for h in next,f.inventories
do table.insert(g,h)end return g end,get_system_size=function(f)local g=0 for h,
i in next,f.inventories do g=g+i.size()end return g end,get_system_items=
function(f)local g={}for h,i in next,f._item_cache do for j,k in next,i do local
l=k.name local m=k.count g[l]=(g[l]or 0)+m end end return g end,
get_system_items_sorted=function(f,g)local h={}for i,j in next,f:
get_system_items()do table.insert(h,{name=i,count=j})end table.sort(h,g or e)
return h end,find_item=function(f,g)local h local i return function()for j,k in
next,f._item_cache,h do for l,m in next,k,i do i=l if m.name==g then return j,l,
m end end h=j i=nil end return nil,nil,nil end end,pull_items=function(f,g,h,i,j
,k)local l=f.inventories[i]if l==nil then error(d:format(i),2)end return l.
pullItems(g,h,k,j)end,push_items=function(f,g,h,i,j,k)local l=f.inventories[g]if
l==nil then error(d:format(g),2)end return l.pushItems(i,h,k,j)end,
import_from_slot=function(f,g,h,i)local j=next(f.inventories)if j==nil then
return 0 end local k=0 while true do local l=i and i-k or nil local m=f:
pull_items(g,h,j,nil,l)k=k+m if i~=nil and k>=i then break end if m==0 then j=
next(f.inventories,j)if j==nil then break end elseif i==nil then break end end
return k end,import_inventory=function(f,g)local h=0 local i=c(g)for j in next,i
.list()do local k=f:import_from_slot(g,j)h=h+k end return h end,import_item=
function(f,g,h,i)local j=0 local k=c(h)for l,m in next,k.list()do if m.name==g
then local n=i and i-j or m.count local o=f:import_from_slot(h,l,math.min(n,m.
count))j=j+o if i==nil or j>=i or o==0 then break end end end return j end,
export_item=function(f,g,h,i,j)local k=0 for l,m in f:find_item(g)do local n=j~=
nil and j-k or nil local o=f:push_items(l,m,h,i,n)k=k+o if j==nil or k>=j then
break end end return k end}local g={__index=f}local function h(i)local j=
setmetatable({inventories={},_item_cache={}},g)if i~=nil then for k,l in next,i
do j:track_inventory(l)end end return j end return h end function a.j()local c=a
.cache.j if not c then c={c=b()}a.cache.j=c end return c.c end end do
local function b()local c={AutoCrafter=a.b(),StorageDisplay=a.h(),StorageSystem=
a.j()}return c end function a.k()local c=a.cache.k if not c then c={c=b()}a.
cache.k=c end return c.c end end do local function b()local c='.storagesystem'
local d='storage.io_inventory'local e='storage.system_inventories'local f=
'storage.processors'settings.define(d,{type='string',description=
'The inventory the system uses for IO operations.'})settings.define(e,{type=
'table',description='The inventories the system has registered.'})settings.
define(f,{type='table',description='The processors the system has registered.'})
return{settings={IO_INVENTORY=d,SYSTEM_INVENTORIES=e,PROCESSORS=f},get=function(
g)return settings.get(g)end,set=function(g,h)settings.set(g,h)end,load=function(
)settings.load(c)end,save=function()settings.save(c)end}end function a.l()local
c=a.cache.l if not c then c={c=b()}a.cache.l=c end return c.c end end do
local function b()local function c(d,e)local f={}for g,h in next,d do if e(g,h)
then if type(g)=='number'then table.insert(f,h)else f[g]=h end end end return f
end return c end function a.m()local c=a.cache.m if not c then c={c=b()}a.cache.
m=c end return c.c end end do local function b()local function c(d)local e={}for
f,g in ipairs(d.getNamesRemote())do if peripheral.hasType(g,'inventory')then
table.insert(e,g)end end table.sort(e)return e end return c end function a.n()
local c=a.cache.n if not c then c={c=b()}a.cache.n=c end return c.c end end do
local function b()local function c(d)local e={}for f,g in next,d do e[f]=g end
return e end return c end function a.o()local c=a.cache.o if not c then c={c=b()
}a.cache.o=c end return c.c end end do local function b()local function c(d,e,f,
g)if#d==0 then return 0 end local h=g or 1 local i,j=term.getSize()local k=j-4
local l=math.ceil(#d/k)while true do term.clear()term.setCursorPos(1,1)term.
write(e)local m=math.ceil(h/k)local n=(m-1)*k+1 local o=math.min(n+k-1,#d)for p=
n,o do local q=d[p]local r=f(tostring(q),p,h)if p==h then term.setTextColor(
colors.lightBlue)end term.setCursorPos(1,(p-n)+3)term.write(r)term.setTextColor(
colors.white)end term.setCursorPos(1,j)term.write(string.format('Page %d/%d',m,l
))local p,q=os.pullEvent('key')if q==keys.up then h=math.max(h-1,1)elseif q==
keys.left then h=math.max(h-k,1)elseif q==keys.down then h=math.min(h+1,#d)
elseif q==keys.right then h=math.min(h+k,#d)elseif q==keys.enter then break end
end return h end return c end function a.p()local c=a.cache.p if not c then c={c
=b()}a.cache.p=c end return c.c end end do local function b()local c=a.o()local
d=a.p()local function e(f,g,h)local i={}local j local k=c(f)table.insert(k,'')
local l=#k while true do local m=d(k,g,function(m,n,o)local p=n==o if n==l then
term.setTextColor(colors.red)return string.format('%s Done',p and'>'or' ')end
local q=i[n]~=nil local r=h and h(m)or m if q then term.setTextColor(colors.
green)end return string.format('%s [%s] %s',p and'>'or' ',q and'x'or' ',r)end,j)
if m==l then break end j=m i[m]=not i[m]and true or nil end local m={}for n in
next,i do table.insert(m,f[n])end return m end return e end function a.q()local
c=a.cache.q if not c then c={c=b()}a.cache.q=c end return c.c end end do
local function b()local c=a.p()local function d(e,f,g)local h=c(e,f,function(h,i
,j)local k=g and g(h)or h local l=i==j return string.format('%s %s',l and'>'or
' ',k)end)return e[h],h end return d end function a.r()local c=a.cache.r if not
c then c={c=b()}a.cache.r=c end return c.c end end do local function b()local c=
a.r()local function d(e,f,g)table.insert(e,'Exit')while true do local h,i=c(e,f)
if i==#e then break end g(i,h)end end return d end function a.s()local c=a.cache
.s if not c then c={c=b()}a.cache.s=c end return c.c end end do local function b
()local function c(d)return function(e)local f=d:get_pattern_info(e)if f==nil
then return'UNKNOWN PATTERN'end return f.label end end return c end function a.t
()local c=a.cache.t if not c then c={c=b()}a.cache.t=c end return c.c end end do
local function b()local c=a.s()local d=a.q()local e=a.t()local function f(g)
return d(g:get_registered_patterns(),'Choose Patterns',e(g))end local function g
(h,i)local j=f(i)for k,l in ipairs(h)do for m,n in ipairs(j)do i:
add_pattern_to_processor(l,n)end end end local function h(i,j)local k=f(j)for l,
m in ipairs(i)do for n,o in ipairs(k)do j:remove_pattern_from_processor(m,o)end
end end return function(i,j)local k={'Add patterns','Remove patterns'}c(k,string
.format('Processor Patterns | %d Selected',#i),function(l)if l==1 then g(i,j)
else h(i,j)end end)end end function a.u()local c=a.cache.u if not c then c={c=b(
)}a.cache.u=c end return c.c end end do local function b()local function c()os.
pullEvent('key')os.pullEvent('key_up')end return c end function a.v()local c=a.
cache.v if not c then c={c=b()}a.cache.v=c end return c.c end end do
local function b()local c=a.s()local d=a.u()local e=a.q()local f=a.m()local g=a.
d()local h=a.n()local i=a.v()local function j(k)local l=k:get_processors()if#l<=
0 then term.clear()term.setCursorPos(1,1)term.write(
'No processors have been registered!')i()return end local m=e(l,
'Select processors to configure',g)if#m==0 then return end d(m,k)end
local function k(l,m,n,o)local function p()return f(h(l),function(q,r)return not
(r==m or n.inventories[r]~=nil or o.processors[r]~=nil)end)end local q=e(p(),
'Register Processors',g)for r,s in ipairs(q)do o:add_processor(s,{})end end
local function l(m)local n=e(m:get_processors(),'Deregister Processors',g)for o,
p in ipairs(n)do m:remove_processor(p)end end return function(m,n,o,p)c({
'Configure patterns','Register','Deregister'},'Processor Inventories',function(q
)if q==1 then j(p)elseif q==2 then k(m,n,o,p)elseif q==3 then l(p)end end)end
end function a.w()local c=a.cache.w if not c then c={c=b()}a.cache.w=c end
return c.c end end do local function b()local function c(d,e,f)local g,h=term.
getSize()term.setCursorPos(1,1)term.write(d)if e~=nil then term.setTextColor(
colors.lightGray)term.setCursorPos(1,h)term.write(e)term.setTextColor(colors.
white)end term.setCursorPos(1,3)term.write('$ ')return read(nil,nil,f)end return
c end function a.x()local c=a.cache.x if not c then c={c=b()}a.cache.x=c end
return c.c end end do local function b()local c=a.s()local d=a.w()local e=a.q()
local f=a.r()local g=a.x()local h=a.d()local i=a.t()local j=a.v()local k=
"Not enough ingredients for %dx '%s'\n%s"local function l(m)local n=i(m)local o=
f(m:get_registered_patterns(),'Choose Pattern',n)local p=m:
get_available_processors(o)if#p==0 then term.clear()term.setCursorPos(1,1)term.
write('No available processors have this pattern!')j()return end term.clear()
local q=tonumber(g(string.format('Process Iterations | %s',n(o))))or 1 if q==0
then return end local r=m:get_missing_ingredients(o,q)if next(r)~=nil then term.
clear()term.setCursorPos(1,1)local s=''for t,u in next,r do s=s..string.format(
'MISSING %s -> %d\n',t,u)end printError(k:format(q,n(o),s))j()return end local s
=e(p,string.format('Select Processor Distribution | %dx %s',q,n(o)),h)if#s==0
then return end local t=math.floor(q/#s)local u=q%#s local v={}for w,x in
ipairs(s)do local y=0 if u>0 then u=u-1 y=1 end table.insert(v,{processor=x,
pattern=o,count=t+y})end os.queueEvent('start_crafting',v)end return function(m,
n,o,p)c({'Craft','Processor inventories'},'Auto Processing Menu',function(q)if q
==1 then l(p)elseif q==2 then d(m,n,o,p)end end)end end function a.y()local c=a.
cache.y if not c then c={c=b()}a.cache.y=c end return c.c end end do
local function b()local function c(d,e)local f local g=math.huge for h,i in
ipairs(d)do local j=string.find(i,e)if j and j<g then g=j f=i end end return f
end return c end function a.z()local c=a.cache.z if not c then c={c=b()}a.cache.
z=c end return c.c end end do local function b()local c=a.s()local d=a.y()local
e=a.r()local f=a.x()local g=a.z()local h=a.d()local i=a.v()local j=
'Exporting %d items...'local k='Importing items...'local l=
'Transferred %d items.'local function m(n,o,p)p.setVisible(true)local function q
(r)local s={}for t in next,o:get_system_items()do local u,v=string.find(t,r)if v
~=nil then table.insert(s,t:sub(v+1,-1))end end return s end local function r()
term.clear()p.redraw()local s=f('Storage System Output',
"'exit' to return to menu",q)if s=='exit'then return true end local t=o:
get_system_items()local u={}for v in next,t do table.insert(u,v)end local v=g(u,
s)if v==nil then printError(string.format("Unable to find '%s'",s))i()return
false end term.clear()p.redraw()local w=f(string.format(
'Item Count - %s | %d in system',h(v),t[v]),"'cancel' to restart")if w=='cancel'
then return false end local x=tonumber(w)or 64 print(j:format(x))local y=o:
export_item(v,n,nil,x)print(l:format(y))i()end while true do if r()then break
end end p.setVisible(false)end local function n(o,p)local q,r=e({'yesss!!!!!!',
'wait nvm'},'Storage System Input - Are you sure?')if r==2 then return end term.
clear()term.setCursorPos(1,1)print(k)local s=p:import_inventory(o)print(l:
format(s))i()end local function o(p)local q,r=term.getSize()term.clear()term.
setCursorPos(1,r)term.write('Press any key to return')p.setVisible(true)i()p.
setVisible(false)end return function(p,q,r,s,t,u)return function()c({
'Storage output','Storage input','Processing','View chart'},'Storage IO Menu',
function(v)if v==1 then m(q,r,t)elseif v==2 then n(q,r)elseif v==3 then d(p,q,r,
s)elseif v==4 then o(u)end end)term.clear()term.setCursorPos(1,1)end end end
function a.A()local c=a.cache.A if not c then c={c=b()}a.cache.A=c end return c.
c end end end local b=a.k()local c=a.d()local d=a.l()local e=a.m()local f=a.n()
local g=a.q()local h=a.r()local i=a.A()local j=peripheral.find('modem')d.load()
local k=d.get(d.settings.IO_INVENTORY)local l=settings.get(d.settings.
SYSTEM_INVENTORIES)if k==nil or not j.isPresentRemote(k)then k=h(f(j),
'Choose IO Inventory',c)d.set(d.settings.IO_INVENTORY,k)end if l==nil then l=g(
e(f(j),function(m,n)return n~=k end),'Select System Inventories',c)d.set(d.
settings.SYSTEM_INVENTORIES,l)end d.save()local m=b.StorageSystem(l)local n=b.
AutoCrafter(m,d.get(d.settings.PROCESSORS))local o=peripheral.find('monitor')o.
setTextScale(0.5)local p,q=term.getSize()local r=window.create(term.current(),p*
2/3,2,math.ceil(p/3),q-2,false)local s=window.create(term.current(),1,1,p,q-1,
false)local t=b.StorageDisplay(o,{column_count=1,index_justification=4})local u=
b.StorageDisplay(r,{column_count=1,index_justification=3})local v=b.
StorageDisplay(s,{column_count=2,index_justification=3})local function w()local
x=fs.getDir(shell.getRunningProgram())local y=fs.combine(x,'patterns')if not fs.
exists(y)then return end for z,A in ipairs(fs.list(y))do local B=A:gsub('%..*',
'')n:register_pattern(B,require('patterns/'..B))end end local function x()while
true do local y,z=os.pullEvent('start_crafting')local A={}for B,C in ipairs(z)do
local D=function()n:start_process_async(C.processor,C.pattern,C.count)end table.
insert(A,D)end parallel.waitForAll(table.unpack(A))end end local function y()
while true do m:update_inventories()local z,A=term.getCursorPos()local B=m:
get_system_items_sorted()u:draw_item_cells(B)v:draw_item_cells(B)t:
draw_item_cells(B)term.setCursorPos(z,A)sleep(5)end end w()parallel.waitForAny(
i(j,k,m,n,r,s),x,y)