type entry = {
  description : string;
  completed : bool;
  editing : bool;
  id : int;
}

type model = {
  entries : entry list;
  field : string;
  uid : int;
  visibility : string;
}

let empty_model = {
  entries = [];
  visibility = "All";
  field = "";
  uid = 0;
}

let new_entry description id =
  { description; id; completed = false; editing = false }

let init = empty_model

let update model = function
  | `NoOp ->
    model

  | `Add ->
    { model with uid = model.uid + 1;
                 field = "";
                 entries = if model.field = "" then
                     model.entries
                   else
                     model.entries @ [new_entry model.field model.uid] }
  | `UpdateField field ->
    { model with field }

  | `EditingEntry (id, editing) ->
    let update_entry t = if t.id = id then
        { t with editing }
      else t in
    { model with entries = List.map update_entry model.entries }
  (* FIXME ! [ focus ("#todo-" ++ toString id) ] *)

  | `UpdateEntry (id, description) ->
    let update_entry t =
      if t.id = id then { t with description } else t in
    { model with entries = List.map update_entry model.entries }

  | `Delete id ->
    { model with entries = List.filter (fun v -> v.id <> id) model.entries }

  | `DeleteComplete ->
    { model with entries = List.filter (fun v -> not v.completed) model.entries }

  | `Check (id, completed) ->
    let update_entry t =
      if t.id = id then { t with completed } else t in
    { model with entries = List.map update_entry model.entries }

  | `CheckAll completed ->
    let update_entry t = { t with completed } in
    { model with entries = List.map update_entry model.entries }

  | `ChangeVisibility visibility ->
    { model with visibility }

module View = struct
  open Html

  let onEnter msg =
    let tagger = function
      | 13 -> msg
      | _ -> `NoOp in
    on "keydown" (Json.Decoder.map tagger keyCode)

  let info_footer =
    footer
      [ className "info" ]
      [ p [] [ text "Double-click to edit a todo" ];
        p []
          [ text "Written by ";
            a [ href "https://github.com/prepor" ] [ text "Andrew Rudenko" ]];
        p []
          [ text "Part of ";
            a [ href "http://todomvc.com" ] [ text "TodoMVC" ]]]

  let view_controls_count entries_left =
    let item = if entries_left = 1 then " item" else " items" in
    span
      [ className "todo-count" ]
      [ strong [] [ text (string_of_int entries_left) ];
        text (item ^ " left") ]

  let view_controls_clear entries_completed =
    button
      [ className "clear-completed";
        hidden (entries_completed = 0);
        onClick `DeleteComplete ]
      [ text @@ Printf.sprintf "Clear completed (%i)" entries_completed ]

  let visibility_swap uri visibility actual_visibility =
    li
      [ onClick (`ChangeVisibility visibility) ]
      [ a [ href uri; classList [("selected", visibility = actual_visibility)]]
          [ text visibility ]]

  let view_controls_filters visibility =
    ul
      [ className "filters" ]
      [ visibility_swap "#/" "All" visibility;
        text " ";
        visibility_swap "#/" "Active" visibility;
        text " ";
        visibility_swap "#/" "Completed" visibility; ]

  let view_controls visibility entries =
    let entries_completed = List.length @@ (List.filter (fun v -> v.completed) entries) in
    let entries_left = List.length entries - entries_completed in
    footer
      [ className "footer";
        hidden (List.length entries = 0)]
      [ view_controls_count entries_left;
        view_controls_filters visibility;
        view_controls_clear entries_completed; ]

  let view_entry todo =
    li
      [ classList [ ("completed", todo.completed); ("editing", todo.editing) ] ]
      [ div
          [ className "view" ]
          [ input
              [ className "toggle";
                type' "checkbox";
                checked todo.completed;
                onClick (`Check (todo.id, not todo.completed))]
              [];
            label
              [ onDoubleClick (`EditingEntry (todo.id, true)) ]
              [ text todo.description ];
            button
              [ className "destroy";
                onClick (`Delete todo.id)]
              []];
        input
          [ className "edit";
            value todo.description;
            name "title";
            id ("todo-" ^ (string_of_int todo.id));
            onInput (fun v -> `UpdateEntry (todo.id, v));
            onBlur (`EditingEntry (todo.id, false));
            onEnter (`EditingEntry (todo.id, false))]
          []]

  let view_input task =
    header
      [ className "header" ]
      [ h1 [] [ text "todos" ];
        input
          [ className "new-todo";
            placeholder "What needs to be done?";
            autofocus true;
            value task;
            name "newTodo";
            onInput (fun v -> `UpdateField v);
            onEnter `Add;]
          []]

  let view_entries visibility entries =
    let list_all f l = List.fold_left (fun b v -> if f v then true else false) true l in
    let is_visible todo =
      match visibility with
      | "Completed" -> todo.completed
      | "Active" -> not todo.completed
      | _ -> true in
    let all_completed = list_all (fun v -> v.completed) entries in
    let css_visibility =
      match entries with
      | [] -> "hidden"
      | _ -> "visible" in
    section
      [ className "main";
        style [("visibility", css_visibility)];]
      [ input
          [ className "toggle-all";
            type' "checkbox";
            name "toggle";
            checked all_completed;
            onClick (`CheckAll (not all_completed));
          ]
          [];
        label
          [ for' "toggle-all"]
          [ text "Mark all as complete" ];
        ul [ className "todo-list" ] @@ List.map view_entry @@ List.filter is_visible entries]

  let view model =
    div
        [ className "todomvc-wrapper";
          (* style [("visibility", "hidden");] *)]
        [ section
            [ className "todoapp";]
            [ view_input model.field;
              view_entries model.visibility model.entries;
              view_controls model.visibility model.entries;];
          info_footer]
end

let view = View.view

let start dom_id =
  Program.simple dom_id ~update ~view ~init
