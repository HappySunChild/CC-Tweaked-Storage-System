local a={cache={}}do do local function b()local c='storage.io_inventory'local d=
'storage.system_inventories'local e='storage.processors'local f=
'storage.monitor_columns'settings.define(c,{type='string',description=
'The inventory the system uses for IO operations.'})settings.define(d,{type=
'table',description='The inventories the system has registered.'})settings.
define(e,{type='table',description='The processors the system has registered.'})
settings.define(f,{default=2,type='number',description=
'The number of columns to render on the monitor.'})return{settings={IO_INVENTORY
=c,SYSTEM_INVENTORIES=d,PROCESSORS=e,MONITORS_COLUMNS=f},get=function(g)return
settings.get(g)end,set=function(g,h)settings.set(g,h)end,load=function()settings
.load()end,save=function()settings.save()end}end function a.a()local c=a.cache.a
if not c then c={c=b()}a.cache.a=c end return c.c end end do local function b()
local function c(d)local e=d:gsub('^[^:]*:',''):gsub('_',' ')local f=e:gsub(
'%s%l',string.upper):gsub('^%l',string.upper)return f end return c end function
a.b()local c=a.cache.b if not c then c={c=b()}a.cache.b=c end return c.c end end
do local function b()local function c(d,e)local f=math.floor(e/#d)local g=e%#d
return function(h,i)local j=next(d,i)if j==nil then return nil end local k=f+(g>
0 and 1 or 0)g=g-1 if k==0 then return nil end return j,h[j],k end,d,nil end
return c end function a.c()local c=a.cache.c if not c then c={c=b()}a.cache.c=c
end return c.c end end do local function b()local function c(d,e)for f,g in next
,d do if g==e then return f end end return nil end return c end function a.d()
local c=a.cache.d if not c then c={c=b()}a.cache.d=c end return c.c end end do
local function b()local c=a.c()local d=a.d()local e=
'Unable to find peripheral "%s"'local f=
'Unable to find processor "%s", did you add it?'local g=
'Processor "%s" does not support this pattern!'local h='Processor "%s" is busy!'
local i='Not enough ingredients!'local function j(k,l)local m={}for n,o in next,
k.input_slots do local p,q=o[1],o[2]m[q]=(m[q]or 0)+(p*l)end return m end
local function k(l)local m=0 for n,o in next,l.results do m=m+o end return m end
local l={register_pattern=function(l,m,n)l.patterns[m]=n end,deregister_pattern=
function(l,m)l.patterns[m]=nil end,get_registered_patterns=function(l)local m={}
for n in next,l.patterns do table.insert(m,n)end return m end,add_processor=
function(l,m,n)if not peripheral.isPresent(m)then error(e:format(m),2)end l.
processors[m]={patterns=n,in_use=false,reserved=false}end,remove_processor=
function(l,m)l.processors[m]=nil end,get_processors=function(l)local m={}for n
in next,l.processors do table.insert(m,n)end table.sort(m)return m end,
add_pattern_to_processor=function(l,m,n)local o=l.processors[m]if o==nil then
error(f:format(m),2)end if d(o.patterns,n)then return end table.insert(o.
patterns,n)end,remove_pattern_from_processor=function(l,m,n)local o=l.processors
[m]if o==nil then error(f:format(m),2)end local p=d(o.patterns,n)if p then table
.remove(o.patterns,p)end end,is_processor_available=function(l,m)local n=l.
processors[m]if n==nil then error(f:format(m))end return not n.in_use and not n.
reserved end,get_available_processors=function(l,m)local n={}for o,p in next,l.
processors do if l:is_processor_available(o)and d(p.patterns,m)then table.
insert(n,o)end end table.sort(n)return n end,get_patterns_with_result=function(l
,m)local n={}for o,p in next,l.patterns do if p.results[m]~=nil then table.
insert(n,o)end end return n end,can_craft=function(l,m,n)local o=l:
get_patterns_with_result(m)for p,q in ipairs(o)do if#l:get_available_processors(
q)>0 then local r=l.patterns[q]local s=math.ceil(n/r.results[m])local t=l:
get_missing_ingredients(q,s)local u=true for v,w in next,t do if v==m or not l:
can_craft(v,w)then u=false break end end if u then return true end end end
return false end,get_missing_ingredients=function(l,m,n)local o=l._storage:
get_system_items()local p={}local q=j(l.patterns[m],n)for r,s in next,q do local
t=o[r]or 0 if t<s then p[r]=s-t end end return p end,start_process_async=
function(l,m,n,o)local p=l.processors[m]if p==nil then error(f:format(m),2)end
if p.in_use then error(h:format(m),2)end if d(p.patterns,n)==nil then error(g:
format(m),2)end p.reserved=false local q=l.patterns[n]local r=l._storage local s
=1/q.poll_rate local t=k(q)local u=q.input_slots local v=q.output_slots p.in_use
=true for w=1,o do for x,y in next,u do local z,A=y[1],y[2]r:export_item(A,m,x,z
)end r:update_inventories()local x=t while x>0 do sleep(s)for y,z in next,v do
local A=r:import_from_slot(m,z)x=x-A end end end p.in_use=false return true end,
start_batch_process_async=function(l,m,n,o)local p=l:get_missing_ingredients(n,o
)for q,r in next,p do if not l:can_craft(q,r)then error(i,2)end local s=l:
get_patterns_with_result(q)[1]local t=l.patterns[s]local u=l:
get_available_processors(s)local v=math.ceil(r/t.results[q])l:
start_batch_process_async(u,s,v)end local q={}for r,s,t in c(m,o)do local u=
function()l:start_process_async(s,n,t)end table.insert(q,u)end parallel.
waitForAll(table.unpack(q))end}local m={__index=l}local function n(o,p)local q=
setmetatable({_storage=o,patterns={},processors={}},m)if p~=nil then for r,s in
next,p do pcall(q.add_processor,q,r,s)end end return q end return n end function
a.e()local c=a.cache.e if not c then c={c=b()}a.cache.e=c end return c.c end end
do local function b()local c={'K','M','B','T','Qa','Qi','Sx','Sp','Oc','No','Dc'
}local function d(e)if e<1000 then return tostring(e)end local f=math.floor(math
.log(e+1,10)/3)local g=c[f]if g==nil then g='!?'end return string.format(
'%.1f%s',e/10^(f*3),g)end return d end function a.f()local c=a.cache.f if not c
then c={c=b()}a.cache.f=c end return c.c end end do local function b()
local function c(d,e)local f=math.abs(e)-#d local g=string.rep(' ',f)if e<0 then
return g..d end return d..g end return c end function a.g()local c=a.cache.g if
not c then c={c=b()}a.cache.g=c end return c.c end end do local function b()
local function c(d,e,f)return d,string.rep(e,#d),string.rep(f,#d)end return c
end function a.h()local c=a.cache.h if not c then c={c=b()}a.cache.h=c end
return c.c end end do local function b()local function c(d,e)if#d<=e then return
d end return(d:sub(1,math.max(e-3,1)):gsub('%s*$','')..'...'):sub(1,e)end return
c end function a.i()local c=a.cache.i if not c then c={c=b()}a.cache.i=c end
return c.c end end do local function b()local c=a.f()local d=a.b()local e=a.g()
local f=a.h()local g=a.i()local h='%d. 'local i={reconfigure=function(i,j)i.
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
function a.j()local c=a.cache.j if not c then c={c=b()}a.cache.j=c end return c.
c end end do local function b()local c='Unable to find peripheral "%s"'local d=
'Peripheral "%s" is not a valid inventory!'local function e(f)local g=peripheral
.wrap(f)if g==nil then error(c:format(f),2)end if g.list==nil then error(d:
format(f),2)end return g end return e end function a.k()local c=a.cache.k if not
c then c={c=b()}a.cache.k=c end return c.c end end do local function b()local c=
a.k()local d='Unable to find inventory "%s", is it being tracked?'local function
e(f,g)return f.count>g.count end local f={load_peripheral=function(f,g)f.
inventories[g]=c(g)end,unload_peripheral=function(f,g)f.inventories[g]=nil end,
update_inventories=function(f)for g,h in next,f.inventories do f._item_cache[g]=
h.list()end end,get_inventories=function(f)local g={}for h in next,f.inventories
do table.insert(g,h)end return g end,get_system_size=function(f)local g=0 for h,
i in next,f.inventories do g=g+i.size()end return g end,get_system_items=
function(f)local g={}for h,i in next,f._item_cache do for j,k in next,i do local
l=k.name local m=k.count g[l]=(g[l]or 0)+m end end return g end,
get_system_items_sorted=function(f,g)local h={}for i,j in next,f:
get_system_items()do table.insert(h,{name=i,count=j})end table.sort(h,g or e)
return h end,query_items=function(f,g)local h local i return function()for j,k
in next,f._item_cache,h do for l,m in next,k,i do i=l if m.name:match(g)then
return j,l,m end end h=j i=nil end return nil,nil,nil end end,pull_items=
function(f,g,h,i,j,k)local l=f.inventories[i]if l==nil then error(d:format(i),2)
end return l.pullItems(g,h,k,j)end,push_items=function(f,g,h,i,j,k)local l=f.
inventories[g]if l==nil then error(d:format(g),2)end return l.pushItems(i,h,k,j)
end,import_from_slot=function(f,g,h,i)local j=next(f.inventories)if j==nil then
return 0 end local k=0 while true do local l=i and i-k or nil local m=f:
pull_items(g,h,j,nil,l)k=k+m if i~=nil and k>=i then break end if m==0 then j=
next(f.inventories,j)if j==nil then break end elseif i==nil then break end end
return k end,import_inventory=function(f,g)local h=0 local i=c(g)for j in next,i
.list()do local k=f:import_from_slot(g,j)h=h+k end return h end,import_item=
function(f,g,h,i)local j=0 local k=c(h)for l,m in next,k.list()do if m.name==g
then local n=i and i-j or m.count local o=f:import_from_slot(h,l,math.min(n,m.
count))j=j+o if i==nil or j>=i or o==0 then break end end end return j end,
export_item=function(f,g,h,i,j)local k=0 for l,m in f:query_items(g)do local n=j
~=nil and j-k or nil local o=f:push_items(l,m,h,i,n)k=k+o if j==nil or k>=j then
break end end return k end}local g={__index=f}local function h(i)local j=
setmetatable({inventories={},_item_cache={}},g)if i~=nil then for k,l in next,i
do j:load_peripheral(l)end end return j end return h end function a.l()local c=a
.cache.l if not c then c={c=b()}a.cache.l=c end return c.c end end do
local function b()local c={format_name=a.b(),AutoCrafter=a.e(),StorageDisplay=a.
j(),ItemStorage=a.l()}return c end function a.m()local c=a.cache.m if not c then
c={c=b()}a.cache.m=c end return c.c end end do local function b()local c={}local
d={}local function e(f,...)local g,h=coroutine.resume(f,...)if g then return h
end printError(h)end local function f(g,...)local h=e(g,...)if coroutine.status(
g)~='dead'then table.insert(d,{thread=g,filter=h})end end return{spawn=function(
g,...)local h=coroutine.create(g)f(h,...)end,defer=function(g,...)local h=
coroutine.create(g)table.insert(c,{thread=h,args=table.pack(...)})end,
start_scheduler=function()while true do while#c>0 do local g=table.remove(c,1)f(
g.thread,table.unpack(g.args))end local g=table.pack(os.pullEvent())local h=g[1]
for i=#d,1,-1 do local j=d[i]if j.filter==nil or j.filter==h then local k=j.
thread local l=e(k,table.unpack(g))if coroutine.status(k)=='dead'then table.
remove(d,i)else j.filter=l end end end end end}end function a.n()local c=a.cache
.n if not c then c={c=b()}a.cache.n=c end return c.c end end do local function b
()local function c(d,e)local f={}for g,h in next,d do if e(g,h)then if type(g)==
'number'then table.insert(f,h)else f[g]=h end end end return f end return c end
function a.o()local c=a.cache.o if not c then c={c=b()}a.cache.o=c end return c.
c end end do local function b()local function c(d)local e={}for f,g in ipairs(d.
getNamesRemote())do if peripheral.hasType(g,'inventory')then table.insert(e,g)
end end table.sort(e)return e end return c end function a.p()local c=a.cache.p
if not c then c={c=b()}a.cache.p=c end return c.c end end do local function b()
local function c(d)local e=fs.getDir(shell.getRunningProgram())local f=fs.
combine(e,'patterns')if not fs.exists(f)then return end for g,h in ipairs(fs.
list(f))do local i=h:gsub('%..*','')local j=loadfile(fs.combine(f,h),'t')()d:
register_pattern(i,j)end end return c end function a.q()local c=a.cache.q if not
c then c={c=b()}a.cache.q=c end return c.c end end do local function b()
local function c(d,e,f,g,h)if#d==0 then return 0 end local i=h or 1 local j,k=
term.getSize()local l=k-4 local m=math.ceil(#d/l)while true do term.clear()term.
setCursorPos(1,1)term.write(e)local n=math.ceil(i/l)local o=(n-1)*l+1 local p=
math.min(o+l-1,#d)for q=o,p do local r=d[q]local s=g(tostring(r),q,i)if q==i
then term.setTextColor(colors.lightBlue)end term.setCursorPos(1,(q-o)+3)term.
write(s)term.setTextColor(colors.white)end term.setCursorPos(1,k)term.write(
string.format('Page %d/%d %s',n,m,f))local q,r=os.pullEvent('key')if r==keys.up
then i=math.max(i-1,1)elseif r==keys.left then i=math.max(i-l,1)elseif r==keys.
down then i=math.min(i+1,#d)elseif r==keys.right then i=math.min(i+l,#d)elseif r
==keys.enter then break end end return i end return c end function a.r()local c=
a.cache.r if not c then c={c=b()}a.cache.r=c end return c.c end end do
local function b()local c=a.r()local function d(e)local f={}for g,h in next,e do
f[g]=h end return f end local function e(f)local g=0 for h in next,f do g=g+1
end return g end local function f(g,h,i)local j={}local k local l=d(g)table.
insert(l,'')local m=#l while true do local n=c(l,h,string.format('- %d selected'
,e(j)),function(n,o,p)local q=o==p if o==m then term.setTextColor(colors.red)
return string.format('%s Done',q and'>'or' ')end local r=j[o]~=nil local s=i and
i(n)or n if r then term.setTextColor(colors.green)end return string.format(
'%s [%s] %s',q and'>'or' ',r and'x'or' ',s)end,k)if n==m then break end k=n j[n]
=not j[n]and true or nil end local n={}for o in next,j do table.insert(n,g[o])
end return n end return f end function a.s()local c=a.cache.s if not c then c={c
=b()}a.cache.s=c end return c.c end end do local function b()local c=a.r()
local function d(e,f,g)local h=c(e,f,'',function(h,i,j)local k=g and g(h)or h
local l=i==j return string.format('%s %s',l and'>'or' ',k)end)return e[h],h end
return d end function a.t()local c=a.cache.t if not c then c={c=b()}a.cache.t=c
end return c.c end end do local function b()local c=a.t()local function d(e,f,g)
table.insert(e,'Exit')while true do local h,i=c(e,f)if i==#e then break end g(i,
h)end end return d end function a.u()local c=a.cache.u if not c then c={c=b()}a.
cache.u=c end return c.c end end do local function b()local function c(d)return
function(e)local f=d.patterns[e]if f==nil then return'UNKNOWN PATTERN'end return
f.label end end return c end function a.v()local c=a.cache.v if not c then c={c=
b()}a.cache.v=c end return c.c end end do local function b()local c=a.u()local d
=a.s()local e=a.v()local f=a.q()local function g(h)return d(h:
get_registered_patterns(),'Choose Patterns',e(h))end local function h(i,j)local
k=g(j)for l,m in ipairs(i)do for n,o in ipairs(k)do j:add_pattern_to_processor(m
,o)end end end local function i(j,k)local l=g(k)for m,n in ipairs(j)do for o,p
in ipairs(l)do k:remove_pattern_from_processor(n,p)end end end return function(j
,k)local l={'Add patterns','Remove patterns','Reload patterns'}c(l,string.
format('Processor Patterns | %d Selected',#j),function(m)if m==1 then h(j,k)
elseif m==2 then i(j,k)elseif m==3 then f(k)end end)end end function a.w()local
c=a.cache.w if not c then c={c=b()}a.cache.w=c end return c.c end end do
local function b()local function c()os.pullEvent('key')os.pullEvent('key_up')end
return c end function a.x()local c=a.cache.x if not c then c={c=b()}a.cache.x=c
end return c.c end end do local function b()local c=a.a()local d=a.u()local e=a.
w()local f=a.s()local g=a.o()local h=a.m().format_name local i=a.p()local j=a.x(
)local function k(l)local m={}for n,o in next,l.processors do m[n]=o.patterns
end c.set(c.settings.PROCESSORS,m)c.save()end local function l(m)local n=m:
get_processors()if#n<=0 then term.clear()term.setCursorPos(1,1)term.write(
'No processors have been registered!')j()return end local o=f(n,
'Select processors to configure',h)if#o==0 then return end e(o,m)k(m)end
local function m(n,o,p,q)local function r()return g(i(n),function(s,t)return not
(t==o or p.inventories[t]~=nil or q.processors[t]~=nil)end)end local s=f(r(),
'Register Processors',h)for t,u in ipairs(s)do q:add_processor(u,{})end k(q)end
local function n(o)local p=f(o:get_processors(),'Deregister Processors',h)for q,
r in ipairs(p)do o:remove_processor(r)end k(o)end return function(o,p,q,r)d({
'Configure patterns','Register','Deregister'},'Processor Inventories',function(s
)if s==1 then l(r)elseif s==2 then m(o,p,q,r)elseif s==3 then n(r)end end)end
end function a.y()local c=a.cache.y if not c then c={c=b()}a.cache.y=c end
return c.c end end do local function b()local function c(d,e,f)local g,h=term.
getSize()term.setCursorPos(1,1)term.write(d)if e~=nil then term.setTextColor(
colors.lightGray)term.setCursorPos(1,h)term.write(e)term.setTextColor(colors.
white)end term.setCursorPos(1,3)term.write('$ ')return read(nil,nil,f)end return
c end function a.z()local c=a.cache.z if not c then c={c=b()}a.cache.z=c end
return c.c end end do local function b()local c=a.n()local d=a.u()local e=a.y()
local f=a.s()local g=a.t()local h=a.z()local i=a.m().format_name local j=a.v()
local k=a.x()local l="Not enough ingredients for %dx '%s'\n%s"local function m(n
)local o=j(n)local p=g(n:get_registered_patterns(),'Choose Pattern',o)local q=n:
get_available_processors(p)if#q==0 then term.clear()term.setCursorPos(1,1)term.
write('No available processors have this pattern!')k()return end term.clear()
local r=tonumber(h(string.format('Process Iterations | %s',o(p))))or 1 if r==0
then return end local s=n:get_missing_ingredients(p,r)if next(s)~=nil then term.
clear()term.setCursorPos(1,1)local t=''local u=true for v,w in next,s do local x
=n:can_craft(v,w)if not x then u=false end t=t..string.format('%s %s -> %d\n',x
and'CRAFTABLE'or'MISSING',v,w)end if not u then printError(l:format(r,o(p),t))k(
)return end end local t=f(q,string.format(
'Select Processor Distribution | %dx %s',r,o(p)),i)if#t==0 then return end c.
spawn(n.start_batch_process_async,n,t,p,r)end return function(n,o,p,q)d({'Craft'
,'Processor inventories'},'Auto Processing Menu',function(r)if r==1 then m(q)
elseif r==2 then e(n,o,p,q)end end)end end function a.A()local c=a.cache.A if
not c then c={c=b()}a.cache.A=c end return c.c end end do local function b()
local function c(d,e)local f local g=math.huge for h,i in ipairs(d)do local j=
string.find(i,e)if j and j<g then g=j f=i end end return f end return c end
function a.B()local c=a.cache.B if not c then c={c=b()}a.cache.B=c end return c.
c end end do local function b()local c=a.u()local d=a.A()local e=a.t()local f=a.
z()local g=a.B()local h=a.m().format_name local i=a.x()local j=
'Exporting %d items...'local k='Importing items...'local l=
'Transferred %d items.'local function m(n,o)local function p(q)local r={}for s
in next,o:get_system_items()do local t,u=string.find(s,q)if u~=nil then table.
insert(r,s:sub(u+1,-1))end end return r end local function q()term.clear()local
r=f('Storage System Output',"'exit' to return to menu",p)if r=='exit'then return
true end local s=o:get_system_items()local t={}for u in next,s do table.insert(t
,u)end local u=g(t,r)if u==nil then printError(string.format(
"Unable to find '%s'",r))i()return false end term.clear()local v=f(string.
format('Item Count - %s | %d in system',h(u),s[u]),"'cancel' to restart")if v==
'cancel'then return false end local w=tonumber(v)or 64 print(j:format(w))local x
=o:export_item(u,n,nil,w)print(l:format(x))i()end while true do if q()then break
end end end local function n(o,p)local q,r=e({'yesss!!!!!!','wait nvm'},
'Storage System Input - Are you sure?')if r==2 then return end term.clear()term.
setCursorPos(1,1)print(k)local s=p:import_inventory(o)print(l:format(s))i()end
local function o(p)local q,r=term.getSize()term.clear()term.setCursorPos(1,r)
term.write('Press any key to return')p.setVisible(true)i()p.setVisible(false)end
return function(p,q,r,s,t)return function()c({'Storage output','Storage input',
'Processing','View chart'},'Storage IO Menu',function(u)if u==1 then m(q,r)
elseif u==2 then n(q,r)elseif u==3 then d(p,q,r,s)elseif u==4 then o(t)end end)
term.clear()term.setCursorPos(1,1)end end end function a.C()local c=a.cache.C if
not c then c={c=b()}a.cache.C=c end return c.c end end end local b=a.a()local c=
a.m()local d=a.n()local e=c.format_name local f=a.o()local g=a.p()local h=a.q()
local i=a.s()local j=a.t()local k=a.C()local l=peripheral.find('modem')b.load()
local m=b.get(b.settings.IO_INVENTORY)local n=settings.get(b.settings.
SYSTEM_INVENTORIES)if m==nil or not l.isPresentRemote(m)then m=j(g(l),
'Choose IO Inventory',e)b.set(b.settings.IO_INVENTORY,m)end if n==nil then n=i(
f(g(l),function(o,p)return p~=m end),'Select System Inventories',e)b.set(b.
settings.SYSTEM_INVENTORIES,n)end b.save()local o=c.ItemStorage(n)local p=c.
AutoCrafter(o,b.get(b.settings.PROCESSORS))local q=peripheral.find('monitor')q.
setTextScale(0.5)local r,s=term.getSize()local t=window.create(term.current(),1,
1,r,s-1,false)local u=c.StorageDisplay(q,{column_count=b.get(b.settings.
MONITORS_COLUMNS),index_justification=4})local v=c.StorageDisplay(t,{
column_count=2,index_justification=3})d.spawn(function()while true do o:
update_inventories()local w,x=term.getCursorPos()local y=o:
get_system_items_sorted()v:draw_item_cells(y)u:draw_item_cells(y)term.
setCursorPos(w,x)sleep(3)end end)h(p)parallel.waitForAny(k(l,m,o,p,t),d.
start_scheduler)