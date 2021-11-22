module H = Dust.Html.Elements
module A = Dust.Html.Attributes

let boxStyle = A.style "border: 10px solid green; padding: 10px;"
let box = 
  H.div [ boxStyle ] (H.text "box alive here")