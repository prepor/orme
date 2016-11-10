type value = Js.Json.t

val type_of : value -> string

module Decoder : sig
  type 'a t
  type 'a field

  val string : string t

  val int : int t
  val float : float t

  val bool : bool t

  val null : 'a -> 'a t

  val list : 'a t -> 'a list t

  val array : 'a t -> 'a array t


  val tuple1 : 'a t -> 'a t
  val tuple2 : 'a t -> 'b t -> ('a * 'b) t


  val (:=) : string -> 'a t -> 'a field

  val succeed : 'a -> 'a t

  val object1 : 'a field -> 'a t

  val object2 : ('a -> 'b -> 'c) -> 'a field -> 'b field -> 'c t

  val at : string list -> 'a t -> 'a t

  val map : ('a -> 'b) -> 'a t -> 'b t

  val obj : 'a -> 'a t

  val required : string -> 'a t -> ('a -> 'b) t -> 'b t

  val decode_string : 'a t -> string -> ('a, string) Result.t

  val decode_value : 'a t -> value -> ('a, string) Result.t

end
