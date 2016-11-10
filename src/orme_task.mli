module Ivar : sig
  type 'a t

  val create : (('a -> unit) -> unit) -> 'a t
  val bind : 'a t -> ('a -> 'b t) -> 'b t
  val realized : 'a -> 'a t
end

type ('ok, 'err) t

val create : (('ok -> unit) -> ('err -> unit) -> unit) -> ('ok, 'err) t

val bind : ('ok, 'err) t -> ('ok -> ('a, 'err) t) -> ('a, 'err) t

val (>>=) : ('ok, 'err) t -> ('ok -> ('a, 'err) t) -> ('a, 'err) t

val succeed : 'ok -> ('ok, 'err) t

val fail : 'err -> ('ok, 'err) t
