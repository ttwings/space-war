local ship=res.shipClass.collector

function ship:findTarget ()
	
	if self.target and self.target.dead  then 
		self.target=nil 
		self.rot=self.moveRot
		return false
	end


	local dist
	local pos
	local tar= self.state=="battle" and game.ship or game.rock
	local len= self.state=="battle" and self.visualRange or self.testRange
	for i,v in ipairs(tar) do
		local range=math.getDistance(self.x,self.y,v.x,v.y)
		local test=range<len and range or nil 
		if self.state=="battle" then --战斗中只找不同队伍的
			if v.side==self.side then
				test=nil
			end
		else --采集中只找没有主的
			if v.exploiter and v.exploiter~=self then
				test= nil
			end
		end
		if  test then
			
			if not dist then
				dist=test
				pos=i
			else
				if dist>test then
					dist=test
					pos=i
				end
			end
		end
	end
	if dist then
		if self.state=="mine" then
			if tar[pos]~= self.target then
				tar[pos].exploiter=nil
			end
			self.target=tar[pos]
			self.fireRange=self.r+self.target.r
			self.target.exploiter=self
		else
			self.target=tar[pos]
		end

		
	end
	
	if self.target then
		local range=math.getDistance(self.x,self.y,self.target.x,self.target.y)
		if range>len then
			self.target=nil
			return false
		else
			return true
		end
	else
		return false
	end
end

function ship:switchState(state)
	self.state=state
	self.target=nil
	self.inFireRange=false
	self.inVisualRange=false
	self:hold()
end


function ship:moveToTarget() --如果当前状态是采矿 那么就去采矿
	if self.state=="battle" or (not self.target) then return end
	

	if self.inVisualRange and not self.dx and not self.inFireRange  then
		self.class.super.moveTo(self,self.target.x,self.target.y)
		self.target.exploiter=self
	end

	if self.inFireRange then
		self:hold()
	end

end

function ship:moveTo(x,y)
	self.class.super.moveTo(self,x,y)
	--self.state="battle"
	if self.target then 
		self.target.exploiter=nil
		self.target=nil
	end
end



function ship:update(dt)
	self.class.super.update(self,dt)
	self:moveToTarget()
	self.rot=self.moveRot
end

function ship:draw()
	self.class.super.draw(self)
	if self.mine then
		self.mine.x=self.x+math.sin(-self.rot+math.pi/2)*(self.r+self.mine.r)
		self.mine.y=self.y+math.cos(-self.rot+math.pi/2)*(self.r+self.mine.r)
		self.mine:draw()
	end
end

return ship

