module Obj = struct
  type t
  external create : unit -> t = "" [@@bs.obj]

  (* external set : t -> string -> 'a Js.t -> unit = "" [@@bs.set_index] *)
  external set_string : t -> string -> string -> unit = "" [@@bs.set_index]
  external set_bool : t -> string -> Js.boolean -> unit = "" [@@bs.set_index]
  external set_event_handler : t -> string -> (Orme_json.value -> unit [@bs]) -> unit = "" [@@bs.set_index]
  external set_obj : t -> string -> t -> unit = "" [@@bs.set_index]

end

class type ['a] _node = object
  method appendChild : 'a -> unit
end [@bs]

type node = node _node Js.t

external document : node = "document" [@@bs.val]

external get_by_id : node -> string -> node Js.null = "getElementById" [@@bs.send]

let boolean_of_bool = function
  | true -> Js.true_
  | false -> Js.false_
