module H = Dust.Html.Elements
module P = Dust.Html.Properties

let main () = 
  H.html [ P.lang "en" ] [
    H.body [] [
      H.h1 [] (H.text "test it out");
      H.a [
        P.disabled true;
        P.rel__a `Nofollow
      ] (H.text "link bokep")
    ]
  ]


let () = Js.log (main ())