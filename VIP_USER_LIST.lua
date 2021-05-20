do
  VIP_users = {"bensto23", "shaunyboi"}
  local function VIP_USER_LIST()
    local USER = client.username
    for _, value in ipairs(VIP_users) do
      if value == USER then
        return true
      end
    return false
  VIP_USER_LIST()
end