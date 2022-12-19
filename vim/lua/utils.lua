return {
  append_slash = function (path)
    if path:sub(#path, #path) ~= '/' then
      return path .. '/'
    end
    return path
  end
}
