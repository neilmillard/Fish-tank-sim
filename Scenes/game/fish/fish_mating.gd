#FishMating
extends FishState

func enter(_msg:={}):
	myBody.currentSwimspeed = myBody.get_current_swimSpeed() / 2.0
