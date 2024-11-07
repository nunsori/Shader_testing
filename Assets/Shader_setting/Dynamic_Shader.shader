Shader "CustomRenderTexture/Dynamic_Shader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex("InputTex", 2D) = "white" {}
        _CircleColor("Circle Color", Color) = (1, 0, 0, 1) // 원의 색상 (기본값은 빨간색)
        _CircleRadius("Circle Radius", Range(0, 1)) = 0.25 // 원의 반지름
        _CircleCenter("Circle Center", Vector) = (0.5, 0.5, 0, 0) // 원의 중심

        _CircleCount("Circle Count", Range(0,30)) = 1 // 원의 개수
    }

    SubShader
    {
        Blend SrcAlpha OneMinusSrcAlpha
        Tags {"RenderType" = "Opaque"}
        LOD 200

        Pass
        {
            Name "Dynamic_Shader"
            Tags { "LightMode" = "Universal2D" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            //#include "Packages/com.unity.render-pipelines.universal/Shaders/2D/Include/Core2D.hlsl"

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            float4 _Color;
            //sampler2D _MainTex;
            half4 _CircleColor;
            half _CircleRadius;
            half2 _CircleCenter;


            half _CircleCount;

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

            struct circles
            {
                half2 CirclePosition;
                half CircleRadius;
                half4 CircleColor;
                
            };

            StructuredBuffer<circles> _Circles;


            v2f vert(appdata v)
            {
                v2f o;
                o.pos = TransformObjectToHClip(v.vertex);
                o.uv = v.uv;
                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                // 텍스처의 기본 배경색
                half4 bgColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);

                // 원 중심을 기준으로 좌표 변환 (행렬 연산)
                half2 centeredUV = i.uv - _CircleCenter;

                // 중심에서 반지름을 기준으로 거리를 계산하여 원 형태를 생성
                //half dist = length(centeredUV);

                // smoothstep을 사용해 가장자리를 부드럽게 만듦
                //half edge = smoothstep(_CircleRadius, _CircleRadius - 0.001, dist);

                // 원 모양을 나타내기 위해 배경과 원의 색상을 혼합
                //bgColor = lerp(bgColor, _CircleColor, edge);

                
                for (int j = 0; j < _CircleCount; j++) {
                    circles cir = _Circles[j];

                    half2 centeredUV2 = i.uv - cir.CirclePosition;
                    half dist2 = length(centeredUV2);
                    half edge2 = smoothstep(cir.CircleRadius, cir.CircleRadius - 0.001, dist2);

                    bgColor = lerp(bgColor, cir.CircleColor, edge2);

                }

                return bgColor;
            }
            ENDHLSL
        }
    }
    FallBack "Diffuse"
}