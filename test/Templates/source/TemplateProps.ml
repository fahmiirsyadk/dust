module H = Internal__Dust_Syntax.Html.Elements

let main (animals: string array) =
  let animals = animals |> Array.to_list in
  H.html [] [
    H.body [] (
      animals |> List.map (fun animal -> H.h1 [] [animal])
    )
  ]