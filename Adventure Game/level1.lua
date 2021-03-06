-----------------------------------------------------------------------------------------
--
-- level1.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

-- include Corona's "physics" library
local physics = require "physics"
physics.start()--; physics.pause()

lime = require("lime.lime")
local ui = require("lime.ui")
local vibrator = require('plugin.vibrator')
local GBCDataCabinet = require("plugin.GBCDataCabinet")
local success = false

local map = lime.loadMap("level1.tmx")
--------------------------------------------
system.activate( "multitouch" )
-- forward declarations and other locals
local screenW, screenH, halfW = display.contentWidth, display.contentHeight, display.contentWidth*0.5
local score = 0

-- Player motion constants
local STATE_IDLE = "Idle"
local STATE_WALKING = "Walking"
local DIRECTION_LEFT = -1
local DIRECTION_RIGHT = 1

success = GBCDataCabinet.createCabinet("Scores")
		--Camera Foco
		local onTouch = function(event)
			map:drag(event)
		end

function scene:create( event )

	local sceneGroup = self.view

	--Runtime:addEventListener( "touch", onTouch )
	success = GBCDataCabinet.load("Scores")
	if(success) then
		GBCDataCabinet.set("Scores", "score", 0)
		score = GBCDataCabinet.get("Scores", "score")
	else
		score = 0
	end
	
end
----------------------------------------------------------------------------------------------

function scoreUpdate()
	textScore:setFillColor(255, 255, 255, 255)
	textScore.x = 120
	textScore.y = 15
	textScore.text = "Pontuação: "..score
	GBCDataCabinet.set("Scores", "score", score)
	success = GBCDataCabinet.save("Scores")
 end
 
-------------------------------------------
 local function playerPicksUpItem(item) 
  local onTransitionEnd = function(s) 
    return function(evt)
		vibrator.vibrate(10)
      evt:removeSelf()
    end
  end
  -- fade out the item
  transition.to(item, {time = 100, alpha = 0, onComplete=onTransitionEnd("item")})
  if item.pickupType == "score" then
    score = score + item.scoreValue
  end
end
-------------------------------------------
local function onCollision(self, event )
  if ( event.phase == "began" ) then
    if event.other.IsGround then
      player.canJump = true       
      if player.state == STATE_JUMPING then
        player.state = STATE_IDLE
        player:setSequence("anim" .. player.state)
        player:play()
		 
      end
    end
  if event.other.IsPickup then
      playerPicksUpItem(event.other)
  end
  
  
  elseif ( event.phase == "ended" ) then
    if event.other.IsGround then
      player.canJump = false
    end
	
	if event.other.IsDead then
		print "Morreu"
		composer.gotoScene( "gameOver", "fade", 100 )
		composer.removeHidden()

	elseif event.other.IsDoor then
		print "Parabéns"
		composer.gotoScene( "menu", "fade", 100 )
		composer.removeHidden()
	end
  end
end

local function onCollisionEsqueleto(self, event )
	if ( event.phase == "began" ) then
		 if event.other.IsBlockRight then
			esqueleto.direction = -1
			esqueleto:setSequence("animWalkingLeft")
			esqueleto:play()
		 end
		 if event.other.IsBlockLeft then
			esqueleto.direction = 1
			esqueleto:setSequence("animWalkingRight")
			esqueleto:play()
		 end
	 elseif ( event.phase == "ended" ) then
	 
	 end
end
-------------------------------------------
local onPlayerProperty = function(property, type, object)
  player = object.sprite

  player.state = STATE_IDLE
  player:setSequence("anim" .. player.state)
  --player.rotation = false
  
  player:play()
  player.collision = onCollision
  player:addEventListener( "collision", player )
end

--local onAnimalProperty = function(property, type, object)
  --animal = object.sprite
  --animal:setSequence("animWalking")
  --animal:play()
  
--end

local onEsqueletoProperty = function(property, type, object)
	
	esqueleto = object.sprite
	esqueleto:setSequence("animWalkingRight")
	esqueleto:play()
	esqueleto.direction = DIRECTION_RIGHT
	esqueleto.collision = onCollisionEsqueleto
	esqueleto:addEventListener("collision", esqueleto)
  
end
----------------------------------------


local onButtonLeftEvent = function(event)
  if event.phase == "press" then
    player.direction = DIRECTION_LEFT
    player.xScale = DIRECTION_LEFT
    player.state = STATE_WALKING
    player:setSequence("anim" .. player.state)
    player:play()
  else
    player.state = STATE_IDLE
    player:setSequence("anim" .. player.state)
    player:play()
  end
end
local onButtonRightEvent = function(event)
  if event.phase == "press" then
    player.direction = DIRECTION_RIGHT
    player.xScale = DIRECTION_RIGHT
    player.state = STATE_WALKING
    player:setSequence("anim" .. player.state)
    player:play()
  else
    player.state = STATE_IDLE
    player:setSequence("anim" .. player.state)
    player:play()
  end
end

local onButtonAPress = function(event)
    if player.canJump then
        player:applyLinearImpulse(0, -30, player.x, player.y)
    end
