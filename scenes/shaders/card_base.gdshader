shader_type canvas_item;

void fragment() {
    vec2 uv = UV - vec2(0.5); // centraliza o UV no centro
    float dist = length(uv);

    if (dist > 0.5) {
        discard; // remove os pixels fora do círculo
    }

    COLOR = texture(TEXTURE, UV);
}
