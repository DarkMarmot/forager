function is_fruit_here(view)
    me = view.me
    for _, f in ipairs(view.fruits) do
        if f.x == me.x and f.y == me.y then
            return true
        end    
    end 
    return false   
end    

function random_direction()
    n = random_int(4)
    directions = {"north", "east", "south", "west"}
    return directions[n]
end  

function move(view)
    if is_fruit_here(view) then
        return "bite"
    else
        return random_direction()
    end        
end