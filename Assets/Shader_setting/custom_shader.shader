Shader "CustomRenderTexture/custom_shader"
{
    Properties
    {
        _Color("Color", Color) = (1,1,1,1)
        _MainTex("InputTex", 2D) = "white" {}
        _TargetColor ("Target Color", Color) = (1,0,0,1)   // 변경하고 싶은 색상
        _ReplaceColor ("Replace Color", Color) = (0,1,0,1) // 새로운 색상
        _Tolerance ("Color Tolerance", Range(0,1)) = 0.1   // 색상 허용 오차
        _TouchPosition ("Touch Position", Vector) = (0.5, 0.5, 0, 0) // 터치 위치
        _SpreadRadius ("Spread Radius", Float) = 0.0       // 색이 퍼지는 반경

        _CircleColor("Circle Color", Color) = (1, 0, 0, 1) // 원의 색상 (기본값은 빨간색)
        _CircleRadius("Circle Radius", Range(0, 1)) = 0.25 // 원의 반지름
        _CircleCenter("Circle Center", Vector) = (0.5, 0.5, 0, 0) // 원의 중심

        _CircleColor2("Second Circle Color", Color) = (0, 0, 1, 1) // 두 번째 원 색상 (파란색)
        _CircleRadius2("Second Circle Radius", Range(0, 1)) = 0.25 // 두 번째 원 반지름
        _CircleCenter2("Second Circle Center", Vector) = (0.7, 0.5, 0, 0) // 두 번째 원 중심

        _CircleCount("Circle Count", Range(0,30)) = 10 // 원의 개수
    }
        
     //}

     SubShader
     {
        Blend SrcAlpha OneMinusSrcAlpha
        Tags {"RenderType"="Opaque"}
        LOD 200

        Pass
        {
            Name "custom_shader"

            Tags { "LightMode" = "Universal2D" }

            HLSLPROGRAM
            //CGPROGRAM
            //#include "UnityCustomRenderTexture.cginc"
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/2D/Include/Core2D.hlsl"

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            float4 _TargetColor;
            float _TransitionRadius;
            float2 _TransitionCenter;

            half4 _CircleColor;
            half _CircleRadius;
            half2 _CircleCenter;

            half4 _CircleColor2;
            half _CircleRadius2;
            half2 _CircleCenter2;

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
                half4 CirclePosition;
                half CircleRadius;
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
                /*
                // 텍스처에서 픽셀 색상 가져오기
                half4 texColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);

                // 중심점으로부터 거리 계산
                float dist = distance(i.uv, _TransitionCenter);

                // 거리를 바탕으로 색상 보간
                float t = smoothstep(_TransitionRadius - 0.1, _TransitionRadius + 0.1, dist);
                half4 outputColor = lerp(_TargetColor, texColor, t);
                

                // 텍스처의 알파 값을 유지
                outputColor.a = texColor.a;
                


                return outputColor;*/
                
                
                // 텍스처의 기본 배경색
                half4 bgColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);

                // 원 중심을 기준으로 좌표 변환 (행렬 연산)
                half2 centeredUV = i.uv - _CircleCenter;

                // 중심에서 반지름을 기준으로 거리를 계산하여 원 형태를 생성
                half dist = length(centeredUV);

                // smoothstep을 사용해 가장자리를 부드럽게 만듦
                half edge = smoothstep(_CircleRadius, _CircleRadius - 0.001, dist);

                // 원 모양을 나타내기 위해 배경과 원의 색상을 혼합
                //bgColor = lerp(_CircleColor, bgColor, edge);
                bgColor = lerp(bgColor, _CircleColor, edge);


                half2 centeredUV2 = i.uv - _CircleCenter2;
                half dist2 = length(centeredUV2);
                half edge2 = smoothstep(_CircleRadius2, _CircleRadius2 - 0.001, dist2);

                bgColor = lerp(bgColor, _CircleColor2, edge2);

                return bgColor;
            }
            ENDHLSL
        }
    }
    FallBack "Diffuse"
}
