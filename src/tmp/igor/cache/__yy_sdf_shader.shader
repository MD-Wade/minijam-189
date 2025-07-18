//
// SDF vertex shader
//
attribute vec3 in_Position;                  // (x,y,z)
//attribute vec3 in_Normal;                  // (x,y,z)     unused in this shader.
attribute vec4 in_Colour;                    // (r,g,b,a)
attribute vec2 in_TextureCoord;              // (u,v)

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main()
{
    vec4 object_space_pos = vec4( in_Position.x, in_Position.y, in_Position.z, 1.0);
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;
    
    v_vColour = in_Colour;
    v_vTexcoord = in_TextureCoord;
}

//######################_==_YOYO_SHADER_MARKER_==_######################@~
//
// SDF fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 gm_SDF_Dist_UV;			// the SDF distance value of half a pixel in UV space (takes account of texture size)

void main()
{
	vec4 texcol = texture2D( gm_BaseTexture, v_vTexcoord );
		
	vec2 coordDiffX = dFdx(v_vTexcoord);
	vec2 coordDiffY = dFdy(v_vTexcoord);
	vec2 scaledCoordDiffX = coordDiffX * gm_SDF_Dist_UV;
	vec2 scaledCoordDiffY = coordDiffY * gm_SDF_Dist_UV;
	float diffXLength = length(scaledCoordDiffX);
	float diffYLength = length(scaledCoordDiffY);		
	float spread = (diffXLength + diffYLength) * 0.5;		// get average	

	//float spread = fwidth(texcol.a);	
	//spread = max(spread * 0.75, 0.001);		
	
	texcol.a = smoothstep(0.5 - spread, 0.5 + spread, texcol.a);			
	
	vec4 combinedcol = v_vColour * texcol;
	DoAlphaTest(combinedcol);	
			
    gl_FragColor = combinedcol;
}

