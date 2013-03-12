--[[
Camera : Une caméra virtuelle qui permet de limiter les éléments "visibles" pour optimiser tests et dessin des objets et tuiles près du joueur.

]]

local Camera = {}
local Camera_mt = {}


--[[
Utilisation: maCamera = Camera.new(15,60,400,300)
Crée une nouvelle Camera, qui vise le pixel aux coordonnées (15,60) et a une taille de 400 par 300

Paramètres:
x : Position en X, par défault, le milieu de l'écran
y : Position en Y, par défault, le milieu de l'écran
w : Largeur de la zone visée, par défaut la largeur de l'écran
h : Hauteur de la zone visée, par défaut égal à la largeur
]]
function Camera.new(x,y,w,h)
	self = setmetatable({},{__index=Camera_mt})
	self.x= x or (love.graphics.getWidth()/2)
	self.y= y or (love.graphics.getHeight()/2)
	self.w= w or love.graphics.getWidth()
	self.h= h or love.graphics.getHeight()
	return self
end

--[[
Utilisation: maCamera:pointAt(40, 23)
maCamera vise maintenant le pixel aux coordonnées (40,23)

Paramètres:
x : Nouvelle position en X
y : Nouvelle position en Y
]]
function Camera_mt.pointAt(self,x,y)
	if type(x)=="table" then
		self.x = x.pos.x
		self.y = x.pos.y
	else
		self.x = x
		self.y = y
	end
end


--[[
Utilisation: maCamera:setSize(800,600)
maCamera a désormais une taille de 800 par 600

Paramètres:
width: Nouvelle largeur
height: Nouvelle hauteur, par défaut égal à la largeur
]]
function Camera_mt.setSize(width,height)
	self.w = width
	self.h = height or self.w
end

--[[
Utilisation:
local x1,y1,x2,y2 = maCamera:getBounds() 

Obtenient la zone visible

Retour:
x1 : Bord de gauche
y1 : Bord du haut
x2 : Bord de droite
y2 : Bord du bas

]]
function Camera_mt.getBounds(self)
	return self.x-self.w/2, self.y-self.h/2, self.x+self.w/2, self.y+self.h/2
end


--[[
Returns the tiles inside the bounds

]]
function Camera_mt.getTileBounds(self)
	local x1, y1, x2, y2 = self:getBounds()
	return math.floor(x1/Tile.SIZE.x), math.floor(y1/Tile.SIZE.y), math.ceil(x2/Tile.SIZE.x), math.ceil(y2/Tile.SIZE.y)
end

function Camera_mt.doForTiles(self, fn, ...)
	local x1, y1, x2, y2 = self:getTileBounds()
	for i=x1,x2 do
		for j=y1,y2 do
			fn(i, j, ...)
		end
	end
end

--[[
Utilisation:
if maCamera:check( obj:getX(), obj:getY() ) then
	obj:draw()
end

Appelle obj:draw() si obj est visible par maCamera

Retour:
booléen : les coordonnées (x,y) sont visibles par maCamera
]]
function Camera_mt.check(self,x,y)
	local x1,y1,x2,y2 = self:getBounds()
	--print(x1,y1,x2,y2,x,y)
	if x>=x1 and x<=x2 and y>=y1 and y<=y2 then
		return true
	else
		return false
	end
end


return Camera