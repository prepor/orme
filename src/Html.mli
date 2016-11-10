type 'msg t
type 'msg prop

val draw : 'msg t -> ('msg -> unit) -> Vdom.t

module Tags : sig
  val div : 'msg prop list -> 'msg t list -> 'msg t
  val a : 'msg prop list -> 'msg t list -> 'msg t
  val header : 'msg prop list -> 'msg t list -> 'msg t
  val footer : 'msg prop list -> 'msg t list -> 'msg t
  val h1 : 'msg prop list -> 'msg t list -> 'msg t
  val input : 'msg prop list -> 'msg t list -> 'msg t
  val button : 'msg prop list -> 'msg t list -> 'msg t
  val label : 'msg prop list -> 'msg t list -> 'msg t
  val ul : 'msg prop list -> 'msg t list -> 'msg t
  val li : 'msg prop list -> 'msg t list -> 'msg t
  val strong : 'msg prop list -> 'msg t list -> 'msg t
  val p : 'msg prop list -> 'msg t list -> 'msg t
  val span : 'msg prop list -> 'msg t list -> 'msg t
  val section : 'msg prop list -> 'msg t list -> 'msg t
end
val text : string -> 'msg t
module Attributes : sig
  val id : string -> 'a prop
  val href : string -> 'a prop
  val className : string -> 'a prop
  val style : (string * string) list -> 'a prop
  val placeholder : string -> 'a prop
  val autofocus : bool -> 'a prop
  val value : string -> 'a prop
  val name : string -> 'a prop
  val type' : string -> 'a prop
  val for' : string -> 'a prop
  val checked : bool -> 'a prop
  val hidden : bool -> 'a prop
  val classList : (string * bool) list -> 'a prop
end

module Events : sig
  val on : string -> 'a Json.Decoder.t -> 'a prop
  val onClick : 'a -> 'a prop
  val onInput : (string -> 'a) -> 'a prop
  val onDoubleClick : 'a -> 'a prop
  val onBlur : 'a -> 'a prop
  val keyCode : int Json.Decoder.t
end

include module type of Tags
include module type of Events
include module type of Attributes
