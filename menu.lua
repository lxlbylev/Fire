--[[
main-file
local composer = require( "composer" )
display.setStatusBar( display.HiddenStatusBar )
math.randomseed( os.time() )
composer.gotoScene( "menu" )
--]]
local composer = require( "composer" )
local scene = composer.newScene()

local widget = require( "widget" )

local androidFilePicker = require "plugin.androidFilePicker"

local tile = require( "tilebg" )

-- local googleSignIn
-- local androidClientID = "157948540483-bq1ivqmrt0q1l4vonaqkhv75p7fsle3r.apps.googleusercontent.com"
-- if isDevice then  
--   googleSignIn = require( "plugin.googleSignIn" )
--   googleSignIn.init({
--   ios={
--       clientId = androidClientID
--   },
--   android={
--       clientId = androidClientID,
--       scopes= {"https://www.googleapis.com/auth/drive.appdata"}
--   }
--   })
-- end
-- local roundedRectAndShadow = require( "shadowRR" )

-- local isDevice = (system.getInfo("environment") == "device")

local allInstaPost = {}

local backGroup

local mainGroup
local topMain

local subGroup
local fireGroup
local streamGroup
local profileGroup

local uiGroup


local q = require("base")
local chat = require("chat")

local json = require( "json" )
local server = "127.0.0.1"


local c = {
  backGround = {.97},
  text1 = {0},
  invtext1 = {1},
  mainButtons = {1},
  hideButtons = {1,0,0,.01},

	black = q.CL"000000",
	gray = q.CL"808080",
	gray2 = q.CL"DEDEDE",
	buttons = q.CL"ADB5BD",
	prewhite = q.CL"F9FAFB",
	ultrablack = q.CL"CCCCCC",
	outline = q.CL"9F9F9F",
	white = q.CL"FFFFFF",
	
  appColor = q.CL"FD4801",
}

-- local c = {
--   backGround = {.03},
--   text1 = {.97},
--   invtext1 = {.03},
--   mainButtons = q.CL"ADB5BD",

--   buttons = q.CL"ADB5BD",
--   mainButtons = q.CL"ADB5BD",
--   appColor = q.CL"0058EE",
-- }

local searchField
local toBotField
local menuButton, newsButton, chatButton, profileButton
local inNewsOverlay
local downNavigateGroup, upNavigateGroup


local closePCMenu = function() end

local pps = require"popup"
pps.init(q) -- popUp system


-- ========== --
-- ========== --
-- ========== --

local function menuButtonsListener( event )
  pps.mainScene(event.target.name)
end
-- -- --

