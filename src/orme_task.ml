module Ivar = struct
  type 'a state = Pending | Realized of 'a
  type 'a t = {
    mutable state : 'a state;
    mutable readers : ('a -> unit) list
  }

  let realize i v =
    match i.state with
    | Pending ->
      i.state <- Realized v;
      List.iter (fun f -> f v) i.readers
    | _ -> ()

  let create f =
    let i = { state = Pending; readers = [] } in
    f (realize i);
    i

  let set_reader i f =
    match i.state with
    | Pending ->
      i.readers <- f::i.readers
    | Realized v ->
      f v

  let connect i i' =
    set_reader i (realize i')


  let bind i f =
    let i' = { state = Pending; readers = []} in
    (match i.state with
     | Pending ->
       i.readers <- (fun v -> connect (f v) i')::i.readers
     | Realized v ->
       connect (f v) i');
    i'

  let realized v =
    { state = Realized v; readers = [] }
end

type ('ok, 'err) t = {
  state : ('ok, 'err) Orme_result.t Ivar.t
}

let create f =
  let t = { state = Ivar.create (fun realize ->
      f (fun v -> realize @@ Orme_result.ok v) (fun v -> realize @@ Orme_result.err v))} in
  t

let bind t f =
  { state = Ivar.bind t.state (function
        | Orme_result.Ok v -> let res = f v in res.state
        | Orme_result.Error v -> Ivar.realized (Orme_result.Error v) )}

let (>>=) = bind

let succeed v = { state = Ivar.realized @@ Orme_result.ok v }

let fail v = { state = Ivar.realized @@ Orme_result.err v }
