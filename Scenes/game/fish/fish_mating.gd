#FishMating
extends FishState

func enter(_msg:={}):
	fishBody.currentSwimspeed = fishBody.swimSpeed / 2.0
