Shader "CustomRenderTexture/customdaynight"
{
    Properties
    {
        _BaseColor("Base Color", Color) = (1,1,1,1)
        _MainTex("Texture", 2D) = "white" {}
        _LightColorDay("Day Light Color", Color) = (1, 0.5, 0.5, 1) // ������
        _LightColorNight("Night Light Color", Color) = (0.5, 0.5, 1, 1) // �Ķ���
        _LightDirection("Light Direction", Vector) = (0, -1, 0)
        _LightCenter("Light Center", Vector) = (0.5, 0.5, 0) // ���� �߽�
        _LightRadius("Light Radius", Float) = 0.5 // ���� �ݰ�
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
                // �⺻ ��� ����� �ؽ�ó ���ø�
                float4 baseColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv) * _BaseColor;

                // _LightMode�� ���� ���� ���� ����
                float4 lightColor = (_LightMode < 0.5) ? _LightColorDay : _LightColorNight;

                // �� �߽ɰ� ���� �ȼ��� �Ÿ� ���
                float2 lightCenterUV = _LightCenter.xy; // ���� �߽� ��ǥ (UV ��������)
                float dist = distance(i.uv, lightCenterUV);

                /*
                // ���� ������ �ݰ濡 ���� ����
                float lightFalloff = smoothstep( 0.0, _LightRadius, dist); // �ݰ��� ������� �ε巴�� ��ο���
                

                // �Ÿ� ����� �� ������ ���⼺ �� ������ ����
                float3 lightDir = normalize(_LightDirection);
                float3 normal = float3(0, 0, -1);
                float directionalLightAmount = max(dot(normal, lightDir), 0.0) * _LightIntensity;

                // ���� �� ����
                float lightAmount = (1.0 - lightFalloff) * directionalLightAmount;

                // ���� ȿ���� ����� ���� ���� ���
                float4 finalColor = baseColor * (lightAmount * lightColor);
                finalColor.a = baseColor.a; // ���� ����
                */

                // ����þ� ���踦 ������ �� ȿ��
                float lightFalloff = exp(-pow(dist / _LightRadius, 2.0)); // ����þ� ����

                // ���� ������ ���踦 �ݿ��� ���� �� ȿ��
                float4 finalLightEffect = lightColor * lightFalloff * _LightIntensity;

                // ���� ���� ���
                float4 finalColor = baseColor * finalLightEffect;
                finalColor.a = baseColor.a; // ���� ����

                return finalColor;
            }
            ENDHLSL
        }
    }
}
