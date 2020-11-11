pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
--shoot the moon
--mobo
c_goal=5000
c_ship_life=3
c_ship_speed=2
c_max_enemies=12
c_max_boss=1
c_bullet_speed=4
c_enemy_bullet_speed=1
c_enemy_life=3
c_enemy_speed=0.3
c_boss_life=50
c_boss_speed=1
c_love_speed=0.2

function _init()
	state=2
end

function _update60()
	if (state==0) update_game()
	if (state==1) update_gameover()
	if (state==2) update_gamestart()
end

function _draw()
	if (state==0) draw_game()
	if (state==1) draw_gameover()
	if (state==2) draw_gamestart()
end
-->8
-- game start
function update_gamestart()
	if (btn(🅾️)) init_game()
end

function draw_gamestart()
	cls()
	rectfill(31,83,105,119,13)
	rectfill(28,80,102,116,2)
	spr(4,128/2-12,128/6-12,4,4)
	spr(2,128/2-4,48)
	spr(1,128/2-4,64)
	print("Shoot the moon!",36,86,6)
	print("c or 🅾️ to start",34,106,6)
end
-->8
-- game
function init_game()
	p={x=60,y=60,speed=c_ship_speed,life=c_ship_life}
	bullets={}
	enemies_bullets={}
	enemies={}
	love={}
	boss={}
	explosions={}
	stars={}
	create_stars()
	score=0
	music_start=false
	state=0
end

function update_game()
 if not music_start then
 	music(0)
 	music_start=true
 end
	update_player()
	update_stars()
	update_bullets()
	update_enemies_bullets()
	if #enemies==0 then
		if score<c_goal then
			spawn_enemies(2+ceil(rnd(c_max_enemies-2)))
		elseif #boss==0 then
			spawn_boss(c_max_boss)
		end
	end
	update_enemies()
	update_boss()
	update_love()
	update_explosions()
end

function draw_game()
	cls()
	draw_stars()
	draw_bullets()
	draw_enemies_bullets()
	draw_player()
	draw_enemies()
	draw_boss()
	draw_love()
	draw_explosions()
	draw_score()
	draw_life()
end


-->8
-- bullets
function shoot()
	local new_bullet={
		x=p.x,
		y=p.y;
		speed=c_bullet_speed
	}
	add(bullets, new_bullet)
	sfx(0)
end

function update_bullets()
	for b in all(bullets) do
		b.y-=b.speed
		if b.y<-8 then
			del(bullets,b)
		end
	end
end

function draw_bullets()
	for b in all(bullets) do
		spr(2,b.x,b.y)
	end
end

-->8
-- stars
function create_stars()
	for i=1,8 do
		local new_star={
			x=rnd(128),
			y=rnd(128),
			col=rnd({5,6}),
			speed=0.5+rnd(0.5)
		}
		add(stars,new_star)
	end
	for i=1,14 do
		local new_star={
			x=rnd(128),
			y=rnd(128),
			col=rnd({9,14,15}),
			speed=2+rnd(2)
		}
		add(stars,new_star)
	end
end

function update_stars()
	for s in all(stars) do
		s.y+=s.speed
		if s.y > 128 then
			s.y=0
			s.x=rnd(128)
		end
	end
end

function draw_stars()
	for s in all(stars) do
		pset(s.x,s.y,s.col)
	end
end

-->8
--player
function update_player()
	-- controls
	if (btn(➡️)) p.x+=p.speed
	if (btn(⬅️)) p.x-=p.speed
	if (btn(⬆️)) p.y-=p.speed
	if (btn(⬇️)) p.y+=p.speed
	if (btnp(❎)) shoot()
	-- map size
	if(p.x<0) p.x=0
	if(p.x>128-8) p.x=128-8
	if(p.y<0) p.y=0
	if(p.y>128-8) p.y=128-8
	--enemies
	for e in all(enemies) do
		if collide(e,p) then
			sfx(2)
			del(enemies,e)
			p.life-=1
		end
	end
	-- boss
	for bo in all(boss) do
		if collide_boss(bo,p) then
			p.life=0
		end
	end
	-- enemies bullets
	for b in all(enemies_bullets) do
		if collide(p,b) then
			create_explosion(b.x+4,b.y+2)
			del(enemies_bullets,b)
			p.life-=1
		end
	end
	-- love
	for l in all(love) do
		if collide(p,l) then
			sfx(5)
			del(love,l)
			if p.life<c_ship_life then
				p.life+=1
			end
		end
	end
	if p.life<=0 then
		sfx(2)
		state=1
	end
end

function draw_player()
	spr(1,p.x,p.y)
end

function draw_score()
	print(score.."/"..c_goal,2,2,10)
end

function draw_life()
	for i=0,p.life-1 do
		spr(0,i*8,128-8)
	end
	for i=p.life,c_ship_life-1 do
		spr(16,i*8,128-8)
	end
