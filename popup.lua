local nowScene = ""
local mainScenes = {}
local scenes = {}
local eventSystem
-- local postfix = "popUp"

local function changeLayer(toScene, group)

  if nowScene==toScene then return end
	-- timer.performWithDelay( 1, function()
    print("hiding from "..nowScene.." to "..toScene)
    native.setKeyboardFocus( nil )
		
    eventSystem.event.group.off(nowScene.."-popUp")
    if scenes[#scenes-1].onHide then --!!! 
      scenes[#scenes-1].onHide()
    end
    
    nowScene = toScene
	-- end )
end 

local to = {}
to.removePop = function()
  if #scenes==1 then return end -- Если главное экран - ничего не делать

  local removingScene = scenes[#scenes]
  if removingScene.onHide then
    removingScene.onHide()
  end

  -- print("remove pop",removingScene.name)
  eventSystem.event.group.remove(removingScene.name.."-popUp")
  
  -- print("display remove",removingScene.group)
  display.remove(removingScene.group)
  -- print("{")
  -- for i=1, #scenes do
  --   print("   "..scenes[i].name)
  -- end
  -- print("}")
  -- print(#scenes)  
  scenes[#scenes] = nil
  
  
  nowScene = scenes[#scenes].name
  eventSystem.event.group.on(nowScene.."-popUp")
  -- print("PopUp buttons on "..nowScene.."-popUp")
  timer.performWithDelay( 1, function()

    native.setKeyboardFocus( nil )

  end )

  if scenes[#scenes].onShow then -- Если переход на главный экран - то
    scenes[#scenes].onShow()
  end
end

to.addMainScene = function( name, group, eventsFunction ) -- onHide, onShow, onPopUp
  if mainScenes[name]~=nil then error("Main scene '"..name.."' already exsist") end
  mainScenes[name] = eventsFunction or {}
  mainScenes[name].group = group
  mainScenes[name].name = name
  if nowScene=="" then nowScene=name scenes={mainScenes[name]} end
  print(scenes[1].name.." = {")
  for k, v in pairs(mainScenes) do
    print("  ",k,"!!",v.group)
  end
  print("}")
end

function to.getName( groupName )
  local i = 1
  local doo = true
  
  while doo do
    local noFound = true
    for j=1, #scenes do
      -- print(j.."# "..scenes[j].." /"..#scenes)
      if groupName..tostring(i) == scenes[j] then
        -- print("занято")
        i = i + 1
        noFound = false
        break
      end
    end
    if noFound then doo = false 
      -- print( groupName..tostring(i),"свободен")  
    end

  end
  return groupName..tostring(i)
end

function to.mainScene( name )
  for i=1, #scenes-1 do
    to.removePop()
  end
  -- print("hide main",scenes[1].name,scenes[1].group)
  if scenes[1].name==name then return end
  if scenes[1].onHide then scenes[1].onHide() end
  scenes[1].group.alpha = 0
  
  scenes[1] = mainScenes[name]
  print("change main to",name)
  scenes[1].group.alpha = 1
  if scenes[1].onShow then scenes[1].onShow() end
  nowScene = name
  -- downNavigateGroup.alpha = 1
end

function to.popUp( realName, group, eventsFunction )
  -- eventSystem.event.group.off(nowScene.."-popUp")
  scenes[1].group:insert(group)
  local NumName = to.getName( realName )
  
  if mainScenes[NumName]~=nil or mainScenes[realName]~=nil then error("PopUp has the same name with mainscen: "..realName) end
  
  scenes[#scenes+1] = eventsFunction or {}
  scenes[#scenes].name=NumName
  scenes[#scenes].group=group
  print("add scene", NumName, #scenes)
  
  changeLayer(NumName, group)
  eventSystem.event.group.add(NumName.."-popUp",{})

  return NumName.."-popUp"
end
function to.init(q)
  if eventSystem~=nil then error("Can use two eventSystem") end 
  eventSystem = q
end
function to.reset()
  print("reset")
  -- for i=1, #scenes-1 do
  --   print("removigPop",scenes[#scenes].name)
  --   to.removePop()
  -- end
  for k,v in pairs(mainScenes) do
    print("removig ",k,v)
    display.remove(v.group)
    eventSystem.event.group.remove(v.name.."-popUp")
  end
  eventSystem.event.clearAll()

  nowScene = ""
  -- mainScenes = nil
  mainScenes = {}
  scenes = {}
  -- eventSystem = ""
  eventSystem = nil
end


return to