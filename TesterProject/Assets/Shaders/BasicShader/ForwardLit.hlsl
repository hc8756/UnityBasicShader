#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"// not in core.hlsl, must be included separately


/*Documentation on accessing SL properties: https://docs.unity3d.com/2021.3/Documentation/Manual/SL-PropertiesInPrograms.html
2D texture properties map to sampler2D variables with same name*/
// These variables correspond with material properties
sampler2D _MyDiffuseTexture; 
sampler2D _MyNormalTexture;
sampler2D _MySpecularTexture;
sampler2D _MyRoughnessTexture;
sampler2D _MyAOTexture;

struct VertexInput {
	//semantics: name first part whatever you want
	//second part has to follow this convention: https://learn.microsoft.com/en-us/windows/win32/direct3dhlsl/dx-graphics-hlsl-semantics
	float3 positionOS		: POSITION; 
	float2 uv				: TEXCOORD;
	float3 normalOS			: NORMAL;
	float4 tangentOS		: TANGENT;
};

struct VertexOutput {
	float4 positionCS		: SV_POSITION;
	float3 positionWS		: WORLD_POSITION;
	float2 uv				: TEXCOORD;
	float3 normalWS			: NORMAL;
	float3 tangentWS		: TANGENT;
	float3 bitangentWS		: BITANGENT;
};

// The vertex function. This runs for each vertex on the mesh.
// Its primary purpose is taking vertex information from object space to clip space
VertexOutput Vertex(VertexInput input) {
	VertexOutput output;

	// Helper functions defined in ShaderVariablesFunctions.hlsl
	// Structs defined in Core.hlsl
	VertexPositionInputs posInputs = GetVertexPositionInputs(input.positionOS);
	VertexNormalInputs normInputs = GetVertexNormalInputs(input.normalOS, input.tangentOS);

	// Pass position and orientation data to the fragment function
	output.positionCS = posInputs.positionCS;
	output.positionWS = posInputs.positionWS;
	output.uv = input.uv;
	output.normalWS = normInputs.normalWS;
	output.tangentWS = normInputs.tangentWS;
	output.bitangentWS = normInputs.bitangentWS;
	return output;
}

float4 Fragment(VertexOutput input) : SV_TARGET{
//Unity hlsl sampler documentation: https://docs.unity3d.com/Manual/SL-SamplerStates.html

	float3 N = normalize(input.normalWS);
	float3 B = normalize(input.bitangentWS);
	float3 T = normalize(input.tangentWS);
	float3x3 TBN = float3x3(T, B, N);
	float3 unpackedNormal = tex2D(_MyNormalTexture, input.uv).rgb * 2 - 1;
	input.normalWS = mul(unpackedNormal, TBN);

	float3 diffuseColor = tex2D(_MyDiffuseTexture, input.uv).rgb;
	
	Light light = GetMainLight();

	float3 lightDir = light.direction;
	float3 lightCol = light.color;
	float3 diffuseTerm = saturate(dot(input.normalWS,lightDir))*lightCol;

	float3 dirToCam = normalize(_WorldSpaceCameraPos - input.positionWS);

	float specVal = tex2D(_MySpecularTexture, input.uv).r;
	float roughVal = tex2D(_MyRoughnessTexture, input.uv).r;
	float aoColor = saturate(pow(tex2D(_MyAOTexture, input.uv).r, 2));

	float shine = (1.0001 - roughVal) * 256.0f;
	//Specular term (Directional)
	float3 reflectDir = reflect(-lightDir, input.normalWS);
	float RdotV = saturate(dot(reflectDir, dirToCam));
	float3 specularTerm = pow(RdotV,shine) * lightCol * specVal;
	float3 ambientTerm = float3(0.4f, 0.6f, 0.75f);

	float3 totalColor =MainLightRealtimeShadow(TransformWorldToShadowCoord(input.positionWS))*diffuseColor * aoColor * (ambientTerm+diffuseTerm +specularTerm);
	
	return  float4(totalColor,1);
}