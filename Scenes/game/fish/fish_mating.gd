#FishMating
extends FishState

func enter(_msg:={}):
	myBody.currentSwimspeed = myBody.myCharacter.swimSpeed / 2.0
