notes for an improved menu type.

```
type State = String

type Result[A]
  = { type = "result", value = A },
  | { type = "cancel" },
  | { type = "state", value = State }

class Menu[Elem = String, Preamble = Text, A](
  title: String,
  preamble: Option[Preamble],
  draw_preamble: (preamble: Preamble) => (),
  measure_preamble: (preamle: Preamble) => (Int, Int)
  elems: List[Elem],
  draw_elem(elem: Elem) => ()
  measure_elem(elem: Elem) => (Int, Int)
  validate_elem(elem: Elem) => Bool
  on_select(elem: Elem) => Result[A],
  min_width: Int,
  min_height: Int,
  allow_cancel: Bool
) {
  def update(x: Int, y: Int) => Option[Result[A]]
  def draw(x: Int, y: Int) => ()
}

class MenuGraph[](
  menus: Map[State, Menu[_, _, A]],
  state: State,
) {
  def update() => Option[Result[A]]
  def draw(x: Int, y: Int) => ()
}
```

