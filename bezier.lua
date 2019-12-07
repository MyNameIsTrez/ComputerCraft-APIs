-- README --------------------------------------------------------
-- Other APIs required:
-- 	   * Common Functions (cf)
--     * Shape (shape)



-- FUNCTIONS --------------------------------------------------------

function createRandomAnchorPoints(args)
    local anchorPoints = {}
    for i = 1, args.anchorPointCount do
        anchorPoints[i] = vector.new(math.random(args.minX, args.maxX), math.random(args.minY, args.maxY))
    end
    return anchorPoints
end

function bezierShow(points, lineIcon)
    for i = 1, #points - 1 do
        shape.line(points[i], points[i + 1], lineIcon)
    end
end

function getPointBetween(p1, p2, t)
    local diff = p2:sub(p1)
    local offset = diff:mul(t)
    return p1:add(offset)
end

function getPointsBetween(points, t)
    local newPoints = {}
    for i = 1, #points - 1 do
        newPoints[i] = getPointBetween(points[i], points[i + 1], t)
    end
    return newPoints
end

function showPoint(point, icon)
    shape.point(point, icon)
end

function getBezierPoints(args)
    local points
    local curvePoints = {}
    local counter = 1

    while counter <= args.curvePointCount do
        counter = counter + 1

        points = args.anchorPoints -- Reset the points table to anchorPoints.

        -- Get a curve point and put it in curvePoints.
        while #points > 1 do
            points = getPointsBetween(points, args.t)
        end

        local curvePoint = points[1]:round() -- Rounding the points, because they get floored when shown.
        curvePoints[#curvePoints + 1] = curvePoint

        if args.showCurvePointsBool then
            showPoint(curvePoint, args.pointIcon)
        end

        args.t = args.t + args.tStep
		
		if args.turboSpeed then
			cf.yield()
		else
			sleep(args.sleepTime)
		end
    end
    return curvePoints
end

function showAnchorPoints(anchorPoints, anchorIcon)
    for i = 1, #anchorPoints do
        showPoint(anchorPoints[i], anchorIcon)
    end
end

function bezierCurve(args)
    local anchorPointCount = args.anchorPointCount or 3 -- Anchors determine the shape of the curve. More anchors means more complex curves. Default is 3.
    local curvePointCount = args.curvePointCount or 20 -- Higher number increases the accuracy of the curve. Default is 20.
	
	local turboSpeed = args.turboSpeed == nil or args.turboSpeed == true -- If turboSpeed is true, sleepTime is ignored. Default is true.
    local showBezierCurveBool = args.showBezierCurveBool == nil or args.showBezierCurveBool == true -- Default is true.
    local showAnchorPointsBool = args.showAnchorPointsBool == true -- Default is false.
	local showCurvePointsBool = args.showCurvePointsBool == true -- Default is false.
	
    local sleepTime = args.sleeptime or 0.2 -- The sleep(n) function is 0 or 0.05 seconds at minimum. Default is 0.15.
    
    local anchorIcon = args.anchorIcon or "a" -- Default is "A".
    local pointIcon = args.pointIcon or "p" -- Default is "P".
    local lineIcon = args.lineIcon or "*" -- Default is "*".

    if args.maxX == nil or args.maxY == nil then
        term.setCursorPos(1, 1)
        print("ERROR: You forgot to give the bezier() function a maxX and/or maxY!")
		sleep(1000)
    end
    
    local minX = args.minX or 1
    local minY = args.minY or 1
    local maxX = args.maxX
    local maxY = args.maxY

    local t = 0
    local tStep = 1/(curvePointCount - 1)
	
	local anchorPoints
	if args.anchorPoints and #args.anchorPoints > 0 then
		anchorPoints = args.anchorPoints
	else
		anchorPoints = createRandomAnchorPoints({
     	   anchorPointCount = anchorPointCount,
     	   minX = minX,
     	   minY = minY,
			maxX = maxX,
			maxY = maxY
		})
	end
    if showAnchorPointsBool then
        showAnchorPoints(anchorPoints, anchorIcon)
    end

    local curvePoints = getBezierPoints({
        turboSpeed = turboSpeed,
        sleepTime = sleepTime,
        anchorPoints = anchorPoints,
        curvePointCount = curvePointCount,
        showCurvePointsBool = showCurvePointsBool,
        pointIcon = pointIcon,
        t = t,
        tStep = tStep
    })
    if showBezierCurveBool then
        bezierShow(curvePoints, lineIcon)
    end
    
    if args.getAnchorPointsBool and args.getCurvePointsBool then
		return {anchorPoints, curvePoints}
	elseif args.getAnchorPointsBool then
		return anchorPoints
	elseif args.getCurvePointsBool then
		return curvePoints
	end
end