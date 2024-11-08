Shader "CustomRenderTexture/customdaynight"
{
    Properties
    {
        _BaseColor("Base Color", Color) = (1,1,1,1)
        _MainTex("Texture", 2D) = "white" {}
        _LightColorDay("Day Light Color", Color) = (1, 0.5, 0.5, 1) // 빨간빛
        _LightColorNight("Night Light Color", Color) = (0.5, 0.5, 1, 1) // 파란빛
        _LightDirection("Light Direction", Vector) = (0, -1, 0)
        _LightCenter("Light Center", Vector) = (0.5, 0.5, 0) // 빛의 중심
        _LightRadius("Light Radius", Float) = 0.5 // 빛의 반경
        _LightIntensity("Light Intensity", Float) = 1
        _LightMode("Light Mode (0: Sun, 1: Moon)", Float) = 0
     }

     SubShader
     {
        
        Tags { "RenderType" = "Opaque" }
        LOD 200

        Pass
        {
            Name "customdaynight"
            Tags { "LightMode" = "Universal2D" }
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite On
            Cull Off

            HLSLPROGRAM
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            //#include "UnityCustomRenderTexture.cginc"
            //#pragma vertex CustomRenderTextureVertexShader
            #pragma vertex vert
            #pragma fragment frag
            

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
            };


            float4 _BaseColor;
            float4 _LightColorDay;
            float4 _LightColorNight;
            float3 _LightDirection;
            float3 _LightCenter;
            float _LightRadius;
            float _LightIntensity;
            float _LightMode; // 0: Sunlight, 1: Moonlight


            v2f vert(appdata v)
            {
                v2f o;
                o.pos = TransformObjectToHClip(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                // 기본 배경 색상과 텍스처 샘플링
                float4 baseColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv) * _BaseColor;

                // _LightMode에 따라 빛의 색상 선택
                float4 lightColor = (_LightMode < 0.5) ? _LightColorDay : _LightColorNight;

                // 빛 중심과 현재 픽셀의 거리 계산
                float2 lightCenterUV = _LightCenter.xy; // 빛의 중심 좌표 (UV 공간에서)
                float dist = distance(i.uv, lightCenterUV);

                /*
                // 빛의 강도는 반경에 따라 감소
                float lightFalloff = smoothstep( 0.0, _LightRadius, dist); // 반경을 벗어날수록 부드럽게 어두워짐
                

                // 거리 기반의 빛 강도와 방향성 빛 강도를 결합
                float3 lightDir = normalize(_LightDirection);
                float3 normal = float3(0, 0, -1);
                float directionalLightAmount = max(dot(normal, lightDir), 0.0) * _LightIntensity;

                // 최종 빛 강도
                float lightAmount = (1.0 - lightFalloff) * directionalLightAmount;

                // 조명 효과가 적용된 최종 색상 계산
                float4 finalColor = baseColor * (lightAmount * lightColor);
                finalColor.a = baseColor.a; // 투명도 유지
                */

                // 가우시안 감쇠를 적용한 빛 효과
                float lightFalloff = exp(-pow(dist / _LightRadius, 2.0)); // 가우시안 감쇠

                // 빛의 강도와 감쇠를 반영한 최종 빛 효과
                float4 finalLightEffect = lightColor * lightFalloff * _LightIntensity;

                // 최종 색상 계산
                float4 finalColor = baseColor * finalLightEffect;
                finalColor.a = baseColor.a; // 투명도 유지

                return finalColor;
            }
            ENDHLSL
        }
    }
}
