--@name Texture Collector v3 Averages Edition
--@author Vurv
--@client

-- This is like the old texture collector, but a bit more optimized and gets all of the textures of the maps automagically
-- without you needing to look at them!
-- Averages edition gets the average color of a texture and saves all of the averages to textures/(map)/averages.txt in JSON format.

-- Source : https://github.com/Vurv78/starfallex-creations

if player() ~= owner() then return end

local CPUMax = 0.8 // 0-1 as a percentage.
local Materials = {}
-- locals
local readPixel = render.readPixel
local format = string.format

-- init
file.createDir("textures")
render.createRenderTarget("rt")

local function canRun()
    return quotaTotalAverage()<quotaMax()*CPUMax
end

local function quotaCheck()
    if not canRun() then coroutine.yield() end
end

local usemat = material.create("UnlitGeneric")
usemat:setInt("$flags",0)

local function main()
    local Started = timer.curtime()
    local SurfaceInfo = find.byClass("worldspawn")[1]:getBrushSurfaces()
    for K,V in pairs(SurfaceInfo) do
        local N = V:getMaterial():getName() -- Locked materials fucking useless !!!! omg!!
        quotaCheck()
        if not Materials[N] then Materials[N] = true end
    end
    print(Color(50,255,255),format("Successfully found [%d] materials!!",table.count(Materials)))
    print(Color(255,255,50),"Starting to load average color for textures")
    local Averages = {}
    for Name in next,Materials do
        printMessage(2,"Loading mat"..Name)
        local Path = format("textures/%s.txt",string.replace(Name,"/","_"))
        quotaCheck()
        if file.exists(Path) then print(Color(255,50,50),"Failed to load mat "..Name..", it already exists!") continue end
        usemat:setTexture("$basetexture",material.getTexture(Name,"$basetexture"))
        render.setMaterial(usemat)
        render.selectRenderTarget("rt")
            render.drawTexturedRect(0,0,512,512)
            render.capturePixels()
        render.selectRenderTarget()
        local Col = Color(0,0,0)
        for X = 0,511 do
            for Y = 0,511 do
                quotaCheck()
                local C = readPixel(X,Y)
                Col = Color(Col.r + C.r,Col.g + C.g,Col.b + C.b)
            end
        end
        local Av = Color(Col.r/512^2,Col.g/512^2,Col.b/512^2)
        print(Av,"Loaded average color for "..Name)
        Averages[Name] = {Col.r,Col.g,Col.b} -- Save as table for json.
        quotaCheck()
    end
    local M = game.getMap()
    print(Color(50,255,50),format("Saved texture averages in JSON to textures/%s/averages.txt",M))
    file.write(format("textures/%s/averages.txt",M),json.encode(Averages))
    print("Finished in "..tostring(timer.curtime()-Started).."s")
    return true
end

co = coroutine.create(main)

hook.add("renderoffscreen","",function()
    if coroutine.status(co) ~= "dead" then
        if canRun() then
            coroutine.resume(co)
        end
    end
end)