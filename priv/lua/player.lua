function distance(item1, item2) 
    return math.abs(item1.x - item2.x) + math.abs(item1.y - item2.y)
end 

function nearest(items, from)
    table.sort(items, function (i1, i2) return distance(i1, from) < distance(i2, from) end)
    return items[1]
end 

function biggest(items)
    table.sort(items, function (f1, f2) return f1.value > f2.value end)
    return items[1]
end 

function towards(target, from) 
    if target.x < from.x then
      return "west"
    elseif target.x > from.x then  
      return "east"
    elseif  target.y < from.y then
        return "north"
    elseif target.y > from.y then
        return "south"
    else
        return "here"
    end
end
