shader_type canvas_item;

// Ranges from 0 to 1 over the course of the transition.
// We use this to actually animate the shader.
uniform float progress : hint_range(0, 1);

// Size of each diamond, in pixels.
uniform float diamondPixelSize = 10.0f;

void fragment() {
	// Keep the circle at the same size as orignal resolution 
	float originalSize = 128.0 / diamondPixelSize;
	float maxSize = min(1.0 / SCREEN_PIXEL_SIZE.x, 1.0 / SCREEN_PIXEL_SIZE.y);
	float size = maxSize / originalSize;
	
	float xFraction = fract(FRAGCOORD.x / size);
	float yFraction = fract(FRAGCOORD.y / size);
	float xDistance = abs(xFraction - 0.5);
	float yDistance = abs(yFraction - 0.5);
	if (xDistance + yDistance + (UV.x + UV.y) > progress * 4.0f) {
		discard;
	}
}