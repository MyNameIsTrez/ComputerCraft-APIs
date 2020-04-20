-- BackwardsOS


--useBackwardsOS = true

-- Power this side with a redstone signal to disable starting BackwardsOS.lua.
disableSide = 'right'

redownloadAPIsOnStartup = false


-- Animation


-- Whether the program sleeps between drawing each frame, by frameSleep number of seconds.
animationFrameSleeping = true

-- Seconds of sleeping between frames, -1 is no sleeping. Default is 0.05.
animationFrameSleep = 0.1

-- How many frames are skipped between sleeping.
-- Setting to 0 or 1 means every frame has a sleep.
-- If frameSleeping is set to false, there is never any sleeping.

-- 1.57 for YouTube videos, with 426x160 animationSize.
animationFrameSleepSkipping = 2

-- How many seconds are counted down before the animation starts playing. Set to 0 for no countdownTime.
countdownTime = 0

-- Whether to start playing the animation. Can be used to exit the while loop of a timed animation being run.
playAnimationBool = true

-- How many frames can be written to a timed animation file before a new timed animation file gets created.
maxFramesPerTimedAnimationFile = 100

-- Whether to print the progress of loading a file.
animationProgressBool = true

useMonitor = false

-- Whether the program loops the animation.
loop = true

-- The top-left corner where the animation will be drawn from.
offset = { x = 1, y = 1 }

folder = 'BackwardsOS/programs/Animation/'

animationSize = { width = 9, height = 8 }


-- UI


UIFrameSleeping      = false
UIFrameSleep         = 0.05
UIFrameSleepSkipping = 1.57
UIProgressBool       = false


-- Particles


createSpawnerTime = 5 -- Seconds.
spawnerParticleCount = 750 -- Integer.
sleepTime = 0.05 -- Seconds.

minLifeTime = 20 -- Integer.
maxLifeTime = 100 -- Integer.

minVelocity = 0.1 -- Float.
maxVelocity = 10 -- Float.

minDirection = 0 -- Radians.
maxDirection = 2 * math.pi -- Radians.


-- Ray Casting


-- The top-left corner where will be drawn from.
--playArea = { X = 1, Y = 1 }


-- ThreeDee


-- The top-left corner where everything will be drawn from.
--offset = { x = 1, y = 1 }


-- Graph


graphCols = 5
graphOffset = { x = 10, y = 10 }
graphSize = { width = 15, height = 10 }
graphChar = '@'


-- Connections


connectionsOffset = { x = 1, y = 1 }

width, height   = term.getSize()
connectionsSize = { width = width, height = height }

connectionsPointCountMult            = 5
connectionsMaxConnectionDistMult     = 10
connectionsConnectionWeightAlphaMult = 0.06
connectionsMaxFPS                    = 30 -- Not necessary?
connectionsPointMinVel               = 30 / connectionsMaxFPS
connectionsPointMaxVel               = 30 / connectionsMaxFPS