end
-->8
--enemies
function spawn_enemies(n)
	for i=1,n do
		local x,y,gap,nr,ir,yr
		if i<=4 then
			ir=i
		 	if (n>4) nr=4 else nr=n
			yr=0
		elseif i>4 and i<=8 then
			ir=i-4
			if (n>8) nr=8-4 else nr=n-4
			yr=2
	 	elseif i>8 then
			nr=n-8
	  		ir=i-8
	 		yr=4
		end
		gap=(128-8*nr)/(nr+1)
		x=gap*ir+8*(ir-1)
		y=-20-yr*8

		local new_enemy={
			x=x,
			y=y,
			life=c_enemy_life,
			speed=c_enemy_speed,
			type=rnd({3,19,35,51}),
			shoot_timer=flr(rnd(90))
		}
		add(enemies, new_enemy)
		end
end

function update_enemies()
	for e in all(enemies) do
		e.y+=e.speed
		if e.y>128 then
			del(enemies,e)
		end
		--collide
		for b in all(bullets) do
			if collide(e,b) then
				create_explosion(b.x+4,b.y+2)
				del(bullets,b)
				e.life-=1
				if e.life==0 then
					del(enemies,e)
					sfx(2)
					score+=100
					if p.life<c_ship_life and 
						ceil(rnd(10))==6 then
						spawn_love(e)
					end
				end
			end
		end
		--shoot
		e.shoot_timer+=1
		if e.shoot_timer==240 then
			enemy_shoot(e)
		e.shoot_timer=flr(rnd(90))
		end
	end
end

function draw_enemies()
	for e in all(enemies) do
		spr(e.type,e.x,e.y)
	end
end
-->8
-- misc
function collide(a,b)
	return not (a.x>b.x+8
		or a.y>b.y+8
		or a.x+8<b.x
		or a.y+8<b.y)
end

function collide_boss(a,b)
	return not (a.x>b.x+8
		or a.y>b.y+8
		or a.x+8*4<b.x
		or a.y+8*4<b.y)
end

-->8
--explosions
function create_explosion(x,y)
	sfx(1)
	add(explosions,{x=x,y=y,
		timer=0})
end

function update_explosions()
	for e in all(explosions) do
		e.timer+=1
			if e.timer==13 then
				del(explosions,e)
			end
	end
end

function draw_explosions()
	for e in all(explosions) do
		circ(e.x,e.y,e.timer/3,
		8+e.timer%3)
	end
end
-->8
-- game over
function update_gameover()
	if (btn(🅾️)) init_game()
	if music_start then
		music_start=false
		music(-1)
	end
end

function draw_gameover()
	cls()
	rectfill(31,43,105,79,13)
	rectfill(28,40,102,76,2)
	if p.life==0 then
 		print("defeat!",54,46,6)
 	else
		print("victory!",52,46,6)
 	end
	print("score:"..score,53,56,6)
	print("c/🅾️ to continue",34,66,6)
end
-->8
--boss
function spawn_boss(n)
	for i=1,n do
		local new_boss={
			x=rnd(127-32),
			y=-48,
			life=c_boss_life,
			speed=c_boss_speed
		}
		add(boss, new_boss)
		end
end

function update_boss()
	for bo in all(boss) do
		bo.y+=bo.speed
		if bo.y>128 then
			bo.y=-48
			bo.x=rnd(128-24)
		end
		--collide
		for b in all(bullets) do
			if collide_boss(bo,b) then
				create_explosion(b.x+4,b.y+2)
				del(bullets,b)
				bo.life-=1
				if bo.life==0 then
					del(boss,bo)
					sfx(2)
					score+=10000
					state=1
				end
			end
		end
	end
end

function draw_boss()
	for bo in all(boss) do
		spr(4,bo.x,bo.y,4,4)
	end
end
-->8
-- enemies bullets
function enemy_shoot(e)
	local new_bullet={
		x=e.x,
		y=e.y;
		speed=c_enemy_bullet_speed,
		type=18
	}
	add(enemies_bullets, new_bullet)
	sfx(0)
end

function update_enemies_bullets()
	for b in all(enemies_bullets) do
		b.y+=b.speed
		if b.y<-8 then
			del(enemies_bullets,b)
		end
	end
end

function draw_enemies_bullets()
	for b in all(enemies_bullets) do
		spr(b.type,b.x,b.y)
	end
end
-->8
-- love
function spawn_love(e)
	local new_love={
		x=e.x,
		y=e.y;
		speed=c_love_speed,
		type=0
	}
	add(love, new_love)
end

function update_love()
	for l in all(love) do
		l.y+=l.speed
		if l.y<-8 then
			del(love,l)
		end
	end
end

function draw_love()
	for l in all(love) do
		spr(l.type,l.x,l.y)
	end
