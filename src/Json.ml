open Js.Json
type value = Js.Json.t

let type_of (x : value) =
  if Js.typeof x = "string" then
    "string" else
  if Js.typeof x = "number" then
    "number"  else
  if Js.typeof x = "boolean" then
    "boolean" else
  if (Obj.magic x) == Js.null then
    "null" else
  if Js.to_bool @@ Js_array.isArray x then
    "array"
  else
    "object"

module Decoder = struct
  type 'a t = (value -> 'a)

  type 'a field = (value Js_dict.t -> 'a)

  exception Error of (string * string list)

  let raise_error e = raise @@ Error e

  let type_error expected x =
    raise_error (Printf.sprintf "Expected %s, got %s" expected (type_of x), [])

  let string x = match reify_type x with
    | String, v -> v
    | _, _ -> type_error "string" x

  let int x = match reify_type x with
    | Number, v -> int_of_float v
    | _, _ -> type_error "number" x

  let float x = match reify_type x with
    | Number, v -> v
    | _, _ -> type_error "number" x

  let bool x = match reify_type x with
    | Boolean, v -> Js.to_bool v
    | _, _ -> type_error "boolean" x

  let null v x = match reify_type x with
    | Null, _ -> v
    | _, _ -> type_error "null" x

  let list d x = match reify_type x with
    | Array, v -> Array.map d v |> Array.to_list
    | _, _ -> type_error "array" x

  let array d x = match reify_type x with
    | Array, v -> Array.map d v
    | _, _ -> type_error "array" x

  let array_size_error expected v =
    raise_error (Printf.sprintf "Expected array[of size %i], got array[of size %i]"
                   expected (Array.length v), [])

  let tuple1 d x = match reify_type x with
    | Array, [|a|] -> d a
    | Array, v -> array_size_error 1 v
    | _, _ -> type_error "array" x

  let tuple2 da db x = match reify_type x with
    | Array, [|a; b|] -> (da a, db b)
    | Array, v -> array_size_error 2 v
    | _, _ -> type_error "array" x

  let tuple3 da db dc x = match reify_type x with
    | Array, [|a; b; c|] -> (da a, db b, dc c)
    | Array, v -> array_size_error 3 v
    | _, _ -> type_error "array" x

  let tuple4 da db dc dd x = match reify_type x with
    | Array, [|a; b; c; d|] -> (da a, db b, dc c, dd d)
    | Array, v -> array_size_error 4 v
    | _, _ -> type_error "array" x

  let (:=) field d x = match Js.Undefined.to_opt @@ Js.Dict.get x field with
    | Some v -> (try d v with Error (v, path) -> raise_error (v, field::path))
    | None -> raise_error (Printf.sprintf "No field %s" field, [])

  let succeed v _ = v

  let object1 d x = match reify_type x with
    | Object, v -> (d v)
    | _, _ -> type_error "object" x

  let object2 f da db x = match reify_type x with
    | Object, v -> f (da v) (db v)
    | _, _ -> type_error "object" x

  let rec at path d x = match path with
    | [] -> d x
    | p::path ->
      let f = p := (at path d) in
      object1 f x

  let map f d x =
    f (d x)

  let obj = succeed

  let custom a b x = match reify_type x with
    | Object, v -> (b x) (a v)
    | _, _ -> type_error "object" x

  let required field val_dec dec x =
    custom (field := val_dec) dec x

  let decode_value d v =
    try Result.ok @@ d v with
    | Error (s, path) -> begin
        Result.err @@ match path with
        | [] -> s
        | path -> Printf.sprintf "%s at %s" s (String.concat " / " path)
      end

  let decode_string d s =
    try decode_value d @@ Js.Json.parse s with
    | _ -> Result.err "JSON parsing error"

end
