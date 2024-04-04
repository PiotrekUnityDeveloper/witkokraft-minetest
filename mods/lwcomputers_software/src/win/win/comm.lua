local private = ...



win.comm = win.__classBase:base ()



function win.comm:constructor (name, timeout)
	self.comm__name = name
	self.comm__timeout = timeout or 5
	self.comm__interests = { }
	self.comm__processing = { }

	return self
end



function win.comm:get_name ()
	return self.comm__name
end



function win.comm:set_name (name)
	self.comm__name = name
end



function win.comm:get_timeout ()
	return self.comm__timeout
end



function win.comm:set_timeout (timeout)
	self.comm__timeout = timeout or 5
end



function win.comm:is_processing ()
	return #self.comm__processing > 0
end



function win.comm:transmit (msg)
	local id = msg.recipient_id or msg.recipient_name

	if type (id) == "string" then
		id = wireless.lookup_id (id)

		if not id then
			return false
		end
	end

	return wireless.send_message (utils.serialize (msg), id)
end



function win.comm:register (wnd, application)
	self.comm__interests[#self.comm__interests + 1] =
	{
		wnd = wnd,
		application = application
	}
end



function win.comm:unregister (wnd, application)
	for i = #self.comm__interests, 1, -1 do
		local interest = self.comm__interests[i]

		if interest.wnd == wnd and
			(interest.application == application or not application) then

			table.remove(self.comm__interests, i)
		end
	end
end



function win.comm:copy_msg (msg)
	return utils.deserialize (utils.serialize (msg))
end



function win.comm:call_sent_handlers (msg, result)
	for i = 1, #self.comm__interests, 1 do
		if self.comm__interests[i].application == msg.application then

			private.workspace:pump_event (self.comm__interests[i].wnd, "comm_sent",
													self:copy_msg (msg), result)
		end
	end
end



function win.comm:is_duplicate (msg)
	for i = 1, #self.comm__processing, 1 do
		local process = self.comm__processing[i]

		if process.msg.message_id == msg.message_id then
			if process.status == "received" then

				return true
			end
		end
	end

	return false
end



function win.comm:is_confirmation (msg)
	if msg.context == "confirm" then
		for i = #self.comm__processing, 1, -1 do
			local process = self.comm__processing[i]

			if process.status == "send" then
				if process.msg.message_id == msg.message_id then
					self:call_sent_handlers (process.msg, true)

					table.remove (self.comm__processing, i)
				end
			end
		end

		return true
	end

	return false
end



function win.comm:is_from_me (msg)
	local sender = tonumber (msg.sender_id) or 0
	local name = os.get_name ()

	return (sender == os.computer_id () or
			  (name:len () > 0 and tostring (msg.sender_name) == name))
end



function win.comm:is_for_me (msg, exclusive)
	if msg.recipient_id then
		return (tonumber(msg.recipient_id) or 0) == os.computer_id ()
	elseif msg.recipient_name then
		return tostring(msg.recipient_name) == os.get_name ()
	elseif exclusive then
		return false
	end

	return (not self:is_from_me (msg))
end



function win.comm:call_receive_handlers (msg)
	local received = false
	local copy = self:copy_msg (msg)

	for i = 1, #self.comm__interests, 1 do
		if self.comm__interests[i].application == msg.application then

			if private.workspace:pump_event (self.comm__interests[i].wnd, "comm_receive", copy) then
				received = true
			end
		end
	end

	return received
end



function win.comm:send_confirmation (msg)
	if msg.recipient_name or msg.recipient_id then
		local copy = self:copy_msg (msg)

		copy.context = "confirm"
		copy.recipient_name = copy.sender_name
		copy.recipient_id = copy.sender_id
		copy.sender_name = os.get_name ()
		copy.sender_id = os.computer_id ()
		copy.sequence = -1

		if not self:transmit (copy) then
			win.syslog ("comm "..self:get_name ().." unable to send confirmation to "..
							tostring (msg.sender_name or ""))
		end
	end
end



function win.comm:receive (message, sender_id, target_id)
	local success, msg = pcall (utils.deserialize, message)

	if success and type(msg) == "table" then
		if msg.message_id and msg.application and msg.context then
			if self:is_for_me (msg) then
				if not self:is_confirmation (msg) then
					if not self:is_duplicate (msg) then
						if self:call_receive_handlers (msg) then
							self.comm__processing[#self.comm__processing + 1] =
							{
								time_stamp = os.clock (),
								status = "received",
								msg = msg
							}

							self:send_confirmation (msg)
						end
					end
				end
			end
		end
	end
end



function win.comm:send (recipient, application, context, data)
	local msg = { }
	local method = "send"

	if recipient then
		if type (recipient) == "number" then
			msg.recipient_id = recipient

			if msg.recipient_id == os.computer_id () then
				return nil
			end
		else
			msg.recipient_name = tostring (recipient or "")

			if msg.recipient_name == os.get_name () then
				return nil
			end
		end
	else
		method = "broadcast"
	end

	msg.context = context
	msg.application = application
	msg.data = data
	msg.sender_id = os.computer_id ()
	msg.sender_name = os.get_name () or ""
	msg.message_id = math.random(1, 65535)
	msg.sequence = 0

	self.comm__processing[#self.comm__processing + 1] =
	{
		time_stamp = os.clock (),
		status = method,
		msg = msg
	}

	return msg.message_id
end



function win.comm:process ()
	for i = #self.comm__processing, 1, -1 do
		local process = self.comm__processing[i]

		if process.status == "received" then
			if (os.clock () - process.time_stamp) > (self:get_timeout () * 2) then
				table.remove (self.comm__processing, i)
			end

		elseif process.status == "send" or process.status == "broadcast" then
			if (os.clock () - process.time_stamp) > self:get_timeout () then
				if process.status == "send" then
					self:call_sent_handlers (process.msg, false)
				end

				table.remove (self.comm__processing, i)
			else
				process.msg.sequence = process.msg.sequence + 1

				if self:transmit (process.msg) then
					if process.status == "broadcast" then
						if process.msg.sequence == 1 then
							self:call_sent_handlers (process.msg, true)
						end
					end
				else
					win.syslog ("comm "..self:get_name ().." unable to send message")
				end
			end

		end
	end
end
