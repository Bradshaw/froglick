math.randomseed(os.time())

function tri(cond, a, b)
	if cond then
		return a
	else
		return b
	end
end


function hit(damage, armour, hp, armbon, fleshbon)
	armbon = armbon or 1
	fleshbon = fleshbon or 1
	local armourrating = math.min(1,armour/(100*armbon))
	local healthdmg = damage*(1- armourrating )*fleshbon
	local armourdmg = (damage*damage)/100 * armourrating/fleshbon



	return math.max(0,math.ceil(armour-armourdmg)), 
		   math.max(0,math.ceil(hp-healthdmg))
end


function test(armbon, fleshbon)

	io.write("\t\tArmor: \t")

	for arm=1,10 do
		io.write((arm*10).."\t")
	end
	print()
	print()
	for dmg=1,20 do
		io.write("Damage: "..(dmg*10).."\t\t");
		for arm=1,10 do
			local a, h = hit(dmg*10,arm*10,100,    armbon,   fleshbon  )
			io.write(tri(h>0,h,"dead").."/"..tri(a>0,a,0).."\t")
		end
		print()
	end

end

print("Normal")
test(1,1)
print("\nDumdum")
test(0.5,2)
print("\nPiercing")
test(2,0.5)