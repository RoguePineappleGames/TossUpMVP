shader_type canvas_item;

uniform vec3 flash_color = vec3(1.0, 1.0, 0.2);
uniform float flash_strength = 1;

void vertex() {
	//runs on every vertex
}

void fragment() {
	// run on every pixel

	//use texture function to read out data of a specific texture. The arguments passed indicate which sprite and position to read out.
	vec4 input_color = texture(TEXTURE, UV);

	COLOR = mix(vec4(flash_color, input_color.a), input_color, flash_strength);

}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
