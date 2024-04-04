local private = ...



win.__classBase = {}



function win.__classBase:constructor (...)
   return self
end



function win.__classBase:new (...)
   local obj = { }

   setmetatable (obj, self)
   self.__index = self

   return obj:constructor (...)
end



function win.__classBase:base ()
   local obj = { }

   setmetatable (obj, self)
   self.__index = self

   return obj
end
