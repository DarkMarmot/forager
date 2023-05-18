   
function move(view)
    fruit = nearest(view.fruits, view.me)
    direction = towards(fruit, view.me)
    if direction == "here" then
        return "bite"
    else
        return direction
    end        
end