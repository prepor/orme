type ('ok, 'err) t = Ok of 'ok | Error of 'err

let ok v = Ok v

let err v = Error v
