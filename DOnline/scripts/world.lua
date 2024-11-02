local item_models = require "core:item_models"
require "SAPI:main"
require "CAPI:main"
require "DO:main"
conserv = {}
itemid = 0
function on_world_open()
   console.add_command(
   "con ip:str=$con.ip port:int=$con.port  bufferSuze:int=$con.bufferSuze comLeght:int=$con.comLeght nickname:str=$con.nickname password:str=$con.password",
   "Connect DOnline server", 
   function (args, kwargs) 
      DOConnect(unpack(args))
   end
   )
   SAPI.out(on_pos)
   CAPI.ChunkUpdate(conservationOpen)
   CAPI.ChunkWorldUpdate(on_chinck_load)
end
function DOConnect(ip, port, bufferSuze, comLeght, nickname, password)
   for i, load in ipairs(SAPI.out_) do
      load("u++")
   end
   local ver = {}
   for i, load in ipairs(pack.get_installed()) do
      ver[i] = load .. ":" .. pack.get_info(load).version
   end
   data = "~cn" .. nickname .. "/" .. password .. "/" .. json.parse(file.read("world:world.json")).generator .. "/" .. world.get_seed() .. "/" .. table.concat(ver, ",") .. "/" .. comLeght .. "\t".. SAPI.data_
   SAPI.data_ = ""
   SAPI.con(ip, port, bufferSuze, data)
end

function on_pos(dat)
   --player
   local px, py, pz = player.get_pos(0)
   local rx, ry, rz = player.get_rot(0)
   local pas = "stspos" .. math.floor(px * 100) / 100 .. "/" .. math.floor(py * 100) / 100 .. "/" .. math.floor(pz * 100) / 100  .. "/" .. math.floor(rx) .. "/" .. math.floor(ry)
   SAPI.data(pas)
   local invid, slotid = player.get_inventory()
   local id, _ = inventory.get(invid, slotid)
   if id ~= itemid then
       local itm = "stsitm" .. item.name(id)
       SAPI.data(itm)
       itemid = id
   end

   local dats = {}
   dats = mysplit(dat, "\t")
   for a = 0, #dats do
     if dats[a] ~= nul then
        local b = string.sub(dats[a], 0, 3)
        local c = string.sub(dats[a], 4)
        local rel = {}
        rel = mysplit(c, '/')
        if b == "pos" then
           if DO.players[rel[1]] ~= nul then
              local uid = DO.players[rel[1]]:get_uid()
              DO.playersdata[uid].pos = {tonumber(rel[2]), tonumber(rel[3]), tonumber(rel[4])}
              DO.playersdata[uid].rotbody = tonumber(rel[5])
              DO.playersdata[uid].rothead = tonumber(rel[6])
           else
              DO.players[rel[1]] = entities.spawn("DO:player", {tonumber(rel[2]), tonumber(rel[3]), tonumber(rel[4])})
              local uid = DO.players[rel[1]]:get_uid()
              DO.playersdata[uid] = {}
              DO.playersdata[uid].pos = {tonumber(rel[2]), tonumber(rel[3]), tonumber(rel[4])}
              DO.playersdata[uid].rotbody = tonumber(rel[5])
              DO.playersdata[uid].rothead = tonumber(rel[6])
              DO.players[rel[1]].rigidbody:set_body_type("kinematic")
              DO.players[rel[1]].rigidbody:set_gravity_scale({0, 0, 0})
           end
        end
        if b == "pls" then
          
           local bhin = {}
           bhin = mysplit(rel[3], ";")
           local hin = {}
           hin = mysplit(rel[4], ";")
           local x = tonumber(rel[1]) * 16 + tonumber(bhin[1])
           local z = tonumber(rel[2]) * 16 + tonumber(bhin[3])
           if block.get(x, tonumber(bhin[2]), z) ~= -1 then
              if block.index(hin[1]) == 0 then
                 block.destruct(x, tonumber(bhin[2]), z)
              else
                 block.place(x, tonumber(bhin[2]), z, block.index(hin[1]), tonumber(hin[2]))
              end
           else
              conservation(tonumber(rel[1]), tonumber(rel[2]), tonumber(bhin[1]), tonumber(bhin[2]), tonumber(bhin[3]), block.index(hin[1]), tonumber(hin[2]))
           end
        end
        if b == "get" then
          
           local bhin = {}
           bhin = mysplit(rel[3], ";")
           local hin = {}
           hin = mysplit(rel[4], ";")
           block.set(tonumber(rel[1]) * 16 + tonumber(bhin[1]), tonumber(bhin[2]), tonumber(rel[2]) * 16 + tonumber(bhin[3]), block.index(hin[1]), tonumber(hin[2]))
        end
        if b == "itm" then
           if DO.players[rel[1]] ~= nul then
              refresh_localmodel(DO.players[rel[1]], rel[2])
           end
        end
        if b == "p--" then
           DO.players[c]:despawn()
        end
     end
   end
   
   --local cam = cameras.get("base:first-person")
   --local spawn_pos = vec3.add(cam:get_pos(), vec3.mul(cam:get_front(), 2))
   --entities.spawn("base:player", spawn_pos, {})
end
function refresh_localmodel(player, id)
    if item.index(id) == 0 then
        player.skeleton:set_model(player.skeleton:index("item"), "")
    else
        local scale = item_models.setup(item.index(id), player.skeleton, player.skeleton:index("item"))
        player.skeleton:set_matrix(player.skeleton:index("item"), mat4.scale(scale))
    end 
end
function conservation(cx, cz, lx, ly, lz, id, st)
    if not conserv[cx] then
        conserv[cx] = {}
    end
    if not conserv[cx][cz] then
        conserv[cx][cz] = { block = {} }
    end
    if not conserv[cx][cz].block[lx] then
        conserv[cx][cz].block[lx] = {}
    end
    if not conserv[cx][cz].block[lx][ly] then
        conserv[cx][cz].block[lx][ly] = {}
    end
    conserv[cx][cz].block[lx][ly][lz] = { id = id, st = st }
end
function conservationOpen(cx, cz)
    if conserv[cx] and conserv[cx][cz] then
        for lx, block in pairs(conserv[cx][cz].block) do
            for ly, layer in pairs(block) do
                for lz, data in pairs(layer) do
                    -- Доступ к id и st
                    local id = data.id
                    local st = data.st
                    block.set(cx * 16 + lx, ly, cz * 16 + lz, id, st)
                end
            end
        end
        conserv[cx][cz] = nil
    end
end

function on_block_placed(b, x, y, z, p)
   if p == 0 then
      local stats = block.get_states(x, y, z)
      local cx, cz, bx, bz = CAPI.Get_Chunck(x, z)
      SAPI.data("set" .. cx .. "/" .. cz .. "/" .. bx .. ";" .. y .. ";" .. bz .. "/" .. block.name(b) .. ";" .. stats)
   end
end
function on_block_broken(b, x, y, z, p)
   if p == 0 then
      local stats = block.get_states(x, y, z)
      local cx, cz, bx, bz = CAPI.Get_Chunck(x, z)
      SAPI.data("set" .. cx .. "/" .. cz .. "/" .. bx .. ";" .. y .. ";" .. bz .. "/" .. "core:air" .. ";0")
   end
end
function on_chinck_load(x, y)
   SAPI.data("get" .. x .. "/" .. y)
end

function mysplit(inputstr, sep)
  if sep == nil then
    sep = "%s"
  end
  local t = {}
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
    table.insert(t, str)
  end
  return t
end