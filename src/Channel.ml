module Promise = PromiseNative

type ('a, 'b) t = {
  queue : ('a, 'b) Task.t Queue.t;
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
    Task.create
      (fun succeed fail ->
         t.current_read <- Some (succeed, fail))

let write t v =
  match t.current_read with
  | Some (succeed, _) ->
    t.current_read <- None;
    succeed v;
  | None ->
    Queue.push (Task.succeed v) t.queue
