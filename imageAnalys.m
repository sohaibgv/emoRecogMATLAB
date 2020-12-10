function [item]=imageAnalys(im)
[formfactor, area] = imageRecog(im);
if formfactor >0.9
    if area > 40000
        item = "fifty cent"
    elseif area > 35000
        item = "one euro"
    elseif area > 20000
        item = "ten cent"
    end
elseif formfactor >0.4
    item = "Key"
else 
    if area > 50000
    item = "pen"
    elseif area > 5000
        item = "pin"
    end
end