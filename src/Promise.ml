(* 'res - type the promise will be resolved with
   'rej - type the promise will be rejected with *)
type ('res, 'rej) t


(* then *)
external then_ : ('res, 'rej) t -> ('res -> ('a, 'b) t [@bs]) -> ('a, 'b) t = "then" [@@bs.send]
external (>>=) : ('res, 'rej) t -> ('res -> ('a, 'b) t [@bs]) -> ('a, 'b) t = "then" [@@bs.send]

external thenValue : ('res, 'rej) t -> ('res -> 'a [@bs]) -> ('a, 'b) t = "then" [@@bs.send]
external (>>|): ('res, 'rej) t -> ('res -> 'a [@bs]) -> ('a, 'b) t = "then" [@@bs.send]

external thenWithError : ('res, 'rej) t -> ('res -> 'a [@bs]) -> ('rej -> 'b [@bs]) -> ('a, 'b) t = "then" [@@bs.send]


(* catch *)
external catch :  ('res, 'rej) t -> ('rej -> 'a [@bs]) -> ('a, 'b) t = "catch" [@@bs.send]
external (>>?) :  ('res, 'rej) t -> ('rej -> 'a [@bs]) -> ('a, 'b) t = "catch" [@@bs.send]


(* Promise.resolve *)
external resolve : 'res -> ('res, 'a) t = "Promise.resolve" [@@bs.val]


(* Promise.reject *)
external reject : 'rej -> ('a, 'rej) t = "Promise.reject" [@@bs.val]


(* Promise.all *)
external all : ('res, 'rej) t array -> ('res array, 'rej) t = "Promise.all" [@@bs.val]


(* Promise.race *)
external race : ('res, 'rej) t array -> ('res, 'rej) t = "Promise.race" [@@bs.val]


(* new Promise *)
external create : (('res -> unit [@bs]) -> ('rej -> unit [@bs]) -> unit [@bs]) -> ('res, 'rej) t = "Promise" [@@bs.new]
