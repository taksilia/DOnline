require "DO:main"

getbody = 0
gethead = 0
targetBodyRot = 0
targetHeadRot = 0

function on_render()
    local data = DO.playersdata[entity:get_uid()]
    if data == null then
       entity:despawn()
       return
    end

    local cp = entity.transform:get_pos();
    entity.rigidbody:set_vel({(data.pos[1] - cp[1]) * 5, (data.pos[2] - cp[2]) * 5, (data.pos[3] - cp[3]) * 5})

    targetBodyRot = tonumber(data.rotbody)
    local bodyRot = interpolateRotation(getbody, targetBodyRot, 0.2)
    entity.transform:set_rot(mat4.rotate({0, 1, 0}, bodyRot))
    getbody = bodyRot 

    targetHeadRot = tonumber(data.rothead)
    local headRot = gethead + (targetHeadRot - gethead) * 0.2 
    entity.skeleton:set_matrix(entity.skeleton:index("head"), mat4.rotate({1, 0, 0}, headRot)) 
    gethead = headRot
end
function interpolateRotation(startAngle, endAngle, t)
    local difference = endAngle - startAngle
    if math.abs(difference) > 180 then
        if difference > 0 then
            endAngle = endAngle - 360
        else
            endAngle = endAngle + 360
        end
    end

    local interpolatedAngle = startAngle + (endAngle - startAngle) * t
    return interpolatedAngle
end