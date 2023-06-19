#FishFleeing
extends FishState

func enter(_msg:={}):
	fishBody.currentSwimspeed = fishBody.fleeSpeed
