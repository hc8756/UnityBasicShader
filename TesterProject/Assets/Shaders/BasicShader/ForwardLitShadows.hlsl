#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"// not in core.hlsl, must be included separately

struct VertexInput {
	float3 positionOS		: POSITION;
};

struct VertexOutput {
	float4 positionCS		: SV_POSITION;
};

// The vertex function. This runs for each vertex on the mesh.
// Its primary purpose is taking vertex information from object space to clip space
VertexOutput Vertex(VertexInput input) {
	VertexOutput output;

	VertexPositionInputs posInputs = GetVertexPositionInputs(input.positionOS);
	//depth buffer included
	output.positionCS = posInputs.positionCS;

	return output;
}

float4 Fragment(VertexOutput input) : SV_TARGET{
	return  0;
}