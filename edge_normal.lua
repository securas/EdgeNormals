-- Based on the script from ericoporto
-- https://gist.github.com/ericoporto/f4b3553bb9bcb666c6113fe084198261

if app.apiVersion < 1 then
	return app.alert("This script requires Aseprite v1.2.10-beta3")
end
  
local cel = app.activeCel
if not cel then
	return app.alert("There is no active image")
end

local d = Dialog("Edge Normal Map")
d:check{ id="Invert_Y", label="Invert Y:", text="", selected=true, focus=true }
 :button{ id="ok", text="&OK", focus=true }
 :button{ text="&Cancel" }
 :show()
data = d.data
if not data.ok then return end



local img0 = cel.image:clone()
local img = cel.image:clone()
local position = cel.position
local height = 1
  
if img.colorMode == ColorMode.RGB then
	local rgba = app.pixelColor.rgba
	local rgbaA = app.pixelColor.rgbaA
	for it in img:pixels() do
		local x = it.x
		local y = it.y
		local top = 2
		local left = 2
		local right = 2
		local bottom = 2
		local maxx = img.width - 1
		local maxy = img.height - 1
		it( rgba( 0, 0, 0, 0 ) )

		-- only works on pixels with color
		if rgbaA( img0:getPixel(x, y) ) == 255 then

			-- Detect Edges around pixel
			local topleft = 0
			local top = 0
			local x_dir = 0
			local y_dir = 0
			
			-- top left
			if( x == 0 and y == 0 ) or ( x == 0 ) or ( y == 0 ) or ( rgbaA( img0:getPixel( x - 1, y - 1 ) ) < 255 ) then
				x_dir = x_dir - 1
				y_dir = y_dir - 1
			end

			-- top
			if( y == 0 ) or ( rgbaA( img0:getPixel(x, y - 1 ) ) < 255 ) then
				y_dir = y_dir - 1
			end

			-- top right
			if( x == maxx and y == 0 ) or ( x == maxx ) or ( y == 0 ) or ( rgbaA( img0:getPixel( x + 1, y - 1 ) ) < 255 ) then
				x_dir = x_dir + 1
				y_dir = y_dir - 1
			end

			-- left
			if( x == 0 ) or ( rgbaA( img0:getPixel( x - 1, y ) ) < 255 ) then
				x_dir = x_dir - 1
			end

			-- right
			if( x == maxx ) or ( rgbaA( img0:getPixel( x + 1, y ) ) < 255 ) then
				x_dir = x_dir + 1
			end

			-- bottom left
			if( x == 0 and y == maxy ) or ( x == 0 ) or ( y == maxy ) or ( rgbaA( img0:getPixel( x - 1, y + 1 ) ) < 255 ) then
				x_dir = x_dir - 1
				y_dir = y_dir + 1
			end

			-- bottom
			if( y == maxy ) or ( rgbaA( img0:getPixel(x, y + 1 ) ) < 255 ) then
				y_dir = y_dir + 1
			end

			-- bottom right
			if( x == maxx and y == maxy ) or ( x == maxx ) or ( y == maxy ) or ( rgbaA( img0:getPixel( x + 1, y + 1 ) ) < 255 ) then
				x_dir = x_dir + 1
				y_dir = y_dir + 1
			end

			--if math.abs( x_dir ) > 0 or math.abs( y_dir ) > 0 then
				
				-- process pixels that have a valid direction
				local normalization = math.sqrt( x_dir * x_dir + y_dir * y_dir + height * height )
				x_dir = x_dir / normalization
				y_dir = -y_dir / normalization
				if data.Invert_Y then
					y_dir = -y_dir
				end
				local z_dir = height / normalization

				--print( x_dir, y_dir, z_dir )

				-- convert direction into color
				local color_dir = rgba( 
					math.floor( ( x_dir * 0.5 + 0.5 ) * 255 ), 
					math.floor( ( y_dir * 0.5 + 0.5 ) * 255 ),
					math.floor( ( z_dir * 0.5 + 0.5 ) * 255 ), 255 )
				it( color_dir )
			
			--end

		end
    end

  elseif img.colorMode == ColorMode.GRAY then
    return app.alert("This script is only for RGB Color Mode")
  elseif img.colorMode == ColorMode.INDEXED then
    return app.alert("This script is only for RGB Color Mode")
  end


  local sprite = app.activeSprite
  local frame = app.activeFrame
  local currentLayer = app.activeLayer
  local newLayerName = currentLayer.name .. "_NormalGenerated"
  local newLayer = nil
  for i,layer in ipairs(sprite.layers) do
    if layer.name == newLayerName then
        -- the layer to write normal on is already exists
        newLayer = layer
    end
  end
  if newLayer == nil then
    newLayer = sprite:newLayer()
    newLayer.name = newLayerName
  end
  local newCel = sprite:newCel(newLayer, frame, img, position)

  app.refresh()
