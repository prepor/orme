type 'msg t = ('msg -> unit) -> Vdom.t

type value =
  | String of string
  | Bool of bool
  | Obj of Browser.Obj.t

type 'msg prop =
  | Attribute of (string * value)
  | Event of (string * 'msg Json.Decoder.t)

let tag n attrs children =
  fun clb ->
    let attrs' = Browser.Obj.create () in
    List.iter (function
        | Attribute (k, v) -> begin
            match v with
            | String v -> Browser.Obj.set_string attrs' k v
            | Obj v -> Browser.Obj.set_obj attrs' k v
            | Bool v -> Browser.Obj.set_bool attrs' k (Browser.boolean_of_bool v)
          end
        | Event (k, decoder) ->
          Browser.Obj.set_event_handler attrs' k (fun [@bs] e ->
              match Json.Decoder.decode_value decoder e with
              | Result.Ok v -> clb v
              | Result.Error err -> Js.log ("Error while event handling:", err)))
      attrs;
    let children' = List.map (fun v -> v clb) children in
    Vdom.node n attrs' (Array.of_list children')

let text txt _clb = Vdom.text txt

let draw view clb =
  view clb

module Tags = struct
  let div attrs children = tag "div" attrs children
  let section attrs children = tag "section" attrs children
  let a attrs children = tag "a" attrs children
  let header attrs children = tag "header" attrs children
  let footer attrs children = tag "footer" attrs children
  let h1 attrs children = tag "h1" attrs children
  let input attrs children = tag "input" attrs children
  let button attrs children = tag "button" attrs children
  let label attrs children = tag "label" attrs children
  let ul attrs children = tag "ul" attrs children
  let li attrs children = tag "li" attrs children
  let strong attrs children = tag "strong" attrs children
  let p attrs children = tag "p" attrs children
  let span attrs children = tag "span" attrs children
end

(* let append_child v = *)
(*   let doc = Dom.get_by_id Dom.document "main" in *)
(*   doc##appendChild v *)

let obj_of_alist l =
  let obj = Browser.Obj.create () in
  List.iter (fun (k, v) -> Browser.Obj.set_string obj k v) l;
  obj

module Attributes = struct
  let string k v = Attribute (k, String v)
  let bool k v = Attribute (k, Bool v)
  let id v = string "id" v
  let href v = string "href" v
  let className v = string "className" v
  let style v = Attribute ("style", Obj (obj_of_alist v))
  let placeholder v = string "placeholder" v
  let autofocus v = bool "autofocus" v
  let value v = string "value" v
  let name v = string "name" v
  let type' v = string "type" v
  let for' v = string "htmlFor" v
  let checked v = bool "checked" v
  let hidden v = bool "hidden" v

  (* FIXME optimize *)
  let classList l =
    string "className"
      (l
       |> List.filter (fun (_, v) -> v)
       |> List.map (fun (v, _) -> v)
       |> String.concat " ")
end

module Events = struct
  let on event d = Event (("on" ^ event), d)
  let onClick v = on "click" @@ Json.Decoder.succeed v
  let onInput v = on "input" Json.Decoder.(map v @@ at ["target"; "value"] string)
  let onDoubleClick v = on "dbclick" @@ Json.Decoder.succeed v
  let onBlur v = on "blur" @@ Json.Decoder.succeed v

  let keyCode = Json.Decoder.(object1 ("keyCode" := int))
end

include Tags
include Attributes
include Events
