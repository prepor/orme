type ('res, 'rej) t

(* then *)
val then_ : ('res, 'rej) t -> ('res -> ('a, 'b) t) -> ('a, 'b) t
val (>>=) : ('res, 'rej) t -> ('res -> ('a, 'b) t) -> ('a, 'b) t

val thenValue : ('res, 'rej) t -> ('res -> 'a) -> ('a, 'b) t
val (>>|): ('res, 'rej) t -> ('res -> 'a) -> ('a, 'b) t

(* catch *)
val catch :  ('res, 'rej) t -> ('rej -> ('a, 'b) t) -> ('a, 'b) t
val (>>?) :  ('res, 'rej) t -> ('rej -> ('a, 'b) t) -> ('a, 'b) t

val catchValue  : ('res, 'rej) t -> ('rej -> 'b) -> ('a, 'b) t
val (>>|?)  : ('res, 'rej) t -> ('rej -> 'b) -> ('a, 'b) t

(* Promise.resolve *)
val resolve : 'res -> ('res, 'a) t

(* Promise.reject *)
val reject : 'rej -> ('a, 'rej) t


(* Promise.all *)
val all : ('res, 'rej) t list -> ('res list, 'rej) t


(* (\* Promise.race *\) *)
val race : ('res, 'rej) t list -> ('res, 'rej) t


(* new Promise *)
val create : (('res -> unit) -> ('rej -> unit) -> unit) -> ('res, 'rej) t
