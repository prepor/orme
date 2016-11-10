type ('a, 'b) t = {
  queue : ('a, 'b) Orme_task.t Queue.t;
  mutable current_read : (('a -> unit) * ('b -> unit)) option;
}

let create () =
  {queue = Queue.create (); current_read = None}

let read t =
  (match t.current_read with
   | Some (_, fail) ->
     fail `Concurrent_read
   | None -> ());
  try Queue.take t.queue with
  | Queue.Empty ->
    Orme_task.create
      (fun succeed fail ->
         t.current_read <- Some (succeed, fail))

let write t v =
  match t.current_read with
  | Some (succeed, _) ->
    t.current_read <- None;
    succeed v;
  | None ->
    Queue.push (Orme_task.succeed v) t.queue
