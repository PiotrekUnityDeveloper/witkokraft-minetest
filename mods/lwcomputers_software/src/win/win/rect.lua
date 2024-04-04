local private = ...



win.rect = win.__classBase:base()



function win.rect:constructor (x, y, width, height)
   self.x = tonumber(x or 0) or 0
   self.y = tonumber(y or 0) or 0
   self.width = tonumber(width or 0) or 0
   self.height = tonumber(height or 0) or 0

   return self
end



function win.rect:is_empty ()
   if self.x and self.y and self.width and self.height then
      return (self.width == 0 or self.height == 0)
   end

   return true
end



function win.rect:empty ()
   self.x = 0
   self.y = 0
   self.width = 0
   self.height = 0
end



function win.rect:copy (rt)
   self.x = tonumber (rt.x or 0) or 0
   self.y = tonumber (rt.y or 0) or 0
   self.width = tonumber (rt.width or 0) or 0
   self.height = tonumber (rt.height or 0) or 0
end



function win.rect:unpack ()
   return self.x, self.y, self.width, self.height
end



function win.rect:clip (rt)
   if rt:is_empty () or self:is_empty () then
      self:empty ()
   else
      self.width = self.width + self.x
      self.height = self.height + self.y

      if rt.x > self.x then
         self.x = rt.x
      end

      if rt.y > self.y then
         self.y = rt.y
      end

      if self.width > (rt.x + rt.width) then
         self.width = rt.x + rt.width
      end

      if self.height > (rt.y + rt.height) then
         self.height = rt.y + rt.height
      end

      self.width = self.width - self.x
      self.height = self.height - self.y

      if self.width <= 0 or self.height <= 0 then
         self:empty ()
      end
   end
end



function win.rect:bound (rt)
   if self:is_empty () then
      self:copy (rt)
   elseif not rt:is_empty () then
      self.width = self.width + self.x
      self.height = self.height + self.y

      if rt.x < self.x then
         self.x = rt.x
      end

      if rt.y < self.y then
         self.y = rt.y
      end

      if self.width < (rt.x + rt.width) then
         self.width = rt.x + rt.width
      end

      if self.height < (rt.y + rt.height) then
         self.height = rt.y + rt.height
      end

      self.width = self.width - self.x
      self.height = self.height - self.y
   end
end



function win.rect:offset (x, y)
   if not self:is_empty () then
      self.x = self.x + x
      self.y = self.y + y
   end
end



function win.rect:contains (x, y)
   if not self:is_empty () then
      return ((x >= self.x) and (x < (self.x + self.width)) and
               (y >= self.y) and (y < (self.y + self.height)))
   end

   return false
end



function win.rect:overlap (rt)
   if self:is_empty () or rt:is_empty () then
      return false
   end

   if self.x >= (rt.x + rt.width) then
      return false
   end

   if rt.x >= (self.x + self.width) then
      return false
   end

   if self.y >= (rt.y + rt.height) then
      return false
   end

   if rt.y >= (self.y + self.height) then
      return false
   end

   return true
end
