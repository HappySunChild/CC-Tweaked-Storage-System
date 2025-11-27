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
local function h(i,j)local k={}for l,m in next,i.patterns do if m.results[j]~=
nil then table.insert(k,m)end end return k end local function i(j,k)local l={}
for m,n in next,j.input_slots do local o,p=n[1],n[2]l[p]=(l[p]or 0)+(o*k)end
return l end local function j(k)local l=0 for m,n in next,k.results do l=l+n end
return l end local k={add_processor=function(k,l,m)if not peripheral.isPresent(l
)then error(d:format(l),2)end k._processors[l]={patterns=m,active=false}end,
remove_processor=function(k,l)k._processors[l]=nil end,is_processor_available=
function(k,l)local m=k._processors[l]if m==nil then error(e:format(l))end return
not m.active end,get_available_processors=function(k,l)local m={}for n,o in next
,k._processors do if k:is_processor_available(n)and#h(o,l)>0 then table.insert(m
,n)end end return m end,get_missing_ingredients=function(k,l,m)local n=k._system
:get_system_items()local o={}for p,q in next,i(l,m)do local r=n[p]if r==nil or r
<q then table.insert(o,p)end end return o end,start_process_async=function(k,l,m
,n)local o=k._processors[l]if o==nil then error(e:format(l),2)end if o.active
then error(g:format(l),2)end if c(o.patterns,m)==nil then error(f:format(l),2)
end local p=k._system local q=1/m.poll_rate local r=j(m)local s=k:
get_missing_ingredients(m,n)if#s>0 then error(table.concat(s,', '))end local t=m
.input_slots local u=m.output_slots o.active=true for v=1,n do for w,x in next,t
do local y,z=x[1],x[2]p:export_item(z,l,w,y)end p:update_inventories()local w=r
while w>0 do sleep(q)for x,y in next,u do local z=p:import_from_slot(l,y)w=w-z
end end end o.active=false end}local l={__index=k}local function m(n,o)local p=
setmetatable({_system=n,_processors={}},l)for q,r in next,o do p:add_processor(q
,r)end return p end return m end function a.c()local c=a.cache.c if not c then c
={c=b()}a.cache.c=c end return c.c end end do local function b()local c={'K','M'
,'B','T','Qa','Qi','Sx','Sp','Oc','No','Dc'}local function d(e)if e<1000 then
return tostring(e)end local f=math.floor(math.log(e+1,10)/3)local g=c[f]if g==
nil then g='!?'end return string.format('%.1f%s',e/10^(f*3),g)end return d end
function a.d()local c=a.cache.d if not c then c={c=b()}a.cache.d=c end return c.
c end end do local function b()local function c(d,e)local f=math.abs(e)-#d local
g=string.rep(' ',f)if e<0 then return g..d end return d..g end return c end
function a.e()local c=a.cache.e if not c then c={c=b()}a.cache.e=c end return c.
c end end do local function b()local function c(d,e,f)return d,string.rep(e,#d),
string.rep(f,#d)end return c end function a.f()local c=a.cache.f if not c then c
={c=b()}a.cache.f=c end return c.c end end do local function b()local function c
(d,e)if#d<=e then return d end return(d:sub(1,math.max(e-3,1)):gsub('%s*$','')..
'...'):sub(1,e)end return c end function a.g()local c=a.cache.g if not c then c=
{c=b()}a.cache.g=c end return c.c end end do local function b()local c=a.d()
local d=a.a()local e=a.e()local f=a.f()local g=a.g()local h='%d. 'local i=' |%s'
local j={reconfigure=function(j,k)j.config=k end,draw_item_cells=function(j,k)
local l=j.redirect local m,n=l.getSize()local o=j.config local p=o.column_count
local q=colors.toBlit(o.index_text_color)local r=colors.toBlit(o.name_text_color
)local s=colors.toBlit(o.count_text_color)local t=colors.toBlit(o.
cell_background_color)local u=colors.toBlit(o.cell_alt_background_color)local v=
math.floor(m/p)-1 local w=(m%p)+1 l.clear()for x,y in next,k do local z=math.
floor((x-1)/n)local A=(x-1)%n+1 local B=z*(v+1)+1 if z>=p then break end local C
=(A+z)%2==0 and u or t local D=e(h:format(x),-o.index_justification)local E=i:
format(e(c(y.count),-o.count_justification))local F=v-#D-#E if z+1>=p then F=F+w
end local G=e(g(d(y.name),F),F)l.setCursorPos(B,A)l.blit(f(D,q,C))l.blit(f(G,r,C
))l.blit(f(E,s,C))end end}local k={__index=j}local function l(m,n)local o=
setmetatable({redirect=m,config=n},k)return o end return l end function a.h()
local c=a.cache.h if not c then c={c=b()}a.cache.h=c end return c.c end end do
local function b()local c='Unable to find peripheral "%s"'local d=
'Peripheral "%s" is not a valid inventory!'local e=
'Unable to find inventory "%s", is it being tracked?'local f=
[[Unable to find items for inventory "%s", did you update the cache?]]
local function g(h)local i=peripheral.wrap(h)if i==nil then error(c:format(h),2)
end if i.list==nil then error(d:format(h),2)end return i end local function h(i,
j)return i.count>j.count end local i={track_inventory=function(i,j)i.inventories
[j]=g(j)end,untrack_inventory=function(i,j)i.inventories[j]=nil end,
update_inventories=function(i)for j,k in next,i.inventories do i._item_cache[j]=
k.list()end end,get_system_size=function(i)local j=0 for k,l in next,i.
inventories do j=j+l.size()end return j end,get_system_items=function(i)local j=
{}for k,l in next,i._item_cache do for m,n in next,l do local o=n.name local p=n
.count j[o]=(j[o]or 0)+p end end return j end,get_system_items_sorted=function(i
,j)local k={}for l,m in next,i:get_system_items()do table.insert(k,{name=l,count
=m})end table.sort(k,j or h)return k end,find_item=function(i,j)local k=nil
local l=nil return function()for m,n in next,i._item_cache,k do for o,p in next,
n,l do l=o if p.name==j then return m,o,p end end k=m l=nil end return nil,nil,
nil end end,pull_items=function(i,j,k,l,m,n)local o=i.inventories[l]if o==nil
then error(e:format(l),2)end return o.pullItems(j,k,n,m)end,push_items=function(
i,j,k,l,m,n)local o=i.inventories[j]if o==nil then error(e:format(j),2)end
return o.pushItems(l,k,n,m)end,import_from_slot=function(i,j,k,l)local m=next(i.
inventories)if m==nil then return 0 end local n=0 while true do local o=l and l-
n or nil local p=i:pull_items(j,k,m,nil,o)n=n+p if l==nil or n>=l then break end
if p==0 then m=next(i.inventories,m)if m==nil then break end end end return n
end,import_item=function(i,j,k,l)local m=0 local n=g(k)for o,p in next,n.list()
do if p.name==j then local q=l and l-m or p.count local r=i:import_from_slot(k,o
,math.min(q,p.count))m=m+r if l==nil or m>=l or r==0 then break end end end
return m end,export_item=function(i,j,k,l,m)local n=0 for o,p in i:find_item(j)
do local q=m~=nil and m-n or nil local r=i:push_items(o,p,k,l,q)n=n+r if m==nil
or n>=m then break end end return n end}local j={__index=i}local function k(l)
local m=setmetatable({inventories={},_item_cache={}},j)if l~=nil then for n,o in
next,l do m:track_inventory(o)end end return m end return k end function a.i()
local c=a.cache.i if not c then c={c=b()}a.cache.i=c end return c.c end end do
local function b()local c={AutoProcessing=a.c(),StorageDisplay=a.h(),
StorageSystem=a.i()}return c end function a.j()local c=a.cache.j if not c then c
={c=b()}a.cache.j=c end return c.c end end do local function b()local function c
(d,e)local f={}for g,h in next,d do if e(g,h)then if type(g)=='number'then table
.insert(f,h)else f[g]=h end end end return f end return c end function a.k()
local c=a.cache.k if not c then c={c=b()}a.cache.k=c end return c.c end end do
local function b()local function c(d)local e={}for f,g in next,d do e[f]=g end
return e end return c end function a.l()local c=a.cache.l if not c then c={c=b()
}a.cache.l=c end return c.c end end do local function b()local c=a.l()
local function d(e,f,g,h)local i=h or 1 local j,k=term.getSize()local l=k-4
local m=math.ceil(#e/l)while true do term.clear()term.setCursorPos(1,1)term.
write(f)local n=math.ceil(i/l)local o=(n-1)*l+1 local p=math.min(o+l-1,#e)for q=
o,p do local r=e[q]local s=g(tostring(r),q,i)term.setCursorPos(1,(q-o)+3)term.
write(s)end term.setCursorPos(1,k)term.write(string.format('Page %d/%d',n,m))
local q,r=os.pullEvent('key')if r==keys.up then i=math.max(i-1,1)elseif r==keys.
left then i=math.max(i-l,1)elseif r==keys.down then i=math.min(i+1,#e)elseif r==
keys.right then i=math.min(i+l,#e)elseif r==keys.enter then break end end return
i end return{checkbox_list=function(e,f,g)local h={}local i=nil local j=c(e)
table.insert(j,'')local k=#j while true do local l=d(j,f,function(l,m,n)local o=
m==n if m==k then return string.format('%s Done',o and'>'or' ')end local p=h[m]
~=nil local q=g and g(l)or l return string.format('%s [%s] %s',o and'>'or' ',p
and'x'or' ',q)end,i)if l==k then break end i=l h[l]=not h[l]and true or nil end
local l={}for m in next,h do table.insert(l,e[m])end return l end,choice_list=
function(e,f,g)local h=d(e,f,function(h,i,j)local k=g and g(h)or h local l=i==j
return string.format('%s %s',l and'>'or' ',k)end)return e[h],h end,text_page=
function(e,f,g)local h,i=term.getSize()term.clear()term.setCursorPos(1,1)term.
write(e)if f~=nil then term.setTextColor(colors.lightGray)term.setCursorPos(1,i)
term.write(f)term.setTextColor(colors.white)end term.setCursorPos(1,3)term.
write('$ ')return read(nil,nil,g)end}end function a.m()local c=a.cache.m if not
c then c={c=b()}a.cache.m=c end return c.c end end end local b=require(
'cc/completion')local c=a.a()local d=a.j()local e=a.k()local f=a.m()local g=
peripheral.find('modem')local h=peripheral.find('monitor')h.setTextScale(0.5)
local function i()local j={}for k,l in ipairs(g.getNamesRemote())do if
peripheral.hasType(l,'inventory')then table.insert(j,l)end end table.sort(j)
return j end local j=nil if j==nil or not g.isPresentRemote(j)then j=f.
choice_list(i(),'Choose IO Inventory',c)end local k=f.checkbox_list(e(i(),
function(k,l)return l~=j end),'Select System Inventories',c)local l=d.
StorageSystem(k)local m=d.StorageDisplay(h,{column_count=1,count_justification=4
,index_justification=4,cell_background_color=colors.black,
cell_alt_background_color=colors.gray,index_text_color=colors.lightBlue,
name_text_color=colors.white,count_text_color=colors.pink})local function n(o,p)
local q=nil local r=math.huge for s,t in ipairs(o)do local u=string.find(t,p)if
u and u<r then r=u q=t end end return q end local function o(p)local q={}for r
in next,l:get_system_items()do local s,t=string.find(r,p)if t~=nil then table.
insert(q,{name=r,index=t})end end table.sort(q,function(r,s)return r.index<s.
index end)local r={}for s,t in ipairs(q)do table.insert(r,t.name:sub(t.index,-1)
)end table.insert(r,'exit')return b.choice(p,r,false)end local function p()
local function q()local r=f.text_page('Storage System Output',
"'exit' to return to menu",o)if r=='exit'then return true end local s=l:
get_system_items()local t={}for u in next,s do table.insert(t,u)end local u=n(t,
r)if u==nil then printError(string.format("Unable to find '%s'",r))os.pullEvent(
'key')os.pullEvent('key_up')return false end local v=f.text_page(string.format(
'Item Count - %s | %d in system',c(u),s[u]),"'cancel' to restart")if v=='cancel'
then return false end local w=tonumber(v)or 64 local x=l:export_item(u,j,nil,w)
print(string.format('Successfully transferred %d items.',x))os.pullEvent('key')
os.pullEvent('key_up')end while not q()do end end local function q()local r,s=f.
choice_list({'yesss!!!!!!','wait nvm'},'Storage System Input - Are you sure?')if
s==2 then return end term.clear()term.setCursorPos(1,1)local t=peripheral.wrap(j
)for u in next,t.list()do local v=l:import_from_slot(j,u)print(string.format(
'Successfully transferred %d items from slot %d.',v,u))end print('Done!')os.
pullEvent('key')os.pullEvent('key_up')end local function r()local s={'Craft',
'Configure','Exit'}while true do local t,u=f.choice_list(s,
'Auto Processing Menu')if u==3 then break end end end local function s()local t=
{'Output from Storage','Input to Storage','Auto Processing'}while true do local
u,v=f.choice_list(t,'Storage IO Menu')if v==1 then p()elseif v==2 then q()elseif
v==3 then r()end end end local function t()while true do local u,v=os.pullEvent(
'processing_job')print(v)end end local function u()while true do l:
update_inventories()m:draw_item_cells(l:get_system_items_sorted())sleep(5)end
end parallel.waitForAll(s,t,u)