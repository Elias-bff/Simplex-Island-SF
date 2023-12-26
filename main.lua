--@name Simplex island
--@include Simplex island/misc.lua
--@include VivaGUI/vivagui.lua
--@include simplex3d.txt
--@author Elias

if SERVER then
    local src=chip():isWeldedTo()
    
    if src then
        src:linkComponent(chip())
    end
else
    misc=require("Simplex island/misc.lua")
    require("VivaGUI/vivagui.lua")           --Required libs in files
    require("simplex3d.txt")                 --Required libs in files

    local sunpos=Vector(512,512)
    local thread
    local usage={}
    local fps={}
    paused=true
    radius=300
    mutate=10*math.random()
    scale=1
    ratio=10
    tide=5
    data={}
    peak=3.5
    sun=false
    
    render.createRenderTarget("fractal")

    hook.add("render","",function()
        if !data.src then
            data.src=render.getScreenInfo(render.getScreenEntity())
        end

        render.setRenderTargetTexture("fractal")
        render.drawTexturedRect(0,0,1024,1024)
        
        if !data.loaded then
            render.selectRenderTarget("fractal")
            
            if !thread then
                thread=coroutine.create(function()
                    for y=0,512/ratio do
                        for x=0,(1024/data.src.RatioX)/ratio do
                            controls.name="Simplex Island - "..math.round(((y*ratio)/512)*100,1).."%"

                            local noise=sim((x*scale/100)*ratio,(y*scale/100)*ratio,mutate,scale,ratio)
                            noise=(noise+0.2)+misc.circle(x,y,ratio,peak)

                            local color=misc.colorMap(math.clamp(noise*127.5,0,255))
                            
                            --1. noise => test
                            --2. test <= test + circle
                            --3. test <= selection to color
                            --4. color <= test / shadow results <-- Not done

                            --t=math.clamp(misc.pixelRay(x*ratio,y*ratio,sunpos[1],sunpos[2],mutate,scale,ratio,peak)*127.5,0,255)
                            --render.setColor(Color(t,t,t))
                            --render.drawRect(x*2,y*2,2,2)
                            --misc.pixelRay(x,y,sunpos[1],sunpos[2],ratio)
                            
                            render.setColor(color)
                            render.drawRect(x*ratio,y*ratio,ratio,ratio)
                            
                            if quotaAverage()>0.006*0.8 then
                                coroutine.yield()
                            end
                        end
                    end
                end)
            end

            if coroutine.status(thread)=="suspended" and quotaAverage()<0.006*0.9 then
                coroutine.resume(thread)
            end
            
            if coroutine.status(thread)=="dead" then
                controls.name="Simplex Island"
                thread=nil
                
                if paused then
                    data.loaded=true
                end
            end
        end

        if !thread and !paused then
            data.loaded=false
        end

        render.selectRenderTarget()

        viva.render()
    end)
    
    --==-VivaGUI Controls/misc start here-==--

    timer.create("vivaLogs",0.05,0,function()
        usage[0]=((quotaAverage()/quotaMax())*15.5)-7.75

        for i=0,100 do
            usage[101-i]=usage[100-i] or 0
        end
        
        fps[0]=(math.clamp(math.floor(math.floor(cpuMax()*100000)/math.floor(cpuAverage()*10000)),0,1000)/4)-7.75

        for i=0,100 do
            fps[101-i]=fps[100-i] or 0
        end
    end)
    
    viva.inputEvent=function()
        if sun then
            data.loaded=false
            sunpos=Vector(x,y)
        end
    end

    controls=viva:new("Simplex Island",{
        x=0,
        y=0,
        width=150,
        height=200,
        active=false
    },nil,function(self)
        self:plotLines("Usage",usage,function()
            return math.round(((usage[0]+7.75)/15.5)*100).."%"
        end)
        
        self:plotLines("FPS",fps,function()
            return (fps[0]+7.75)*4
        end)
        
        self:collapsingHeader("Simplex Nose",{})
        
        self:slider("Scale","scale",{
            min=0.1,
            max=4,
        },function(float)
            return string.format("%.2f",float)
        end,function()
            data.loaded=false
            thread=nil
        end)
        
        self:slider("Mutate","mutate",{
            min=0,
            max=10,
        },function(float)
            return string.format("%.2f",float)
        end,function()
            data.loaded=false
            thread=nil
        end)
        
        self:separatorText("Island")
        
        self:slider("Radius","radius",{
            min=50,
            max=500,
        },function(float)
            return string.format("%.0f",float)
        end,function()
            data.loaded=false
            thread=nil
        end)
        
        self:slider("Peak","peak",{
            min=1,
            max=5,
        },function(float)
            return string.format("%.1f",float)
        end,function()
            data.loaded=false
            thread=nil
        end)
        
        self:slider("Tide","tide",{
            min=1,
            max=30,
        },function(float)
            return string.format("%.1f",float)
        end,function()
            data.loaded=false
            thread=nil
        end)
        
        self:endHeader()
        
        self:collapsingHeader("Rendering",{})
        
        self:slider("Render ratio","ratio",{
            min=1,
            max=10,
        },function(float)
            return string.format("%.1f",float)
        end,function()
            data.loaded=false
            thread=nil
        end)
        
        self:checkbox("Pause auto-render","paused")
        
        --self:checkbox("Toggle sun (click event)","sun")
    end)
  
    hitboxes.filter=function(key)
        if table.hasValue({15,107},key) then
            return true
        end
    end
end