end
__gfx__
00000000080110800099990088222288000000000000666665555500000000000000000000000000000000000000000000000000000000000000000000000000
088088000811118009aaaa9082277228000000000666666655555550000000000000000000000000000000000000000000000000000000000000000000000000
88888780081261809aaaaaa922788722000000066666666555500555500000000000000000000000000000000000000000000000000000000000000000000000
88888880011221109aa77aa922788722000000666666666555500555550000000000000000000000000000000000000000000000000000000000000000000000
88888880211111129aa77aa922277222000006666666666555555555555000000000000000000000000000000000000000000000000000000000000000000000
08888800211111129aaaaaa922222222000066666666665555555555555500000000000000000000000000000000000000000000000000000000000000000000
008880002111111209aaaa9002111120000666666556665555555000555550000000000000000000000000000000000000000000000000000000000000000000
00080000050880500099990000222200006666666556665555550000055555000000000000000000000000000000000000000000000000000000000000000000
00000000000000000022220099111199006666666666655555500000005555000000000000000000000000000000000000000000000000000000000000000000
06606600000000000288882091177119066556666666655555500000005555500000000000000000000000000000000000000000000000000000000000000000
60060060000000002888888211799711066556666666655555500000005555500000000000000000000000000000000000000000000000000000000000000000
6000006000000000288ee88211799711066666666666655555550000055555500000000000000000000000000000000000000000000000000000000000000000
6000006000000000288ee88211177111666666666666655555555000555555550000000000000000000000000000000000000000000000000000000000000000
06000600000000002888888211111111666666666666655005555555555555550000000000000000000000000000000000000000000000000000000000000000
00606000000000000288882001222210666665556666655005555555555005550000000000000000000000000000000000000000000000000000000000000000
00060000000000000022220000111100666555555566655555555555555005550000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000cc3333cc666555555566655555555555555555550000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000c337733c665555555556655555555555555555550000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000337cc733665555555556655555555000055555550000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000337cc733665555555556655555500000000555550000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000033377333066555555566655555500000000555500000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000033333333066555555566655555000000000055500000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000003888830066665556666655555000000000055500000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000333300006666666666665555000000000055000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000ee4444ee006666666666665555000000000055000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000e447744e000666666666665555500000000550000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000447ee744000066666655666555500000000500000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000447ee744000006666655666555555000055000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000044477444000000666666666555555555550000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000044444444000000066666666655555555500000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000004dddd40000000000666666665555550000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000444400000000000000666666660000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00aaa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00a0a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e000000000000000
00a0a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00a0a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00aaa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000999900000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000009aaaa90900000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000009aaaaaa9000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000009aa77aa9000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000009aa77aa9000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000009aaaaaa9000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000009aaaa90000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000999900000000000000000000000000666665555500000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000666666655555550000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000066666666555500555500000000000000000
00000000000000000f00000000000000000000000000000000000000000000000000000000000000000000000000666666666555500555550000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006666666666555555555555000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000066666666665555555555555500000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000666666556665555555000555550000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000006666666556665555550000055555000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000006666666666655555500000005555000900000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000066556666666655555500000005555500000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000066556666666655555500000005555500000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000066666666666655555550000055555500000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000666666666666655555555000555555550000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000666666666666655005555555555555550000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000666665556666655005555555555005550000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000666555555566655555555555555005550000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000666555555566655555555555555555550000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000665555555556655555555555555555550000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000665555555556655555555000055555550000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000665555555556655555500000000555550000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000066555555566655555500000000555500000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000066555555566655555000000000055500000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000066665556666655555000000000055500000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000006666666666665555000000000055000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000006666666666665555000000000055000000000006
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000666666666665555500000000550000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000066666655666555500000000500000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006666655666555555000055000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000666666666555555555550000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000066666666655555555500000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000666666665555550000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000a00000000000666666660000000000000000000000
00000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000050000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000f000000000000000000000000000000000000000050000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008011080000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008111180000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008126180000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001122110000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000021111112000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000021111112000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000021111112000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005088050000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f0000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f00000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000050000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000900000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000090000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000e000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000050000000000000000000000000000000000000000000
08808800088088000880880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888780888887808888878000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888880888888808888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
888888808888888088888880000000000000000000000000000000000000000000000000000000000000e0000000000000000000000000000000000000000000
08888800088888000888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00888000008880000088800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000800000008000000080000000000000000000000000000f0000000000000000000000000000000000000000000000000000000000000000000000000000000

__sfx__
00010000315502f5502d5502c550285502555025550205501e5501a550175501355012550105500d5500c5400b5300a5200352002510005100051008500005000050000500005000050000500005000050000500
000100002961029630236401c65015650106500e6500d6500c6500c6500c6500c6500c6500e6501065011650136500b6300761003610006000060000600006000060000600006000060000600006000060000600
01020000000001e0501d0501c0501805014050110500f0500d0500a05007050050500405002050010400104000030000200002000020000100001000000000000000000000000000000000000000000000000000
0118000004022070220b0220702204022070220b0220702204022070220b0220702204022070220b0220702204022070220b0220702204022070220b0220702204022070220b0220702204022070220b02207022
011800002402200002000020000228022000022602200002290220000200002000022802200002000020000224022000020000200002280220000226022000021a02200002000021d02200000000001c02200000
000100000000000010000200002001030010300203003040050400604007040090400a0400b0400c0500d0500e0500f05010050130501405016050190501b0501d05020050220502505026050290502a0502b050
__music__
01 03444344
02 03044344
02 43444344

