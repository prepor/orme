(* type model = { counter : int } *)

(* let init = { counter = 0 } *)

(* let update { counter } = function *)
(*   | `Increment -> { counter = counter + 1} *)

(* let view {counter} = *)
(*   let open Html in *)
(*   div [] [ *)
(*     text (Printf.sprintf "Hello %i times " counter); *)
(*     a [href "#"; onClick `Increment] [text "One more!"]] *)

(* let start dom_id = *)
(*   Program.simple dom_id ~update ~view ~init *)

(* module Task = Task *)


(* let () = *)
(*   let json = Js.Json.parse "[1, 2, 3]" in *)
(*   let p = Json.Decoder.list Json.Decoder.int in *)
(*   let parsed = p json in *)
(*   List.iter (fun i -> Js.log i) parsed *)


(* let () = *)
(*   let p = Json.Decoder.(obj (fun a b -> (a, b)) *)
(*                         |> required "foo" string *)
(*                         |> required "bar" int) in *)
(*   match Json.Decoder.decode_string p "{\"foo\":\"Hello\", \"bar\": null}" with *)
(*   | Result.Ok (foo, bar) -> *)
(*     Js.log @@ Printf.sprintf "Foo: %s, bar: %i" foo bar *)
(*   | Result.Error err -> *)
(*     Js.log err *)


(* let () = *)
(*   let p = Json.Decoder.(at ["foo"; "bar"] string) in *)
(*   match Json.Decoder.decode_string p "{\"foo\":{\"bar\": 1}}" with *)
(*   | Result.Ok v -> *)
(*     Js.log @@ Printf.sprintf "Foo->bar: %s" v *)
(*   | Result.Error err -> *)
(*     Js.log err *)
