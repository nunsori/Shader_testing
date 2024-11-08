Shader "CustomRenderTexture/NewImageEffectShader"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _Resolution("Resolution", Vector) = (1, 1, 1)
        //_Time("Time", Float) = 0
        _WaterLevel("Water Level", Float) = 70.0
        _WaveGain("Wave Gain", Float) = 1.0
        _LargeWaveHeight("Large Wave Height", Float) = 1.0
        _SmallWaveHeight("Small Wave Height", Float) = 1.0
        _FogColor("Fog Color", Color) = (0.5, 0.7, 1.1, 1.0)
        _SkyBottom("Sky Bottom Color", Color) = (0.6, 0.8, 1.2, 1.0)
        _SkyTop("Sky Top Color", Color) = (0.05, 0.2, 0.5, 1.0)
        _LightDirection("Light Direction", Vector) = (0.1, 0.25, 0.9)
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" "LightMode" = "Universal2D" }
        LOD 100

        Pass
        {
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            // Unity includes
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            //#include "UnityCG.cginc"
            //#include "UnityShaderVariables.cginc"
            //#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            //sampler2D _MainTex;
            float3 _Resolution;
            float _WaterLevel;
            float _WaveGain;
            float _LargeWaveHeight;
            float _SmallWaveHeight;
            float4 _FogColor;
            float4 _SkyBottom;
            float4 _SkyTop;
            float3 _LightDirection;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = mul(UNITY_MATRIX_MVP, v.vertex); // UnityObjectToClipPos ¥Î√º
                o.uv = v.uv;
                return o;
            }

            // Noise functions for HLSL
            float hash(float n) { return frac(cos(n) * 41415.92653); }

            float noise(float2 p)
            {
                return SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, p * 1.0 / 256.0).r;
            }

            // 3D noise function
            float noise3D(float3 x)
            {
                float3 p = floor(x);
                float3 f = smoothstep(0.0, 1.0, frac(x));
                float n = p.x + p.y * 57.0 + 113.0 * p.z;
                return lerp(
                    lerp(lerp(hash(n + 0.0), hash(n + 1.0), f.x),
                         lerp(hash(n + 57.0), hash(n + 58.0), f.x), f.y),
                    lerp(lerp(hash(n + 113.0), hash(n + 114.0), f.x),
                         lerp(hash(n + 170.0), hash(n + 171.0), f.x), f.y), f.z);
            }

            float fbm(float3 p)
            {
                float f = 0.5 * noise3D(p);
                p *= 1.5;
                f += 0.25 * noise3D(p);
                p *= 1.5;
                f += 0.125 * noise3D(p);
                return f;
            }

            float water(float2 p)
            {
                float height = _WaterLevel;
                ///float2 shift1 = float2(_Time * 160.0, _Time * 120.0) * 0.001;
                //
                float2 shift1 = float2(_Time.x * 160.0, _Time.y * 120.0) * float2(0.001, 0.001);
                float2 shift2 = float2(_Time.x * 190.0, -_Time.y * 130.0) * float2(0.001, 0.001);

                float wave = 0.0;
                wave += sin(p.x * 0.021 + shift2.x) * 4.5;
                wave += sin(p.x * 0.0172 + p.y * 0.010 + shift2.x * 1.121) * 4.0;
                wave *= _LargeWaveHeight;
                wave -= fbm(float3(p * 0.004 - shift2 * 0.5, 0.0)) * _SmallWaveHeight * 24.0;

                return height + wave;
            }

            float3 camera(float time)
            {
                return float3(500.0 * sin(1.5 + 1.57 * time), 0.0, 1200.0 * time);
            }

            float4 frag(v2f i) : SV_Target
            {
                float2 uv = i.uv * _Resolution.xy;
                float time = (_Time + 13.5 + 44.0) * 0.05;

                float3 campos = camera(time);
                float3 camtar = camera(time + 0.4);
                campos.y = max(_WaterLevel + 30.0, _WaterLevel + 90.0 + 60.0 * sin(time * 2.0));
                camtar.y = campos.y * 0.5;

                float3 cw = normalize(camtar - campos);
                float3 cu = normalize(cross(cw, float3(0.0, 1.0, 0.0)));
                float3 cv = normalize(cross(cu, cw));

                float2 s = uv * float2(1.75, 1.0) - 1.0;
                float3 rd = normalize(s.x * cu + s.y * cv + 1.6 * cw);

                float3 col = lerp(_SkyBottom.rgb, _SkyTop.rgb, rd.y);
                float sundot = saturate(dot(rd, normalize(_LightDirection)));

                col += _FogColor.rgb * sundot;

                return float4(col, 1.0);
            }
            ENDHLSL
        }
    }
    FallBack "Diffuse"
}
