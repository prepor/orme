type ('res, 'rej) state = Pending | Fullfilled of 'res | Rejected of 'rej

type ('res, 'rej) t = {
  mutable state : ('res, 'rej) state;
  mutable fullfilled_clbs : ('res -> unit) list;
  mutable rejected_clbs : ('rej -> unit) list;
}

let resolve' p v =
  match p.state with
  | Pending ->
    Js.log "---RESOLVE";
    p.state <- Fullfilled v;
    List.iter (fun f -> f v) p.fullfilled_clbs
  | _ -> ()

let reject' p v =
  match p.state with
  | Pending ->
    p.state <- Rejected v;
    List.iter (fun f -> f v) p.rejected_clbs
  | _ -> ()


let create f =
  let p = { state = Pending; fullfilled_clbs = []; rejected_clbs = []} in
  f (resolve' p) (reject' p);
  p

let set_callbacks p onFullfill onReject =
  match p.state with
  | Pending ->
    p.fullfilled_clbs <- onFullfill::p.fullfilled_clbs;
    p.rejected_clbs <- onReject::p.rejected_clbs
  | Fullfilled v ->
    onFullfill v
  | Rejected v ->
    onReject v


let connect p p' =
  set_callbacks p (resolve' p') (reject' p')

let rec then_ p clb =
  let p' = { state = Pending; fullfilled_clbs = []; rejected_clbs = []} in
  (match p.state with
   | Pending ->
     p.fullfilled_clbs <- (fun v -> connect (clb v) p')::p.fullfilled_clbs
   | Fullfilled v ->
     connect (clb v) p'
   | Rejected _ -> ());
  p'

let (>>=) = then_

let resolve v = { state = Fullfilled v; fullfilled_clbs = []; rejected_clbs = [] }

let thenValue p clb =
  then_ p (fun v -> resolve (clb v))

let (>>|) = thenValue

let catch p clb =
  let p' = { state = Pending; fullfilled_clbs = []; rejected_clbs = []} in
  (match p.state with
   | Pending ->
     p.rejected_clbs <- (fun v -> connect (clb v) p')::p.rejected_clbs
   | Rejected v ->
     connect (clb v) p'
   | Fullfilled _ -> ());
  p'

let (>>?) = catch

let reject v = { state = Rejected v; fullfilled_clbs = []; rejected_clbs = [] }

let catchValue p clb =
  catch p (fun v -> reject (clb v))

let (>>|?) = catchValue

(* (\* Promise.all *\) *)
(* val all : ('res, 'rej) t array -> ('res array, 'rej) t = "Promise.all" [@@bs.val] *)

let all ps =
  let rec wait acc = function
    | [] -> resolve acc
    | p::ps ->
      p >>= (fun v -> wait (v::acc) ps) |> ignore;
      p >>? (fun v -> reject v) in
  wait [] ps

(* (\* Promise.race *\) *)
(* val race : ('res, 'rej) t array -> ('res, 'rej) t = "Promise.race" [@@bs.val] *)

let race ps =
  create (fun resolve reject ->
      List.iter (fun p -> p >>| resolve |> ignore) ps;
      List.iter (fun p -> p >>|? reject |> ignore) ps)