local function textWithLetterSpacing(options, space, anchorX)
	space = space*.01 + 1
	if options.color==nil then options.color={1,1,1} end

	local j = 0
	local text = options.text 
	local width = 0
	local textGroup = display.newGroup()
	options.parent:insert(textGroup)
	for i=1, #text:gsub('[\128-\191]', '') do
		local char = text:sub(i+j,i+j+1)
    local bytes = {string.byte(char,1,#char)}

    if bytes[1]==208 or bytes[1]==209 then -- for russian char
      char = text:sub(i+j,i+j+1)
      j=j+1
    else  -- for english char
      char = char:sub(1,1)
    end
		local charLabel = display.newText( textGroup, char, options.x+width, options.y, options.font, options.fontSize )
		charLabel.anchorX=0
		width = width + (charLabel.width-1.5)*space
		charLabel:setFillColor( unpack(options.color) )
	end
	if anchorX then
		textGroup.x = -width*(anchorX)
	end
  return textGroup
end

local incorrectChange
local function showPassWarning(text, time)
  timer.cancel( "passwarn" )
  transition.cancel( "passwarn" )
  
  time = time~=nil and time or 2000
  incorrectChange.text=text
  incorrectChange.alpha=1
  incorrectChange.fill.a=1
  timer.performWithDelay( time, 
  function()
    transition.to(incorrectChange.fill,{a=0,time=500, tag="passwarn"} )
  end, 1, "passwarn")
end
local function changeResponder(event)
  if ( event.isError) then
    print( "Change password server error:", event.response)
  else
    local myNewData = event.response
    -- print("Server:"..myNewData)
    if myNewData=="Incorrect\n\n\n" then
      showPassWarning("Текущий пароль не верен")
    elseif myNewData=="PasswordChanged\n\n\n" then
      -- showPassWarning("Пароль изменён успешно!")
      closePCMenu()
    else
    -- elseif myNewData=="User not found\n\n\n" then
      showPassWarning("Упс.. Что-то пошло не так")
    end

  end
end

local function line(group, y, width, stroke, color)
  local line = display.newRoundedRect(group, q.cx, y, width or (q.fullw-110), stroke or (3*2), 50 )
  line.fill = color or q.CL"EEEEEE"
  return line
end



local function getLabelSize(options)
  -- print(options)
  local label = display.newText(options)
  local width = label.width
  local height = label.height
  display.remove(label)
  return width, height
end


local submitButton
local jsonLink = "https://api.jsonstorage.net/v1/json/7258cfc4-e9f4-4045-be0a-9179b1ee9d45/fee33a78-f8ae-4524-b75c-e7e96bfdfcf1"
local apiKey = "602b9c9c-acc1-4cb5-a412-8200236660e4"
local allUsers
local function patchResponse( event )
  if ( event.isError)  then
    print( "Error!" )
  else
    local myNewData = event.response
    if myNewData==nil or myNewData=="[]" or myNewData=="" then
      print("Server patch: нет ответа")
      return
    elseif myNewData:sub(1,3)=='{"u' then
      print("Server patch: успешно")
      -- hideMain()
      -- handleResponse()
    end
    print(myNewData)
  end
end
local function patcher( patch )
  print(patch)
  network.request( jsonLink.."?apiKey="..apiKey, "PATCH", patchResponse, {
    headers = {
      ["Content-Type"] = "application/json"
    },
    body = patch,
    bodyType = "text",
  } )
end

local function submitFunc(event)
  if finished then
    composer.gotoScene("signin")
    return
  end
  submitButton.fill = q.CL"4d327a"
  local r,g,b = unpack( c.appColor )
  timer.performWithDelay( 400, 
  function()
    transition.to(submitButton.fill,{r=r,g=g,b=b,time=300} )
  end)

  local email, pass, name = firldsTable.email.text, firldsTable.pass.text, firldsTable.name.text
  -- print(email, pass, name)
  local allows, errorMail = validemail(email)
  if not allows then
    showWarnin(errorMail and errorMail or "mail")
  elseif allUsers[email]~=nil then
    showWarnin("Аккаунт с этой почтой ужу сущетсвует")
  elseif #pass==0 then
    showWarnin("Введите пароль")
  elseif #pass<8 then
    showWarnin("Пароль от 8 символов")
  else
    local signupdate = os.date("!*t",os.time())
    signupdate = signupdate.day.."."..os.date("%m",os.time()).."."..signupdate.year

    local user = {}
    user[email] = {
      password = pass,
      name = name,
      signupdate = signupdate
    }

    patcher( json.encode(user) )
    -- network.request( "http://127.0.0.1/dashboard/register.php?email="..email.."&password="..pass.."&date="..time..name, "GET", handleResponse )
  end
end

local createAllInstaPost
local function loadAllUsers( event )
  if ( event.isError)  then
    print( "Error!", event.response)
    return false
  else
    local myNewData = event.response
    if myNewData==nil or myNewData=="[]" then
      print("Server read: нет ответа")
      return false
    end
    -- print(myNewData)
    allUsers = json.decode(myNewData)
    createAllInstaPost()

  end
  return true
end


local function getButtonsInfo( vuzes, grouped )
  local buttonsInfo = {}
  for index, vuz in pairs(vuzes) do
    for i=1, #vuz.sortedSpec do
      local sorted = vuz.sortedSpec[i]
      local specNum = sorted.specNum
      local to = (grouped and specNum or #buttonsInfo+1)
      
      if buttonsInfo[to]==nil then

        local minBudget = payMin(sorted.ball.middleBudgetOchno, sorted.ball.middleBudgetZaochno)
        local minPlatno = payMin(sorted.ball.middlePlatnoOchno, sorted.ball.middlePlatnoZaochno)

        buttonsInfo[to] = {
          miniLogo = "img/icon/vuzes/"..vuz.nameEn..".png",
          label = allSpec[specNum],
          specNum = specNum,
          vuzes = {vuz.nameShortRu, eng=vuz.nameEn},
          specPhoto = (grouped and "img/spec/".. specNum:gsub("%.","/")..".png" or "img/kolledg/"..vuz.nameEn..".png"),
          specPhotoFill = nil,
          budget = {
            mest = sorted.mest.budget,
            ball = minBudget,
          },
          platno = {
            mest = sorted.mest.platno,
            ball = minPlatno,
          },
          pay = payMin(sorted.pay.ochno, sorted.pay.zaochno)
        }
      else
        local mas = buttonsInfo[to] 
        mas.miniLogo = "img/icon/chemodan.png"
        mas.vuzes[#mas.vuzes+1] = vuz.nameEn

        mas.pay = payMin(mas.pay, sorted.pay.ochno, sorted.pay.zaochno)

        if sorted.mest.budget then
          mas.budget.mest = tostring(tonumber(mas.budget.mest or 0) + tonumber(sorted.mest.budget))
        end
        if sorted.mest.platno then
          mas.platno.mest = tostring(tonumber(mas.platno.mest or 0) + tonumber(sorted.mest.platno)) 
        end

        local minBudget = payMin(sorted.ball.middleBudgetOchno, sorted.ball.middleBudgetZaochno)
        if minBudget then
          mas.budget.ball = tostring(math.min(tonumber((mas.budget.ball~=nil) and mas.budget.ball or 10000),tonumber(minBudget))) 
        end

        local minPlatno = payMin(sorted.ball.middlePlatnoOchno, sorted.ball.middlePlatnoZaochno)
        if minPlatno then
          mas.platno.ball = tostring(math.min(tonumber((mas.platno.ball~=nil) and mas.platno.ball or 10000),tonumber(minPlatno)))
        end
      end
      
    
    end
  end
  return buttonsInfo
end

local function generateButtonWithLogo(options)
  if options.textWidth==nil then
    options.textWidth = getLabelSize({
      font = "mont_sb",
      fontSize = 18*2,
      text = options.text1
    })
  end
  local group = display.newGroup( )
  if options.parent then
    options.parent:insert(group)
  end
  group.x = options.x
  group.y = options.y

  local text = {
    font = "mont_sb",
    fontSize = 18*2,
  }
  -- local back = roundedRectAndShadow({
  --   parent = group, 
  --   x = 0, 
  --   y = 0, 
  --   width = 140+math.ceil(options.textWidth), 
  --   height = 66*2,
  --   shadeWidth = 7,
  --   cornerRadius = 12*2, 
  --   anchorX = 0, 
  --   anchorY = 0,
  --   color = options.backColor,
  -- })
  -- group.back = back
  local back = display.newRoundedRect( group, 0, 0, 140+math.ceil(options.textWidth), 66*2, 12*2 )
  back.anchorX = 0
  back.anchorY = 0
  back:setStrokeColor( 0,0,0,.1 )
  back.strokeWidth = 3
  back.fill = c.mainButtons
  group.back = back

  local icon = display.newImageRect(group, options.imagePath or "img/search.png", 80, 80 )
  icon.x, icon.y = back.x, back.height*.5
  icon.anchorX = 0
  icon.x = icon.x + 20


  text.parent = group
  text.x = icon.x + icon.width + 15
  text.y = icon.y - 20
  text.align = "left"

  local label = display.newParagraph(options.text1:gsub("\n"," \n "), 60,{
    lineHeight = 1,
    font = "mont_sb",
    size = text.fontSize,
    align = "left",
    color = options.textColor or{0,0,0}
  })
  group:insert( label )
  label.x = text.x
  label.y = text.y - label.height*.5 - 30


  -- text.text = options.text2
  -- text.y = text.y + label.height*.5 + 15
  -- text.font = "mont_m.ttf"
  -- local label = display.newText(text)
  -- label:setFillColor(0)
  -- label.anchorX = 0
  -- label.alpha = .35

  return group
end

local function generateGroupedWikiButtons(options)

  local group = display.newGroup()
  options.parent:insert(group)
  group.y = options.y

  local bufferX = 35
  local bufferY = 30
  local startX = 0 + bufferX
  
  local height = 66*2

  local lastX = startX
  local lastY = 0
  local buttons = {}
  for k, v in pairs(options.buttons) do
    local text = v.label

    local textWidth = getLabelSize({
      font = "mont_sb",
      fontSize = 18*2,
      text = text
    })
    if (lastX + textWidth) >= (q.fullw - bufferX*2) then
      lastX = startX
      lastY = lastY + height + bufferY
    end
    local button = generateButtonWithLogo({
      parent = group,
      x = lastX,
      y = lastY,
      text1 = text,
      imagePath = v.imagePath,
      textWidth = textWidth,
    })
    button.adress = v.adress
    buttons[k] = button
    -- button.specName = v
    -- q.event.add("to"..(v:upper()).."_"..info.name, button, openGroupSpec, "menu-popUp" )
   
    lastX = lastX + (140 + math.ceil(textWidth)) + bufferX
  end

  local scrollEndPoint = display.newRect(group, q.cx, lastY+320, 20, 20)

  return group, buttons
end
local function generateInteristingButton(options)

  local group = display.newGroup()
  options.parent:insert(group)
  group.y = options.y

  local bufferX = 35
  local bufferY = 30
  local startX = 0 + bufferX
  
  local height = 66*2

  local lastX = startX
  local lastY = 0 - height - bufferY
  local buttons = {}
  for k, v in pairs(options.buttons) do
    local text = v.label

    local textWidth = getLabelSize({
      font = "mont_sb",
      fontSize = 18*2,
      text = text
    })
    -- if (lastX + textWidth) >= (q.fullw - bufferX*2) then
      lastX = startX
      lastY = lastY + height + bufferY
    -- end
    local button = generateButtonWithLogo({
      parent = group,
      x = lastX,
      y = lastY,
      text1 = text,
      imagePath = v.imagePath,
      textWidth = q.fullw-210,
    })
    button.adress = v.adress
    buttons[k] = button
    -- button.specName = v
    -- q.event.add("to"..(v:upper()).."_"..info.name, button, openGroupSpec, "menu-popUp" )
   
    lastX = lastX + (140 + math.ceil(textWidth)) + bufferX
  end

  local scrollEndPoint = display.newRect(group, q.cx, lastY+320, 20, 20)
  scrollEndPoint.alpha = .01

  return group, buttons
end

---------------------

local account
local myID, toID, id1, id2, myI

local function htmlRead(text)
  text = text:gsub("<b>","")
  text = text:gsub("</b>","")
  text = text:gsub("<br>","\n")
  text = text:gsub("<br />","")
  print("response:\n"..text)
  return text
end

local function drawInMsg(event)
  if ( event.isError)  then
    print( "Messager load error:", event.response)
    return
  end

  local myNewData = event.response
  -- htmlRead(myNewData)
  -- if text~="[]" then
  --   error(text)
  -- end
  -- print( "response:", myNewData:gsub("<br>","\n"))
  local msg = json.decode( myNewData ) or {}
  local msgIn = {}
  for k,v in pairs(msg) do
    msgIn[tonumber(k)] = v
  end
  for k,v in pairs(msgIn) do
    msgIn[k].fromYou = false
    msgIn[k].i = nil
  end
  -- print( "response:", q.printTable(msgIn))
  
  for k,msg in pairs(msgIn) do
    chat.addMsg(msg)
  end
end

local allChats = {}
local drawChatlist
local function openChat(event)
  -- print("open chat")
  local params = event.target.params
  
  myID = account.id
  toID = params.id
  local my,toID = tonumber( account.id ), tonumber( params.id )
  id1 = tostring(math.min(my,toID))
  id2 = tostring(math.max(my,toID))
  myI = (myID==id1) and 1 or 2
  
  local chatGroup = display.newGroup()
  local eventGroupName = pps.popUp("chatWith"..toID, chatGroup, {
    onHide=function()
    drawChatlist()

    downNavigateGroup.alpha = 1
  end})
  downNavigateGroup.alpha = 0


  local back = display.newRect(chatGroup, q.cx, q.cy, q.fullw, q.fullh)

  -- q.timer.add("updateChat", 1500, function()

  --   q.getConnection("","profine/timerinmsg.php", drawInMsg, {
  --     roomid = params.roomid,
  --     id = account.id,
  --     -- hasedPassword = account.hasedPassword,
  --     hasedPassword = "fa585d89c851dd338a70dcf535aa2a92fee7836dd6aff1226583e88e0996293f16bc009c652826e0fc5c706695a03cddce372f139eff4d13959da6f1f5d3eabe",
  --   })    
  
  -- end, 0) 
  -- q.timer.on"updateChat"

  local scrollView = widget.newScrollView(
    {
      top = 150,
      left = 0,
      width = q.fullw,
      height = q.fullh-200 -100,
      scrollWidth = 0,
      scrollHeight = 0,
      horizontalScrollDisabled = true,
      -- verticalScrollDisabled = true,
      hideBackground = true,
    }
  )
  chatGroup:insert(scrollView)

  display.remove(msgGroup)
  msgGroup = display.newGroup()
  scrollView:insert(msgGroup)

  chat.init(msgGroup,0)
  for i=1, #params.msg do
    chat.addMsg(params.msg[i])
  end

  local keyboardOffset = 165
  local inTextGroup = display.newGroup()
  chatGroup:insert(inTextGroup)
  inTextGroup.y = q.fullh - 30
  inTextGroup.startY = inTextGroup.y

  local back = display.newRect( chatGroup, q.cx, 0, q.fullw, 120)
  back.anchorY = 0
  back:setFillColor( unpack(c.appColor) )
  back.alpha = .9

  local backImage = display.newImageRect( chatGroup, "img/back_arrow.png", 55, 60 ) 
  backImage.x, backImage.y = 40, back.height*.5
  backImage.anchorX=0
  q.event.add("backToListFrom"..params.id, backImage, pps.removePop, eventGroupName)
  -- backImage.anchorY=0

  local userImage = display.newCircle( chatGroup, 35+100, (back.height*.5-40), 40 ) 
  userImage.anchorX=0
  userImage.anchorY=0
  userImage.fill = {
    type = "image",
    -- filename = info.postedBy.image,
    filename = "img/profile_photo.png",
  }

  local userName = q.subBySpaces(params.name)
  userName = (#userName==1) and userName[1] or (userName[1].." "..userName[2])

  local userName = display.newText({
    parent = chatGroup,
    text = userName,
    x = userImage.x+userImage.width+20,
    y = userImage.y+userImage.height*.5,
    font = "ubuntu_m.ttf",
    fontSize = 13*2,
    })
  userName.anchorX = 0
  userName.anchorY = 1
  -- userName:setFillColor( unpack(c.text1) )
  userName:setFillColor( unpack(c.invtext1) )
  
  local onlineLabel = display.newText({
    parent = chatGroup,
    text = "Офлайн",
    x = userName.x,
    y = userName.y,
    font = "ubuntu_m.ttf",
    fontSize = 13*2,
    })
  onlineLabel.anchorX = 0
  onlineLabel.anchorY = 0
  onlineLabel:setFillColor( unpack(c.invtext1) )
  -- onlineLabel.alpha = .8


  local rounded = display.newRoundedRect( inTextGroup, 30, 0, q.fullw-170, 90, 30 )
  rounded.anchorX = 0
  rounded.anchorY = 1
  rounded.fill = c.gray2

  local send = display.newRoundedRect( inTextGroup, rounded.x+rounded.width+20, 0, q.fullw-(rounded.x+rounded.width+20*2), 90, 40 )
  send.anchorX = 0
  send.anchorY = 1
  send.fill = c.appColor
 

  local scrollChatOn = false
  
  local function moveFieldsDown()
    timer.performWithDelay(100, function()
      transition.to( inTextGroup, { time=200, y=inTextGroup.startY} )
    end)
  end
  local function moveFieldsUp()
    transition.to( inTextGroup, { time=200, y=q.fullh-keyboardOffset-150-200+20} )
  end

  local toBotField
  q.event.add("sendMsg", send, function()
    local text = q.trim(toBotField.text)
    -- print("press",text,text~="")

    if text~="" then 
      
        
      local my,to = tonumber( account.id ), tonumber( params.id )
      local id = {
        tostring(math.min(my,to)),
        tostring(math.max(my,to)),
      }
      moveFieldsDown()
      native.setKeyboardFocus( nil )
      
      -- local thisChatI 
      for i=1, #allChats do
        if allChats[i].roomid == params.roomid then
          local myChat = allChats[i]
          myChat.msg[#myChat.msg+1] = {
            date = tostring(os.time()),
            text = text,
            fromYou = true,
          }
          break
        end
      end
      -- for i=1, #allChats do
      --   allChats[tostring(i)] = allChats[i]
      --   allChats[i] = nil
      -- end      
      allChats.ready = true
      -- print("toSave")
      -- print(q.printTable(allChats))
      chat.addMsg({fromYou=true,text = text})
      toBotField.text = ""
      native.setKeyboardFocus( nil )
      q.postConnection("chats",allChats)
      scrollView:insert(msgGroup)
      -- q.getConnection("","profine/addmsg.php", function(event)
      --   print("response",event.response)
      --   if event.response=="Chat updated" then
      --     chat.addMsg({fromYou=true,text = text})
      --     toBotField.text = ""
      --     native.setKeyboardFocus( nil )
      --   end
      -- end, {
      --   myid = account.id,
      --   id1 = id[1],
      --   id2 = id[2],
      --   msg = text,
      --   -- hasedPassword = account.hasedPassword,
      --   hasedPassword = "fa585d89c851dd338a70dcf535aa2a92fee7836dd6aff1226583e88e0996293f16bc009c652826e0fc5c706695a03cddce372f139eff4d13959da6f1f5d3eabe",
      -- })  
    
    end
  end, eventGroupName )

  local function keyBack(event)
    if event.phase=="down" then
      local message = "Key '" .. event.keyName .. "' was pressed " .. event.phase
      chat.addMsg({fromYou=false,text=message})
      if event.keyName == "back" then
        moveFieldsDown()
        return true
      end
      return false
    end
  end
  -- if ( system.getInfo("environment") == "device" ) then
  local function moveDescription(event) 
    if event.phase == "began" then
      moveFieldsUp()
      -- Runtime:addEventListener( "key", keyBack )

    elseif event.phase == "editing" then
      
      
    elseif event.phase == "submitted" then
      chat.addMsg({fromYou=false,text="submitted"})
      moveFieldsDown()
    end
  end
  toBotField = native.newTextField(rounded.x+20-3000, -rounded.height*.5, rounded.width-20*2, 200)
  inTextGroup:insert( toBotField )
  toBotField.anchorX=0

  toBotField.startX=toBotField.x+3000
  toBotField.hasBackground = false
  toBotField.placeholder = "Введите сообщение"

  toBotField.font = native.newFont( "ubuntu_r.ttf",20*2)

  toBotField:resizeHeightToFitFont()
  toBotField:setTextColor( 0, 0, 0 )
  toBotField:addEventListener( "userInput", moveDescription )

  local sendIco = display.newImageRect( inTextGroup, "img/send.png", 45, 45 )
  sendIco.x, sendIco.y = send.x+send.width*.5+5, send.y-send.height*.5

  toBotField.x=toBotField.startX
  inTextGroup.y = inTextGroup.y + 10
     
  q.event.group.on(eventGroupName)
end

local chatButtonsGroup
drawChatlist = function()
  if chatButtonsGroup~=nil then
    for i=1, #chatButtonsGroup.events do
      q.event.remove(chatButtonsGroup.events[i],"chat-popUp")
    end
    chatButtonsGroup.events = nil
    display.remove( chatButtonsGroup.scroll )
    display.remove( chatButtonsGroup )
    chatButtonsGroup = nil
  end
  local scrollView = widget.newScrollView(
  {
    top = 110,
    left = 0,
    width = q.fullw,
    height = q.fullh-175-60,
    horizontalScrollDisabled = true,
    -- verticalScrollDisabled = true,
    hideBackground = true,
  })
  chatlistGroup:insert(scrollView)
  scrollView:toBack( )

  chatButtonsGroup = display.newGroup()
  chatButtonsGroup.scroll = scrollView
  scrollView:insert( chatButtonsGroup )

  local lastY = 190-110
  local sizeLogo = 50
  local x = 30

  local chatByDate = {}
  for i = 1, #allChats do
    local info = allChats[i]
    local date
    if #info.msg==0 then 
      date = os.time()
    else
      print(i,info.msg[#info.msg].text,info.msg[#info.msg].date)
      date = tonumber(info.msg[#info.msg].date)
    end
    chatByDate[i] = {i=i, date=date}
  end
  table.sort( chatByDate, function( a,b )
    return (a.date > b.date)
  end )

  chatButtonsGroup.events = {}
  for j = 1, #allChats do
    local i = chatByDate[j].i
    local info = allChats[i]

    -- local chatBack = display.newRect( chatButtonsGroup, q.cx, lastY, q.fullw, sizeLogo*2+30 )

    local logo = display.newCircle( chatButtonsGroup, 90, lastY, sizeLogo )
    -- logo.anchorX = 0
    logo.fill = {
      type = "image",
      filename = "img/chat_profile.png"
    }

    local userName = q.subBySpaces(info.name)
    userName = (#userName==1) and userName[1] or (userName[1].." "..userName[2])

    local nameLabel = display.newText( {
      parent = chatButtonsGroup, 
      text = userName, 
      x = logo.x+logo.width*.5+x, 
      y = lastY-5, 
      font = "ubuntu_m.ttf", 
      fontSize = 16*2,
    })
    nameLabel:setFillColor( unpack(c.text1) )
    nameLabel.anchorX = 0
    nameLabel.anchorY = 1

    local lastMsg = display.newText({
      parent = chatButtonsGroup, 
      text = "Нет сообщений", 
      x = logo.x+logo.width*.5+x, 
      y = lastY+5, 
      font = "ubuntu_r.ttf", 
      fontSize = 16*2,
    })
    lastMsg:setFillColor( unpack(c.text1) )
    lastMsg.anchorX = 0
    lastMsg.anchorY = 0
    lastMsg.alpha = .65
    -- local text = "Нет сообщений"
    if #info.msg~=0 then
      local text = info.msg[#info.msg].text--:sub(1,30)
      if #text>50 then
        text = text:sub(1,50).."..."
      end
      if info.msg[#info.msg].fromYou then
        local galka = display.newImageRect( chatButtonsGroup, "img/galka2.png", 35, 35 )
        galka:setFillColor( unpack(c.text1) )
        galka.alpha = .7
        galka.x = lastMsg.x+2
        galka.y = lastMsg.y+2
        galka.anchorX = 0
        galka.anchorY = 0
        
        lastMsg.x = lastMsg.x + 45
      end
      lastMsg.text = text

      local nowDate = os.date("*t")
      local msgDate = os.date("*t",tonumber(info.msg[#info.msg].date))
      local dateText

      if nowDate.year == msgDate.year
      and nowDate.month == msgDate.month then
        if nowDate.day == msgDate.day then
          msgDate.hour = msgDate.hour<10 and "0"..msgDate.hour or msgDate.hour
          msgDate.min = msgDate.min<10 and "0"..msgDate.min or msgDate.min
          dateText = msgDate.hour ..":"..msgDate.min
        elseif (nowDate.day-1) == msgDate.day then
          dateText = "Вчера"
        end 
      end
      if dateText==nil then
        dateText = msgDate.day.."."..msgDate.month.."."..msgDate.year
      end
      
      local dateLabel = display.newText( {
        parent = chatButtonsGroup, 
        -- text = os.date("today is %A, in %B", tonumber(info.msg[#info.msg].date)), 
        text = dateText or "",
        x = q.fullw-50, 
        y = nameLabel.y, 
        font = "ubuntu_r.ttf", 
        fontSize = 16*2,
      })
      dateLabel:setFillColor( unpack(c.text1) )
      dateLabel.anchorX = 1
      dateLabel.anchorY = 1
      dateLabel.alpha = .65
    end

    

    local button = display.newRect( chatButtonsGroup, q.cx, lastY, q.fullw, 130 )
    button.fill = {1,0,0,.5}
    button.alpha = .01

    button.params = info
    chatButtonsGroup.events[#chatButtonsGroup.events+1] = q.event.add("chatWith_"..info.id, button, openChat, "chat-popUp")
    lastY = lastY + 145
  end
end

local function messagerInput(event)
  if ( event.isError)  then
    print( "Messager load error:", event.response)
    return
  end

  local myNewData = event.response
  -- print( "response:", myNewData:gsub("<br>","\n"))
  local serverChats = json.decode( myNewData ) or {}
  -- print(q)
  -- print(q.printTable(serverChats))
  if serverChats.ready~=true then
    local i = 1
    for hesID, chatInfo in pairs(serverChats) do
      allChats[i] = chatInfo

      local thisChat = allChats[i]
      thisChat.id = hesID
      -- print("#",i,thisChat.id)
      
      local my,to = tonumber( account.id ), tonumber( thisChat.id )
      local id = {
        tostring(math.min(my,to)),
        tostring(math.max(my,to)),
      }
      local intMsg = {}
      for i, msgInfo in pairs(thisChat.msg) do
        intMsg[tonumber( i )] = msgInfo
        thisChat.msg[i] = nil
      end
      thisChat.msg = nil
      thisChat.msg = intMsg

      for msgI=1, #thisChat.msg do
        local msg = thisChat.msg[msgI]
        -- print("is equal",id[tonumber(msg.i)],account.id)
        msg.fromYou = tonumber(id[tonumber(msg.i)]) == tonumber(account.id)
        msg.i = nil
      end
      
      i = i + 1
    end
  else
    serverChats.ready=nil
    for k,v in pairs(serverChats) do
      -- print("#"..k,type,"tonum")
      allChats[tonumber(k)] = serverChats[k]
      serverChats[k] = nil
    end
  end

  -- print(q.printTable(allChats))

  drawChatlist()
end


local onKeyEvent
if ( system.getInfo("environment") == "device" ) then
  onKeyEvent = function( event )
    -- Print which key was pressed down/up
    local message = "Key '" .. event.keyName .. "' was pressed " .. event.phase
    -- print( message )
    -- print(system.getInfo("platform") )
    -- If the "back" key was pressed on Android, prevent it from backing out of the app
    if ( event.keyName == "back" and nowScene~="menu" and nowScene~="chatlist" and event.phase == "down" ) then
      pps.removePop()
      
      return true
    end

    -- IMPORTANT! Return false to indicate that this app is NOT overriding the received key
    -- This lets the operating system execute its default handling of the key
    return false
  end
else
  onKeyEvent = function( event )
    
    local key = event.keyName
    local message = "PC Key '" .. key .. "' was pressed " .. event.phase
    -- print( message )

    if ( event.phase == "down" ) then
      if key=="escape" and nowScene~="menu" and nowScene~="chatlist" then
        -- display.remove(newPopUp)
        pps.removePop()
      end
    end

  end
end
 

local function getMenuButtonsInfo( table )
  local out = {}
  local i = 0
  for k,v in pairs(table) do
  -- for i=1, #numiration do
    if k~="rus" then 
      i = i + 1
      -- print('adress:',k)
      out[i] = {
        adress = k,
        label = v.rus,
        imagePath = "img/miniButtonsLogo/"..k..".png"
      }
    end
  end
  return out
end

local function createButton(group,label,y, name)
  local submitButton = display.newRoundedRect(group, 50, y, q.fullw-50*2, 100, 6)
  submitButton.anchorX=0
  submitButton.anchorY=1
  submitButton.fill = c.appColor

  local labelContinue = textWithLetterSpacing( {
    parent = group, 
    text = label, 
    x = submitButton.x+submitButton.width*.5, 
    y = submitButton.y-submitButton.height*.5, 
    font = "ubuntu_b.ttf", 
    fontSize = 14*2,
    }, 10, .5)

  return submitButton, labelContinue
end

-- {label = "Как легко узнать погоду?",imagePath="img/wiki/map/system/how_check_weather/logo.png",adress="programs map how_check_weather"},
-- {label = "Как посмотреть где автобус?",imagePath="img/wiki/map/smartbus/how_check_bus/logo.png",adress="map smartbus how_check_bus"},
-- {label = "Как доехать до театра/музея?",imagePath="img/wiki/map/2gis/how_find_way/logo.png",adress="map 2gis how_find_way"},
local allWiki = {
  chats = {
    rus = "Общение",
    helper = {
      rus = "Волонтерам",
      remind = {
        rus = "Памятка для волонтера",
        body = {
          { type = "instruction", body = "Главные задачи волонтера"},
          { type = "step", body = "Узнать у знакомых, кому требуется помощь в освоении смартфона"},
          { type = "step", body = "Узнать, какими программами Ваш подопечный не умеет, но хочет научится пользоваться"},
          { type = "step", body = "Самостоятельно предложить некоторые популярные программы для изучения"},
          { type = "step", body = "Записать, какие программы были изучены и усвоены"},
          { type = "step", body = "Попросить подопечного дать комментарий о Вашей работе"},

          { type = "instruction", body = "Первые шаги"},
          { type = "step", body = "Определите операционную систему (Android / iOS / и др.)"},
          { type = "step", body = "Помогите создать электронную почту (mail.com / gmail.com)"},
          { type = "step", body = "Объясните, как искать информацию в интернете (Safari / Google Chrome и др.)"},
          { type = "instruction", body = "Общение"},
          { type = "step", body = "Менеджеры для сообщений и звонков: WhatsApp, Telegram.\nСоцсети для интересных новостей мира и публикаций о своей жизни: Instagram, VK, Twitter, TikTok.\nВидеосвязь для конференций и онлайн кружков / занятий: Zoom и др."},
          { type = "instruction", body = "Повседневные задачи"},
          { type = "step", body = "Как легко узнать погоду"},
          { type = "step", body = "Как дойти / доехать до театра с помощью Карты (2ГИС и др.)"},
          { type = "step", body = "Посмотреть где находится автобус и когда он приедет (Транспорт и др.)"},
          { type = "step", body = "Можно заказать Такси (InDriver и др.)"},
          { type = "step", body = "Пользоваться услугами Госуслуги"},
          { type = "instruction", body = "Развлечения"},
          { type = "step", body = "Приложения для просмотра интересных и познавательных видеороликов, для прослушивания радио и музыки без антенн: Youtube, Яндекс.Радио, Spotify "},
          
          { type = "instruction", body = "Успех!"},
          { type = "step", body = "Вы сделали многое, и тепеь вы достойны её.. Все ради футболки!\n\nНу и самое главное ориентируйтесь на нужды и запросы ваших подопечных :)"},
          
        },
      },
    },
    whatsapp = {
      rus = "Ватсап",
      how_use = {
        rus = "Как пользоваться мобильным приложением WhatsApp",
        body = {
          { type = "text", body = "В этой статье мы расскажем вам, как на iPhone или Android-смартфоне установить и пользоваться WhatsApp. WhatsApp — это приложение для бесплатного обмена сообщениями, с помощью которого можно отправлять сообщения или звонить другим пользователям WhatsApp, когда смартфон подключен к беспроводной сети или мобильной сети передачи данных."},
          { type = "instruction", body = "Как установить и настроить WhatsApp"},
          { type = "step", body = "Скачайте Whatsapp. Это можно сделать в магазине приложений вашего смартфона."},
          { type = "step", body = "Запустите WhatsApp. Нажмите «Открыть» в магазине приложений смартфона или коснитесь значка в виде речевого облака с телефонной трубкой внутри на зеленом фоне. Как правило, иконку приложения можно найти на одном из рабочих столов или на панели приложений."},
          { type = "step", body = "Нажмите OK, когда появится запрос. WhatsApp получит доступ к вашим контактам. Возможно, вам придется разрешить WhatsApp отправлять уведомления; для этого нажмите «Разрешить». На Android-смартфоне также нажмите «Разрешить»"},
          { type = "instruction", body = "Как отправить текстовое сообщение"},
          { type = "step", body = "Нажмите Чаты. Это вкладка внизу экрана. На Android-смартфоне эта вкладка находится вверху экрана."},
          { type = "step", body = "Нажмите на значок «Новый чат» Изображение с названием Iphonenewnote.png. Он находится в правом верхнем углу экрана.На Android-смартфоне нажмите на значок в виде белого речевого облака на зеленом фоне в правом нижнем углу экрана."},
          { type = "step", body = "Выберите контакт. Нажмите на имя контакта, которому вы хотите отправить сообщение. Откроется чат с этим контактом"},
          { type = "step", body = "Коснитесь текстового поля. Оно находится внизу экрана."},
          { type = "step", body = "Введите текст сообщения, которое вы хотите отправить. В сообщение можно вставить эмодзи с экранной клавиатуры."},
          { type = "step", body = "Отправьте сообщение. Для этого нажмите на значок «Отправить» Изображение с названием справа от текстового поля. Сообщение отобразится справа в чате."},
        },
      },
      how_logout = {
        rus = "Как выйти из WhatsApp",
        body = {
          { type = "text", body = "В этой статье вы узнаете, как выйти из WhatsApp на компьютере и устройствах на базе Android или iOS. Хотя в мобильном приложении отсутствует кнопка «Выход», того же результата можно добиться, удалив данные приложения (Android) или само приложение (iPhone и iPad)."},
          { type = "instruction", body = "Android"},
          { type = "step", body = "Откройте Настройки Android. Для этого нажмите на иконку в виде серой шестеренки на рабочем столе или на панели приложений."},
          { type = "step", body = "Пролистайте вниз и выберите WhatsApp. Приложения упорядочены в алфавитном порядке, поэтому вам, скорее всего, придется пролистать практически в самый конец списка."},
          { type = "step", body = "Нажмите Стереть данные. Если вас попросят подтвердить удаление настроек и файлов приложения, нажмите «ОК». В противном случае просто перейдите к следующему шагу."},
        },
      },
      how_restore_msg = {
        rus = "Как восстановить сообщения в Whatsapp",
        body = {
          { type = "text", body = "Если вы случайно удалили или каким-то образом потеряли свою историю переписки в WhatsApp, не переживайте, ее еще можно восстановить. WhatsApp автоматически сохраняет переписку за последние семь дней, создавая резервную копию каждый день в 2 часа ночи на вашем же телефоне. Кроме того, телефон можно настроить так, чтобы он сохранял вашу переписку в облаке. Если вам просто нужно восстановить стертые чаты из последней резервной копии, которая находится в облачном хранилище, то самый простой способ этого добиться – удалить и переустановить приложение. При этом не стоит забывать, что поскольку устройство создает ночные копии за последние семь дней, не исключена возможность вернуться в определенный день в пределах последней недели, используя эти резервные файлы."},
          { type = "instruction", body = "Восстановление из последней копии"},
          { type = "step", body = "Удалите WhatsApp с телефона. Чтобы восстановить стертые сообщения, сначала необходимо полностью удалить приложение.."},
          { type = "step", body = "Зайдите в магазин приложений своего телефона и повторно скачайте WhatsApp."},
          { type = "step", body = "Восстановите свои сообщения. На следующем экране вам сообщат, что для вашего телефона была найдена резервная копия переписки. Нажмите на кнопку «Восстановить» и дождитесь окончания процесса восстановления. Каждый день в 2 часа ночи WhatsApp в автоматическом режиме создает резервную копию всех ваших разговоров. Именно последняя созданная копия будет загружена на ваш телефон."},
        },
      },
    }
  },
  ethernet = {
    rus = "Интернет",
  },
  settings = {
    rus = "Настройки"
  },
  mail = {
    rus = "Почта",
    google = {
      rus = "Gmail",
      how_create_email = {
        rus = "Как создать адрес электронной почты",
        body = {
          { type = "text", body = "Вы когда-нибудь задумывались над тем, как создать свою электронную почту? По всему миру в день отправляются тысячи, миллионы электронных писем, а также многие услуги в сети не доступны без наличия электронной почты. С помощью этого руководства вы сможете завершить простой процесс создания своей электронной почты за считанные минуты."},
          { type = "instruction", body = "Создание электронной почты"},
          { type = "step", body = "Посетите сайт, который предлагает услуги электронной почты. Одни из самых популярных это yahoo.com, google.com и hotmail.com, все они всегда бесплатны."},
          { type = "step", body = "Следуйте всем инструкциям, представленным на странице, заполняя все необходимые данные. Иногда вам будет неудобно выдавать определенную информацию. Будьте спокойны, в большинстве случаев для создания электронной почты нет необходимости предоставлять такую информацию, как номер телефона или адрес, и вы можете пропустить эти шаги."},
          { type = "step", body = "Поздравляем! Вы только что создали электронную почту. Продолжите, импортируйте свои контакты, обменивайтесь сообщениями с друзьями или пишите электронные письма, и многое другое."},
        },
      },
      how_restore_password = {
        rus = "Как восстановить пароль от почты Gmail",
        body = {
          { type = "text", body = "В этой статье рассказывается, как восстановить утерянный или забытый пароль к аккаунту Gmail с помощью веб-сайта Gmail или с помощью мобильного приложения Gmail."},
          { type = "instruction", body = "С помощью веб-сайта Gmail"},
          { type = "step", body = "Нажмите 'Забыли пароль?'. Вы найдете эту ссылку под строкой для ввода пароля."},
          { type = "step", body = "Введите последний пароль, который помните, а затем нажмите Далее. Если вы не помните ни один из паролей, которые использовали ранее, нажмите «Другой вопрос» в нижней части окна. Нажимайте «Другой вопрос» до тех пор, пока не откроется вопрос, на который вы можете ответить – ответьте на него, а затем нажмите «Далее»."},
          { type = "step", body = "Дважды введите новый пароль. Нажмите Изменить пароль"},
        },
      },
    }
  },
  map = {
    rus = "Навигация",
    ["system"] = {
      rus = "Системные",
      how_check_weather = {
        rus = "Как отобразить прогноз погоды на экране блокировки iPhone",
        body = {
          { type = "text", body = "В этой статье мы расскажем вам, как отобразить прогноз погоды на экране блокировки iPhone."},
          { type = "instruction", body = "Как посмотреть прогноз погоды на экране блокировки"},
          { type = "step", body = "Выключите экран. Для этого нажмите на кнопку, которая расположена вверху правой боковой панели iPhone. На старых моделях эта кнопка расположена на верхней панели смартфона."},
          { type = "step", body = "Нажмите кнопку «Домой». Появится экран блокировки."  },
          { type = "step", body = "Проведите по экрану вправо. Отобразится виджет «Погода» и другие виджеты, которые вы добавили в Центр уведомлений."},
        },
      },
    },
    ["smartbus"] = {
      rus = "Умный транспорт",
      how_check_bus = {
        rus = "Как скачать 'Умный Транспорт' и посмотреть где находится автобус.",
        body = {
          { type = "text", body = "В этой статье мы расскажем вам, как в любое время узнать когда подъедет автобус."},
          { type = "instruction", body = "Умный транспорт"},
          { type = "step", body = "Скачайте через google play приложение 'Умный транспорт'"},
          { type = "step", body = "Дождитесь окончания установки и запустите приложение"  },
          { type = "step", body = "Нажмите на кнопку с тремя полосками"},
          { type = "step", body = "Нажмите 'Автобусы'"},
          { type = "step", body = "Выберите автобусы за которыми вы хотите наблюдать и нажмите ОК"},
          { type = "step", body = "Включите геолокацию и нажмите на галочку внизу справа экрана."},
          { type = "step", body = "Поздравляем! Теперь вы можете наблюдать за движением автобусов"},
        },
      },
    },
    ["2gis"] = {
      rus = "2гис",
      how_find_way = {
        rus = "Как найти дорогу",
        body = {
          { type = "text", body = "В этой статье рассказывается, как найти дорогу из пункта А к пунтку Б при помощи приложения 2gis"},
          { type = "instruction", body = "2gis"},
          { type = "step", body = "Включите геолокацию в телефоне."},
          { type = "step", body = "Запустите 2gis и ввиедите адрем пункта Б"},
          { type = "step", body = "Нажмите на значек посторить путь в нижнем правом краю экрана."},
        },
      },
    },
  },
}

local wikicreate = {
  text = function(info)
    local label = display.newParagraph( (info.body):gsub("\n"," \n "), 68,{
      lineHeight = 1.1,
      font = "mont_sb",
      size = 15*2,
      align = "left",
      color = {0,0,0},
    })
    label.x = 25
    label.y = -40
    return label
  end,
  instruction = function(info)
    local group = display.newGroup()

    local back = display.newRect(group, q.cx,0, q.fullw, 110)
    back.fill = q.CL"BFE8F6"
    back.anchorY = 0

    local numBack = display.newRect(group, 40, back.height*.5, 86,86)
    numBack.fill = q.CL"51C2E6"
    numBack.anchorX = 0
    
    local num = display.newText(group, info.num, numBack.x+numBack.width*.5, numBack.y, "mont_sb", 26*2)
    local outOf = display.newText(group, "Инструкция "..info.num.." из "..info.max, numBack.x+numBack.width + 20, numBack.y, "mont_sb", 13*2)
    outOf.anchorX = 0
    outOf.anchorY = 1
    outOf:setFillColor( unpack( q.CL"6F8287" ) )

    local label = display.newText(group, info.body, numBack.x+numBack.width + 20, numBack.y, "mont_sb", 13*2)
    label.anchorX = 0
    label.anchorY = 0
    label:setFillColor( 0 )

    return group
  end,
  step = function(info)
    local group = display.newGroup()

    local y = 0
    local ifImageExist = display.newImageRect( info.imagePath, 1, 1 )
    if ifImageExist~=nil then
      --728 546
      -- print("Creating")
      local image = display.newImageRect(group, info.imagePath, q.fullw, q.fullw/728*546)
      image.anchorY = 0
      image.x = q.cx
      image.y = 0
      y = image.height
    end

      local back = display.newRect(group, q.cx,y, q.fullw, 110)
      back.fill = q.CL"E8F7FC"
      back.anchorY = 0

      local num = display.newText(group, "Шаг "..info.num, 40, y+20, "mont_sb", 18*2)
      num.anchorX = 0
      num.anchorY = 0
      num:setFillColor( 0 )

      local label = display.newParagraph( (info.body):gsub("\n"," \n "), 68,{
        lineHeight = 1.1,
        font = "mont_sb",
        size = 15*2,
        align = "left",
        color = {0,0,0},
      })
      group:insert(label)
      label.x = 40
      label.y = y+num.height-10

      back.height = (label.y+label.height+50-y)

    display.remove(ifImageExist)
    return group
  end
}


local function wikiByAdress( adress )
  -- print(adress)
  local keys = q.subBySpaces(adress)
  local path = {} 
  local tables = {[0] = allWiki}
  for i=1, #keys do
    local key = keys[i]
    tables[i] = tables[i-1][key]
    -- print(tables[i].rus)
  end
  -- print("give",q.printTable(info))
  -- print("give",info.rus)
  return tables[#tables], tables[#tables-1],  tables[#tables-2]
end

local function wikiButtonInfoByAdress( adress )
  local wiki, app, group = wikiByAdress(adress)
  -- local ifImage = display.newRect()
  return {
    adress = adress,
    groupName = group.rus,
    label = wiki["rus"],
    miniLogo = "img/wiki/"..adress:gsub(" ","/").."/logo.png",
    -- specPhoto = "img/wiki/"..adress:gsub(" ","/").."/V1_step1.png",
    specPhoto = "img/wiki/"..adress:gsub(" ","/").."/preview.png",
  }
end

local function generateWikiButtons(options)
  local scrollView = widget.newScrollView(
    {
      top = options.y-30,
      left = 0,
      width = q.fullw,
      height = q.fullh-options.y+30,--100,
      scrollWidth = 0,
      scrollHeight = 0,
      horizontalScrollDisabled = true,
      -- verticalScrollDisabled = true,
      hideBackground = true,
    }
  )
  options.parent:insert( scrollView )

  local group = display.newGroup()
  scrollView:insert(group)
  group.y = 30
  ---

  local lastX = 30
  local lastY = 0
  local backs = {}
  -- for i=1, #options.buttonsInfo do
  for specNum, info in pairs(options.buttonsInfo) do
    -- local info = options.buttonsInfo[i]
    
    local miniLogoWidth = lastX
    -- if info.miniLogo then
      local miniLogo = display.newImageRect(group, info.miniLogo, 110, 110)
      if miniLogo == nil then
        miniLogo = {height = 110,width = 110}
      end
      miniLogo.anchorX, miniLogo.anchorY = 0, 0
      miniLogo.x, miniLogo.y = lastX + 25, lastY + 20

      miniLogoWidth = miniLogo.x + miniLogo.width
    -- end

    local label = display.newParagraph(info.label, 55,{
      font = "mont_sb",
      size = 17*2,
      align = "left",
      color = {0,0,0}
    })
    group:insert(label)
    label.x = (miniLogoWidth + 25) + 15 - 30 + 15
    label.y = lastY - 20
    label.anchorX, label.anchorY = 0, 0

    local disc = display.newText{
      parent = group,
      text = "Тема: "..info.groupName,
      x = miniLogoWidth + 25 - 10 + 10,
      y = label.y + label.height + 35,
      font = "mont_m",
      fontSize = 15*2,
      align = "left",
      width = q.fullw - lastX*2 - (miniLogoWidth + 25 - 10)
    }
    disc.anchorX, disc.anchorY = 0, 0
    disc:setFillColor(0)
    disc.alpha = .375

    local photo = display.newRoundedRect(group, q.cx, math.max(disc.y + disc.height+30,miniLogo.y + miniLogo.height+25), q.fullw-lastX*2 - 50, 121*2, 12*2)
    photo.fill = {
      type = "image",
      filename = info.specPhoto
    }
    -- photo:setFillColor(.5)
    photo.anchorY = 0
    if info.specPhotoFill then
      photo:setFillColor(unpack(info.specPhotoFill))
    end

    -- local back = roundedRectAndShadow{
    --   parent = group, 
    --   x = lastX, 
    --   y = lastY, 
    --   width = q.fullw - lastX*2, 
    --   height = math.ceil(photo.y + photo.height+25 - lastY),
    --   shadeWidth = 7,
    --   cornerRadius = 12*2, 
    --   anchorX = 0, 
    --   anchorY = 0
    -- }
    local back = display.newRoundedRect( group, lastX, lastY, q.fullw-lastX*2, math.ceil(photo.y + photo.height+25 - lastY), 12*2 )
    back:setStrokeColor( 0,0,0,.1 )
    back.strokeWidth = 3
    back.anchorX = 0
    back.anchorY = 0

    back:toBack() 
    backs[specNum] = back
    backs[specNum].options = {
      vuzes=info.vuzes,
      specNum=info.specNum
    }

    lastY = lastY + back.height + 35
  end

  local scrollEndPoint = display.newRect( group, q.cx, group.y + group.height + 100, 20, 20)
  -- scrollEndPoint.fill = {1,0,0}
  scrollEndPoint.alpha = .01
  return backs
end

local function createWiki(event)
  if event.y>q.fullh-150 then return end
  local adress = type(event)=="string" and event or event.target.adress
  
  local scrollView = widget.newScrollView(
    {
      top = 0,
      left = 0,
      width = q.fullw,
      height = q.fullh-120,
      horizontalScrollDisabled = true,
      hideBackground = true,
      isBounceEnabled = false,
    }
  )
  local newPopUp = display.newGroup()

  local eventGroupName = pps.popUp("wiki",scrollView)

  local keys = q.subBySpaces(adress)
  local path = {} 
  local pathText = ""
  local imagePathRoot = "img/wiki/"
  local info = allWiki
  for i=1, #keys do
    local key = keys[i]
    imagePathRoot = imagePathRoot..key.."/"
    -- print(i,key)
    info = info[key]
    path[i] = info.rus
    -- print(path[i])
    if i~=#keys then
      pathText = pathText .. " > ".. path[i]
    end
  end
  pathText = pathText:sub(4,-1)



  local backLight = display.newRect(newPopUp, q.cx, 0, q.fullw, 1)
  backLight.anchorY = 0
  
  local backColor = display.newRect(newPopUp,q.cx, 0, q.fullw, 1)
  backColor.fill = q.CL"51C2E6"
  backColor.anchorY = 0





  local pathLabel = display.newText(newPopUp, pathText, 30, 40, "mont_sb", 15*2)
  pathLabel:setFillColor( 0 )
  pathLabel.anchorX = 0

  local topLabel = display.newParagraph( (path[#path]):gsub("\n"," \n "), 55,{
    lineHeight = 1.1,
    font = "mont_sb",
    size = 22*2,
    align = "left",
    color = {1,1,1},
  })
  newPopUp:insert( topLabel )
  topLabel.x = 25
  topLabel.y = 30
  topLabel.anchorY = 0

  backColor.height = (topLabel.y + topLabel.height + 60)

  local backTagColor = display.newRect(newPopUp,q.cx, backColor.height, q.fullw, 64)
  backTagColor.fill = q.CL"4BB2D4"
  backTagColor.anchorY = 0


  local wiki = info.body
  local y = backColor.height + backTagColor.height + 30
  local instructionCount = 0
  for i=1, #wiki do
    if wiki[i].type == "instruction" then
      instructionCount = instructionCount + 1
    end
  end
  local instruction = 0
  local step = 0
  local lastPart = "text"
  for i=1, #wiki do
    local thisPart = wiki[i]
    local Ptype = thisPart.type 
    local part
    if Ptype == "text" then
      part = wikicreate[Ptype](thisPart)
      part.y = part.y+y
      y = y + part.height
    elseif Ptype == "instruction" then
      instruction = instruction + 1
      step = 0
      thisPart.num = instruction
      thisPart.max = instructionCount
      part = wikicreate[Ptype](thisPart)
      local space = 30
      part.y = part.y+y+space
      y = y + part.height+space
    elseif Ptype == "step" then
      step = step + 1
      thisPart.num = step
      thisPart.imagePath = imagePathRoot.."V"..instruction.."_step"..step..".png"
      part = wikicreate[Ptype](thisPart)
      local space = 0
      if lastPart=="step" then
        space = 50
      end
      part.y = part.y+y+space
      y = y + part.height+space
    end
    newPopUp:insert( part )
    lastPart = Ptype
    -- if Ptype==
  end
  backLight.height = math.max(newPopUp.height+30, q.fullh-120)
  
  scrollView:insert(newPopUp)
  
end

local function groupView(event)
  if event.y>q.fullh-150 then return end
  local newPopUp = display.newGroup()
  local eventGroupName = pps.popUp("groupedWiki", newPopUp)
  
  local adress
  if type(event)=="string" then
    adress = event
  else
    adress = event.target.adress
  end

  local backLight = display.newRect(newPopUp, q.cx, 0, q.fullw, q.fullh*2)
  backLight.anchorY = 0

  local gV = wikiByAdress(adress)

  local mainLabel = display.newText( {
    parent = newPopUp,
    text = gV.rus,
    x=30,
    y=60,
    font = "ubuntu_m.ttf",
    fontSize = 24*2} )
  mainLabel.fill = c.black  
  mainLabel.anchorX = 0

  local buttonsInfo = {}

  for appName, aV in pairs(gV) do
    if appName~="rus" then
      for themeName, tV in pairs(aV) do
        if themeName~="rus" then
          local adress = adress.." "..appName.." "..themeName
          buttonsInfo[#buttonsInfo+1] = wikiButtonInfoByAdress(adress)

        end
      end
    end
  end

  local buttons = generateWikiButtons{
    parent = newPopUp,
    y = 110+20,
    buttonsInfo = buttonsInfo
  }
  
  for i=1, #buttons do
    buttons[i].adress = buttonsInfo[i].adress
    q.event.add("toWiki-"..buttons[i].adress.."", buttons[i], createWiki, eventGroupName)
  end
  q.event.group.on(eventGroupName)

  if #buttons==0 then
    local mainLabel = display.newText( {
      parent = newPopUp,
      text = "Упс.. мы все еще заполняем этот\nраздел",
      x=30,
      y=150,
      font = "ubuntu_m.ttf",
      fontSize = 20*2} )
    mainLabel.fill = {.4}  
    mainLabel.anchorX = 0
  end
end







local searchMap
local function adreessToHotWords()
  local out = {}
  for groupName, gV in pairs(allWiki) do
    for appName, aV in pairs(gV) do
      if appName~="rus" then
        for themeName, tV in pairs(aV) do
          if themeName~="rus" then
            local adress = groupName.." "..appName.." "..themeName
            out[adress] = appName.." "..aV.rus.." "..tV.rus

            for i=1, #tV.body do
              if tV.body[i].type == "instruction" then
                out[adress] = out[adress].." "..tV.body[i].body
              end
            end

          end
        end
      end
    end
  end
  -- print(q.printTable(out))
  searchMap = out
  -- return out
end


-- local function createGraf(event)
--   mainLabel.alpha = 0
--   -- profileGroup.alpha = 0
--   local newPopUp = display.newGroup()
--   local name = pps.popUp("search",newPopUp)

--   local backLight = display.newRect(newPopUp, q.cx, 0, q.fullw, q.fullh*2)
--   backLight.anchorY = 0
  
--   local backColor = display.newRect(newPopUp,q.cx, 0, q.fullw, 1)
--   backColor.fill = q.CL"51C2E6"
--   backColor.anchorY = 0

--   local pathLabel = display.newText(newPopUp, "СТАТИСТИКА", 30, 40, "mont_sb", 15*2)
--   pathLabel:setFillColor( 0 )
--   pathLabel.anchorX = 0

--   local topLabel = display.newParagraph("ТЕСТОВ: 1", 55,{
--     lineHeight = 1.1,
--     font = "mont_sb",
--     size = 22*2,
--     align = "left",
--     color = {1,1,1},
--   })
--   newPopUp:insert( topLabel )
--   topLabel.x = 25
--   topLabel.y = 30
--   topLabel.anchorY = 0

--   backColor.height = (topLabel.y + topLabel.height + 60)

--   local backTagColor = display.newRect(newPopUp,q.cx, backColor.height, q.fullw, 64)
--   backTagColor.fill = q.CL"4BB2D4"
--   backTagColor.anchorY = 0

--   local scrollView = widget.newScrollView(
--     {
--       top = 0,
--       left = 0,
--       width = q.fullw,
--       height = q.fullh,
--       scrollWidth = 0,
--       scrollHeight = 0,
--       horizontalScrollDisabled = true,
--       -- verticalScrollDisabled = true,
--       hideBackground = true,
--       isBounceEnabled = false,
--     }
--   )

--   profileGroup:insert(scrollView)

--   scrollView:insert(newPopUp)
-- end



local lastSearch = {}
local inSearchButtons
local function smartSearch( event )
  if event.phase=="editing" then
    local search = event.newCharacters
    -- print(search)
    local include = {}
    if search~="" then

      for adress, hotworlds in pairs(searchMap) do
        if hotworlds:find(search) then
          include[#include+1] = wikiButtonInfoByAdress(adress)
        end
      end
    -- else
      -- native.setKeyboardFocus( nil )
    end

    if #include~=#lastSearch then

      q.event.group.add("search1-popUp",{})
      display.remove(inSearchButtons)
      inSearchButtons = display.newGroup()
      scenes[#scenes].group:insert(inSearchButtons)

      local buttons = generateWikiButtons{
        parent = inSearchButtons,
        y = 350,
        buttonsInfo = include
      }
      lastSearch = include
      
      for i=1, #buttons do
        buttons[i].adress = include[i].adress
        q.event.add("toWiki-"..include[i].adress, buttons[i], createWiki, "search1-popUp")
      end
      q.event.group.on("search1-popUp")
    end

  elseif event.phase=="ended" then
    searchField.text = ""
    lastSearch = {}
    -- pps.removePop()
    -- q.event.group.remove("search-buttons")
    -- display.remove(lastSearchGroup)
    -- lastSearchGroup = display.newGroup()
    -- searchRezultGroup:insert(lastSearchGroup)

    -- searchRezultGroup.alpha = 0
    -- timer.performWithDelay( 2, function()
    --   if nowScene=="menu" then
    --     q.event.group.on("menu-popUp" )
    --   end
    -- end )
  end
end

local function searchPopUp()
  local searchRezultGroup = display.newGroup() -- Группа результатов поиска

  local eventGroupName = pps.popUp("search", searchRezultGroup,{
    onHide = function()
      searchField.x = 1000
    end,
    onShow = function()
      searchField.x = searchField.myX
    end,
  } )
  if eventGroupName~="search1-popUp" then error(eventGroupName.." 2 раза сеарч появляется") end
  searchRezultGroup.back = display.newRect(searchRezultGroup, q.cx, 170, q.fullw, q.fullh)
  searchRezultGroup.back.anchorY = 0
  searchRezultGroup.back.fill = c.backGround

  local y = 200
  -- local backSearch = roundedRectAndShadow({
  --   parent = searchRezultGroup, 
  --   x = q.cx, 
  --   y = y+55, 
  --   width = q.fullw-100, 
  --   height = 110,
  --   shadeWidth = 7,
  --   cornerRadius = 30, 
  --   anchorX = .5, 
  --   anchorY = .5
  -- })
  local backSearch = display.newRoundedRect( searchRezultGroup, q.cx, y+55, q.fullw-100, 110, 30 )
  backSearch:setStrokeColor( 0,0,0,.1 )
  backSearch.strokeWidth = 3

  local searchIcon = display.newImageRect( searchRezultGroup, "img/search.png", 60,60 )
  searchIcon.x = 50 + 30
  searchIcon.y = backSearch.y
  searchIcon.anchorX = 0

  searchField = native.newTextField(-200, -200, 100, 110)
  searchRezultGroup:insert(searchField)
  searchField.x, searchField.y = searchIcon.x + 80, backSearch.y
  searchField.myX = searchField.x
  searchField.width = q.fullw-(100+120)
  searchField.anchorX = 0

  searchField.hasBackground = false
  searchField.font = native.newFont( "mp_r.ttf",50)
  searchField:setTextColor( 0, 0, 0 )
  searchField.placeholder = "Поиск"
  searchField:resizeHeightToFitFont()

  searchField:addEventListener( "userInput", smartSearch )

  inSearchButtons = display.newGroup()
  timer.performWithDelay( 1, function()
    native.setKeyboardFocus( searchField )
  end )

end


local function printServer( event )
  if ( event.isError)  then
    print("Load error:", event.response)
  else
    local myNewData = event.response
    print("!",myNewData)
  end
end



local realEvent = {}
local allHeight
local newsListGroup
local createAllButtonsNews

local function newsEditor(event)
  -- mainLabel.text = "Редактирование новости"
  local editNewsGroup = display.newGroup()
  local eventGroupName = pps.popUp("editNewss",editNewsGroup)

  local info = event.target.info
  local back = display.newRect(editNewsGroup, q.cx, q.cy, q.fullw, q.fullh)

  local backTitle = display.newRoundedRect(editNewsGroup, 40, 180, q.fullw-40*2, 90, 12)
  backTitle.anchorX=0
  backTitle.fill = c.gray2

  local titleField = native.newTextField(60, 180, back.width-120, 90)
  editNewsGroup:insert( titleField )
  titleField.anchorX=0
  titleField.pos = {x=titleField.x, y=titleField.y}
  titleField.isEditable = true
  titleField.hasBackground = false
  titleField.placeholder = "Название"
  titleField.font = native.newFont( "ubuntu_r.ttf",16*2)
  titleField:resizeHeightToFitFont()
  titleField:setTextColor( .5, .5, .5 )
  titleField.text = info.title

  local backLong = display.newRoundedRect(editNewsGroup, 40, 300-45, q.fullw-40*2, 630, 12)
  backLong.anchorX=0
  backLong.anchorY=0
  backLong.fill = c.gray2

  local longField = native.newTextBox(60, 300-45+20, back.width-120, 590)
  editNewsGroup:insert( longField )
  longField.anchorX = 0
  longField.anchorY = 0
  longField.pos = {x=longField.x, y=longField.y}
  longField.isEditable = true
  longField.hasBackground = false
  longField.placeholder = "Тело новости"
  longField.font = native.newFont( "ubuntu_r.ttf",16*2)
  longField:setTextColor( .5, .5, .5 )
  longField.text = info.text

  local submitNews, label = createButton(editNewsGroup, "ОПУБЛИКОВАТЬ",q.fullh-150-120,"id")
  q.event.add("submitEditNews",submitNews, function() 
    -- print("publish")
    local myI
    for i=1, #realEvent do
      local id = realEvent[i].id
      q.event.remove("oneNews"..id.."_news-popUp", "news-popUp")
      if id==info.id then
        myI = i
      end
    end
    realEvent[myI].title=titleField.text
    realEvent[myI].text=longField.text

    -- inverseRealEvent[#inverseRealEvent+1] = {title=titleField.text, datePost=time, text=longField.text, id=idNew}
    -- if isDevice then
      q.postConnection("news",realEvent)
    -- else
    -- print("http://"..server.."/dashboard/editUpload.php?title="..titleField.text.."&text="..longField.text.."&id="..info.id)
    -- network.request( "http://"..server.."/dashboard/editUpload.php?title="..titleField.text.."&text="..longField.text.."&id="..info.id, "GET", printServer )
    -- end

    timer.performWithDelay( 1, pps.removePop, 2 )
    createAllButtonsNews()
    
  end, eventGroupName)

  local cancelNews, label = createButton(editNewsGroup, "ОТМЕНА",q.fullh-150,"id")
  -- cancelNews:addEventListener( "tap", 
  q.event.add("cancelEditNews",cancelNews, function() 
    timer.performWithDelay( 1, pps.removePop )
  end, eventGroupName)
  q.event.group.on(eventGroupName)
end
local function openNews(event)
  if event.y>(q.fullh-260) or event.y<110 then return end
  local info = event.target.info
  -- print("Open news id#"..info.id)

  local oneNewsGroup = display.newGroup()
  local eventGroupName = pps.popUp("readNews",oneNewsGroup)

  local backGround = display.newRect(oneNewsGroup, q.cx, q.cy, q.fullw, q.fullh)
  backGround.fill={.95}

  local newsLabel = display.newText({
    parent = oneNewsGroup,
    text = info.title,
    x = 45,
    y = 30,
    width = q.fullw-100,
    font = "ubuntu_m.ttf",
    fontSize = 18*2,
    })
  newsLabel.anchorX = 0
  newsLabel.anchorY = 0
  newsLabel:setFillColor( unpack( c.black ) )

  local discLabel = display.newText({
    parent = oneNewsGroup,
    text = info.text,
    x = 60,
    y = newsLabel.y+newsLabel.height-15+50,
    width = q.fullw-120,
    font = "ubuntu_r.ttf",
    fontSize = 16*2,
    })
  discLabel.anchorX = 0
  discLabel.anchorY = 0
  discLabel:setFillColor( unpack( c.black ) )

  if account.status=="admin" then
    local createNewsButton, labelNews = createButton(oneNewsGroup, "РЕДАКТИРОВАТЬ НОВОСТЬ",q.fullh-150,"editNews")
    createNewsButton.info = info
    -- print("РЕДАКТИРОВАТЬ НОВОСТЬ")
    q.event.add( "editNewsOn", createNewsButton, newsEditor, eventGroupName )
    q.event.group.on( eventGroupName )
   
  end
end
local rusMonthNames = {
  "Января",
  "Февраля",
  "Марта",
  "Апреля",
  "Майя",
  "Июня",
  "Июля",
  "Августа",
  "Сентября",
  "Октября",
  "Ноября",
  "Декабря",
}
local function createButtonNews(group, y, info)

  if info.postedBy~=nil then
    local newsLabel = display.newText({
      parent = group,
      text = info.title,
      x = 50,
      y = 105+y,
      width = q.fullw-100,
      font = "ubuntu_m.ttf",
      fontSize = 16*2,
      })
    newsLabel.anchorX = 0
    newsLabel.anchorY = 0
    newsLabel:setFillColor( unpack( c.text1 ) )

    local back = display.newRoundedRect(group, q.cx, y, q.fullw-60, 120+newsLabel.height, 12)
    back.anchorY=0
    back:setStrokeColor( 0,0,0,.1 )
    back.strokeWidth = 3
    back:toBack()

    local adminImage = display.newCircle( group, 50, 20+y, 35 ) 
    adminImage.anchorX=0
    adminImage.anchorY=0
    adminImage.fill = {
      type = "image",
      filename = info.postedBy.image,
    }

    local adminName = display.newText({
      parent = group,
      text = info.postedBy.name,
      x = adminImage.x+adminImage.width+20,
      y = adminImage.y+adminImage.height*.5,
      font = "ubuntu_m.ttf",
      fontSize = 13*2,
      })
    adminName.anchorX = 0
    adminName.anchorY = 1
    adminName:setFillColor( unpack(c.text1) )
    
    local date = os.date("*t",tonumber(info.datePost))
    local dateLabel = display.newText({
      parent = group,
      text = date.day.." "..rusMonthNames[date.month].." "..date.year,
      x = adminName.x,
      y = adminImage.y+adminImage.height*.5,
      font = "ubuntu_m.ttf",
      fontSize = 13*2,
      })
    dateLabel.anchorX = 0
    dateLabel.anchorY = 0
    dateLabel:setFillColor( unpack(c.text1) )
    dateLabel.alpha = .6

    -- if info.discription then
      local subTo = 210
      local b = {string.byte(info.text:sub(subTo,subTo))}
      if b[1]==208 or b[1]==209 then subTo = subTo + 1 end

      local discLabel = display.newText({
        parent = group,
        text = info.text:sub(1,subTo).."...",
        x = 50,
        y = 120+newsLabel.height+y,
        width = q.fullw-100,
        font = "ubuntu_r.ttf",
        fontSize = 15*2,
        })
      discLabel.anchorX = 0
      discLabel.anchorY = 0
      discLabel:setFillColor( unpack( c.text1 ) )
      
      back.height = 120+newsLabel.height+30+discLabel.height
    -- end

    back.info = info
    q.event.add("oneNews"..info.id, back, openNews, "news-popUp")

    

    return (back.height)
  else
    local newsLabel = display.newText({
      parent = group,
      text = info.title,
      x = 60,
      y = 30+y,
      width = q.fullw-100,
      font = "ubuntu_m.ttf",
      fontSize = 16*2,
      })
    newsLabel.anchorX = 0
    newsLabel.anchorY = 0
    newsLabel:setFillColor( unpack( c.text1 ) )

    local back = display.newRoundedRect(group, q.cx, y, q.fullw-60, 120+newsLabel.height, 12)
    back.anchorY=0
    back:toBack()
    back:setStrokeColor( 0,0,0,.2 )
    back.strokeWidth = 4
    back.info = info

    q.event.add("oneNews"..info.id, back, openNews, "news-popUp")

    local dateLabel = display.newText({
      parent = group,
      text = info.datePost,
      x = 60,
      y = back.height-50+y,
      font = "roboto_r.ttf",
      fontSize = 13*2,
      })
    dateLabel.anchorX = 0
    dateLabel:setFillColor( unpack( q.CL"818C99" ) )

    return (back.height)
  end
end

createAllButtonsNews = function()
  if newsListGroup~=nil then display.remove(newsListGroup.scrollGroup) display.remove(newsListGroup) newsListGroup = nil end
  local minusButtonSize = 0
  if account.status=="admin" then
    minusButtonSize = 145
  end
  local scrollView = widget.newScrollView(
  {
    top = 110,
    left = 0,
    width = q.fullw,
    height = q.fullh-175-minusButtonSize-60,
    horizontalScrollDisabled = true,
    -- verticalScrollDisabled = true,
    hideBackground = true,
  })
  scrollView:toBack( )

  newsListGroup = display.newGroup()
  newsListGroup.scrollGroup = scrollView
  
  local allHeight = 80-60
  local spaceY = 30
  for i=#realEvent, 1, -1 do
    realEvent[i].postedBy = {name="Администратор",image="img/chat_profile.png"}
    -- realEvent[i].discription="Hard skills — профессиональные навыки для выполнения конкретных рабочих задач.  отрасли быть востребованными и добиваться успеха в карьере."
    allHeight = allHeight + spaceY + createButtonNews(newsListGroup, allHeight, realEvent[i])
  end
  scrollView:insert(newsListGroup)
  inNewsOverlay:insert(scrollView)

  local scrollEndPoint = display.newRect( newsListGroup, q.cx, newsListGroup.y + newsListGroup.height + 50, 20, 20)
  scrollEndPoint.alpha = 0
end

local function newsCreator()
  local createNewsGroup = display.newGroup()
  local eventGroupName = pps.popUp("newsCreator", createNewsGroup)

  local back = display.newRect(createNewsGroup, q.cx, q.cy, q.fullw, q.fullh)

  local mainLabel = display.newText( {
    parent = createNewsGroup,
    text = "Создание новости",
    x = 35,
    y = 60,
    font = "ubuntu_m.ttf",
    fontSize = 24*2} )
  mainLabel:setFillColor( 0 )  
  mainLabel.anchorX = 0

  local backTitle = display.newRoundedRect(createNewsGroup, 40, 180, q.fullw-40*2, 90, 12)
  backTitle.anchorX=0
  backTitle.fill = c.gray2

  local titleField = native.newTextField(60, 180, back.width-120, 90)
  createNewsGroup:insert( titleField )
  titleField.anchorX=0
  titleField.pos = {x=titleField.x, y=titleField.y}
  titleField.isEditable = true
  titleField.hasBackground = false
  titleField.placeholder = "Название"
  titleField.font = native.newFont( "ubuntu_r.ttf",16*2)
  titleField:resizeHeightToFitFont()
  titleField:setTextColor( .5, .5, .5 )

  local backLong = display.newRoundedRect(createNewsGroup, 40, 300-45, q.fullw-40*2, 630, 12)
  backLong.anchorX=0
  backLong.anchorY=0
  backLong.fill = c.gray2

  local longField = native.newTextBox(60, 300-45+20, back.width-120, 590)
  createNewsGroup:insert( longField )
  longField.anchorX = 0
  longField.anchorY = 0
  longField.pos = {x=longField.x, y=longField.y}
  longField.isEditable = true
  longField.hasBackground = false
  longField.placeholder = "Тело новости"
  longField.font = native.newFont( "ubuntu_r.ttf",16*2)
  longField:setTextColor( .5, .5, .5 )

  local submitNews, label = createButton(createNewsGroup, "ОПУБЛИКОВАТЬ",q.fullh-150-120*0,"id")
  
  q.event.add("publishNews", submitNews, function()
    local time = os.time()
    
    local idNew = realEvent[1].id
    for i=1, #realEvent do
      local id = realEvent[i].id
      idNew = math.max(idNew,id)
      q.event.remove("oneNews"..id.."_news-popUp", "news-popUp")
    end
    idNew = idNew + 1

    -- inverseRealEvent[#inverseRealEvent+1] = {title=titleField.text, datePost=time, text=longField.text, id=idNew}
    -- table.insert(realEvent, 1, {title=titleField.text, datePost=time, text=longField.text, id=idNew} )
    realEvent[#realEvent+1] = {title=titleField.text, datePost=time, text=longField.text, id=idNew}
    -- if isDevice then
      q.postConnection("news",realEvent)
    -- else
      -- network.request( "http://"..server.."/dashboard/newsUpload.php?title="..titleField.text.."&date="..time.."&text="..longField.text, "GET" )
    -- end

    createAllButtonsNews()
    
    timer.performWithDelay( 1, pps.removePop)
    
  end, eventGroupName)
  q.event.group.on(eventGroupName)
  
end


local function newsResponder(event)
  if ( event.isError)  then
    print( "News load error:", event.response)
  else
    local myNewData = event.response
    -- print("news",myNewData)
    realEvent = (json.decode(myNewData))
    -- local j = 1
    -- for i=#inverseRealEvent, 1, -1 do
    --   realEvent[j] = inverseRealEvent[i] -- Переворачиваем список чтобы сначало были свежие новости
    --   j = j + 1
    -- end
    -- j = nil

    createAllButtonsNews()
    
    if account.status=="admin" then

      local down = display.newRect(inNewsOverlay, q.cx, q.fullh, q.fullw, 260)
      down.anchorY=1

      local createNewsButton, labelNews = createButton(inNewsOverlay, "СОЗДАТЬ НОВОСТЬ",q.fullh-150,"id")
      q.event.add("createNews",createNewsButton,newsCreator,"news-popUp")

    end
    q.event.group.on("news-popUp")

    -- checkIfNeedScroll(events)
    -- q.event.group.on("newsButtons")
  end
end

local photoForPost = {}
local kraySpase = 30
local inSpase = 20
local max = 3
local ost = (q.fullw - kraySpase*2 - inSpase*(max-1) )/max
local addPhotoButton

local postCreateGroup
local postCreateEventGroupName
local function removePhoto( event )
  -- error("hi")
  local back = event.target
  local i = back.i
  display.remove(photoForPost[i])
  display.remove(back)

  if #photoForPost==max then
    addPhotoButton.alpha = 1
  else
    addPhotoButton.x = addPhotoButton.x - ost - inSpase
  end
  for i=i+1, #photoForPost do
    photoForPost[i].x = photoForPost[i].x - ost - inSpase
    photoForPost[i].back.x = photoForPost[i].x
    photoForPost[i].back.i = photoForPost[i].back.i - 1
  end
  table.remove(photoForPost, i)
end

local function photoResponser( event )
  local photo = event.target
  postCreateGroup:insert(photo)
  photo.x = addPhotoButton.x + ost*.5
  photo.y = 130
  -- photo.anchorX = 0
  photo.anchorY = 0
  
  if photo.width>photo.height then
    photo.height = ost*(photo.height/photo.width)
    photo.width = ost
  else
    photo.width = ost*(photo.width/photo.height)
    photo.height = ost
  end
  photoForPost[#photoForPost+1] = photo
  
  if max==#photoForPost then
    addPhotoButton.alpha = 0
  else
    addPhotoButton.x = addPhotoButton.x +ost+inSpase
  end

  local back = display.newRect(postCreateGroup, photo.x, photo.y + ost*.5, ost, ost)
  back.fill = {0}
  back.i = #photoForPost
  -- back.photo = photo
  photo.back = back
  photo:toFront()

  timer.performWithDelay( 10, function()
    local eventName = q.event.add("removePhoto"..back.i, back, removePhoto, postCreateEventGroupName)
    q.event.on(eventName)
  end )
  -- print( "photo w,h = " .. photo.width .. "," .. photo.height )
  -- display.save(photo,{

  -- })
end

local function fakephotoResponser( event )
  local photo = display.newImage( "img/tests/1.jpg" )
  postCreateGroup:insert(photo)
  photo.x = addPhotoButton.x + ost*.5
  photo.y = 130
  -- photo.anchorX = 0
  photo.anchorY = 0
  
  if photo.width>photo.height then
    photo.height = ost*(photo.height/photo.width)
    photo.width = ost
  else
    photo.width = ost*(photo.width/photo.height)
    photo.height = ost
  end
  photoForPost[#photoForPost+1] = photo
  
  if max==#photoForPost then
    addPhotoButton.alpha = 0
  else
    addPhotoButton.x = addPhotoButton.x +ost+inSpase
  end

  local back = display.newRect(postCreateGroup, photo.x, photo.y + ost*.5, ost, ost)
  back.fill = {0}
  back.i = #photoForPost
  -- back.photo = photo
  photo.back = back
  photo:toFront()

  timer.performWithDelay( 10, function()
    local eventName = q.event.add("removePhoto"..back.i, back, removePhoto, postCreateEventGroupName)
    q.event.on(eventName)
  end )
  -- print( "photo w,h = " .. photo.width .. "," .. photo.height )
  -- display.save(photo,{

  -- })
end

local function createOrangeButton(group, y, text, space, height)
  space = space or 130
  height = height or 90
  local regButton = display.newRoundedRect( group, q.cx, y, q.fullw-space, height, 50)
  regButton.anchorY=1
  regButton.fill = c.appColor

  local labelContinue = display.newText( {
    parent = group, 
    text = text, 
    x = q.cx, 
    y = regButton.y-regButton.height*.5,  
    font = "fonts/hindv_r.ttf", 
    fontSize = 16*2,
  })
  regButton.text = labelContinue

  return regButton
end

local postsEvents = {}
local function createPost()
  downNavigateGroup.alpha = 0
  postCreateGroup = display.newGroup()
  local eventGroupName = pps.popUp("postCreate", postCreateGroup, {
    onShow = function()
      downNavigateGroup.alpha = 0
    end,
    onHide = function()
      downNavigateGroup.alpha = 1
      -- for i=1, #photoForPost do
      --   q.deleteFile("forPost"..i..".jpg", system.TemporaryDirectory)
      -- end
      photoForPost = {}
      createAllInstaPost()
    end,
  })
  postCreateEventGroupName = eventGroupName
  local back = display.newRect(postCreateGroup,q.cx,q.cy,q.fullw,q.fullh)
  back.fill = c.backGround

  
  
  addPhotoButton = display.newImageRect( postCreateGroup, "img/addphoto.png", ost, ost )
  addPhotoButton.anchorY = 0
  addPhotoButton.anchorX = 0
  addPhotoButton.x = kraySpase
  addPhotoButton.y = 130

  local backTitle = display.newRoundedRect(postCreateGroup, q.cx, 425, q.fullw-40*2, 590, 30)
  backTitle.anchorY=0
  backTitle.fill = q.CL"F3F3F3"
  backTitle:setStrokeColor( unpack(q.CL"A1A1A1") )
  backTitle.strokeWidth = 5

  local titleField = native.newTextField(65, backTitle.y+45, back.width-120, 90)
  postCreateGroup:insert( titleField )
  titleField.anchorX=0
  titleField.pos = {x=titleField.x, y=titleField.y}
  titleField.isEditable = true
  titleField.hasBackground = false
  titleField.placeholder = "Заголовок поста"
  titleField.font = native.newFont( "fonts/hindv_b.ttf", 30 )
  titleField:resizeHeightToFitFont()
  titleField:setTextColor( .5, .5, .5 )

  local longField = native.newTextBox(65, titleField.y+titleField.height-10, back.width-120, 490)
  postCreateGroup:insert( longField )
  longField.anchorX = 0
  longField.anchorY = 0
  longField.pos = {x=longField.x, y=longField.y}
  longField.isEditable = true
  longField.hasBackground = false
  longField.placeholder = "Описание поста"
  longField.font = native.newFont( "fonts/hindv_r.ttf", 30 )
  longField:setTextColor( .5, .5, .5 )

  local space = 40
  local height = 90
  local publicateButton = display.newRoundedRect( postCreateGroup, space, backTitle.y+backTitle.height+120, q.fullw-space*2, height, 50)
  publicateButton.anchorX=0
  publicateButton.anchorY=1
  publicateButton.fill = c.appColor

  local labelContinue = display.newText( {
    parent = postCreateGroup, 
    text = "Опубликовать", 
    x = q.cx, 
    y = publicateButton.y-publicateButton.height*.5,  
    font = "fonts/hindv_r.ttf", 
    fontSize = 16*2,
  })
  -- local submitNews, label = createButton(postCreateGroup, "ОПУБЛИКОВАТЬ",q.fullh-150-120*0,"id")
  
  if ( media.hasSource( media.PhotoLibrary ) ) then
    q.event.add("addPhoto", addPhotoButton, function()

        media.selectPhoto(
        {
          mediaSource = media.PhotoLibrary,
          listener = photoResponser, 
          -- destination = { baseDir=system.TemporaryDirectory, filename="forPost"..(#photoForPost+1)..".jpg" } 
        })
    end, eventGroupName)
  else
    q.event.add("addPhoto", addPhotoButton, fakephotoResponser, eventGroupName )
    -- native.fakephotoResponsershowAlert( "Fire", "Добавление фото не поддерживается на вашем устройстве.", { "OK" } )
  end


  q.event.add("publishPost", publicateButton, function()
    for i=1, #postsEvents do
      q.event.remove(postsEvents[i], "home-popUp")
    end
    postsEvents = {}
    local time = os.time()
    
    local idNew
    if allInstaPost[account.nick]==nil then error(account.nick) end
    if allInstaPost[account.nick].post[1]~=nil then
      print("had to check")
      idNew = allInstaPost[account.nick].post[1].id
      for i=2, #allInstaPost[account.nick].post do
        local id = allInstaPost[account.nick].post[i].id
        idNew = math.max(idNew,id)
      end
    else
      idNew = 0
    end
    idNew = idNew + 1
    
    allInstaPost[account.nick].post[#allInstaPost[account.nick].post+1] = {
      title=titleField.text,
      datePost=time,
      text=longField.text,
      id=idNew,
      images = #photoForPost,
      likes = 0,
    }
    q.postConnection("post",allInstaPost)

    for i=1, #photoForPost do
      local photo = photoForPost[i]
      local ost = q.fullw-100
      if photo.width>photo.height then
        photo.height = ost*(photo.height/photo.width)
        photo.width = ost
      else
        photo.width = ost*(photo.width/photo.height)
        photo.height = ost
      end
  
      display.save( photo, { filename=account.nick.." "..idNew.." "..i..".png", baseDir=system.DocumentsDirectory, captureOffscreenArea=true, backgroundColor={0,0,0,0} } )
    end
    
    timer.performWithDelay( 1, pps.removePop)  
  end, eventGroupName)
  q.event.group.on(eventGroupName)
end


local function createInstaPostButton(group, y, info)
  if not allUsers then return end
  -- local newsLabel = display.newText({
  --   parent = group,
  --   text = info.title,
  --   x = 50,
  --   y = 105+y,
  --   width = q.fullw-100,
  --   font = "ubuntu_m.ttf",
  --   fontSize = 16*2,
  --   })
  -- newsLabel.anchorX = 0
  -- newsLabel.anchorY = 0
  -- newsLabel:setFillColor( unpack( c.text1 ) )

  local back = display.newRoundedRect(group, q.cx, y, q.fullw-60, 120, 30)
  -- back.fill = c.hideButtons
  back.anchorY=0
  back:setStrokeColor( unpack(c.appColor) )
  back.strokeWidth = 3
  back:toBack()

  local adminImage = display.newCircle( group, 50, 20+y, 35 ) 
  adminImage.anchorX=0
  adminImage.anchorY=0
  adminImage.fill = {
    type = "image",
    filename = info.postedBy.image,
  }

  local followButton = display.newImageRect( group, "img/follow0.png",131.5*2.2,2.2*26.44)
  followButton.x = q.fullw-50
  followButton.y = adminImage.y + adminImage.height*.5
  followButton.anchorX = 1

  local followFilledButton = display.newImageRect( group, "img/follow1.png",131.5*2.2,2.2*26.44)
  followFilledButton.x = q.fullw-50
  followFilledButton.y = adminImage.y + adminImage.height*.5
  followFilledButton.anchorX = 1
  followFilledButton.alpha = 0

  local adminName = display.newText({
    parent = group,
    text = info.postedBy.name,
    x = adminImage.x+adminImage.width+20,
    y = adminImage.y+adminImage.height*.5,
    font = "fonts/hindv_b.ttf",
    fontSize = 13*2,
    })
  adminName.anchorX = 0
  adminName.anchorY = 1
  adminName:setFillColor( unpack(c.text1) )
  
  local date = os.date("*t",tonumber(info.datePost))
  local dateLabel = display.newText({
    parent = group,
    text = date.day.." "..rusMonthNames[date.month].." "..date.year,
    x = adminName.x,
    y = adminImage.y+adminImage.height*.5,
    font = "fonts/hindv_r.ttf",
    fontSize = 13*2,
    })
  dateLabel.anchorX = 0
  dateLabel.anchorY = 0
  dateLabel:setFillColor( unpack(c.text1) )
  dateLabel.alpha = .6


  local postImage = display.newImage( group, account.nick.." "..info.id.." "..(1)..".png", system.DocumentsDirectory, q.cx, dateLabel.y+dateLabel.height + 20 )
  postImage.anchorY = 0

  local ost = q.fullw-100
  if postImage.width>postImage.height then
    postImage.height = ost*(postImage.height/postImage.width)
    postImage.width = ost
  else
    postImage.width = ost*(postImage.width/postImage.height)
    postImage.height = ost
  end
    
  local lastY = postImage.y + postImage.height + 40
  -- local likesCount = display.newText(group, (info.likes or 0), 65, lastY, "fonts/hindv_r.ttf", 40 )
  -- likesCount:setFillColor( 0 )
  -- likesCount.anchorX = 0

  -- local likesLogo = display.newImageRect( group, "img/like0.png", 50, 50)
  -- likesLogo.x = likesCount.x + likesCount.width + 20
  -- likesLogo.y = lastY
  -- likesLogo.anchorX = 0
  local likesLogo = display.newImageRect( group, "img/like0.png", 50, 50)
  likesLogo.x = 60
  likesLogo.y = lastY
  likesLogo.anchorX = 0

  local likesFilledLogo = display.newImageRect( group, "img/like1.png", 50, 50)
  likesFilledLogo.x = 60
  likesFilledLogo.y = lastY
  likesFilledLogo.anchorX = 0
  likesFilledLogo.alpha = 0

  local likesCount = display.newText(group, (info.likes), likesLogo.x + likesLogo.width + 10, lastY, "fonts/hindv_r.ttf", 40 )
  likesCount:setFillColor( 0 )
  likesCount.anchorX = 0

  local likesButton = display.newRect(group, likesLogo.x-15, lastY, (likesCount.x+likesCount.width+15)-(likesLogo.x-20), 70)
  likesButton.fill = c.hideButtons
  likesButton.anchorX = 0

  local chatLogo = display.newImageRect( group, "img/postchat.png", 50, 50)
  chatLogo.x = likesCount.x + likesCount.width + 40
  chatLogo.y = lastY
  chatLogo.anchorX = 0

  local inLike = false
  
  
  for i=1, #account.likedTo do
    if account.likedTo[i]==info.id then
      inLike = true
      break
    end
  end
  if inLike then
    likesLogo.alpha = 0
    likesFilledLogo.alpha = 1
  end

  local authorNick = info.postedBy.name
  local eventName = q.event.add("lik_post_by"..authorNick.."_#"..info.id, likesButton, function()
    if inLike==false then
      likesLogo.alpha = 0
      likesFilledLogo.alpha = 1
      account.likedTo[#account.likedTo+1] = info.id
      info.likes = info.likes + 1
    else
      info.likes = info.likes - 1
      likesLogo.alpha = 1
      likesFilledLogo.alpha = 0
      for i=1, #account.likedTo do
        if account.likedTo[i]==info.id then
          table.remove(account.likedTo, i)
          break
        end
      end

    end
    likesCount.text = info.likes
    inLike = not inLike
    q.saveLogin(account)
    q.postConnection("post",allInstaPost)
  end, "home-popUp" )
  q.event.on(eventName)
  postsEvents[#postsEvents+1] = eventName

  local inFollow = false

  local authorId
  -- print(q.printTable(allUsers))
  for mail, infoAcc in pairs(allUsers) do
    -- print(mail, info)
    if infoAcc.nick==authorNick then
      authorId = infoAcc.id
    end
  end
  -- print(allUsers.google,"hihi")

  for i=1, #account.subTo do
    if account.subTo[i]==authorId then
      inFollow = true
      break
    end
  end
  if inFollow then
    followButton.alpha = .01
    followFilledButton.alpha = 1
  end

  local eventName = q.event.add("subTo"..info.postedBy.name.."inPost"..info.id, followButton, function()
    if inFollow==false then
      local postsBy = allInstaPost[info.postedBy.name] 
      postsBy.subcribes = postsBy.subcribes + 1
      followButton.alpha = .01
      followFilledButton.alpha = 1
      account.subTo[#account.subTo+1] = authorId
      print("sub")
    else
      print("unsub")
      local postsBy = allInstaPost[info.postedBy.name] 
      postsBy.subcribes = postsBy.subcribes - 1
      followButton.alpha = 1
      followFilledButton.alpha = 0
      for i=1, #account.subTo do
        if account.subTo[i]==authorId then
          table.remove(account.subTo, i)
          break
        end
      end

    end
    inFollow = not inFollow
    q.saveLogin(account)
    q.postConnection("post",allInstaPost)
  end, "home-popUp" )
  q.event.on(eventName)
  postsEvents[#postsEvents+1] = eventName
  -- if info.discription then
    -- local subTo = 210
    -- local b = {string.byte(info.text:sub(subTo,subTo))}
    -- if b[1]==208 or b[1]==209 then subTo = subTo + 1 end

    -- local discLabel = display.newText({
    --   parent = group,
    --   text = info.text:sub(1,subTo).."...",
    --   x = 50,
    --   y = 120+newsLabel.height+y,
    --   width = q.fullw-100,
    --   font = "ubuntu_r.ttf",
    --   fontSize = 15*2,
    --   })
    -- discLabel.anchorX = 0
    -- discLabel.anchorY = 0
    -- discLabel:setFillColor( unpack( c.text1 ) )
    
  -- end

  back.height = 120+postImage.height + 40 + 30
  back.info = info

  return (back.height)

end
local mainListGroup
createAllInstaPost = function()
  if not allUsers then return end
  if mainListGroup~=nil then display.remove(mainListGroup.scrollGroup) display.remove(mainListGroup) mainListGroup = nil end
  local minusButtonSize = 0
  if account.status=="admin" then
    minusButtonSize = 145
  end
  local scrollView = widget.newScrollView(
  {
    top = 110,
    left = 0,
    width = q.fullw,
    height = q.fullh-175-minusButtonSize-60,
    horizontalScrollDisabled = true,
    -- verticalScrollDisabled = true,
    hideBackground = true,
  })
  scrollView:toBack( )

  mainListGroup = display.newGroup()
  mainListGroup.scrollGroup = scrollView
  
  local allHeight = 20
  local spaceY = 30

  -- q.event.group.off("home-popUp")
  for k, v in pairs( allInstaPost ) do
    for i=1, #v.post do
      allInstaPost[k].post[i].postedBy = {name=k,image="img/chat_profile.png"}
      allHeight = allHeight + spaceY + createInstaPostButton(mainListGroup, allHeight, v.post[i])
    end
    print(k,#v)
  end
  scrollView:insert(mainListGroup)
  inNewsOverlay:insert(scrollView)
  -- q.event.group.on("home-popUp")

  local scrollEndPoint = display.newRect( mainListGroup, q.cx, mainListGroup.y + mainListGroup.height + 50, 20, 20)
  scrollEndPoint.alpha = 0
  
  -- local bag = display.newText( {
  --   text = q.printTable(allInstaPost), 
  --   x = 10,
  --   y = 100,
  --   fontSize = 30
  -- } )
  -- bag:setFillColor( 0 )
  -- bag.anchorX = 0
  -- bag.anchorY = 0
end


function scene:create( event )
  print("menu state: CREATE")
	local sceneGroup = self.view

	backGroup = display.newGroup() -- Группа фоновых элементов
	sceneGroup:insert(backGroup)

	mainGroup = display.newGroup() -- Группа основного экрана
	sceneGroup:insert(mainGroup)

  inNewsOverlay = display.newGroup() -- Группа для кнопок 
  mainGroup:insert(inNewsOverlay)

  subGroup = display.newGroup() -- Группа основного экрана
  sceneGroup:insert(subGroup)
  subGroup.alpha = 0

  fireGroup = display.newGroup() -- Группа основного экрана
  sceneGroup:insert(fireGroup)
  fireGroup.alpha = 0

  streamGroup = display.newGroup() -- Группа основного экрана
  sceneGroup:insert(streamGroup)
  streamGroup.alpha = 0

	profileGroup = display.newGroup() -- Группа профиля
	sceneGroup:insert(profileGroup)
	profileGroup.alpha = 0

  account = q.loadLogin()
  q.getConnection("post", nil, function(event)
    allInstaPost = json.decode(event.response)
    -- print(q.printTable(allInstaPost),"got")
    if allInstaPost[account.nick]==nil then
      allInstaPost[account.nick] = {
        post = {},
        subcribes = 0,
      }
    end
    if allInstaPost[account.nick].subcribes==nil then
      allInstaPost[account.nick].subcribes = 0
    end
    q.postConnection("post",allInstaPost)
  end, nil, true)

	uiGroup = display.newGroup() -- Группа общих элементов
	sceneGroup:insert(uiGroup)

  local back = display.newRect( backGroup, q.cx, q.cy, q.fullw, q.fullh )
  back.fill = c.backGround
  

  downNavigateGroup = display.newGroup()
  uiGroup:insert(downNavigateGroup)

  upNavigateGroup = display.newGroup()
  uiGroup:insert(upNavigateGroup)


  do -- Н А В И Г А Ц И Я -- D O W N
    local downBack = display.newRect(downNavigateGroup, q.cx, q.fullh, q.fullw, 125)
    downBack.anchorY = 1
    downBack.fill = {1}

    local Vshadow = display.newImageRect( downNavigateGroup, "img/shadow.png", q.fullw, q.fullw*.0611 )
    Vshadow.x = q.cx
    Vshadow.y = q.fullh-downBack.height
    Vshadow.anchorY=1
    
    local spase = 20
    local size = downBack.height - spase - 16
    local buttonY = q.fullh-spase

    local buttons = {}
    local names = {
      "home",
      "subcribes",
      "fire",
      "stream",
      "profile",
    }
    local diff = {
      [1] = 20,
      [2] = 10,
    }

    for k,name in pairs(names) do
      buttons[name] = {}
      for j=0, 1 do

        local button = display.newImageRect( downNavigateGroup, "img/downbar/"..name..j..".png", size*1.4, size )
        button.y = buttonY
        button.anchorY = 1
        button.x = q.fullw/(5)*(k-.5) + (diff[k] or 0)
        -- button.name = name
        buttons[name][j] = button
      end
      local button = display.newRect( downNavigateGroup, q.fullw/(5)*(k-.5) + (diff[k] or 0), buttonY, size*1.4, size )
      button.fill = c.hideButtons
      -- button.alpha = 0a
      button.anchorY = 1
      button.name = name
      q.event.add("to"..name, button, menuButtonsListener, "downBar")
      buttons[name][3] = button
      
      buttons[name][1].alpha = 0
    end
    buttons.home[0].alpha = 0
    buttons.home[1].alpha = 1
  end

  do -- Н А В И Г А Ц И Я -- U P
    local upBack = display.newRect(upNavigateGroup, q.cx, 0, q.fullw, 100)
    upBack.anchorY = 0
    upBack.fill = {1}

    local logo = display.newImageRect(upNavigateGroup, "img/logotext.png", 80, 80)
    logo.x, logo.y = 10, 10
    logo.anchorX = 0
    logo.anchorY = 0

    local createPostButtons = display.newImageRect(upNavigateGroup, "img/create.png",84*2.5,27.1*2.5)
    createPostButtons.x, createPostButtons.y = q.fullw-30, upBack.height*.5
    createPostButtons.anchorX = 1
    q.event.add("createPost", createPostButtons, createPost, "upBar")
  end


  -- -- ======= М Е Н Ю ========= --
  do
  --   local scrollView = widget.newScrollView(
  --     {
  --       top = 0,
  --       left = 0,
  --       width = q.fullw,
  --       height = q.fullh,
  --       -- scrollWidth = 0,
  --       -- scrollHeight = 0,
  --       horizontalScrollDisabled = true,
  --       -- verticalScrollDisabled = true,
  --       hideBackground = true,
  --     }
  --   )
  --   mainGroup:insert(scrollView)
  --   -- mainGroup.scroll = scrollView

    topMain = display.newGroup()
    -- scrollView:insert(topMain)
    mainGroup:insert( topMain )

    local logo = display.newImageRect( topMain, "img/logo.png",85*2,85*2 )
    logo.x, logo.y = 18*2 + 10, 18*2 - 20
    logo.anchorX = 1
    logo.anchorY = 1
    logo.alpha = .01

    q.event.add("nothing",logo, function()
    end, "home-popUp")

    pps.addMainScene("home", topMain)
    q.event.group.on("home-popUp")
  end

  -- -- ======= П О Д П И С К И ========= --
  do
    local logo = display.newImageRect( subGroup, "img/logo.png",85*2,85*2 )
    logo.x, logo.y = 18*2 + 110, 18*2 - 20
    logo.anchorX = 0
    logo.anchorY = 0

    q.event.add("nothing",logo, function()
    end, "subcribes-popUp")

    pps.addMainScene( "subcribes", subGroup)
    q.event.group.on("subcribes-popUp")
  end

  -- -- ======= К О С Т Ё Р ========== --
  do
   local logo = display.newImageRect( fireGroup, "img/logo.png",85*2,85*2 )
    logo.x, logo.y = 18*2 + 210, 18*2 - 20
    logo.anchorX = 0
    logo.anchorY = 0

    q.event.add("nothing",logo, function()
    end, "fire-popUp")

    pps.addMainScene( "fire", fireGroup)
    q.event.group.on("fire-popUp")
  end

  -- -- ======= С Т Р И М Ы ========== --
  do
   local logo = display.newImageRect( streamGroup, "img/logo.png",85*2,85*2 )
    logo.x, logo.y = 18*2 + 210, 18*2 - 20+100
    logo.anchorX = 0
    logo.anchorY = 0

    q.event.add("nothing",logo, function()
    end, "stream-popUp")

    pps.addMainScene( "stream", streamGroup)
    q.event.group.on("stream-popUp")
  end

  -- -- ======== П Р О Ф И Л Ь ========== --
  do
    local back = display.newRect( profileGroup, q.cx, q.cy, q.fullw, q.fullh)
    back.fill = c.backGround
    
    local button = createOrangeButton( profileGroup, 230, "Выйти")

    q.event.add("logOut",button, function()
        q.saveLogin({needGoogleOut=account.google})
        composer.gotoScene( "signin" )
        composer.removeScene( "menu" )
      end, "profile-popUp")

    pps.addMainScene( "profile", profileGroup)
    q.event.group.on("profile-popUp")
  end

  

  q.event.group.on"downBar"
  q.event.group.on"upBar"
  Runtime:addEventListener( "key", onKeyEvent )

  -- adreessToHotWords()
  -- adreessToHotWords = nil

end


function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

  print("menu state: "..phase:upper().."-SHOW")
	if ( phase == "will" ) then
    network.request( jsonLink, "GET", loadAllUsers )
    -- if q.loadLogin()["test"]==nil then
    --   signUpAnket()
    -- end
	elseif ( phase == "did" ) then
    -- createPost()
    -- pps.mainScene("chat")
    -- createWiki("programs whatsapp how_use")
    -- openVuz(
    --   {target={options ={vuz = getVuzByName("imisvfu")}}}
    -- )
	end
end


function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

  print("menu state: "..phase:upper().."-HIDE")
	if ( phase == "will" ) then
    Runtime:removeEventListener( "key", onKeyEvent )
    pps.reset()

	elseif ( phase == "did" ) then
    -- q.event.group.off()
    -- composer.removeScene( "menu" )
    -- print("scene hide")
	end
end


function scene:destroy( event )

  print("menu state: DESTROY")
	local sceneGroup = self.view
  chat.reset()

end


scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene
