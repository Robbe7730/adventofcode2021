json = require 'lunajson'

function printList(l)
  print(json.encode(l))
end

function findOverflow(l, depth)
  if type(l) ~= 'table' then
    return nil
  end

  if depth == 5 then
    return {}
  end

  local ret = findOverflow(l[1], depth+1)
  if ret ~= nil then
      table.insert(ret, 1)
      return ret
  end

  local ret = findOverflow(l[2], depth+1)
  if ret ~= nil then
      table.insert(ret, 2)
      return ret
  end
end

function multipleIndexGet(list, indices)
  local index = table.remove(indices)
  local currList = list[index]
  while #indices ~= 0 do
    index = table.remove(indices)
    currList = currList[index]
  end
  return currList
end

function multipleIndexSet(list, indices, value)
  if #indices == 0 then
    return value
  end

  local index = table.remove(indices)
  if index == 1 then
    return {multipleIndexSet(list[1], indices, value), list[2]}
  else
    return {list[1], multipleIndexSet(list[2], indices, value)}
  end
end

function multipleIndexAdd(list, indices, value)
  if #indices == 0 then
    return list+value
  end

  local index = table.remove(indices)
  if index == 1 then
    return {multipleIndexAdd(list[1], indices, value), list[2]}
  else
    return {list[1], multipleIndexAdd(list[2], indices, value)}
  end
end

function table.table_copy(t)
   local t2 = {}
   for k,v in ipairs(t) do
      t2[k] = v
   end
   return t2
end

function findLeft(n, indices)
  while (#indices ~= 0) and (indices[1] ~= 2) do
    table.remove(indices, 1)
  end
  if #indices == 0 then
    return nil
  end

  indices[1] = 1

  local subtree = multipleIndexGet(n, table.table_copy(indices))
  while type(subtree) == 'table' do
    table.insert(indices, 1, 2)
    subtree = subtree[2]
  end
  return indices
end

function findRight(n, indices)
  while (#indices ~= 0) and (indices[1] ~= 1) do
    table.remove(indices, 1)
  end
  if #indices == 0 then
    return nil
  end

  indices[1] = 2

  local subtree = multipleIndexGet(n, table.table_copy(indices))
  while type(subtree) == 'table' do
    table.insert(indices, 1, 1)
    subtree = subtree[1]
  end
  return indices
end

function findSplit(l)
  if type(l) ~= 'table' then
    if l >= 10 then
      return {}
    else
      return nil
    end
  else
    local ret = findSplit(l[1])
    if ret ~= nil then
      table.insert(ret, 1)
      return ret
    end
    ret = findSplit(l[2])
    if ret ~= nil then
      table.insert(ret, 2)
    end
    return ret
  end
end

function exploded(n)
  local overflowMulIdx = findOverflow(n, 1)
  if overflowMulIdx == nil then
    return {false, n}
  end

  local overflowTuple = multipleIndexGet(n, table.table_copy(overflowMulIdx))

  local leftValue = overflowTuple[1]
  local leftTarget = findLeft(n, table.table_copy(overflowMulIdx))
  if leftTarget ~= nil then
    n = multipleIndexAdd(n, leftTarget, leftValue)
  end

  local rightValue = overflowTuple[2]
  local rightTarget = findRight(n, table.table_copy(overflowMulIdx))
  if rightTarget ~= nil then
    n = multipleIndexAdd(n, rightTarget, rightValue)
  end

  n = multipleIndexSet(n, overflowMulIdx, 0)
  return {true, n}
end

function split(n)
  local splitIdx = findSplit(n)
  if splitIdx == nil then
    return {false, n}
  end

  local splitValue = multipleIndexGet(n, table.table_copy(splitIdx))
  local newValue = {math.floor(splitValue/2), math.ceil(splitValue / 2)}
  n = multipleIndexSet(n, splitIdx, newValue)
  return {true, n}
end

function reduce(n)
  while true do
    local explodedRet = exploded(n)
    if not explodedRet[1] then
      local splitRet = split(n)
      n = splitRet[2]
      if not splitRet[1] then
        return n
      end
    else
      n = explodedRet[2]
    end
  end
end

function magnitude(l)
  if type(l) ~= 'table' then
    return l
  end

  return 3*magnitude(l[1]) + 2*magnitude(l[2])
end

local sum = nil
for line in io.lines() do
  local num = json.decode(line)
  if sum == nil then
    sum = num
  else
    sum = {sum, num}
  end
  sum = reduce(sum)
end
print(magnitude(sum))
