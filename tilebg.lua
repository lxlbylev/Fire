
local function tileImage(ImagePath,width,height,tileSize,offSetX,offSetY)
   
	local isImageExsist = display.newImageRect(ImagePath,1,1)
	if not isImageExsist then error("TileImage: bad argument #1 (image '".. ImagePath .. "'' not found)") end
	if type(width)~="number" then error("TileImage: bad argument #2 (number expected, got ".. type(width) ..")") end
	if type(height)~="number" then error("TileImage: bad argument #3 (number expected, got ".. type(height) ..")") end
	if type(tileSize)~="number" then error("TileImage: bad argument #4 (number expected, got ".. type(tileSize) ..")") end
	display.remove(isImageExsist)
	
	--Calculate how manytimes to repeat the image based on display size, math.ceil roundup for loops
	local bgRepeatX=math.ceil(width/tileSize) --number of times to repeat bg on x axis
	local bgRepeatY=math.ceil(height/tileSize) --number of times to repeat bg on y axis

	if offSetX~=nil and offSetX~=0 then
		local ost = math.abs(offSetX)%tileSize
		if offSetX>0 then offSetX = ost
		else offSetX = -ost end
	else
		offSetX = 0
	end

	if offSetY~=nil and offSetY~=0 then
		local ost = math.abs(offSetY)%tileSize
		if offSetY>0 then offSetY = ost
		else offSetY = -ost end
	else
		offSetY = 0
	end

	--Useful debug info
	-- print ("TileImage: ImagePath: " .. ImagePath)
	-- print ("TileImage: width: " .. width)
	-- print ("TileImage: height: " .. height)
	-- print ("TileImage: bgRepeatX: " .. bgRepeatX .. " (number of times to repeat bg on X axis)")
	-- print ("TileImage: bgRepeatY: " .. bgRepeatY .. " (number of times to repeat bg on Y axis)")
	-- print ("TileImage: offSetX: " .. offSetX)
	-- print ("TileImage: offSetY: " .. offSetY)
	
	--Loop through and place the image
	local tilesGroup = display.newGroup()

	local container = display.newContainer(width,height)
	tilesGroup:insert(container)
	container:translate(width*.5, height*.5)

	local startX = -width*.5 --start at origin
	if offSetX~=0 then
		bgRepeatX = bgRepeatX + 1
		startX = startX + offSetX - tileSize * (offSetX > 0 and 1 or 0)
	end

	local bgLocationY = -height*.5 --start at origin
	if offSetY~=0 then
		bgRepeatY = bgRepeatY + 1
		bgLocationY = bgLocationY + offSetY - tileSize * (offSetY > 0 and 1 or 0)
	end

	for bgY=1,bgRepeatY do
		local bgLocationX = startX --reset x position each time we go to next row
		for bgX=1,bgRepeatX do
			local tile = display.newImageRect( ImagePath, tileSize, tileSize )
			container:insert( tile)
			tile.x, tile.y = bgLocationX, bgLocationY
			tile.anchorX, tile.anchorY = 0, 0
			-- print ("TileImage: Placed tile at x,y: " .. bgLocationX .. "," .. bgLocationY)
			bgLocationX=bgLocationX+tileSize
		end
		bgLocationY=bgLocationY+tileSize
	end

    -- print ( "textureMemoryUsed: " .. system.getInfo( "textureMemoryUsed" ) )
   	
   	--a function to cleanup the bg
	function tilesGroup.remove()
		if container.numChildren then
			-- print ("TileImage: Removing " .. container.numChildren .. " images from background.")
			while container.numChildren > 0 do   -- we have have tiles left in the tilesGroup group, so first clean them out		
				container:remove(container.numChildren) -- clean out the last member of the group (work from the top down!)
			end
		end	
		container:removeSelf() --whats left is now an empty group. remove it.
		tilesGroup:removeSelf() --whats left is now an empty group. remove it.
	    -- print ("TileImage: Removed")
		return
	end
 
   --Send everything back to mama
   return tilesGroup
end

return tileImage