end
local onButtonBPress = function(event)
	--physics.setGravity(0, 10.8)
--	player:applyLinearImpulse(0, -50, player.x, player.y)
end


-----------------------------------------------------------------------


----------------------------------------------------------------------

local onUpdate = function(event)
  if player then else return end
  if player.state == STATE_WALKING then
	map:setFocus(player)
	
    player:applyForce(player.direction * 8, 0, player.x, player.y)
  elseif player.state == STATE_IDLE then
    local vx, vy = player:getLinearVelocity()
    if vx ~= 0 then
      player:setLinearVelocity(vx * 0.6, vy)
    end
  end
end


---------------------------------------------------------

--local function enemyMoviment()
	--animal.direction = 1
	--animal:applyForce(animal.direction * 10, 0, animal.x, animal.y)
--end

local function enemyMoviment2()
	
	esqueleto:applyForce(esqueleto.direction * 5, 0, esqueleto.x, esqueleto.y)
end

local update = function( event )
	-- Update the map. Needed for using map:setFocus()
	map:update( event )
end



----------------------------------------------------------------------------------------------
function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
		map:addPropertyListener("IsPlayer", onPlayerProperty)
		--map:addPropertyListener("IsEnemy", onAnimalProperty)
		map:addPropertyListener("IsEnemy2", onEsqueletoProperty)
		visual = lime.createVisual(map)
		local physical = lime.buildPhysical(map)
		
		
		Runtime:addEventListener( "enterFrame", update )
		
		--Runtime:addEventListener( "enterFrame", enemyMoviment )
		Runtime:addEventListener( "enterFrame", enemyMoviment2 )
		
		
		Runtime:addEventListener( "touch", onTouch )

		map:setPosition(9999, 0)
		map:slideToPosition (0, 0, 5000)
		--map:setFocus(player)
		
		Runtime:addEventListener("touch", function(event)
		  if event.phase == "end" then
		  player.state = STATE_IDLE
		  player:setSequence("anim" .. player.state)
		  player:play()
		end
		end)
		
		Runtime:addEventListener("enterFrame", onUpdate)
		
	elseif phase == "did" then
		textScore = display.newText( "Pontuação: "..score, 0, 0, "Helvetica", 30 )
		Runtime:addEventListener( "enterFrame", scoreUpdate )
		buttonLeft = ui.newButton{
		  default = "buttonLeft.png",
		  over = "buttonLeft_over.png",
		  onEvent = onButtonLeftEvent
		}
		buttonLeft.x = (buttonLeft.width / 2 + 10)
		buttonLeft.y = (display.contentHeight - buttonLeft.height / 2 - 10) + 30
		buttonLeft.width = 50
		buttonLeft.height = 50
		
		buttonRight = ui.newButton{
		  default = "buttonRight.png",
		  over = "buttonRight_over.png",
		  onEvent = onButtonRightEvent
		}
		buttonRight.x = (buttonLeft.x + buttonRight.width)
		buttonRight.y = (buttonLeft.y)
		buttonRight.width = 50
		buttonRight.height = 50
		---------------------------------------------------------------------
		buttonA = ui.newButton{
			default = "buttonA.png",
			over = "buttonA_over.png",
			onEvent = onButtonAPress
		}
		buttonA.x = (display.contentWidth - buttonA.width / 2 - 10)
		buttonA.y = (display.contentHeight - buttonA.height / 2 - 10) + 30
		buttonA.width = 60
		buttonA.height = 60
		buttonB = ui.newButton{
			default = "buttonB.png",
			over = "buttonB_over.png",
			onEvent = onButtonBPress
		}
		buttonB.x = (buttonA.x - buttonB.width) + 30
		buttonB.y = (buttonA.y)
		buttonB.width = 60
		buttonB.height = 60
	
		physics.start()
	end
end

function scene:hide( event )
	local sceneGroup = self.view
	
	local phase = event.phase
	
	if event.phase == "will" then
		-- Called when the scene is on screen and is about to move off screen
		
		-- INSERT code here to pause the scene
		-- e.g. stop timers, stop animation, unload sounds, etc.)
		physics.stop()
	elseif phase == "did" then
		-- Called when the scene is now off screen
	end	
	
end

function scene:destroy( event )
		
	-- Called prior to the removal of scene's "view" (sceneGroup)
		Runtime:removeEventListener( "enterFrame", update )
		
		Runtime:removeEventListener("enterFrame", onUpdate)
		Runtime:removeEventListener( "touch", onTouch )
		--Runtime:removeEventListener( "enterFrame", enemyMoviment )
		Runtime:removeEventListener( "enterFrame", enemyMoviment2 )
		buttonLeft:removeSelf()
		buttonRight:removeSelf()
		buttonA:removeSelf()
		buttonB:removeSelf()
		visual:removeSelf()
		Runtime:removeEventListener( "enterFrame", scoreUpdate )
		textScore:removeSelf()
		GBCDataCabinet.clean ()
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
	local sceneGroup = self.view
	
	package.loaded[physics] = nil
	physics = nil
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene