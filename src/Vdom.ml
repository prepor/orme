type t
type diff

external node : string -> Browser.Obj.t -> t array -> t = "virtual-dom/vnode/vnode" [@@bs.new] [@@bs.module]

external text : string -> t = "virtual-dom/vnode/vtext" [@@bs.new] [@@bs.module]

external create_element : t -> Browser.node = "virtual-dom/create-element" [@@bs.module]

external diff : t -> t -> diff = "virtual-dom/diff" [@@bs.module]

external patch : Browser.node -> diff -> unit = "virtual-dom/patch" [@@bs.module]
