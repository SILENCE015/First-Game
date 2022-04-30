Shader "Shader/Leafs"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1)
        _NoiseTex ("噪声", 2D) = "gray" {}
        _WindSpeed ("流动速度", Range(0, 1)) = 1
        _WindStrength ("风强", Range(0, 1)) = 1
        _WindDirection ("风向", vector) = (0.0, 0.0, 0.0)
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }

        Pass
        {
            Tags { "LightMode"="Forwardbase" }
            Cull off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma target 3.0

            float3 _Color;
            sampler2D _NoiseTex;
            half _WindSpeed;
            half _WindStrength;
            float2 _WindDirection;

            struct VertexInput
            {
                float4 vertex : POSITION;
                float2 uv0 : TEXCOORD0;
                float2 uv1 : TEXCOORD1; 
                float4 normal : NORMAL;
            };

            struct VertexOutput
            {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float3 nDirWS : TEXCOORD1;
                SHADOW_COORDS(2)
            };

            #define TWO_PI 6.283185
            // 动画方法
            void WindAnim(float2 noise, inout float4 vertex) {
                float swingX = sin(frac(_Time.z * _WindSpeed) * TWO_PI + vertex.x * _WindStrength * TWO_PI) * lerp(0,1,noise.x) * 2;
                float swingZ = sin(frac(_Time.z * _WindSpeed) * TWO_PI + vertex.x * _WindStrength * TWO_PI) * lerp(0,1,noise.y) * 2;
                vertex.xz += normalize(_WindDirection.xy) * float2(swingX, swingZ) * 0.03;
            }
            VertexOutput vert (VertexInput v)
            {
                VertexOutput o;
                float2 noise = tex2Dlod(_NoiseTex, float4(v.uv0, 1.0, 1.0)).rg;
                WindAnim(noise, v.vertex);
                o.uv0 = v.uv0;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.nDirWS = UnityObjectToWorldNormal(v.normal);
                TRANSFER_SHADOW(o)
                return o;
            }

            half4 frag (VertexOutput i) : SV_Target
            {
                float3 nDir = i.nDirWS;
                float3 lDir = _WorldSpaceLightPos0.xyz;
                float3 vDir = normalize(_WorldSpaceCameraPos.xyz - i.pos.xyz);
                float3 rDir = reflect(-lDir, nDir);
                float nDotl = dot(nDir, lDir) * 0.5 + 0.5;
                float vDotr = dot(vDir, rDir);

                float lambert = max(0.0, nDotl);

                float shadow = SHADOW_ATTENUATION(i);

                half3 finalRGB = _Color * lambert * shadow;
                return half4(finalRGB, 1.0);
            }
            ENDCG
        }
    }
    Fallback "Diffuse"
}