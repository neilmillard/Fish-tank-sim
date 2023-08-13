shader_type canvas_item;

uniform bool PREVIEW = false;
uniform bool PLACEABLE = true;

void fragment() {
	vec4 previous_colour = texture(TEXTURE, UV);
	vec4 white_colour = vec4(1.0, 1.0, 1.0, previous_colour.a);
	vec4 new_colour = previous_colour;
	
	if (PREVIEW == true) {
		
		if (PLACEABLE == true) {
			new_colour = texture(TEXTURE, UV);
		} else {
			new_colour.r = 0.9;
			new_colour.g = new_colour.g / 2.0;
			new_colour.b = new_colour.b / 2.0;
		}
	
		// opacity
		if (new_colour.a == 1.0) {
			new_colour.a = 0.75;
		}
	
	} else {
		new_colour = texture(TEXTURE, UV);
	}
	
	COLOR = new_colour;
}
