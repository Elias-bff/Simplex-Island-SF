return {
    circle=function(x,y,ratio,peak)
        return (0.7+-Vector(x*ratio,y*ratio):getDistance(Vector(512/data.src.RatioX/2,512/2))/radius)*peak
    end,
    colorMap=function(value)
        if value<=31.875+math.sin(timer.realtime())*tide then
            value=misc.mix({54,88,195},{83,166,207},value/31.875)
        elseif value<=63.75 then
            value=misc.mix({83,166,207},{236,236,195},value/63.75)
        elseif value<=95.625 then
            value=misc.mix({236,236,195},{122,212,51},value/95.625)
        elseif value<=127.5 then
            value=misc.mix({122,212,51},{56,166,65},value/127.5)
        elseif value<=159.375 then
            value=misc.mix({56,166,65},{132,116,102},value/159.375)
        elseif value<=191.25 then
            value=misc.mix({132,116,102},{111,111,111},value/191.25)
        elseif value<=223.125 then
            value=misc.mix({111,111,111},{255,255,255},value/223.125)
        else
            value=misc.mix({value,value,value},{255,255,255},value/255)
        end

        return value
    end,
    mix=function(a,b,percent)
        return Color(a[1]-(a[1]-b[1])*percent, a[2]-(a[2]-b[2])*percent, a[3]-(a[3]-b[3])*percent)
    end,
    pixelRay=function(x,y,x2,y2,ratio)-- <-- not done
        local dx = x2 - x
        local dy = y2 - y
        local D = 2 * dy - dx
        local y = y/ratio

        for x = x/ratio, x2/ratio do
            --render.drawRect(x*ratio,y*ratio,ratio,ratio)

            if D > 0 then
                y = y + 1
                D = D - 2 * dx
            end

            D = D + 2 * dy
        end
    end
}