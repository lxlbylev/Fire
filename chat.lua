local listMsg = {}
local q = require"base"

local fontA = native.newFont("hnc_b.ttf")
local c =
{
  msgBot = q.CL("0058EE"),
  -- msgBot = {.5},
  msgUser = q.CL("caf0f8"),
  textBot = q.CL("FFFFFF"),
  textUser = q.CL("000000"),
}

local textMinwidth
local textMaxwidth
local group 

local function getTextSize( text )
  local a = display.newText( text, -50, -50, nil, 35 )
  local w, h = a.width, a.height
  display.remove( a )
  return w, h
end

textMinwidth = getTextSize( "." )
textMaxwidth = getTextSize( "))))))))))))))))))))))))))))))))))))))))))))" )
getTextSize = nil

local diff = 90
local spaceLeft = 30
local spaceTop = 30
local topY = 0

local last = {y=60}
local maxUp = 0
local function init(groupFunc, startY)
	group = groupFunc
  topY = startY + 60
	last.y = topY
end
local function reset()
  maxUp = 0
  topY = 0
  last.y = topY
  group = nil
end
local function addSpace(space)
  last.y = last.y + space
end
local function loadMgs(_msg)
  listMsg[#listMsg+1] = _msg
  local angl
  if _msg.fromYou~=last.my or #listMsg==1 then
    if #listMsg~=1 then
      last.y = last.y+14.9
    end
    angl = display.newImageRect(group, "img/angl.png", 98*.35, 60*.35)
    angl.y = last.y+5-60 +  angl.height*.5
    local x
    if _msg.fromYou then
      x = q.fullw-32-4
      angl:setFillColor( unpack(c.msgUser) )
    else
      x = 32+4
    end
    angl.x = x
  end
  local back = display.newRoundedRect( group, q.fullw-32, last.y+5-60, 172, 60, 23 )
  back.fill = c.msgUser
  back.anchorX=1
  back.anchorY=0
  
  local options =  {
    parent = group,
    text = _msg.text,
    x = back.x - spaceLeft,
    y = last.y+5-(back.height+38)*.5-1,
    fontSize = 35,
    align = "right",
  }
  
  local textMaxwidthA = textMaxwidth + ((_msg.fromYou==true and 0) or -10)
  local msgLbl = display.newText( options  )
  msgLbl.anchorX=1
  msgLbl.anchorY=0
  msgLbl.fill = {0}
  
  
  local tooBig = false
  if msgLbl.width>(textMaxwidthA) then
    tooBig = true
    
    options.align = "left"
    options.width = textMaxwidth + 100
    
    display.remove( msgLbl )
    msgLbl = display.newText( options  )
    msgLbl.anchorX=1
    msgLbl.anchorY=0
    msgLbl.fill = {0}
    
    back.height = msgLbl.height+25
  end
  back.width = msgLbl.width + spaceLeft*2
  last.y = last.y+back.height+6.4

  if _msg.fromYou==false then
    display.remove( sended )
    
    back.x = 30
    back.anchorX = 0
    back.fill = c.msgBot
    if angl then
      angl:setFillColor( unpack(c.msgBot) )
    end

    msgLbl.anchorX=0
    msgLbl.x=30+spaceLeft*.5
    
    back.width = back.width - 30
    msgLbl:setFillColor( unpack(c.textBot) )
  else
    msgLbl:setFillColor( unpack(c.textUser) )
    msgLbl.y = msgLbl.y - 5
    if tooBig then
      msgLbl.x = msgLbl.x + 100 - 5 - diff
    end
  end

  last.my = _msg.fromYou
  maxUp = -back.y+150+15
end


return {addMsg=loadMgs,listMsg=listMsg,init=init,reset=reset,addSpace=addSpace}