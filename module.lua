local HttpService = game:GetService("HttpService")
local API = ".com/apis/ai/imagetocolor3.php"
local ImageKey = "?Image="

local function DecodeImage(Data, PixelsPerSecond)
	local Success, Decoded = pcall(function() return HttpService:JSONDecode(Data) end)
	if not Success then
		error(Data)
	end
	local Data = Decoded
	local NewData = {}
	local PixelsPerSecond = PixelsPerSecond or 600
	local PassedPixels = 0
	
	print("Setting data.")
	for _, Value in pairs(Data) do
		NewData[#NewData+1] = {X = Value[1], Y = Value[2], Color = Color3.new(Value[3][1]/255, Value[3][2]/255, Value[3][3]/255)}
		PassedPixels = PassedPixels + 1
		if PassedPixels >= PixelsPerSecond then
			PassedPixels = 0
			coroutine.yield()
		end
	end
	
	print("Set data.")
	return NewData
end

local function DrawImage(URL, Type, Size, Resolution, PixelsPerSecond, PrintPercentage, Part)
	local URL = API .. ImageKey .. URL
	local Type = Type or "Frame"
	local PixelsPerSecond = PixelsPerSecond or 60
	local PassedPixels = 0
	local MaxX = 0
	local MaxY = 0

	print("Getting image data.")
	local Data = HttpService:GetAsync(URL, true)
	print("Decoding image.")
	local Decoded = DecodeImage(tostring(Data):sub(0,#Data-154))
	print("Decoded image.")
	
	local PixelsParent
	local SurfaceGui
	
	print("Getting Resolution.")
	
	for _, Data in pairs(Decoded) do
		local X, Y = Data.X+1, Data.Y+1
		if X > MaxX then
			MaxX = X
		end
		if Y > MaxY then
			MaxY = Y
		end
	end
	
	print("Resolution: "..MaxX.."*"..MaxY)
	print("Generating type:"..Type)
	
	if Type == "Frame" then
		PixelsParent = Instance.new("Part", workspace)
		PixelsParent.CFrame = CFrame.new(1e6, 1e6, 1e6)
		SurfaceGui = Instance.new("SurfaceGui", PixelsParent)
		PixelsParent.FormFactor = "Custom"
		PixelsParent.CanCollide = false
		PixelsParent.Anchored = true
		PixelsParent.Transparency = 1
		PixelsParent.Size = Vector3.new(MaxX/100*Size, MaxY/100*Size, .1)
		SurfaceGui.CanvasSize = Vector2.new(MaxX, MaxY)
	elseif Type == "Brick" then
		PixelsParent = Instance.new("Model", workspace)
	end
	
	if Part then
		PixelsParent.Parent = Part
	end
	
	local Pixels = (MaxX+1)*(MaxY+1)/Resolution
	local GeneratedPixels = 0
	
	for _, Data in pairs(Decoded) do
		if Data.X % Resolution == 0 and Data.Y % Resolution == 0 then
			if Type == "Frame" then
				local NewPixel = Instance.new("Frame", SurfaceGui)
				NewPixel.Size = UDim2.new(0, Resolution, 0, Resolution)
				NewPixel.Position = UDim2.new(0, Data.X, 0, Data.Y)
				NewPixel.BackgroundColor3 = Data.Color
				NewPixel.BorderSizePixel = 0
			elseif Type == "Brick" then
				local NewPixel = Instance.new("Part", PixelsParent)
				local SpecialMesh = Instance.new("SpecialMesh", NewPixel)
				NewPixel.FormFactor = "Custom"
				NewPixel.Size = Vector3.new(1*Resolution*Size, 1*Resolution*Size, .1)
				NewPixel.CFrame = CFrame.new(Data.X*Size, MaxY*Size-Data.Y*Size, 0)
				NewPixel.TopSurface, NewPixel.BottomSurface, NewPixel.RightSurface, NewPixel.LeftSurface, NewPixel.BackSurface, NewPixel.FrontSurface = "SmoothNoOutlines","SmoothNoOutlines","SmoothNoOutlines","SmoothNoOutlines","SmoothNoOutlines","SmoothNoOutlines"
				NewPixel.Anchored = true
				
				SpecialMesh.MeshId = "http://www.roblox.com/Asset/?id=9856898"
				SpecialMesh.TextureId = "rbxassetid://275610628"
				SpecialMesh.Scale = NewPixel.Size*2
				SpecialMesh.VertexColor = Vector3.new(Data.Color.r, Data.Color.g, Data.Color.b)
			end
			GeneratedPixels = GeneratedPixels + Resolution
			PassedPixels = PassedPixels + 1
			if PassedPixels >= PixelsPerSecond then
				local WaitTime = wait()
				local PixelsLeft = (Pixels-GeneratedPixels)
				if PrintPercentage then
					print(math.floor(100/Pixels*GeneratedPixels) .. "% Complete (".. PixelsLeft .." to go. Time left: ".. math.ceil(PixelsLeft/PixelsPerSecond*WaitTime) ..")")
				end
				PassedPixels = 0
			end
		end
	end
	
	if PixelsParent:IsA("Part") then
		PixelsParent.CFrame = Part:IsA("Part") and Part.CFrame * CFrame.new(0, Part.Size.Y/2+PixelsParent.Size.Y/2, 0) or PixelsParent.CFrame
	end
	
	print("Generated")
end

return function(Url)
	if tostring(Url):lower():sub(1,4) == "http" then
		pcall(function()
			DrawImage(Url,"Frame",25,2,_,true,workspace.Base)
		end)
	end
end
