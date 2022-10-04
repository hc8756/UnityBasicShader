Shader "Unlit/MyBasicShader"
{
    //Properties documentation: https://docs.unity3d.com/2021.3/Documentation/Manual/SL-Properties.html
    //Basically information that would be passed in a constant buffer in DirectX
    Properties{
        _MyDiffuseTexture("Texture", 2D) = "white" {}
        _MyNormalTexture("Texture", 2D) = "white" {}
        _MySpecularTexture("Texture", 2D) = "white" {}
        _MyRoughnessTexture("Texture", 2D) = "white" {}
        _MyAOTexture("Texture", 2D) = "white" {}
    }
    SubShader
    {
        //Subshader tag documentation: https://docs.unity3d.com/2021.3/Documentation/Manual/SL-SubShaderTags.html
        Tags { "RenderPipeline"="UniversalPipeline" }

        Pass
        {
            Name "ForwardLit"
            //Pass tag documentation:
            //https://docs.unity3d.com/Packages/com.unity.render-pipelines.universal@11.0/manual/urp-shaders/urp-shaderlab-pass-tags.html#urp-pass-tags-lightmode
            //Universal Forward means all sources of light are taken into consideration
            Tags {"LightMode"="UniversalForward"}
            HLSLPROGRAM
                //Pragma directives register vertex and fragment shaders from included hlsl file
                #pragma vertex Vertex
                #pragma fragment Fragment                
                #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
                #pragma multi_compile _ _MAIN_LIGHT_CALCULATE_SHADOWS
                #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
                #include "ForwardLit.hlsl"
            ENDHLSL
        }
        Pass{
           Name "ShadowPass"
            Tags {"LightMode" = "ShadowCaster"}
            HLSLPROGRAM
                #pragma vertex Vertex
                #pragma fragment Fragment

                #include "ForwardLitShadows.hlsl"
            ENDHLSL
        }
    }
}
