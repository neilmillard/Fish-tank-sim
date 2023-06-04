extends MarginContainer

class Property:
	var num_format = "%4.2f"
	var object
	var property
	var label_ref
	var display
	
	func _init(_object, _property, _label, _display):
		object = _object
		property = _property
		label_ref = _label
		display = _display
	
	func set_label():
		var s = object.name + "/" + property + ": "
		var p = object.get_indexed(property)
		match display:
			"":
				s += str(p)
			"length":
				s += num_format % p.length()
			"round":
				match typeof(p):
					TYPE_INT, TYPE_FLOAT:
						s += num_format % p
					TYPE_VECTOR2, TYPE_VECTOR3:
						s += str(p.round())
		label_ref.text = s

var props = []

func _enter_tree():
	GameManager.set_debug_overlay(self)
	
func _process(_delta):
	if not visible:
		return
	for prop in props:
		prop.set_label()

func add_property(object, property, display):
	var label = Label.new()
	$VBoxContainer.add_child(label)
	props.append(Property.new(object, property, label, display))
	
func remove_property(object, property):
	for prop in props:
		if prop.object == object and prop.property == property:
			props.erase(prop)
