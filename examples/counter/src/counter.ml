open Orme
type model = { counter : int }

let init = { counter = 0 }

let update { counter } = function
  | `Increment -> { counter = counter + 1}

let view {counter} =
  let open Html in
  div [] [
    text (Printf.sprintf "Hello %i times " counter);
    a [href "#"; onClick `Increment] [text "One more!"]]

let start dom_id =
  Program.simple dom_id ~update ~view ~init
