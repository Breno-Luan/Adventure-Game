-----------------------------------------------------------------------------------------
--
-- menu.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

lime = require("lime.lime")
-- include Corona's "widget" library
local widget = require "widget"

--------------------------------------------

-- forward declarations and other locals
local playBtn



-- 'onRelease' event listener for playBtn
local function onPlayBtnRelease(self, event)
	
	if ( event.phase == "began" ) then
		print "Clicou"
		composer.gotoScene( "level1", "fade", 500 )
	end	
	return true
end

local function onCreditoBtnRelease(self, event)
	
	if ( event.phase == "began" ) then
		print "Clicou"
		composer.gotoScene( "creditos", "fade", 500 )
	end	
	return true
end

function scene:create( event )

	local sceneGroup = self.view
	
	-- display a background image
	local background = display.newImageRect( "background.jpg", display.contentWidth+90, display.contentHeight )
	background.anchorX = 0
	background.anchorY = 0
	background.x, background.y = -45, 0
	
	playBtn = display.newImageRect( "play-over.png", 64, 64 )
	playBtn.width = 64
	playBtn.height = 64
	playBtn.anchorX = 0
	playBtn.anchorY = 0
	playBtn.x, playBtn.y = 320, 250
	playBtn.touch = onPlayBtnRelease
	playBtn:addEventListener( "touch", playBtn )
		
	creditoBtn = display.newImageRect( "config-over.png", 64, 64 )
	creditoBtn.width = 64
	creditoBtn.height = 64
	creditoBtn.anchorX = 0
	creditoBtn.anchorY = 0
	creditoBtn.x, creditoBtn.y = playBtn.x+80, playBtn.y
	creditoBtn.touch = onCreditoBtnRelease
	creditoBtn:addEventListener( "touch", creditoBtn )
	-- Called when the scene's view does not exist.
	-- 
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.
	--sceneGroup:insert( visual )
	--sceneGroup:insert( titleLogo )
	sceneGroup:insert( background )
	sceneGroup:insert( creditoBtn )
	sceneGroup:insert( playBtn )
	
	
	
end


function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
		--visual = lime.createVisual(map)
	elseif phase == "did" then
		-- Called when the scene is now on screen
		-- 
		-- INSERT code here to make the scene come alive
		-- e.g. start timers, begin animation, play audio, etc.
		
		
	end	
end

function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if event.phase == "will" then
		-- Called when the scene is on screen and is about to move off screen
		--
		-- INSERT code here to pause the scene
		-- e.g. stop timers, stop animation, unload sounds, etc.)
	elseif phase == "did" then
		-- Called when the scene is now off screen
	end	
end

function scene:destroy( event )
	local sceneGroup = self.view
	
	-- Called prior to the removal of scene's "view" (sceneGroup)
	-- 
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
	
	if playBtn then
		playBtn:removeSelf()	-- widgets must be manually removed
		playBtn = nil
		creditoBtn:removeSelf()	-- widgets must be manually removed
		creditoBtn = nil
	end
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene