local taskPath = system.pathForFile( "stats.json", system.DocumentsDirectory )
local accountPath = system.pathForFile( "user.json", system.DocumentsDirectory )
local usersPath = system.pathForFile( "users.json", system.DocumentsDirectory )
local json = require( "json" )
local crypto = require( "crypto" )

local round = function(num, idp)
  local mult = (10^(idp or 0))
  return math.floor(num * mult + 0.5) *(1/ mult)
end

local function CL(code)
  code = code:lower()
  code = code and string.gsub( code , "#", "") or "FFFFFFFF"
  code = string.gsub( code , " ", "")
  local colors = {1,1,1,1}
  while code:len() < 8 do
    code = code .. "F"
  end
  local r = tonumber( "0X" .. string.sub( code, 1, 2 ) )
  local g = tonumber( "0X" .. string.sub( code, 3, 4 ) )
  local b = tonumber( "0X" .. string.sub( code, 5, 6 ) )
  local a = tonumber( "0X" .. string.sub( code, 7, 8 ) )
  local colors = { r/255, g/255, b/255, a/255 }
  return colors
end

local function openFile(dir)
  local file = io.open( dir, "r" )
 
  local data
  if file then
    local contents = file:read( "*a" )
    io.close( file )
    data = json.decode( contents )
  end
  return data
end

local events = {list={},groups={}}

local function saveFile(data,dir)
  local file = io.open( dir, "w" )
 
  if file then
    file:write( json.encode( data ) )
    io.close( file )
  end
end

local timers = {tags={}}

local function onTimer(tag)
  timer.performWithDelay( timers[tag].time, timers[tag].func, timers[tag].cycle, tag )
end
local function jsonForUrl(jsonString)
  jsonString = jsonString:gsub("{","%%7b")
  jsonString = jsonString:gsub("}","%%7d")
  jsonString = jsonString:gsub(",", "%%2c")
  jsonString = jsonString:gsub(",", "%%2c")
  jsonString = jsonString:gsub(",", "%%2c")
  jsonString = jsonString:gsub(":", "%%3a")
  jsonString = jsonString:gsub("%[", "%%5b")
  jsonString = jsonString:gsub("%]", "%%5d")

  jsonString = jsonString:gsub("=", "-")
  jsonString = jsonString:gsub("-", "%%3d")
  return jsonString
end

local function printTable(val, name, skipnewlines, depth)
    skipnewlines = skipnewlines or false
    depth = depth or 0

    local tmp = string.rep(" ", depth)

    if name then
     if type(name)=="string" then name = '"'..name..'"' end
      tmp = tmp .. "[".. name .. "] = "
    end

    if type(val) == "table" then
        tmp = tmp .. "{" .. (not skipnewlines and "\n" or "")

        for k, v in pairs(val) do
            tmp =  tmp .. printTable(v, k, skipnewlines, depth + 1) .. "," .. (not skipnewlines and "\n" or "")
        end

        tmp = tmp .. string.rep(" ", depth) .. "}"
    elseif type(val) == "number" then
        tmp = tmp .. tostring(val)
    elseif type(val) == "string" then
        tmp = tmp .. string.format("%q", val)
    elseif type(val) == "boolean" then
        tmp = tmp .. (val and "true" or "false")
    else
        tmp = tmp .. "\"[inserializeable datatype:" .. type(val) .. "]\""
    end

    return tmp
end

local function groupAdd(groupName,mas)
  -- print("")
  if events[groupName]==nil then
    print("CREATE group - "..groupName)
    events.groups[#events.groups+1]=groupName
  else
    -- print("ADD TO group - "..groupName)
  end
  if type(mas)=="string" then
    print("ADD event '"..mas.."'")
    if events[groupName]~=nil then
      events[groupName][#events[groupName]+1]=mas
    else
      events[groupName]={mas}
    end
  else
    print("ADD {...} events")
    events[groupName]=mas
  end
  -- print("")
end
local isLocalBase = false
-- http://127.0.0.1/dashboard/newsDownload.php
local baseScriptsUrl = "http://127.0.0.1/dashboard/"

local a = math.random( 1000)
local base = {
  cx = round(display.contentCenterX),
  cy = round(display.contentCenterY),
  fullw  = round(display.actualContentWidth),
  fullh  = round(display.actualContentHeight),
  deleteFile = function(path,dir)
    return os.remove( system.pathForFile( path, dir ) )
  end,


  printTable = printTable,
  trim = function(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
  end,
  subBySpaces = function(str,raz)
    local mas = {}
    for token in string.gmatch(str, raz or "[^%s]+") do
      mas[#mas+1] = token
    end
    return mas
  end,

  jsonForUrl = jsonForUrl,
  options = options,
  hashText = function(text)
    return crypto.digest( crypto.sha512, text )
  end,
  -- copyToResources = function( path, name )
  --   local data = openFile(system.pathForFile( path, system.ResourceDirectory ))
  --   saveFile(data, system.pathForFile( name, system.ResourceDirectory ))
  -- end,
  getConnection = function( path, url, func,params, setLocalBase )
    local isLocalBase = setLocalBase or isLocalBase
    if isLocalBase then
      local file = io.open( system.pathForFile( path..".json", system.DocumentsDirectory ), "r" )
      
      local data
      if file then
        data = file:read( "*a" )
        io.close( file )

      else
        print(path.." not found. Create new")
        data = require("data."..path)

        local file = io.open( system.pathForFile( path..".json", system.DocumentsDirectory ), "w" )
   
        if file then
          file:write( data )
          io.close( file )
        end

      end 
      func({response=data})
    else
      local textParams =""
      if params~=nil then
        textParams = "?"
        for k, v in pairs(params) do 
          textParams = textParams..k.."="..v.."&"
        end
        textParams = textParams:sub(1,-2)
      end

      print('connecting to: '..baseScriptsUrl..url..textParams)
      network.request( baseScriptsUrl..url..textParams, "GET", func )
      return data
    end
  end,
  postConnection = function( path, val )
    local file = io.open( system.pathForFile( path..".json", system.DocumentsDirectory ), "w" )
 
    if file then
      file:write( json.encode( val ) )
      io.close( file )
    end
    return data
  end,

  CL = CL,
  div = function(num, hz)
    return num*(1/hz)-(num%hz)*(1/hz)
  end,
  getAngle = function(sx, sy, ax, ay)
    return (((math.atan2(sy - ay, sx - ax) *(1/ (math.pi *(1/ 180))) + 270) % 360))
  end,
  getCathetsLenght = function(hypotenuse, angle)
    angle = math.abs(angle*math.pi/180)
    local firstL = math.abs(hypotenuse*(math.sin(angle)))
    local secondL = math.abs(hypotenuse*(math.sin(90*math.pi/180-angle)))
    return firstL, secondL
  end,
  saveStats = function(infoTasks)
    saveFile(infoTasks, taskPath)
  end,
  loadStats = function()

    local infoTasks = openFile(taskPath)

    if ( infoTasks == nil or #infoTasks.levelStats == 0 ) then
      infoTasks = {lvl=1,levelStats={},xp=0, graf={} }
      for i=1, 1 do
        infoTasks.levelStats[i]={doneBestStep=false,doneBestCmd=false,done=false}
      end
      saveFile(infoTasks, taskPath)
    end
    return infoTasks
  end,
  saveLogin = function(account)
    saveFile(account, accountPath)
  end,
  loadLogin = function()

    local account = openFile(accountPath)

    if ( account == nil or account == {}) then
      account = {"",""}
      saveFile(account, accountPath)
    end
    return account
  end,
  saveUsers = function(users)
    saveFile(users, usersPath)
  end,
  loadUsers = function()
    local users = openFile(usersPath)

    if ( users == nil or #users == 0 ) then
      users = {
        [[{"id":"1","email":"user@gmail.com","name":"Софронов Александр Иннокентьевич","phonenumber":"","password":"12345678","working":"0","lic":"user","plan":"BASIC","signupdate":"3 May 2022","havejobdate":"{}"}]],
        [[{"id":"2","email":"worker@gmail.com","name":"Филиппов Егор Донатович","phonenumber":"","password":"12345678","working":"0","lic":"worker","plan":"VIP","signupdate":"3 May 2022","havejobdate":"{}"}]],
        [[{"id":"3","email":"admin@gmail.com","name":"Ершов Яков Лаврентьевич","phonenumber":"","password":"12345678","working":"0","lic":"user","plan":"BASIC","signupdate":"1 May 2022","havejobdate":"{}"}]],
      }
      -- users = {
      --   [[{"id":"1","email":"alex@gmail.com","name":"Софронов Александр Иннокентьевич","phonenumber":"","password":"12345678","working":"0","lic":"user","plan":"BASIC","signupdate":"3 May 2022","havejobdate":"{}"}]],
      --   [[{"id":"2","email":"egor@gmail.com","name":"Филиппов Егор Донатович","phonenumber":"","password":"12345678","working":"0","lic":"user","plan":"BASIC","signupdate":"3 May 2022","havejobdate":"{}"}]],
      --   [[{"id":"3","email":"yakov@gmail.com","name":"Ершов Яков Лаврентьевич","phonenumber":"","password":"12345678","working":"0","lic":"user","plan":"VIP","signupdate":"3 May 2022","havejobdate":"{}"}]],
      --   [[{"id":"4","email":"uriy@gmail.com","name":"Симонов Юрий Альвианович","phonenumber":"","password":"12345678","working":"0","lic":"worker","plan":"BASIC","signupdate":"3 May 2022","havejobdate":"{}"}]],
      --   [[{"id":"5","email":"mihail@gmail.com","name":"Владимиров Михаил Львович","phonenumber":"","password":"12345678","working":"0","lic":"worker","plan":"BASIC","signupdate":"3 May 2022","havejobdate":"{}"}]],
      --   [[{"id":"6","email":"bogdan@gmail.com","name":"Калашников Богдан Христофорович","phonenumber":"","password":"12345678","working":"0","lic":"admin","plan":"BASIC","signupdate":"3 May 2022","havejobdate":"{}"}]],
      -- }
      saveFile(users, usersPath)
    end
    return users
  end,
  printJson = function(var)
    print(json.encode(var))
  end,
  event = {
    clearAll = function()
      events = {list={},groups={}}
    end, 
    add = function(name, butt, funcc, group)
      if type(name)~="string" then error("Add event: bad argument #1 (string expected, got ".. type(name) ..")") end
      if events[name]~=nil then error("Add event: bad argument #1 (event ".. name .." already exist)") end
      if type(butt)~="table" then error("Add event: bad argument #2 (table expected, got ".. type(butt) ..")") end
      if type(funcc)~="function" then error("Add event: bad argument #3 (function expected, got ".. type(funcc) ..")") end

      if group then
        name = name.."_"..group
      end
      events.list[#events.list+1]=name
      events[name]={eventOn=false, but=butt, func=funcc}
      if group then
        groupAdd(group,name)
        return name
      end
    end,
    off = function(name, enable)
      if name==true then
        for i=1, #events.list do
          local event = events[events.list[i]]
          if event.eventOn==true then
            event.but:removeEventListener("tap", event.func)
          end
        end
      else
        local event = events[name]
        event.eventOn = enable or false
        event.but:removeEventListener("tap", event.func)
      end
    end,
    on = function(name, enable)
      if name==true then
        for i=1, #events.list do
          local event = events[events.list[i]]
          if event.eventOn==true then
            event.but:addEventListener("tap", event.func)
          end
        end
      else 
        local event = events[name]
        if event==nil then error("Enable event: event '"..name.."' not found)") end
        if event.but==nil then error("Enable event: button for '"..name.."' not found)") end
        if type(event.func)~="function" then error("Enable event: function for '"..name.."' not found)") end
        events.eventOn = enable or true
        event.but:addEventListener("tap", event.func)
      end
    end,
    remove = function(eventName,groupName)
      -- print("REMOVE event - "..eventName)

      local event = events[eventName]
      if event==nil then error("Remove event: bad argument #1 (event '"..eventName.."' not found)") end
      if event.eventOn then 
        event.but:removeEventListener("tap", event.func)
      end
      for i=1, #events.list do
        if events.list[i]==eventName then
          table.remove(events.list, i)
          break
        end
      end
      events[eventName] = nil

      if groupName==nil then return end
      if events[groupName]==nil then error("Remove event from group: bad argument #2 (group ".. groupName .." not exist)") end
      local found = false
      for i=1, #events[groupName] do
        if events[groupName][i]==eventName then
          table.remove(events[groupName], i)
          found = true
          break
        end
      end
      if found==false then error("Remove event from group: event '"..eventName.."' in '"..groupName.."' not found") end
      
    end,
    group = { 
      add = groupAdd,
      on = function(groupName, enable)
        if events[groupName]==nil then
          -- local text = "{\n"
          -- for k,v in pairs(events) do
          --   text = text.."  "..k..",\n"
          -- end
          -- print("Error: "..text.."\n}")
          error("Enable event group: bad argument #1 (group ".. groupName .." not exist)") 
        end
        -- print("is on now",groupName)
        for i=1, #events[groupName] do
          local name = events[groupName][i]
          local event = events[name]
          events.eventOn = enable or true
          -- print(name,"is on now")
          -- print(a.."#group "..groupName.." enable "..name)
          event.but:addEventListener("tap", event.func)
        end
      end,
      off = function(groupName, enable)
        if events[groupName]==nil then error("Disable event group: bad argument #1 (group ".. groupName .." not exist)") end
        for i=1, #events[groupName] do
          local name = events[groupName][i]
          local event = events[name]
          -- print(name,"is off now")
          event.eventOn = enable or false
          event.but:removeEventListener("tap", event.func)
        end
      end,
      remove = function(groupName)
        print("REMOVE group - "..groupName)
        if events[groupName]==nil then error("Remove event group: bad argument #1 (group ".. groupName .." not exist)") end
        -- print(printTable(events.groups))
        -- for i=1,#events.groups do
        --   print(events.groups[i].." = "..printTable(events[events.groups[i]]))
        -- end
        -- print(printTable(events.list))
        for i=1, #events[groupName] do
          local name = events[groupName][i]
          local event = events[name]
          if event==nil then error("Remove event group: event not found (".. name .." in " .. groupName..")") end
          if event.eventOn then 
            event.but:removeEventListener("tap", event.func)
          end
          for i=1, #events.list do
            if events.list[i]==name then
              table.remove(events.list, i)
              break
            end
          end
          events[name] = nil
        end
        events[groupName] = nil

        for i=1, #events.groups do
          if events.groups[i]==groupName then
            table.remove(events.groups, i)
            break
          end
        end
        -- print("===============>>>")
        -- print(printTable(events.groups))
        -- for i=1,#events.groups do
        --   print(events.groups[i].." = "..printTable(events[events.groups[i]]))
        -- end
        -- print(printTable(events.list))
        
      end
    }
  },
  timer = {
    add = function(tag, time, func, cycle)
      timers.tags[#timers.tags+1]=tag
      timers[tag] = {enabled=true, func=func, time=time, cycle = cycle or 1}

    end,
    restart = function(tag, sec)
      timer.cancel(tag)
      if sec then
        timers[tag].time=sec
      end
      onTimer(tag)
    end,
    remove = function(tag)
      timer.cancel(tag)
      timers[tag]=nil
      for i=1, #timers.tags do
        if timers.tags[i]==tag then
          table.remove(timers.tags, i)
          break
        end
      end
    end,
    off = function(tag, enable)
      if tag==true then
        for i=1, #timers.tags do
          local tag = timers.tags[i]
          if timers[tag].enabled==true then
            timer.cancel( tag )
          end
        end
      else
        timer.cancel( tag )
        timers[tag].enabled = enable or false
      end
    end,
    on = function(tag, enable)
      if tag==true then
        for i=1, #timers.tags do
          local tag = timers.tags[i]
          if timers[tag].enabled==true then
            onTimer(tag)
          end
        end
      else
        timers[tag].enabled = enable or true
        onTimer(tag)
      end
    end
  },
  round = round,
  emitters = {laserShip = EMshipLfire}
  }
return base
