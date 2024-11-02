SAPI = {}
SAPI.data_ = ""
SAPI.out_ = {}
SAPI.dis_ = {}
SAPI.connected = false

SAPI.dis = function (func)
   table.insert(SAPI.dis_, func)
end
SAPI.con = function (ip, port, bufferSuze, data)
   if file.exists("export:inData") then
      print("SAPI: CONNECT FAULED")
   else
      SAPI.connected = true
      file.write("export:inData", ip .. "/" .. port .. "/" .. bufferSuze .. "/" .. data)
   end
end

--Data
SAPI.out = function (func)
    table.insert(SAPI.out_, func)
end
SAPI.data = function (dat)
    SAPI.data_ = SAPI.data_ .. dat .. "\t"
end