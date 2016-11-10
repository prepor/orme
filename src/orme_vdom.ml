type t
type diff

external node : string -> Orme_browser.Obj.t -> t array -> t = "virtual-dom/vnode/vnode" [@@bs.new] [@@bs.module]

external text : string -> t = "virtual-dom/vnode/vtext" [@@bs.new] [@@bs.module]

external create_element : t -> Orme_browser.node = "virtual-dom/create-element" [@@bs.module]

external diff : t -> t -> diff = "virtual-dom/diff" [@@bs.module]

external patch : Orme_browser.node -> diff -> unit = "virtual-dom/patch" [@@bs.module]
