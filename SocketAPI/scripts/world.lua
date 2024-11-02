require "SAPI:main"
tps = true
function on_world_open()
   console.add_command(
   "connect ip:str=$con.ip port:str=$con.port bufferSuze:str=$con.bufferSuze data:str=$con.bufferSuze",
   "Connect", 
   function (args, kwargs) 
      SAPI.con(unpack(args))
   end
   )
end
--out and in from server
function on_world_tick()
   if tps then
      tps = false
      if file.exists("export:outData") then
         local a = file.read("export:outData")
         if string.sub(a, 0, 3) == "-cn" then
            SAPI.connected = false
            file.remove("export:outData")
            return
         end
         if SAPI.connected == false then
            return
         end
         for i, load in ipairs(SAPI.out_) do
            load(a)
         end
         file.remove("export:outData")
         if file.exists("export:inData") then
            print("SAPI: CONNECT FAULED")
         else
            file.write("export:inData", SAPI.data_)
            SAPI.data_ = ""
         end
      end
   else
      tps = true
   end
end

