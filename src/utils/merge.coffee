### Merge properties of 2 dictionaries.###

merge = (child, parent) ->
    for key of parent
        if not child[key]?
            child[key] = parent[key] if Object::hasOwnProperty.call parent, key
    child