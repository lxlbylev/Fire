
local tonum = tonumber
local split = function(str, pat)
    local t = {}
    local fpat = "(.-)" .. (pat or " ")
    local last_end = 1
    local s, e, cap = str:find(fpat, 1)
    while s do
        if s ~= 1 or cap ~= "" then table.insert(t,cap) end
        last_end = e+1
        s, e, cap = str:find(fpat, last_end)
    end
    if last_end <= #str then
        cap = str:sub(last_end)
        table.insert(t,cap)
    end
    return t
end
string.split = split




local crawlspaceTextColor = function(self,r,g,b)
    local r,g,b = r,g,b
    if type(r) == "string" then
        local hex = string.lower(string.gsub(r,"#",""))
        if hex:len() == 6 then
            r = tonum(hex:sub(1, 2), 16)
            g = tonum(hex:sub(3, 4), 16)
            b = tonum(hex:sub(5, 6), 16)
        elseif hex:len() == 3 then
            r = tonum(hex:sub(1, 1) .. hex:sub(1, 1), 16)
            g = tonum(hex:sub(2, 2) .. hex:sub(2, 2), 16)
            b = tonum(hex:sub(3, 3) .. hex:sub(3, 3), 16)
        end
    end
    self:cachedTextColor(r,g,b)
    r,g,b = nil, nil, nil
end

local newText = function( parent, text, xPos, yPos, width, height, font, size, rp )

    local t
    local parent, text, xPos, yPos, width, height, font, size, rp = parent, text, xPos, yPos, width, height, font, size, rp
    if type(parent) ~= "table" then
        text, xPos, yPos, width, height, font, size, rp = parent, text, xPos, yPos, width, height, font, size
        if type(width) == "number" then
            t = display.newText(text, 0, 0, width * 2, height * 2, font, size * 2)
        else
            rp = font
            t = display.newText(text, 0, 0, width, height * 2)
        end
    else
        if type(width) == "number" then
            t = display.newText(parent, text, 0, 0, width, height, font, size * 2)
        else
            rp = font
            t = display.newText(parent, text, 0, 0, width, height * 2)
        end
    end
    t.anchorX = 0
    t.anchorY = 0
    t.xScale, t.yScale, t.x, t.y = 0.5, 0.5, xPos, yPos
    t.cachedTextColor = t.setTextColor
    t.setFillColor = crawlspaceTextColor
    parent, text, xPos, yPos, font, size, rp = nil, nil, nil, nil, nil, nil
    return t
end

            --[[ ########## New Paragraphs ########## ]--

Making paragraphs is now pretty easy. You can call the paragraph
by itself, passing in the text size as the last parameter, or you
can apply various formatting properties. Right now the list of
available properties are:

font       = myCustomFont
lineHeight = 1.4
align      = ["left", "right", "center"]
color  = { 255, 0, 0 }

The method returns a group, which cannot be directly editted (yet),
but can be handled like any other group. You may position it,
transition it, insert it into another group, etc. Additionally,
All paragraph text is accessible, though not edditable, with
myParagraph.text

:: USAGE ::

    display.newParagraph( text, charactersPerLine, size or parameters )

:: EXAMPLE 1 ::

    local format = {}
    format.font = flyer
    format.size = 36
    format.lineHeight = 2
    format.align = "center"

    local myParagraph = display.newParagraph( "Welcome to the Crawl Space Library!", 15, format)
    myParagraph:center("x")
    myParagraph:fadeIn()

:: EXAMPLE 2 ::

    local myParagraph = display.newParagraph( "I don't care about formatting this paragraph, just place it", 20, 24 )

]]
local function getTextWidth(text, font, size)
    local a = display.newText(text, -100, -100, font, size)
    local width = a.width
    display.remove(a)
    return width
end

display.newVisualParagraph = function( string, width, params )
    local format; if type(params) == "number" then format={size = params} else format=params end
    -- string = string:gsub("\n", " \n ") -- не распознает новую линию \n без пробелов по краям 
    local splitString, lineCache, tempString = split(string, " "), {}, ""
    for i=1, #splitString do
        -- print("check: "..splitString[i])
        if splitString[i] == "\n" then
            -- print("\\n symbol")
            local s = string.gsub(splitString[i], '\n', '')
            lineCache[#lineCache+1]=tempString; tempString=s
        elseif getTextWidth(tempString..splitString[i],format.font, format.size) > width then
            -- print("more then max width")
            lineCache[#lineCache+1]=tempString; tempString=splitString[i].." "
        else
            -- print("xz")
            tempString = tempString..splitString[i].." "
        end
    end
    lineCache[#lineCache+1]=tempString
    local g, align = display.newGroup(), format.align or "left"
    -- print("lines: "..#lineCache)
    for i=1, #lineCache do
        g.text=(g.text or "")..lineCache[i]
        local t = newText(lineCache[i],0,( format.size * ( format.lineHeight or 1 ) ) * (i),format.font, format.size, align)
        format.color = format.color or format.textColor or {255, 255, 255}
        t:setFillColor(format.color[1],format.color[2],format.color[3])
        g:insert(t)
    end
    return g
end

display.newParagraph = function( string, width, params )
    local format; if type(params) == "number" then format={size = params} else format=params end
    -- string = string:gsub("\n", " \n ") -- не распознает новую линию \n без пробелов по краям 
    local splitString, lineCache, tempString = split(string, " "), {}, ""
    for i=1, #splitString do
        -- print("check: "..splitString[i])
        if splitString[i] == "\n" then
            -- print("\\n symbol")
            local s = string.gsub(splitString[i], '\n', '')
            lineCache[#lineCache+1]=tempString; tempString=s
        elseif #tempString + #splitString[i] > width then
            -- print("more then max width")
            lineCache[#lineCache+1]=tempString; tempString=splitString[i].." "
        else
            -- print("xz")
            tempString = tempString..splitString[i].." "
        end
    end
    lineCache[#lineCache+1]=tempString
    local g, align = display.newGroup(), format.align or "left"
    -- print("lines: "..#lineCache)
    for i=1, #lineCache do
        g.text=(g.text or "")..lineCache[i]
        local t = newText(lineCache[i],0,( format.size * ( format.lineHeight or 1 ) ) * (i),format.font, format.size, align)
        format.color = format.color or format.textColor or {255, 255, 255}
        t:setFillColor(format.color[1],format.color[2],format.color[3])
        g:insert(t)
    end
    return g
end

