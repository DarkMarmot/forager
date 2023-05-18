   
function move(view)
    fruit = biggest(view.fruits)
    direction = towards(fruit, view.me)
    if direction == "here" then
        return "bite"
    else
        return direction
    end        
end