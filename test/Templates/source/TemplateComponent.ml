module H = Internal__Dust_Syntax.Html.Elements

let main () =
  H.html [] [
    TemplateComponentChild.head "test"
    ; H.body [] [
      TemplateComponentChild.heading "another comp"
    ]
  ]