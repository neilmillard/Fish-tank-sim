#FishMating
extends FishState

func enter(_msg:={}):
	myBody.currentSwimspeed = myBody.swimSpeed / 2.0
