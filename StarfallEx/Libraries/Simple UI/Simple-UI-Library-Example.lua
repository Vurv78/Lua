--@name UI Example
--@author Vurv
--@client
--@include modules/ui.txt

ui = require("modules/ui.txt")
Font = render.createFont("Roboto",256,true,true)

local function loadMain(C)
    render.selectRenderTarget("rt")
        render.setColor(C)
        render.drawRect(0,0,1024,1024)
    render.selectRenderTarget()
end

btn = ui.createButton(256,256,512,512,Color(255,0,0),"Test",Font)
btn:whenPressedRender(function(self,changed)
    if changed then
        loadMain(Color(math.random(1,255),math.random(1,255),math.random(1,255)))
    end
end)
ui.reloadUI()
render.createRenderTarget("rt")

-- Load screen for the first time
hook.add("renderoffscreen","",function() loadMain(Color(0,255,0)) hook.remove("renderoffscreen","") end)

hook.add("render","",function()
    render.setRenderTargetTexture("rt")
    render.setRGBA(255,255,255,255)
    render.drawTexturedRect(0,0,512,512)
    ui.drawUI()
end)
