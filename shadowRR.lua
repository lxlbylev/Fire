local function roundedRectAndShadow(options)

  local width = options.width
  local height = options.height
  local cornerRadius = options.cornerRadius
  
  if type(width)~="number" then error("bad argument \"width\" (number expected, got ".. type(width) ..")") end
  if type(height)~="number" then error("bad argument \"height\" (number expected, got ".. type(height) ..")") end
  if type(cornerRadius)~="number" then error("bad argument \"cornerRadius\" (number expected, got ".. type(cornerRadius) ..")") end

  local x = options.x or 0
  local y = options.y or 0
  local anchorX = options.anchorX or .5
  local anchorY = options.anchorY or .5
  local sWidth = options.shadeWidth or 10
  local color = options.color or {1}

  sWidth = sWidth - 2

  local parent = options.parent

  local alpha = .15

  local filename = "shadow"..width.."x"..height.."x"..sWidth.."x.png"

  local thisButton = display.newGroup()
  if parent then
    parent:insert(thisButton)
  end
  x = x - (width*(anchorX-.5))
  y = y - (height*(anchorY-.5))
  thisButton.x = x
  thisButton.y = y

  local shadow = display.newImageRect( thisButton, filename, system.DocumentsDirectory, width+sWidth+50, height+sWidth+50 )

  local rect = display.newRoundedRect( thisButton, 0, 0, width, height, cornerRadius )
  rect:setFillColor(unpack(color))
  thisButton.rect = rect
  
  if shadow==nil then
    local shadow = display.newGroup()
    shadow.x, shadow.y = display.contentCenterX, display.contentCenterY

    local shadeZone = display.newRoundedRect( shadow, 0, 0, width+sWidth+50, height+sWidth+50, cornerRadius )
    shadeZone.alpha = .001
    local shadowFiller = display.newRoundedRect( shadow, 0, 0, width+sWidth, height+sWidth, cornerRadius )
    shadowFiller:setFillColor(0,0,0,alpha)

    timer.performWithDelay(100, function()
      local imageShadow = display.capture(shadow)
      display.remove(shadow)
      imageShadow.x, imageShadow.y = display.contentCenterX, display.contentCenterY

      imageShadow.fill.effect = "filter.blurGaussian"
      imageShadow.fill.effect.horizontal.blurSize = 30 
      imageShadow.fill.effect.vertical.blurSize = 30 
      imageShadow.fill.effect.horizontal.sigma = 20
      imageShadow.fill.effect.vertical.sigma = 20

      display.save(imageShadow, { filename=filename, baseDir=system.DocumentsDirectory})

      thisButton:insert(imageShadow)
      imageShadow.x, imageShadow.y = 0, 0
      imageShadow:toBack()

    end)
  end
  
  local shadeZone = display.newRoundedRect( thisButton, 0, 0, width+sWidth+50, height+sWidth+50, cornerRadius )
  shadeZone.alpha = .001

  return thisButton
end

return roundedRectAndShadow