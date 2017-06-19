module.exports =
  user: ({ message: { user_id } }) -> user_id
  resource: ({ message: { resource } }) -> resource